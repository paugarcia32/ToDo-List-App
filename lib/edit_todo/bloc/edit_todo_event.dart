part of 'edit_todo_bloc.dart';

sealed class EditTodoEvent extends Equatable {
  const EditTodoEvent();

  @override
  List<Object> get props => [];
}

final class EditTodoTitleChanged extends EditTodoEvent {
  const EditTodoTitleChanged(this.title);

  final String title;

  @override
  List<Object> get props => [title];
}

final class EditTodoDescriptionChanged extends EditTodoEvent {
  const EditTodoDescriptionChanged(this.description);

  final String description;

  @override
  List<Object> get props => [description];
}

final class EditTodoTagsChanged extends EditTodoEvent {
  const EditTodoTagsChanged(this.tags);

  final List<String>? tags;

  @override
  List<Object> get props => [tags ?? []];
}

final class EditTodoSubmitted extends EditTodoEvent {
  const EditTodoSubmitted();
}
