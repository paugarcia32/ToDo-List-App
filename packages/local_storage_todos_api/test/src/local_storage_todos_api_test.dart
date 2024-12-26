// ignore_for_file: prefer_const_constructors
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_todos_api/local_storage_todos_api.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_api/todos_api.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('LocalStorageTodosApi', () {
    late SharedPreferences plugin;

    final todos = [
      Todo(
        id: '1',
        title: 'title 1',
        description: 'description 1',
        isCompleted: false,
        tagIds: {'1', '2'},
        date: DateTime.now(),
      ),
      Todo(
        id: '2',
        title: 'title 2',
        description: 'description 2',
        isCompleted: false,
        tagIds: {'3'},
        date: DateTime.now(),
      ),
      Todo(
        id: '3',
        title: 'title 3',
        description: 'description 3',
        isCompleted: false,
        tagIds: {'3', '2'},
        date: DateTime.now(),
      ),
      Todo(
        id: '4',
        title: 'title 4',
        description: 'description 4',
        isCompleted: false,
        tagIds: {'1', '2'},
        date: DateTime.now(),
      ),
    ];

    final tags = [
      Tag(
        id: '1',
        title: 'title 1',
        isArchived: false,
        color: '#FFFFFFFF',
        todoIds: {'1'},
      ),
      Tag(
        id: '2',
        title: 'title 2',
        isArchived: false,
        color: '#FFFFFFFF',
        todoIds: {'1', '3'},
      ),
      Tag(
        id: '3',
        title: 'title 3',
        isArchived: false,
        color: '#FFFFFFFF',
        todoIds: {'2', '3'},
      ),
    ];

    setUp(() {
      plugin = MockSharedPreferences();
      when(() => plugin.getString(LocalStorageTodosApi.kTodosCollectionKey)).thenReturn(json.encode(todos));
      when(() => plugin.getString(LocalStorageTodosApi.kTagsCollectionKey)).thenReturn(json.encode(tags));
      when(() => plugin.setString(any(), any())).thenAnswer((_) async => true);
    });

    LocalStorageTodosApi createSubject() {
      return LocalStorageTodosApi(
        plugin: plugin,
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(
          createSubject,
          returnsNormally,
        );
      });

      group('initializes the todos stream', () {
        test('with existing todos if present', () {
          final subject = createSubject();

          expect(subject.getTodos(), emits(todos));
          verify(
            () => plugin.getString(
              LocalStorageTodosApi.kTodosCollectionKey,
            ),
          ).called(1);
        });

        test('with empty list if no todos present', () {
          when(() => plugin.getString(any())).thenReturn(null);

          final subject = createSubject();

          expect(subject.getTodos(), emits(const <Todo>[]));
          verify(
            () => plugin.getString(
              LocalStorageTodosApi.kTodosCollectionKey,
            ),
          ).called(1);
        });
      });

      group("initializes the tags stream", () {
        test('with existing tags if present', () {
          final subject = createSubject();

          expect(subject.getTags(), emits(tags));
          verify(
            () => plugin.getString(
              LocalStorageTodosApi.kTagsCollectionKey,
            ),
          ).called(1);
        });
        test('with empty list if no tags present', () {
          when(() => plugin.getString(any())).thenReturn(null);

          final subject = createSubject();

          expect(subject.getTags(), emits(const <Tag>[]));
          verify(
            () => plugin.getString(
              LocalStorageTodosApi.kTagsCollectionKey,
            ),
          ).called(1);
        });
      });
    });

    test('getTodos returns stream of current list todos', () {
      expect(
        createSubject().getTodos(),
        emits(todos),
      );
    });

    group('saveTodo', () {
      test('saves new todos', () {
        final newTodo = Todo(
          id: '5',
          title: 'title 5',
          description: 'description 5',
          isCompleted: false,
          tagIds: {'3', '2'},
          date: DateTime.now(),
        );

        final newTodos = [...todos, newTodo];

        final subject = createSubject();

        expect(subject.saveTodo(newTodo), completes);
        expect(subject.getTodos(), emits(newTodos));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTodosCollectionKey,
            json.encode(newTodos),
          ),
        ).called(1);
      });

      test('updates existing todos', () {
        final updatedTodo = Todo(
          id: '1',
          title: 'new title 1',
          description: 'new description 1',
          isCompleted: true,
        );
        final newTodos = [updatedTodo, ...todos.sublist(1)];

        final subject = createSubject();

        expect(subject.saveTodo(updatedTodo), completes);
        expect(subject.getTodos(), emits(newTodos));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTodosCollectionKey,
            json.encode(newTodos),
          ),
        ).called(1);
      });

      test('updates tagIds for the todo and tags correctly', () {
        final updatedTodo = todos[0].copyWith(
          tagIds: {'2', '3'},
        );

        final expectedTags = [
          tags[0].copyWith(todoIds: {}),
          tags[1].copyWith(todoIds: {'1', '3'}),
          tags[2].copyWith(todoIds: {'1', '2', '3'}),
        ];

        final subject = createSubject();

        expect(subject.saveTodo(updatedTodo), completes);
        expect(subject.getTags(), emits(expectedTags));
      });

      test('adds new todo and updates tags with new tagIds', () {
        final newTag = Tag(
          id: '4',
          title: 'title 4',
          isArchived: false,
          color: '#FFFFFFFF',
          todoIds: {'2', '3'},
        );

        /// Ajustamos la lista esperada de Tags, agregando `newTag` al final
        final expectedTags = [
          tags[0], // Tag(1)
          tags[1].copyWith(todoIds: {'1', '3'}), // Tag(2) modificado
          tags[2], // Tag(3)
          newTag // <-- El nuevo Tag (4)
        ];

        final subject = createSubject();

        expect(subject.saveTag(newTag), completes);
        expect(subject.getTags(), emits(expectedTags));
      });

      test('removes all tagIds from a todo and updates tags correctly', () {
        final updatedTodo = todos[0].copyWith(
          tagIds: {},
        );

        final expectedTags = [
          tags[0].copyWith(todoIds: {}),
          tags[1].copyWith(todoIds: {'3'}),
          tags[2].copyWith(todoIds: {'2', '3'}),
        ];

        final subject = createSubject();

        expect(subject.saveTodo(updatedTodo), completes);
        expect(subject.getTags(), emits(expectedTags));
      });
    });

    group('deleteTodo', () {
      test('deletes existing todos', () async {
        final newTodos = todos.sublist(1);
        final subject = createSubject();

        expectLater(
            subject.getTodos(),
            emitsInOrder([
              todos,
              newTodos,
            ]));

        await subject.deleteTodo(todos[0].id);

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTodosCollectionKey,
            json.encode(newTodos),
          ),
        ).called(1);
      });

      test(
        'throws TodoNotFoundException if todo '
        'with provided id is not found',
        () {
          final subject = createSubject();

          expect(
            () => subject.deleteTodo('non-existing-id'),
            throwsA(isA<TodoNotFoundException>()),
          );
        },
      );

      test('updates tags when a todo is deleted', () {
        final subject = createSubject();

        // Elimina el primer Todo
        final todoToDelete = todos[0];

        // Tags esperados después de eliminar el todo
        final expectedTags = [
          tags[0].copyWith(todoIds: <String>{}), // El Todo eliminado ya no está en el Tag '1'
          tags[1].copyWith(todoIds: {'3'}), // El Todo eliminado ya no está en el Tag '2'
          tags[2].copyWith(todoIds: {'2', '3'}), // El Todo eliminado ya no está en el Tag '3'
        ];

        expect(subject.deleteTodo(todoToDelete.id), completes);
        expect(subject.getTags(), emits(expectedTags));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTagsCollectionKey,
            json.encode(expectedTags),
          ),
        ).called(1);
      });

      test('does not update unrelated tags when a todo is deleted', () {
        final subject = createSubject();

        final todoToDelete = todos.last;

        expect(subject.deleteTodo(todoToDelete.id), completes);
        expect(subject.getTags(), emits(tags));

        verifyNever(
          () => plugin.setString(
            LocalStorageTodosApi.kTagsCollectionKey,
            any<String>(),
          ),
        );
      });

      test('clears todoIds for a tag when its last associated todo is deleted', () {
        final subject = createSubject();

        final todoToDelete = todos[0];

        final expectedTags = [
          tags[0].copyWith(todoIds: {}),
          tags[1].copyWith(todoIds: {'3'}),
          tags[2].copyWith(todoIds: {'2', '3'}),
        ];

        expect(subject.deleteTodo(todoToDelete.id), completes);
        expect(subject.getTags(), emits(expectedTags));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTagsCollectionKey,
            json.encode(expectedTags),
          ),
        ).called(1);
      });

      test('clears all tags when all todos are deleted', () async {
        final subject = createSubject();

        for (final todo in todos) {
          await subject.deleteTodo(todo.id);
        }

        final expectedTags = tags.map((tag) => tag.copyWith(todoIds: {})).toList();

        expect(subject.getTodos(), emits(const <Todo>[]));
        expect(subject.getTags(), emits(expectedTags));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTagsCollectionKey,
            json.encode(expectedTags),
          ),
        ).called(1);
      });
    });

    group('clearCompleted', () {
      test('deletes all completed todos', () {
        final newTodos = todos.where((todo) => !todo.isCompleted).toList();
        final deletedTodosAmount = todos.length - newTodos.length;

        final subject = createSubject();

        expect(
          subject.clearCompleted(),
          completion(equals(deletedTodosAmount)),
        );
        expect(subject.getTodos(), emits(newTodos));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTodosCollectionKey,
            json.encode(newTodos),
          ),
        ).called(1);
      });
    });

    group('completeAll', () {
      test('sets isCompleted on all todos to provided value', () {
        final newTodos = todos.map((todo) => todo.copyWith(isCompleted: true)).toList();
        final changedTodosAmount = todos.where((todo) => !todo.isCompleted).length;

        final subject = createSubject();

        expect(
          subject.completeAll(isCompleted: true),
          completion(equals(changedTodosAmount)),
        );
        expect(subject.getTodos(), emits(newTodos));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTodosCollectionKey,
            json.encode(newTodos),
          ),
        ).called(1);
      });
    });

    test('getTags returns stream of current list tags', () {
      expect(
        createSubject().getTags(),
        emits(tags),
      );
    });

    group("getTodosByTag", () {
      test('returns todos associated with the specified tagId', () async {
        final subject = createSubject();
        const tagId = '2';

        final result = await subject.getTodosByTag(tagId);

        final expectedTodos = [
          todos[0],
          todos[2],
          todos[3],
        ];

        expect(result, equals(expectedTodos));
      });

      test('returns an empty list if no todos are associated with the tagId', () async {
        final subject = createSubject();
        const tagId = 'non-existing-tag';

        final result = await subject.getTodosByTag(tagId);

        expect(result, isEmpty);
      });
    });

    group('saveTag', () {
      test('saves new tags', () {
        final newTag = Tag(
          id: '5',
          title: 'title 5',
          isArchived: false,
          color: '#FFFFFFFF',
          todoIds: {'1', '2'},
        );

        final newTags = [...tags, newTag];

        final subject = createSubject();

        expect(subject.saveTag(newTag), completes);
        expect(subject.getTags(), emits(newTags));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTagsCollectionKey,
            json.encode(newTags),
          ),
        ).called(1);
      });

      test('saves new tag and updates corresponding Todos', () {
        final newTag = Tag(
          id: '5',
          title: 'title 5',
          isArchived: false,
          color: '#FFFFFFFF',
          todoIds: {'1', '2'},
        );

        final expectedTodos = [
          todos[0].copyWith(tagIds: {'1', '2', '5'}),
          todos[1].copyWith(tagIds: {'3', '5'}),
          todos[2],
          todos[3],
        ];

        final subject = createSubject();

        expect(subject.saveTag(newTag), completes);

        expect(subject.getTodos(), emits(expectedTodos));
      });

      test('updates existing tag', () {
        final updatedTag = Tag(
          id: '1',
          title: 'new title 1',
          isArchived: false,
          color: '#FFFFFFFF',
          todoIds: {'1', '2'},
        );
        final newTags = [updatedTag, ...tags.sublist(1)];

        final subject = createSubject();

        expect(subject.saveTag(updatedTag), completes);
        expect(subject.getTags(), emits(newTags));

        verify(
          () => plugin.setString(
            LocalStorageTodosApi.kTagsCollectionKey,
            json.encode(newTags),
          ),
        ).called(1);
      });

      test('updates existing tag and updates Todos accordingly', () {
        final updatedTag = tags[0].copyWith(
          todoIds: {'1', '2'},
        );

        final expectedTodos = [
          todos[0],
          todos[1].copyWith(tagIds: {'3', '1'}),
          todos[2],
          todos[3],
        ];

        final subject = createSubject();

        expect(subject.saveTag(updatedTag), completes);
        expect(subject.getTodos(), emits(expectedTodos));
      });

      test('updates todosIds for the tag and todos correctly', () {
        final updatedTag = tags[0].copyWith(
          todoIds: {'2'},
        );

        final expectedTodos = [
          todos[0].copyWith(tagIds: {'2'}),
          todos[1].copyWith(tagIds: {'1', '3'}),
          todos[2].copyWith(tagIds: {'2', '3'}),
          todos[3].copyWith(tagIds: {'1', '2'}),
        ];

        final subject = createSubject();

        expect(subject.saveTag(updatedTag), completes);
        expect(subject.getTodos(), emits(expectedTodos));
      });

      test('removes all tagIds from a todo and updates tags correctly', () {
        final updatedTodo = todos[0].copyWith(
          tagIds: {},
        );

        final expectedTags = [
          tags[0].copyWith(todoIds: {}),
          tags[1].copyWith(todoIds: {'3'}),
          tags[2].copyWith(todoIds: {'2', '3'}),
        ];

        final subject = createSubject();

        expect(subject.saveTodo(updatedTodo), completes);
        expect(subject.getTags(), emits(expectedTags));
      });
    });

    group('close', () {
      test('closes the instance', () async {
        final subject = createSubject();

        await subject.close();

        expect(
          () => subject.saveTodo(
            Todo(id: '1', title: 'title 1'),
          ),
          throwsStateError,
        );
        expect(
          () => subject.saveTag(
            Tag(id: '1', title: 'title 1'),
          ),
          throwsStateError,
        );
      });
    });
  });
}
