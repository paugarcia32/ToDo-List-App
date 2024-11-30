import 'package:todos_api/todos_api.dart';

abstract class TodosApi {
  const TodosApi();

  Stream<List<Todo>> getTodos();

  Future<void> saveTodo(Todo todo);

  Future<void> deleteTodo(String id);

  Future<int> clearCompleted();

  Future<int> completeAll({required bool isCompleted});

  Future<void> close();

  Stream<List<Tag>> getTags();

  Future<void> saveTag(Tag tag);

  Future<void> deleteTag(String id);

  Future<List<Todo>> getTodosByTag(String tagId);
}

class TodoNotFoundException implements Exception {}

class TagNotFoundException implements Exception {}
