part of 'todos_overview_bloc.dart';

enum TodosOverviewStatus { initial, loading, success, failure }

class TodosOverviewState extends Equatable {
  const TodosOverviewState({
    this.todosStatus = TodosOverviewStatus.initial,
    this.tagsStatus = TodosOverviewStatus.initial,
    this.todos = const [],
    this.tags = const [],
    this.filter = TodosViewFilter.all,
    this.lastDeletedTodo,
    this.todosWithTags = const [],
  });

  final TodosOverviewStatus todosStatus;
  final TodosOverviewStatus tagsStatus;
  final List<Todo> todos;
  final List<Tag> tags;
  final TodosViewFilter filter;
  final Todo? lastDeletedTodo;
  final List<TodoWithTags> todosWithTags;

  TodosOverviewState copyWith({
    TodosOverviewStatus Function()? todosStatus,
    TodosOverviewStatus Function()? tagsStatus,
    List<Todo> Function()? todos,
    List<Tag>? tags,
    TodosViewFilter Function()? filter,
    Todo? Function()? lastDeletedTodo,
    List<TodoWithTags>? todosWithTags,
  }) {
    return TodosOverviewState(
      todosStatus: todosStatus != null ? todosStatus() : this.todosStatus,
      tagsStatus: tagsStatus != null ? tagsStatus() : this.tagsStatus,
      todos: todos != null ? todos() : this.todos,
      tags: tags ?? this.tags,
      filter: filter != null ? filter() : this.filter,
      lastDeletedTodo: lastDeletedTodo != null ? lastDeletedTodo() : this.lastDeletedTodo,
      todosWithTags: todosWithTags ?? this.todosWithTags,
    );
  }

  @override
  List<Object?> get props => [
        todosStatus,
        tagsStatus,
        todos,
        tags,
        filter,
        lastDeletedTodo,
        todosWithTags,
      ];
}
