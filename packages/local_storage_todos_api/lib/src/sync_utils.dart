import 'package:todos_api/todos_api.dart';

class SyncUtils {
  /// Calculates the difference between two sets of IDs.
  /// Returns a Map with keys 'added' and 'removed', each containing a Set<String>.
  static Map<String, Set<String>> diffIds(
    Set<String> oldIds,
    Set<String> newIds,
  ) {
    final added = newIds.difference(oldIds);
    final removed = oldIds.difference(newIds);
    return {
      'added': added,
      'removed': removed,
    };
  }

  /// Updates the list of [tags] by adding or removing [todoId] in each [Tag].
  /// [addedTagIds] are the tag IDs that should add the [todoId].
  /// [removedTagIds] are the tag IDs that should remove the [todoId].
  static List<Tag> syncTagsFromTodo({
    required List<Tag> tags,
    required String todoId,
    required Set<String> addedTagIds,
    required Set<String> removedTagIds,
  }) {
    final updatedTags = List<Tag>.from(tags);

    void updateTagForTodo(String tagId, bool add) {
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

    for (final tagId in addedTagIds) {
      updateTagForTodo(tagId, true);
    }

    for (final tagId in removedTagIds) {
      updateTagForTodo(tagId, false);
    }

    return updatedTags;
  }

  /// Updates the list of [todos] by adding or removing [tagId] in each [Todo].
  /// [addedTodoIds] are the todo IDs that should add the [tagId].
  /// [removedTodoIds] are the todo IDs that should remove the [tagId].
  static List<Todo> syncTodosFromTag({
    required List<Todo> todos,
    required String tagId,
    required Set<String> addedTodoIds,
    required Set<String> removedTodoIds,
  }) {
    final updatedTodos = List<Todo>.from(todos);

    void updateTodoForTag(String todoId, bool add) {
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

    for (final todoId in addedTodoIds) {
      updateTodoForTag(todoId, true);
    }

    for (final todoId in removedTodoIds) {
      updateTodoForTag(todoId, false);
    }

    return updatedTodos;
  }
}
