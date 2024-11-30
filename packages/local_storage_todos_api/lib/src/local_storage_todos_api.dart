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
      _tagStreamController.add([]);
    }
  }

  @override
  Stream<List<Todo>> getTodos() => _todoStreamController.asBroadcastStream();

  @override
  Future<void> saveTodo(Todo todo) async {
    final todos = [..._todoStreamController.value];
    final todoIndex = todos.indexWhere((t) => t.id == todo.id);

    Set<String> oldTagIds = {};

    if (todoIndex >= 0) {
      final oldTodo = todos[todoIndex];
      oldTagIds = oldTodo.tagIds;
      todos[todoIndex] = todo;
    } else {
      oldTagIds = {};
      todos.add(todo);
    }

    final newTagIds = todo.tagIds;

    final addedTagIds = newTagIds.difference(oldTagIds);
    final removedTagIds = oldTagIds.difference(newTagIds);

    final tags = [..._tagStreamController.value];

    for (final tagId in addedTagIds) {
      final tagIndex = tags.indexWhere((t) => t.id == tagId);
      if (tagIndex >= 0) {
        final tag = tags[tagIndex];
        final updatedTodoIds = Set<String>.from(tag.todoIds)..add(todo.id);
        tags[tagIndex] = tag.copyWith(todoIds: updatedTodoIds);
      }
    }

    for (final tagId in removedTagIds) {
      final tagIndex = tags.indexWhere((t) => t.id == tagId);
      if (tagIndex >= 0) {
        final tag = tags[tagIndex];
        final updatedTodoIds = Set<String>.from(tag.todoIds)..remove(todo.id);
        tags[tagIndex] = tag.copyWith(todoIds: updatedTodoIds);
      }
    }

    _tagStreamController.add(tags);
    await _setValue(kTagsCollectionKey, json.encode(tags));

    _todoStreamController.add(todos);
    await _setValue(kTodosCollectionKey, json.encode(todos));
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = [..._todoStreamController.value];
    final todoIndex = todos.indexWhere((t) => t.id == id);

    if (todoIndex == -1) {
      throw TodoNotFoundException();
    } else {
      todos.removeAt(todoIndex);

      final tags = [..._tagStreamController.value];
      bool tagsUpdated = false;
      for (int i = 0; i < tags.length; i++) {
        final tag = tags[i];
        if (tag.todoIds.contains(id)) {
          final updatedTodoIds = Set<String>.from(tag.todoIds)..remove(id);
          tags[i] = tag.copyWith(todoIds: updatedTodoIds);
          tagsUpdated = true;
        }
      }

      if (tagsUpdated) {
        _tagStreamController.add(tags);
        await _setValue(kTagsCollectionKey, json.encode(tags));
      }

      _todoStreamController.add(todos);
      await _setValue(kTodosCollectionKey, json.encode(todos));
    }
  }

  @override
  Future<int> clearCompleted() async {
    final todos = [..._todoStreamController.value];
    final completedTodos = todos.where((t) => t.isCompleted).toList();

    todos.removeWhere((t) => t.isCompleted);

    final tags = [..._tagStreamController.value];
    bool tagsUpdated = false;
    final completedTodoIds = completedTodos.map((t) => t.id).toSet();

    for (int i = 0; i < tags.length; i++) {
      final tag = tags[i];
      final intersection = tag.todoIds.intersection(completedTodoIds);
      if (intersection.isNotEmpty) {
        final updatedTodoIds = Set<String>.from(tag.todoIds)..removeAll(completedTodoIds);
        tags[i] = tag.copyWith(todoIds: updatedTodoIds);
        tagsUpdated = true;
      }
    }

    if (tagsUpdated) {
      _tagStreamController.add(tags);
      await _setValue(kTagsCollectionKey, json.encode(tags));
    }

    _todoStreamController.add(todos);
    await _setValue(kTodosCollectionKey, json.encode(todos));
    return completedTodos.length;
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
