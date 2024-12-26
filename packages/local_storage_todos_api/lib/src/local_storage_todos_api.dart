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

  Map<String, Set<String>> diffIds(Set<String> oldIds, Set<String> newIds) {
    final added = newIds.difference(oldIds);
    final removed = oldIds.difference(newIds);
    return {
      'added': added,
      'removed': removed,
    };
  }

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

  /// Update the `tags` list adding or removing `todoId` in each Tag
  List<Tag> syncTagsFromTodo({
    required List<Tag> tags,
    required String todoId,
    required Set<String> addedTagIds,
    required Set<String> removedTagIds,
  }) {
    final updatedTags = List<Tag>.from(tags);

    void _updateTagForTodo(String tagId, bool add) {
      final tagIndex = updatedTags.indexWhere((t) => t.id == tagId);
      if (tagIndex >= 0) {
        final tag = updatedTags[tagIndex];
        final updatedTodoIds = Set<String>.from(tag.todoIds);
        if (add) {
          updatedTodoIds.add(todoId);
        } else {
          updatedTodoIds.remove(todoId);
        }
        updatedTags[tagIndex] = tag.copyWith(todoIds: updatedTodoIds);
      }
    }

    // Añadimos
    for (final tagId in addedTagIds) {
      _updateTagForTodo(tagId, true);
    }
    // Quitamos
    for (final tagId in removedTagIds) {
      _updateTagForTodo(tagId, false);
    }

    return updatedTags;
  }

  @override
  Future<void> saveTodo(Todo todo) async {
    final currentTodos = List<Todo>.from(_todoStreamController.value);
    final currentTags = List<Tag>.from(_tagStreamController.value);

    final todoIndex = currentTodos.indexWhere((t) => t.id == todo.id);
    final oldTagIds = (todoIndex >= 0) ? currentTodos[todoIndex].tagIds : <String>{};

    if (todoIndex >= 0) {
      currentTodos[todoIndex] = todo;
    } else {
      currentTodos.add(todo);
    }

    final diff = diffIds(oldTagIds, todo.tagIds);
    final addedTagIds = diff['added']!;
    final removedTagIds = diff['removed']!;

    final updatedTags = syncTagsFromTodo(
      tags: currentTags,
      todoId: todo.id,
      addedTagIds: addedTagIds,
      removedTagIds: removedTagIds,
    );

    _todoStreamController.add(List.unmodifiable(currentTodos));
    _tagStreamController.add(List.unmodifiable(updatedTags));

    await Future.wait([
      _setValue(kTodosCollectionKey, json.encode(currentTodos)),
      _setValue(kTagsCollectionKey, json.encode(updatedTags)),
    ]);
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

      final todos = [..._todoStreamController.value];
      bool todosUpdated = false;

      for (int i = 0; i < todos.length; i++) {
        final todo = todos[i];
        if (todo.tagIds.contains(id)) {
          final updatedTagIds = Set<String>.from(todo.tagIds)..remove(id);
          todos[i] = todo.copyWith(tagIds: updatedTagIds);
          todosUpdated = true;
        }
      }

      if (todosUpdated) {
        _todoStreamController.add(todos);
        await _setValue(kTodosCollectionKey, json.encode(todos));
      }
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

  /// Update the `todos` list adding or removing `tagId` in each Todo
  List<Todo> syncTodosFromTag({
    required List<Todo> todos,
    required String tagId,
    required Set<String> addedTodoIds,
    required Set<String> removedTodoIds,
  }) {
    final updatedTodos = List<Todo>.from(todos);

    void _updateTodoForTag(String todoId, bool add) {
      final todoIndex = updatedTodos.indexWhere((t) => t.id == todoId);
      if (todoIndex >= 0) {
        final todo = updatedTodos[todoIndex];
        final updatedTagIds = Set<String>.from(todo.tagIds);
        if (add) {
          updatedTagIds.add(tagId);
        } else {
          updatedTagIds.remove(tagId);
        }
        updatedTodos[todoIndex] = todo.copyWith(tagIds: updatedTagIds);
      }
    }

    // Añadimos
    for (final todoId in addedTodoIds) {
      _updateTodoForTag(todoId, true);
    }
    // Quitamos
    for (final todoId in removedTodoIds) {
      _updateTodoForTag(todoId, false);
    }

    return updatedTodos;
  }

  @override
  Future<void> saveTag(Tag tag) async {
    final currentTags = List<Tag>.from(_tagStreamController.value);
    final currentTodos = List<Todo>.from(_todoStreamController.value);

    final tagIndex = currentTags.indexWhere((t) => t.id == tag.id);
    final oldTodoIds = (tagIndex >= 0) ? currentTags[tagIndex].todoIds : <String>{};

    if (tagIndex >= 0) {
      currentTags[tagIndex] = tag;
    } else {
      currentTags.add(tag);
    }

    final diff = diffIds(oldTodoIds, tag.todoIds);
    final addedTodoIds = diff['added']!;
    final removedTodoIds = diff['removed']!;

    final updatedTodos = syncTodosFromTag(
      todos: currentTodos,
      tagId: tag.id,
      addedTodoIds: addedTodoIds,
      removedTodoIds: removedTodoIds,
    );

    _tagStreamController.add(List.unmodifiable(currentTags));
    _todoStreamController.add(List.unmodifiable(updatedTodos));

    await Future.wait([
      _setValue(kTagsCollectionKey, json.encode(currentTags)),
      _setValue(kTodosCollectionKey, json.encode(updatedTodos)),
    ]);
  }

  @override
  Future<void> close() async {
    await _todoStreamController.close();
    await _tagStreamController.close();
  }
}
