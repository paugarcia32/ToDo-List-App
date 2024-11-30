import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

part 'explore_event.dart';
part 'explore_state.dart';

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final TodosRepository todosRepository;
  StreamSubscription<List<Tag>>? _tagsSubscription;

  ExploreBloc({required this.todosRepository}) : super(const ExploreState()) {
    on<TagsSubscriptionRequested>(_onTagsSubscriptionRequested);
    on<TagDeleted>(_onTagDeleted);
  }

  Future<void> _onTagsSubscriptionRequested(
    TagsSubscriptionRequested event,
    Emitter<ExploreState> emit,
  ) async {
    emit(state.copyWith(status: ExploreStatus.loading));

    emit.forEach<List<Tag>>(
      todosRepository.getTags(),
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
      await todosRepository.deleteTag(event.tagId);
    } catch (e) {
      emit(state.copyWith(status: ExploreStatus.failure));
    }
  }

  @override
  Future<void> close() {
    _tagsSubscription?.cancel();
    return super.close();
  }
}
