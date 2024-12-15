import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final TodosRepository _todosRepository;
  StreamSubscription<List<Tag>>? _tagsSubscription;

  ExploreBloc({
    required TodosRepository todosRepository,
    required Tag? initialTag,
  })  : _todosRepository = todosRepository,
        super(ExploreState(
          initialTag: initialTag,
          title: initialTag?.title ?? "",
          color: initialTag?.color ?? "#FFFFFFFF",
        )) {
    on<TagsSubscriptionRequested>(_onTagsSubscriptionRequested);
    on<TagDeleted>(_onTagDeleted);
    on<TagAdded>(_onTagAdded);
    on<TagEdited>(_onTagEditted);
    on<AddTagName>(_onNameTagAdded);
    on<AddTagSubmitted>(_onSubmitted);
    on<AddTagColor>(_onColorTagAdded);
  }

  Future<void> _onTagsSubscriptionRequested(
    TagsSubscriptionRequested event,
    Emitter<ExploreState> emit,
  ) async {
    emit(state.copyWith(status: ExploreStatus.loading));

    await emit.forEach<List<Tag>>(
      _todosRepository.getTags(),
      onData: (tagsList) => state.copyWith(
        status: ExploreStatus.success,
        tags: tagsList.toSet(),
      ),
      onError: (_, __) => state.copyWith(status: ExploreStatus.failure),
    );
  }

  Future<void> _onTagDeleted(
    TagDeleted event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      await _todosRepository.deleteTag(event.tagId);
    } catch (e) {
      emit(state.copyWith(status: ExploreStatus.failure));
    }
  }

  Future<void> _onTagAdded(
    TagAdded event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      await _todosRepository.saveTag(event.addedTag);
    } catch (e) {
      emit(state.copyWith(status: ExploreStatus.failure));
    }
  }

  Future<void> _onTagEditted(
    TagEdited event,
    Emitter<ExploreState> emit,
  ) async {
    try {} catch (e) {
      emit(state.copyWith(status: ExploreStatus.failure));
    }
  }

  Future<void> _onNameTagAdded(
    AddTagName event,
    Emitter<ExploreState> emit,
  ) async {
    emit(state.copyWith(title: event.tagName));
  }

  Future<void> _onSubmitted(
    AddTagSubmitted event,
    Emitter<ExploreState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ExploreStatus.loading));

      if (state.initialTag != null) {
        final updatedTag = state.initialTag!.copyWith(
          title: state.title,
          color: state.color,
        );
        await _todosRepository.saveTag(updatedTag);
      } else {
        final newTag = Tag(
          title: state.title,
          color: state.color,
        );
        await _todosRepository.saveTag(newTag);
      }

      emit(state.copyWith(
        status: ExploreStatus.success,
        title: "",
        color: "#FFFFFFFF",
        initialTag: null,
      ));
    } catch (e) {
      emit(state.copyWith(status: ExploreStatus.failure));
    }
  }

  Future<void> _onColorTagAdded(
    AddTagColor event,
    Emitter<ExploreState> emit,
  ) async {
    emit(state.copyWith(color: event.tagColor));
  }

  @override
  Future<void> close() {
    _tagsSubscription?.cancel();
    return super.close();
  }
}
