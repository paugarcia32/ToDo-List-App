// lib/todos_overview/bloc/tags_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

part 'tags_event.dart';
part 'tags_state.dart';

class TagsBloc extends Bloc<TagsEvent, TagsState> {
  TagsBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const TagsState()) {
    on<TagsSubscriptionRequested>(_onSubscriptionRequested);
  }

  final TodosRepository _todosRepository;

  Future<void> _onSubscriptionRequested(
    TagsSubscriptionRequested event,
    Emitter<TagsState> emit,
  ) async {
    emit(state.copyWith(status: TagsStatus.loading));

    try {
      await emit.forEach<List<Tag>>(
        _todosRepository.getTags(),
        onData: (tags) {
          final tagIdToTitleMap = {for (var tag in tags) tag.id: tag.title};
          return state.copyWith(
            status: TagsStatus.success,
            tags: tags,
            tagIdToTitleMap: tagIdToTitleMap,
          );
        },
        onError: (_, __) => state.copyWith(
          status: TagsStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(
        status: TagsStatus.failure,
      ));
    }
  }
}
