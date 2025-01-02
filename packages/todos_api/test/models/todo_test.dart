import 'package:test/test.dart';
import 'package:todos_api/todos_api.dart';

void main() {
  group('Todo', () {
    Todo createSubject({
      String? id = '1',
      String title = 'title',
      String description = 'description',
      bool isCompleted = true,
      Set<String>? tagIds,
      DateTime? date,
    }) {
      return Todo(
        id: id,
        title: title,
        description: description,
        isCompleted: isCompleted,
        tagIds: tagIds,
        date: date,
      );
    }

    group('constructor', () {
      test('works correctly', () {
        expect(
          createSubject,
          returnsNormally,
        );
      });

      test('throws AssertionError when id is empty', () {
        expect(
          () => createSubject(id: ''),
          throwsA(isA<AssertionError>()),
        );
      });

      test('sets id if not provided', () {
        final todo = createSubject(id: null);
        expect(todo.id, isNotEmpty);
      });
    });

    test('supports value equality', () {
      expect(
        createSubject(),
        equals(createSubject()),
      );
    });

    test('props are correct', () {
      expect(
        createSubject().props,
        equals(<Object?>[
          '1',
          'title',
          'description',
          true,
          <String>{},
          null,
        ]),
      );
    });

    group('copyWith', () {
      test('returns the same object if not arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          createSubject().copyWith(
            id: null,
            title: null,
            description: null,
            isCompleted: null,
            tagIds: null,
            date: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        final newDate = DateTime(2025, 1, 2);
        final newTagIds = <String>{'tag1', 'tag2'};
        expect(
          createSubject().copyWith(
            id: '2',
            title: 'new title',
            description: 'new description',
            isCompleted: false,
            tagIds: newTagIds,
            date: newDate,
          ),
          equals(
            createSubject(
              id: '2',
              title: 'new title',
              description: 'new description',
              isCompleted: false,
              tagIds: newTagIds,
              date: newDate,
            ),
          ),
        );
      });
    });

    group('fromJson', () {
      test('works correctly with minimal fields', () {
        expect(
          Todo.fromJson(<String, dynamic>{
            'id': '1',
            'title': 'title',
            'description': 'description',
            'isCompleted': true,
          }),
          equals(createSubject()),
        );
      });

      test('works correctly with tagIds and date', () {
        final date = DateTime(2025, 1, 2).toIso8601String();
        expect(
          Todo.fromJson(<String, dynamic>{
            'id': '123',
            'title': 'custom title',
            'description': 'custom desc',
            'isCompleted': false,
            'tagIds': ['tag1', 'tag2'],
            'date': date,
          }),
          equals(
            createSubject(
              id: '123',
              title: 'custom title',
              description: 'custom desc',
              isCompleted: false,
              tagIds: {'tag1', 'tag2'},
              date: DateTime.parse(date),
            ),
          ),
        );
      });
    });

    group('toJson', () {
      test('works correctly with default fields', () {
        expect(
          createSubject().toJson(),
          equals(<String, dynamic>{
            'id': '1',
            'title': 'title',
            'description': 'description',
            'isCompleted': true,
            'tagIds': <String>[],
            'date': null,
          }),
        );
      });

      test('works correctly with tagIds and date', () {
        final testDate = DateTime(2025, 1, 2);
        expect(
          createSubject(
            id: 'abc',
            tagIds: {'tag1'},
            date: testDate,
            isCompleted: false,
            title: 'title X',
            description: 'desc X',
          ).toJson(),
          equals(<String, dynamic>{
            'id': 'abc',
            'title': 'title X',
            'description': 'desc X',
            'isCompleted': false,
            'tagIds': <String>['tag1'],
            'date': testDate.toIso8601String(),
          }),
        );
      });
    });
  });
}
