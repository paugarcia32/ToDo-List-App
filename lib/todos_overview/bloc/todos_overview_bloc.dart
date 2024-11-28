import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

part 'todos_overview_event.dart';
part 'todos_overview_state.dart';

class TodosOverviewBloc extends Bloc<TodosOverviewEvent, TodosOverviewState> {
  TodosOverviewBloc({
    required TodosRepository todosRepository,
  })  : _todosRepository = todosRepository,
        super(const TodosOverviewState()) {
    on<TodosOverviewSubscriptionRequested>(_onSubscriptionRequested);
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

  Future<void> _onSubscriptionRequested(
    TodosOverviewSubscriptionRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    emit(state.copyWith(
      todosStatus: () => TodosOverviewStatus.loading,
      tagsStatus: () => TodosOverviewStatus.loading,
    ));

    add(const TodosOverviewTodosSubscriptionRequested());
    add(const TodosOverviewTagsSubscriptionRequested());
  }

  Future<void> _onTodosSubscriptionRequested(
    TodosOverviewTodosSubscriptionRequested event,
    Emitter<TodosOverviewState> emit,
  ) async {
    try {
      await emit.forEach<List<Todo>>(
        _todosRepository.getTodos(),
        onData: (todos) => state.copyWith(
          todosStatus: () => TodosOverviewStatus.success,
          todos: () => todos,
        ),
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
    try {
      await emit.forEach<List<Tag>>(
        _todosRepository.getTags(),
        onData: (tags) => state.copyWith(
          tagsStatus: () => TodosOverviewStatus.success,
          tags: tags,
        ),
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
    emit(state.copyWith(filter: () => event.filter));
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
