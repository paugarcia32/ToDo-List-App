import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../fakers/fake_todos.dart';

void main() {
  group('TodosViewFilter', () {
    group('apply', () {
      test('always returns true when filter is .all', () {
        expect(
          TodosViewFilter.all.apply(mockTodos[0]),
          isTrue,
        );
        expect(
          TodosViewFilter.all.apply(mockTodos[1]),
          isTrue,
        );
      });

      test(
        'returns true when filter is .activeOnly '
        'and the todo is incomplete',
        () {
          expect(
            TodosViewFilter.activeOnly.apply(mockTodos[0]),
            isFalse,
          );
          expect(
            TodosViewFilter.activeOnly.apply(mockTodos[1]),
            isTrue,
          );
        },
      );

      test(
        'returns true when filter is .completedOnly '
        'and the todo is completed',
        () {
          expect(
            TodosViewFilter.completedOnly.apply(mockTodos[1]),
            isFalse,
          );
          expect(
            TodosViewFilter.completedOnly.apply(mockTodos[0]),
            isTrue,
          );
        },
      );
    });

    group('applyAll', () {
      test('correctly filters provided iterable based on selected filter', () {
        expect(
          TodosViewFilter.all.applyAll(mockTodos).toList(),
          equals(mockTodos),
        );
        expect(
          TodosViewFilter.activeOnly.applyAll(mockTodos).toList(),
          equals([mockTodos[1]]),
        );
        expect(
          TodosViewFilter.completedOnly.applyAll(mockTodos).toList(),
          equals([mockTodos[0], mockTodos[2]]),
        );
      });
    });

    group('filtering by tags', () {
      test('filters todos by tag', () {
        final workTodos = mockTodos.where((todo) => todo.tagIds.contains('3')).toList();
        expect(workTodos, equals([mockTodos[1]]));

        final personalTodos = mockTodos.where((todo) => todo.tagIds.contains('2')).toList();
        expect(personalTodos, equals([mockTodos[0]]));

        final urgentTodos = mockTodos.where((todo) => todo.tagIds.contains('1')).toList();
        expect(urgentTodos, equals([mockTodos[0]]));
      });

      group('filtering by tags', () {
        test('filters todos by tag and completion status', () {
          final activeWorkTodos = mockTodos.where((todo) => !todo.isCompleted && todo.tagIds.contains('3')).toList();
          expect(activeWorkTodos, equals([mockTodos[1]]));

          final completedWorkTodos = mockTodos.where((todo) => todo.isCompleted && todo.tagIds.contains('3')).toList();
          expect(completedWorkTodos, equals([]));
        });
      });
    });

    group('TodosFilter', () {
      test('filters by status and tag', () {
        final filter = (List<Todo> todos, TodosViewFilter statusFilter, String? tag) {
          return todos.where((todo) {
            final matchesStatus = statusFilter.apply(todo);
            final matchesTag = tag == null || (todo.tagIds.contains(tag));
            return matchesStatus && matchesTag;
          }).toList();
        };

        expect(
          filter(mockTodos, TodosViewFilter.activeOnly, '4'),
          equals([]),
        );

        expect(
          filter(mockTodos, TodosViewFilter.completedOnly, '4'),
          equals([mockTodos[2]]),
        );

        expect(
          filter(mockTodos, TodosViewFilter.all, '4'),
          equals([mockTodos[2]]),
        );

        expect(
          filter(mockTodos, TodosViewFilter.activeOnly, '3'),
          equals([mockTodos[1]]),
        );
      });

      test('filters by tag only when no status filter', () {
        final filter = (List<Todo> todos, TodosViewFilter statusFilter, String? tag) {
          return todos.where((todo) {
            final matchesStatus = statusFilter.apply(todo);
            final matchesTag = tag == null || (todo.tagIds.contains(tag));
            return matchesStatus && matchesTag;
          }).toList();
        };

        expect(
          filter(mockTodos, TodosViewFilter.all, '1'),
          equals([mockTodos[0]]),
        );

        expect(
          filter(mockTodos, TodosViewFilter.all, '3'),
          equals([mockTodos[1]]),
        );
      });

      test('filters by status only when no tag filter', () {
        final filter = (
          List<Todo> todos,
          TodosViewFilter statusFilter,
          String? tag,
        ) {
          return todos.where((todo) {
            final matchesStatus = statusFilter.apply(todo);
            final matchesTag = tag == null || (todo.tagIds.contains(tag));
            return matchesStatus && matchesTag;
          }).toList();
        };

        expect(
          filter(mockTodos, TodosViewFilter.activeOnly, null),
          equals([mockTodos[1]]),
        );

        expect(
          filter(mockTodos, TodosViewFilter.completedOnly, null),
          equals([mockTodos[0], mockTodos[2]]),
        );
      });
    });
  });
}
