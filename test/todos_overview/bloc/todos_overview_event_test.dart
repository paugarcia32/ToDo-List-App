// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import '../../fakers/fake_todos.dart';

void main() {
  group('TodosOverviewEvent', () {
    group('TodosOverviewSubscriptionRequested', () {
      test('supports value equality', () {
        expect(
          TodosOverviewSubscriptionRequested(),
          equals(TodosOverviewSubscriptionRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewSubscriptionRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('TodosOverviewTodoCompletionToggled', () {
      test('supports value equality', () {
        expect(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodos[1],
            isCompleted: true,
          ),
          equals(
            TodosOverviewTodoCompletionToggled(
              todo: mockTodos[1],
              isCompleted: true,
            ),
          ),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodos[1],
            isCompleted: true,
          ).props,
          equals(<Object?>[
            mockTodos[1],
            true,
          ]),
        );
      });
    });

    group('TodosOverviewTodoDeleted', () {
      test('supports value equality', () {
        expect(
          TodosOverviewTodoDeleted(mockTodos[1]),
          equals(TodosOverviewTodoDeleted(mockTodos[1])),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewTodoDeleted(mockTodos[1]).props,
          equals(<Object?>[
            mockTodos[1],
          ]),
        );
      });
    });

    group('TodosOverviewUndoDeletionRequested', () {
      test('supports value equality', () {
        expect(
          TodosOverviewUndoDeletionRequested(),
          equals(TodosOverviewUndoDeletionRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewUndoDeletionRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('TodosOverviewFilterChanged', () {
      test('supports value equality', () {
        expect(
          TodosOverviewFilterChanged(TodosViewFilter.all),
          equals(TodosOverviewFilterChanged(TodosViewFilter.all)),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewFilterChanged(TodosViewFilter.all).props,
          equals(<Object?>[
            TodosViewFilter.all, // filter
          ]),
        );
      });
    });

    group('TodosOverviewToggleAllRequested', () {
      test('supports value equality', () {
        expect(
          TodosOverviewToggleAllRequested(),
          equals(TodosOverviewToggleAllRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewToggleAllRequested().props,
          equals(<Object?>[]),
        );
      });
    });

    group('TodosOverviewClearCompletedRequested', () {
      test('supports value equality', () {
        expect(
          TodosOverviewClearCompletedRequested(),
          equals(TodosOverviewClearCompletedRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosOverviewClearCompletedRequested().props,
          equals(<Object?>[]),
        );
      });
    });
  });
}
