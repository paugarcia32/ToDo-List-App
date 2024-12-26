import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_todos_api/src/sync_utils.dart';
import 'package:todos_api/todos_api.dart';

void main() {
  group('SyncUtils', () {
    group('diffIds', () {
      test('returns added IDs in "added" when newIds include extra elements', () {
        final oldIds = {'1', '2'};
        final newIds = {'1', '2', '3'};

        final diff = SyncUtils.diffIds(oldIds, newIds);

        expect(diff['added'], equals({'3'}));
        expect(diff['removed'], equals(<String>{}));
      });

      test('returns removed IDs in "removed" when newIds have fewer elements', () {
        final oldIds = {'1', '2', '3'};
        final newIds = {'1', '2'};

        final diff = SyncUtils.diffIds(oldIds, newIds);

        expect(diff['added'], equals(<String>{}));
        expect(diff['removed'], equals({'3'}));
      });

      test('returns both added and removed lists when there are mixed changes', () {
        final oldIds = {'1', '2', '3'};
        final newIds = {'2', '4'};

        final diff = SyncUtils.diffIds(oldIds, newIds);

        expect(diff['added'], equals({'4'}));
        expect(diff['removed'], equals({'1', '3'}));
      });

      test('returns empty when there are no changes', () {
        final oldIds = {'1', '2'};
        final newIds = {'1', '2'};

        final diff = SyncUtils.diffIds(oldIds, newIds);

        expect(diff['added'], equals(<String>{}));
        expect(diff['removed'], equals(<String>{}));
      });
    });

    group('syncTagsFromTodo', () {
      final initialTags = [
        Tag(
          id: '1',
          title: 'Tag 1',
          isArchived: false,
          color: '#FFFFFF',
          todoIds: {'1'},
        ),
        Tag(
          id: '2',
          title: 'Tag 2',
          isArchived: false,
          color: '#FFFFFF',
          todoIds: {'1', '2'},
        ),
        Tag(
          id: '3',
          title: 'Tag 3',
          isArchived: false,
          color: '#FFFFFF',
          todoIds: {'3'},
        ),
      ];

      test('adds todoIds to the corresponding tags', () {
        final addedTagIds = {'3'};
        final removedTagIds = <String>{};
        final todoId = '2';

        final updatedTags = SyncUtils.syncTagsFromTodo(
          tags: initialTags,
          todoId: todoId,
          addedTagIds: addedTagIds,
          removedTagIds: removedTagIds,
        );

        final expectedTagsAfterAdd = [
          initialTags[0],
          initialTags[1],
          initialTags[2].copyWith(todoIds: {'3', '2'}),
        ];

        expect(updatedTags, equals(expectedTagsAfterAdd));
      });

      test('removes todoIds from the corresponding tags', () {
        final tagsWithAdded = [
          initialTags[0],
          initialTags[1],
          initialTags[2].copyWith(todoIds: {'3', '2'}),
        ];

        final addedTagIds = <String>{};
        final removedTagIds = {'1'};
        final todoId = '1';

        final updatedTags = SyncUtils.syncTagsFromTodo(
          tags: tagsWithAdded,
          todoId: todoId,
          addedTagIds: addedTagIds,
          removedTagIds: removedTagIds,
        );

        final expectedTagsAfterRemove = [
          initialTags[0].copyWith(todoIds: <String>{}),
          initialTags[1],
          initialTags[2].copyWith(todoIds: {'3', '2'}),
        ];

        expect(updatedTags, equals(expectedTagsAfterRemove));
      });
    });

    group('syncTodosFromTag', () {
      test('adds and removes tagIds in the corresponding Todos', () {
        final initialTodos = [
          Todo(
            id: '1',
            title: 'Todo 1',
            description: 'Desc 1',
            isCompleted: false,
            tagIds: {'1'},
            date: DateTime.now(),
          ),
          Todo(
            id: '2',
            title: 'Todo 2',
            description: 'Desc 2',
            isCompleted: false,
            tagIds: {'1', '2'},
            date: DateTime.now(),
          ),
          Todo(
            id: '3',
            title: 'Todo 3',
            description: 'Desc 3',
            isCompleted: false,
            tagIds: {'3'},
            date: DateTime.now(),
          ),
        ];

        final addedTodoIds = {'3'};
        final removedTodoIds = <String>{};
        final tagId = '2';

        final updatedTodos = SyncUtils.syncTodosFromTag(
          todos: initialTodos,
          tagId: tagId,
          addedTodoIds: addedTodoIds,
          removedTodoIds: removedTodoIds,
        );

        final expectedTodosAfterAdd = [
          initialTodos[0],
          initialTodos[1],
          initialTodos[2].copyWith(tagIds: {'3', '2'}),
        ];
        expect(updatedTodos, equals(expectedTodosAfterAdd));

        final addedTodoIds2 = <String>{};
        final removedTodoIds2 = {'1'};
        final tagId2 = '2';

        final updatedTodos2 = SyncUtils.syncTodosFromTag(
          todos: updatedTodos,
          tagId: tagId2,
          addedTodoIds: addedTodoIds2,
          removedTodoIds: removedTodoIds2,
        );

        final expectedTodosAfterRemove = [
          initialTodos[0].copyWith(tagIds: {'1'}),
          initialTodos[1],
          initialTodos[2].copyWith(tagIds: {'3', '2'}),
        ];

        expect(updatedTodos2, equals(expectedTodosAfterRemove));
      });
    });
  });
}
