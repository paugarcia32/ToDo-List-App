import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todos_api/todos_api.dart';

class LocalStorageTodosApi extends TodosApi {
  LocalStorageTodosApi({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _init();
  }

  final SharedPreferences _plugin;

  late final _todoStreamController = BehaviorSubject<List<Todo>>.seeded(
    const [],
  );

  late final _tagStreamController = BehaviorSubject<List<Tag>>.seeded(const []);

  @visibleForTesting
  static const kTodosCollectionKey = '__todos_collection_key__';

  @visibleForTesting
  static const kTagsCollectionKey = '__tags_collection_key__';

  String? _getValue(String key) => _plugin.getString(key);
  Future<void> _setValue(String key, String value) => _plugin.setString(key, value);

  void _init() {
    final todosJson = _getValue(kTodosCollectionKey);
    if (todosJson != null) {
      final todos = List<Map<dynamic, dynamic>>.from(
        json.decode(todosJson) as List,
      ).map((jsonMap) => Todo.fromJson(Map<String, dynamic>.from(jsonMap))).toList();
      _todoStreamController.add(todos);
    } else {
      _todoStreamController.add(const []);
    }

    final tagsJson = _getValue(kTagsCollectionKey);
    if (tagsJson != null) {
      final tags = List<Map<dynamic, dynamic>>.from(
        json.decode(tagsJson) as List,
      ).map((jsonMap) => Tag.fromJson(Map<String, dynamic>.from(jsonMap))).toList();
      _tagStreamController.add(tags);
    } else {
      _tagStreamController.add(const []);
    }
  }

  @override
  Stream<List<Todo>> getTodos() => _todoStreamController.asBroadcastStream();

  @override
  Future<void> saveTodo(Todo todo) {
    final todos = [..._todoStreamController.value];
    final todoIndex = todos.indexWhere((t) => t.id == todo.id);
    if (todoIndex >= 0) {
      todos[todoIndex] = todo;
    } else {
      todos.add(todo);
    }

    _todoStreamController.add(todos);
    return _setValue(kTodosCollectionKey, json.encode(todos));
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = [..._todoStreamController.value];
    final todoIndex = todos.indexWhere((t) => t.id == id);
    if (todoIndex == -1) {
      throw TodoNotFoundException();
    } else {
      todos.removeAt(todoIndex);
      _todoStreamController.add(todos);
      return _setValue(kTodosCollectionKey, json.encode(todos));
    }
  }

  @override
  Future<int> clearCompleted() async {
    final todos = [..._todoStreamController.value];
    final completedTodosAmount = todos.where((t) => t.isCompleted).length;
    todos.removeWhere((t) => t.isCompleted);
    _todoStreamController.add(todos);
    await _setValue(kTodosCollectionKey, json.encode(todos));
    return completedTodosAmount;
  }

  @override
  Future<int> completeAll({required bool isCompleted}) async {
    final todos = [..._todoStreamController.value];
    final changedTodosAmount = todos.where((t) => t.isCompleted != isCompleted).length;
    final newTodos = [
      for (final todo in todos) todo.copyWith(isCompleted: isCompleted),
    ];
    _todoStreamController.add(newTodos);
    await _setValue(kTodosCollectionKey, json.encode(newTodos));
    return changedTodosAmount;
  }

  @override
  Future<void> deleteTag(String id) async {
    final tags = [..._tagStreamController.value];
    final tagIndex = tags.indexWhere((t) => t.id == id);

    if (tagIndex == -1) {
      throw TagNotFoundException();
    } else {
      tags.removeAt(tagIndex);
      _tagStreamController.add(tags);
      await _setValue(kTagsCollectionKey, json.encode(tags));
    }
  }

  @override
  Stream<List<Tag>> getTags() {
    final tags = _tagStreamController.value;
    print('Tags emitidos desde el repositorio: ${tags.map((tag) => tag.title).toList()}');
    return _tagStreamController.asBroadcastStream();
  }

  @override
  Future<List<Todo>> getTodosByTag(String tagId) async {
    final todos = [..._todoStreamController.value];
    return todos.where((todo) => todo.tagIds.contains(tagId)).toList();
  }

  @override
  Future<void> saveTag(Tag tag) async {
    final tags = [..._tagStreamController.value];
    final tagIndex = tags.indexWhere((t) => t.id == tag.id);

    if (tagIndex >= 0) {
      tags[tagIndex] = tag;
    } else {
      tags.add(tag);
    }

    _tagStreamController.add(tags);
    await _setValue(kTagsCollectionKey, json.encode(tags));
  }

  @override
  Future<void> close() async {
    await _todoStreamController.close();
    await _tagStreamController.close();
  }
}
