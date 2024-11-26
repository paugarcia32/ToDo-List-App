import 'package:todos_api/todos_api.dart';

class TodosRepository {
  const TodosRepository({
    required TodosApi todosApi,
  }) : _todosApi = todosApi;

  final TodosApi _todosApi;

  Stream<List<Todo>> getTodos() => _todosApi.getTodos();

  Future<void> saveTodo(Todo todo) => _todosApi.saveTodo(todo);

  Future<void> deleteTodo(String id) => _todosApi.deleteTodo(id);

  Future<int> clearCompleted() => _todosApi.clearCompleted();

  Future<int> completeAll({required bool isCompleted}) => _todosApi.completeAll(isCompleted: isCompleted);

  Stream<List<Tag>> getTags() => _todosApi.getTags();

  Future<void> saveTag(Tag tag) => _todosApi.saveTag(tag);

  Future<void> deleteTag(String id) => _todosApi.deleteTag(id);

  Future<List<Todo>> getTodosByTag(String tagId) => _todosApi.getTodosByTag(tagId);
}
