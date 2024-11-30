part of 'edit_todo_bloc.dart';

enum EditTodoStatus { initial, loading, success, failure }

extension EditTodoStatusX on EditTodoStatus {
  bool get isLoadingOrSuccess => [
        EditTodoStatus.loading,
        EditTodoStatus.success,
      ].contains(this);
}

final class EditTodoState extends Equatable {
  const EditTodoState({
    this.status = EditTodoStatus.initial,
    this.initialTodo,
    this.title = '',
    this.description = '',
    this.selectedTags = const {},
  });

  final EditTodoStatus status;
  final Todo? initialTodo;
  final String title;
  final String description;
  final Set<Tag> selectedTags;

  bool get isNewTodo => initialTodo == null;

  EditTodoState copyWith({
    EditTodoStatus? status,
    Todo? initialTodo,
    String? title,
    String? description,
    Set<Tag>? selectedTags,
  }) {
    return EditTodoState(
      status: status ?? this.status,
      initialTodo: initialTodo ?? this.initialTodo,
      title: title ?? this.title,
      description: description ?? this.description,
      selectedTags: selectedTags ?? this.selectedTags,
    );
  }

  Iterable<Tag> get tags => selectedTags;

  @override
  List<Object?> get props => [status, initialTodo, title, description, selectedTags];
}
