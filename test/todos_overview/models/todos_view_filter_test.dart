import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

void main() {
  group('TodosViewFilter', () {
    final completedTodo = Todo(
      id: '0',
      title: 'completed',
      isCompleted: true,
      tags: ['work', 'urgent'],
    );

    final incompleteTodo = Todo(
      id: '1',
      title: 'incomplete',
      tags: ['personal'],
    );

    final anotherTodo = Todo(
      id: '2',
      title: 'another',
      isCompleted: false,
      tags: ['work'],
    );

    final allTodos = [completedTodo, incompleteTodo, anotherTodo];

    group('apply', () {
      test('always returns true when filter is .all', () {
        expect(
          TodosViewFilter.all.apply(completedTodo),
          isTrue,
        );
        expect(
          TodosViewFilter.all.apply(incompleteTodo),
          isTrue,
        );
      });

      test(
        'returns true when filter is .activeOnly '
        'and the todo is incomplete',
        () {
          expect(
            TodosViewFilter.activeOnly.apply(completedTodo),
            isFalse,
          );
          expect(
            TodosViewFilter.activeOnly.apply(incompleteTodo),
            isTrue,
          );
        },
      );

      test(
        'returns true when filter is .completedOnly '
        'and the todo is completed',
        () {
          expect(
            TodosViewFilter.completedOnly.apply(incompleteTodo),
            isFalse,
          );
          expect(
            TodosViewFilter.completedOnly.apply(completedTodo),
            isTrue,
          );
        },
      );
    });

    group('applyAll', () {
      test('correctly filters provided iterable based on selected filter', () {
        expect(
          TodosViewFilter.all.applyAll(allTodos),
          equals(allTodos),
        );
        expect(
          TodosViewFilter.activeOnly.applyAll(allTodos),
          equals([incompleteTodo, anotherTodo]),
        );
        expect(
          TodosViewFilter.completedOnly.applyAll(allTodos),
          equals([completedTodo]),
        );
      });
    });

    group('filtering by tags', () {
      test('filters todos by tag', () {
        final workTodos = allTodos.where((todo) => todo.tags?.contains('work') ?? false).toList();
        expect(workTodos, equals([completedTodo, anotherTodo]));

        final personalTodos = allTodos.where((todo) => todo.tags?.contains('personal') ?? false).toList();
        expect(personalTodos, equals([incompleteTodo]));

        final urgentTodos = allTodos.where((todo) => todo.tags?.contains('urgent') ?? false).toList();
        expect(urgentTodos, equals([completedTodo]));
      });

      test('filters todos by tag and completion status', () {
        final activeWorkTodos =
            allTodos.where((todo) => !todo.isCompleted && (todo.tags?.contains('work') ?? false)).toList();
        expect(activeWorkTodos, equals([anotherTodo]));

        final completedWorkTodos =
            allTodos.where((todo) => todo.isCompleted && (todo.tags?.contains('work') ?? false)).toList();
        expect(completedWorkTodos, equals([completedTodo]));
      });
    });

    group('TodosFilter', () {
      test('filters by status and tag', () {
        final filter = (List<Todo> todos, TodosViewFilter statusFilter, String? tag) {
          return todos.where((todo) {
            final matchesStatus = statusFilter.apply(todo);
            final matchesTag = tag == null || (todo.tags?.contains(tag) ?? false);
            return matchesStatus && matchesTag;
          }).toList();
        };

        expect(
          filter(allTodos, TodosViewFilter.activeOnly, 'work'),
          equals([anotherTodo]),
        );

        expect(
          filter(allTodos, TodosViewFilter.completedOnly, 'work'),
          equals([completedTodo]),
        );

        expect(
          filter(allTodos, TodosViewFilter.all, 'work'),
          equals([completedTodo, anotherTodo]),
        );

        expect(
          filter(allTodos, TodosViewFilter.activeOnly, 'personal'),
          equals([incompleteTodo]),
        );
      });

      test('filters by tag only when no status filter', () {
        final filter = (List<Todo> todos, TodosViewFilter statusFilter, String? tag) {
          return todos.where((todo) {
            final matchesStatus = statusFilter.apply(todo);
            final matchesTag = tag == null || (todo.tags?.contains(tag) ?? false);
            return matchesStatus && matchesTag;
          }).toList();
        };

        expect(
          filter(allTodos, TodosViewFilter.all, 'urgent'),
          equals([completedTodo]),
        );

        expect(
          filter(allTodos, TodosViewFilter.all, 'nonexistent'),
          isEmpty,
        );
      });

      test('filters by status only when no tag filter', () {
        final filter = (List<Todo> todos, TodosViewFilter statusFilter, String? tag) {
          return todos.where((todo) {
            final matchesStatus = statusFilter.apply(todo);
            final matchesTag = tag == null || (todo.tags?.contains(tag) ?? false);
            return matchesStatus && matchesTag;
          }).toList();
        };

        expect(
          filter(allTodos, TodosViewFilter.activeOnly, null),
          equals([incompleteTodo, anotherTodo]),
        );

        expect(
          filter(allTodos, TodosViewFilter.completedOnly, null),
          equals([completedTodo]),
        );
      });
    });
  });
}
