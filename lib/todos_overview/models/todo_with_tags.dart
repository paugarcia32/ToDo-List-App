import 'package:equatable/equatable.dart';
import 'package:todos_api/todos_api.dart';

class TodoWithTags extends Equatable {
  const TodoWithTags({
    required this.todo,
    required this.tagTitles,
  });

  final Todo todo;
  final List<String> tagTitles;

  @override
  List<Object?> get props => [todo, tagTitles];
}
