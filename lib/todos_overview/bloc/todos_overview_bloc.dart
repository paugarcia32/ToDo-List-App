import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';
import '../models/models.dart';

part 'todos_overview_event.dart';
part 'todos_overview_state.dart';

class TodosOverviewBloc extends Bloc<TodosOverviewEvent, TodosOverviewState> {
  TodosOverviewBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const TodosOverviewState()) {
    on<TodosOverviewTodosSubscriptionRequested>(_onTodosSubscriptionRequested);
    on<TodosOverviewTagsSubscriptionRequested>(_onTagsSubscriptionRequested);
    on<TodosOverviewTodoCompletionToggled>(_onTodoCompletionToggled);
    on<TodosOverviewTodoDeleted>(_onTodoDeleted);
    on<TodosOverviewUndoDeletionRequested>(_onUndoDeletionRequested);
    on<TodosOverviewFilterChanged>(_onFilterChanged);
    on<TodosOverviewToggleAllRequested>(_onToggleAllRequested);
    on<TodosOverviewClearCompletedRequested>(_onClearCompletedRequested);
  }

  final TodosRepository _todosRepository;

  Future<void> _onTodosSubscriptionRequested(
    TodosOverviewTodosSubscriptionRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    emit(state.copyWith(todosStatus: () => TodosOverviewStatus.loading));

    try {
      await emit.forEach<List<Todo>>(
        _todosRepository.getTodos(),
        onData: (todos) {
          final newState = state.copyWith(
            todosStatus: () => TodosOverviewStatus.success,
            todos: () => todos,
          );
          return _updateFilteredTodosWithTags(newState);
        },
        onError: (_, __) => state.copyWith(
          todosStatus: () => TodosOverviewStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(
        todosStatus: () => TodosOverviewStatus.failure,
      ));
    }
  }

  Future<void> _onTagsSubscriptionRequested(
    TodosOverviewTagsSubscriptionRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    emit(state.copyWith(tagsStatus: () => TodosOverviewStatus.loading));

    try {
      await emit.forEach<List<Tag>>(
        _todosRepository.getTags(),
        onData: (tags) {
          final newState = state.copyWith(
            tagsStatus: () => TodosOverviewStatus.success,
            tags: tags,
          );
          return _updateFilteredTodosWithTags(newState);
        },
        onError: (_, __) => state.copyWith(
          tagsStatus: () => TodosOverviewStatus.failure,
        ),
      );
    } catch (_) {
      emit(state.copyWith(
        tagsStatus: () => TodosOverviewStatus.failure,
      ));
    }
  }

  TodosOverviewState _updateFilteredTodosWithTags(TodosOverviewState currentState) {
    final Map<String, String> tagMap = {
      for (var tag in currentState.tags) tag.id: tag.title,
    };

    final filteredTodos = currentState.filter.applyAll(currentState.todos);

    final todosWithTags = filteredTodos.map((todo) {
      final tagTitles = todo.tagIds.map((id) => tagMap[id] ?? 'Desconocido').toList();
      return TodoWithTags(todo: todo, tagTitles: tagTitles);
    }).toList();

    return currentState.copyWith(todosWithTags: todosWithTags);
  }

  Future<void> _onTodoCompletionToggled(
    TodosOverviewTodoCompletionToggled event,
    Emitter<TodosOverviewState> emit,
  ) async {
    final newTodo = event.todo.copyWith(isCompleted: event.isCompleted);
    await _todosRepository.saveTodo(newTodo);
  }

  Future<void> _onTodoDeleted(
    TodosOverviewTodoDeleted event,
    Emitter<TodosOverviewState> emit,
  ) async {
    emit(state.copyWith(lastDeletedTodo: () => event.todo));
    await _todosRepository.deleteTodo(event.todo.id);
  }

  Future<void> _onUndoDeletionRequested(
    TodosOverviewUndoDeletionRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    assert(
      state.lastDeletedTodo != null,
      'Last deleted todo cannot be null.',
    );

    final todo = state.lastDeletedTodo!;
    emit(state.copyWith(lastDeletedTodo: () => null));
    await _todosRepository.saveTodo(todo);
  }

  void _onFilterChanged(
    TodosOverviewFilterChanged event,
    Emitter<TodosOverviewState> emit,
  ) {
    final newState = state.copyWith(filter: () => event.filter);
    emit(_updateFilteredTodosWithTags(newState));
  }

  Future<void> _onToggleAllRequested(
    TodosOverviewToggleAllRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    final areAllCompleted = state.todos.every((todo) => todo.isCompleted);
    await _todosRepository.completeAll(isCompleted: !areAllCompleted);
  }

  Future<void> _onClearCompletedRequested(
    TodosOverviewClearCompletedRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    await _todosRepository.clearCompleted();
  }
}
