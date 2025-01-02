import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/stats/stats.dart';

void main() {
  group('StatsState', () {
    StatsState createSubject({
      StatsStatus status = StatsStatus.initial,
      int completedTodos = 0,
      int activeTodos = 0,
      int totalTags = 0,
    }) {
      return StatsState(
        status: status,
        completedTodos: completedTodos,
        activeTodos: activeTodos,
        totalTags: totalTags,
      );
    }

    test('supports value equality', () {
      expect(
        createSubject(),
        equals(createSubject()),
      );
    });

    test('props are correct', () {
      expect(
        createSubject(
          status: StatsStatus.initial,
          completedTodos: 1,
          activeTodos: 2,
          totalTags: 3,
        ).props,
        equals(<Object?>[
          StatsStatus.initial,
          1,
          2,
          3,
        ]),
      );
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          createSubject().copyWith(
            status: null,
            completedTodos: null,
            activeTodos: null,
            totalTags: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        expect(
          createSubject().copyWith(
            status: StatsStatus.success,
            completedTodos: 1,
            activeTodos: 2,
            totalTags: 4,
          ),
          equals(
            createSubject(
              status: StatsStatus.success,
              completedTodos: 1,
              activeTodos: 2,
              totalTags: 4,
            ),
          ),
        );
      });
    });
  });
}
