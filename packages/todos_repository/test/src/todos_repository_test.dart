// ignore_for_file: prefer_const_constructors
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosApi extends Mock implements TodosApi {}

class FakeTodo extends Fake implements Todo {}

class FakeTag extends Fake implements Tag {}

void main() {
  group('TodosRepository', () {
    late TodosApi api;

    final todos = [
      Todo(
        id: '1',
        title: 'title 1',
        description: 'description 1',
      ),
      Todo(
        id: '2',
        title: 'title 2',
        description: 'description 2',
      ),
      Todo(
        id: '3',
        title: 'title 3',
        description: 'description 3',
        isCompleted: true,
      ),
    ];

    final tags = [
      Tag(
        id: '1',
        title: 'Work',
      ),
      Tag(
        id: '2',
        title: 'Personal',
      ),
    ];

    setUpAll(() {
      registerFallbackValue(FakeTodo());
      registerFallbackValue(FakeTag());
    });

    setUp(() {
      api = MockTodosApi();
      when(() => api.getTodos()).thenAnswer((_) => Stream.value(todos));
      when(() => api.saveTodo(any())).thenAnswer((_) async {});
      when(() => api.deleteTodo(any())).thenAnswer((_) async {});
      when(
        () => api.clearCompleted(),
      ).thenAnswer((_) async => todos.where((todo) => todo.isCompleted).length);
      when(
        () => api.completeAll(isCompleted: any(named: 'isCompleted')),
      ).thenAnswer((_) async => 0);

      when(() => api.getTags()).thenAnswer((_) => Stream.value(tags));
      when(() => api.saveTag(any())).thenAnswer((_) async {});
      when(() => api.deleteTag(any())).thenAnswer((_) async {});
      when(() => api.getTodosByTag(any())).thenAnswer((invocation) async {
        final tagId = invocation.positionalArguments.first as String;
        return todos.where((todo) => todo.tagIds.contains(tagId)).toList();
      });
    });

    TodosRepository createSubject() => TodosRepository(todosApi: api);

    group('constructor', () {
      test('works properly', () {
        expect(
          createSubject,
          returnsNormally,
        );
      });
    });

    group('getTodos', () {
      test('makes correct api request', () {
        final subject = createSubject();

        expect(
          subject.getTodos(),
          isNot(throwsA(anything)),
        );

        verify(() => api.getTodos()).called(1);
      });

      test('returns stream of current list todos', () {
        expect(
          createSubject().getTodos(),
          emits(todos),
        );
      });
    });

    group('saveTodo', () {
      test('makes correct api request', () {
        final newTodo = Todo(
          id: '4',
          title: 'title 4',
          description: 'description 4',
        );

        final subject = createSubject();

        expect(subject.saveTodo(newTodo), completes);

        verify(() => api.saveTodo(newTodo)).called(1);
      });
    });

    group('deleteTodo', () {
      test('makes correct api request', () {
        final subject = createSubject();

        expect(subject.deleteTodo(todos[0].id), completes);

        verify(() => api.deleteTodo(todos[0].id)).called(1);
      });
    });

    group('clearCompleted', () {
      test('makes correct request', () {
        final subject = createSubject();

        expect(subject.clearCompleted(), completes);

        verify(() => api.clearCompleted()).called(1);
      });
    });

    group('completeAll', () {
      test('makes correct request', () {
        final subject = createSubject();

        expect(subject.completeAll(isCompleted: true), completes);

        verify(() => api.completeAll(isCompleted: true)).called(1);
      });
    });

    group('getTags', () {
      test('makes correct api request', () {
        final subject = createSubject();

        expect(
          subject.getTags(),
          isNot(throwsA(anything)),
        );

        verify(() => api.getTags()).called(1);
      });

      test('returns stream of current list tags', () {
        expect(
          createSubject().getTags(),
          emits(tags),
        );
      });
    });

    group('saveTag', () {
      test('makes correct api request', () {
        final newTag = Tag(
          id: '3',
          title: 'Urgent',
        );

        final subject = createSubject();

        expect(subject.saveTag(newTag), completes);

        verify(() => api.saveTag(newTag)).called(1);
      });
    });

    group('deleteTag', () {
      test('makes correct api request', () {
        final subject = createSubject();

        expect(subject.deleteTag(tags[0].id), completes);

        verify(() => api.deleteTag(tags[0].id)).called(1);
      });
    });

    group('getTodosByTag', () {
      test('makes correct api request', () async {
        final subject = createSubject();
        final tagId = '1';

        final todosConTag = [
          todos[0],
          todos[1],
        ];

        when(() => api.getTodosByTag(tagId)).thenAnswer((_) async => todosConTag);

        final result = await subject.getTodosByTag(tagId);

        expect(result, equals(todosConTag));
        verify(() => api.getTodosByTag(tagId)).called(1);
      });

      test('returns empty list when no todos have the tag', () async {
        final subject = createSubject();
        final tagId = '999';

        when(() => api.getTodosByTag(tagId)).thenAnswer((_) async => []);

        final result = await subject.getTodosByTag(tagId);

        expect(result, isEmpty);
        verify(() => api.getTodosByTag(tagId)).called(1);
      });
    });
  });
}
