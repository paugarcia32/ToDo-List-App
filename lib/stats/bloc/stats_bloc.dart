import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const StatsState()) {
    on<TodosSubscriptionRequested>(_onTodosSubscriptionRequested);
    on<TagsSubscriptionRequested>(_onTagsSubscriptionRequested);
  }

  final TodosRepository _todosRepository;

  Future<void> _onTodosSubscriptionRequested(
    TodosSubscriptionRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatsStatus.loading));
    try {
      await emit.forEach<List<Todo>>(
        _todosRepository.getTodos(),
        onData: (todos) => state.copyWith(
          completedTodos: todos.where((todo) => todo.isCompleted).length,
          activeTodos: todos.where((todo) => !todo.isCompleted).length,
        ),
        onError: (error, stackTrace) {
          print('Error al escuchar todos: $error');
          return state.copyWith(status: StatsStatus.failure);
        },
      );
    } catch (error) {
      print('Error general en _onTodosSubscriptionRequested: $error');
      emit(state.copyWith(status: StatsStatus.failure));
    }
  }

  Future<void> _onTagsSubscriptionRequested(
    TagsSubscriptionRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(state.copyWith(status: StatsStatus.loading));
    try {
      await emit.forEach<List<Tag>>(
        _todosRepository.getTags(),
        onData: (tags) {
          final uniqueTagIds = tags.map((tag) => tag.id).toSet();
          return state.copyWith(
            totalTags: uniqueTagIds.length,
            status: StatsStatus.success,
          );
        },
        onError: (error, stackTrace) {
          print('Error al escuchar tags: $error');
          return state.copyWith(status: StatsStatus.failure);
        },
      );
    } catch (error) {
      print('Error general en _onTagsSubscriptionRequested: $error');
      emit(state.copyWith(status: StatsStatus.failure));
    }
  }
}
