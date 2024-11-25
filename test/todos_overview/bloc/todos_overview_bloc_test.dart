import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTodo extends Fake implements Todo {}

void main() {
  final mockTodos = [
    Todo(
      id: '1',
      title: 'title 1',
      description: 'description 1',
      tags: ['work', 'urgent'],
    ),
    Todo(
      id: '2',
      title: 'title 2',
      description: 'description 2',
      tags: ['personal', 'later'],
    ),
    Todo(
      id: '3',
      title: 'title 3',
      description: 'description 3',
      isCompleted: true,
      tags: ['shopping', 'important', 'Prueba'],
    ),
  ];

  group('TodosOverviewBloc', () {
    late TodosRepository todosRepository;

    setUpAll(() {
      registerFallbackValue(FakeTodo());
    });

    setUp(() {
      todosRepository = MockTodosRepository();
      when(() => todosRepository.getTodos()).thenAnswer((_) => Stream.value(mockTodos));
      when(() => todosRepository.saveTodo(any())).thenAnswer((_) async {});
      when(() => todosRepository.deleteTodo(any())).thenAnswer((_) async {});
    });

    TodosOverviewBloc buildBloc() {
      return TodosOverviewBloc(todosRepository: todosRepository);
    }

    group('constructor', () {
      test('works properly', () => expect(buildBloc, returnsNormally));

      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const TodosOverviewState()),
        );
      });
    });

    group('TodosOverviewSubscriptionRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'starts listening to repository getTodos stream',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        verify: (_) {
          verify(() => todosRepository.getTodos()).called(1);
        },
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with updated status and todos '
        'when repository getTodos stream emits new todos',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        expect: () => [
          const TodosOverviewState(
            status: TodosOverviewStatus.loading,
          ),
          TodosOverviewState(
            status: TodosOverviewStatus.success,
            todos: mockTodos,
          ),
        ],
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with failure status '
        'when repository getTodos stream emits error',
        setUp: () {
          when(() => todosRepository.getTodos()).thenAnswer((_) => Stream.error(Exception('oops')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewSubscriptionRequested()),
        expect: () => [
          const TodosOverviewState(status: TodosOverviewStatus.loading),
          const TodosOverviewState(status: TodosOverviewStatus.failure),
        ],
      );
    });

    group('TodosOverviewTodoCompletionToggled', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'saves todo with isCompleted set to event isCompleted flag and preserves tags',
        build: buildBloc,
        seed: () => TodosOverviewState(todos: mockTodos),
        act: (bloc) => bloc.add(
          TodosOverviewTodoCompletionToggled(
            todo: mockTodos.first,
            isCompleted: true,
          ),
        ),
        verify: (_) {
          final expectedTodo = mockTodos.first.copyWith(isCompleted: true);
          verify(() => todosRepository.saveTodo(expectedTodo)).called(1);
          expect(expectedTodo.tags, equals(mockTodos.first.tags));
        },
      );
    });

    group('TodosOverviewTodoDeleted', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'deletes todo using repository and stores lastDeletedTodo with correct tags',
        build: buildBloc,
        seed: () => TodosOverviewState(todos: mockTodos),
        act: (bloc) => bloc.add(TodosOverviewTodoDeleted(mockTodos.first)),
        expect: () => [
          TodosOverviewState(
            todos: mockTodos,
            lastDeletedTodo: mockTodos.first,
          ),
        ],
        verify: (bloc) {
          verify(() => todosRepository.deleteTodo(mockTodos.first.id)).called(1);
          expect(bloc.state.lastDeletedTodo?.tags, equals(['work', 'urgent']));
        },
      );
    });

    group('TodosOverviewUndoDeletionRequested', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'restores last deleted todo with correct tags and clears lastDeletedTodo field',
        build: buildBloc,
        seed: () => TodosOverviewState(lastDeletedTodo: mockTodos.first),
        act: (bloc) => bloc.add(const TodosOverviewUndoDeletionRequested()),
        expect: () => const [TodosOverviewState()],
        verify: (_) {
          verify(() => todosRepository.saveTodo(mockTodos.first)).called(1);
          expect(mockTodos.first.tags, equals(['work', 'urgent']));
        },
      );
    });

    group('TodosOverviewFilterChanged', () {
      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'emits state with updated filter',
        build: buildBloc,
        act: (bloc) => bloc.add(
          const TodosOverviewFilterChanged(TodosViewFilter.completedOnly),
        ),
        expect: () => const [
          TodosOverviewState(filter: TodosViewFilter.completedOnly),
        ],
      );
    });

    group('TodosOverviewToggleAllRequested', () {
      setUp(() {
        when(
          () => todosRepository.completeAll(
            isCompleted: any(named: 'isCompleted'),
          ),
        ).thenAnswer((_) async => 0);
      });

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'toggles all todos to completed when some or none are uncompleted',
        build: buildBloc,
        seed: () => TodosOverviewState(todos: mockTodos),
        act: (bloc) => bloc.add(const TodosOverviewToggleAllRequested()),
        verify: (_) {
          verify(
            () => todosRepository.completeAll(isCompleted: true),
          ).called(1);
        },
      );

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'toggles all todos to uncompleted when all are completed',
        build: buildBloc,
        seed: () => TodosOverviewState(
          todos: mockTodos.map((todo) => todo.copyWith(isCompleted: true)).toList(),
        ),
        act: (bloc) => bloc.add(const TodosOverviewToggleAllRequested()),
        verify: (_) {
          verify(
            () => todosRepository.completeAll(isCompleted: false),
          ).called(1);
        },
      );
    });

    group('TodosOverviewClearCompletedRequested', () {
      setUp(() {
        when(() => todosRepository.clearCompleted()).thenAnswer((_) async => 0);
      });

      blocTest<TodosOverviewBloc, TodosOverviewState>(
        'clears completed todos using repository',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosOverviewClearCompletedRequested()),
        verify: (_) {
          verify(() => todosRepository.clearCompleted()).called(1);
        },
      );
    });

    group('TodosOverviewState', () {
      test('filteredTodos returns all todos when no filter is applied', () {
        final state = TodosOverviewState(todos: mockTodos);
        expect(state.filteredTodos, equals(mockTodos));
      });

      test('filteredTodos filters by status and preserves tags', () {
        final state = TodosOverviewState(
          todos: mockTodos,
          filter: TodosViewFilter.completedOnly,
        );
        final expectedTodos = mockTodos.where((todo) => todo.isCompleted).toList();
        expect(state.filteredTodos, equals(expectedTodos));

        for (var todo in state.filteredTodos) {
          final originalTodo = mockTodos.firstWhere((t) => t.id == todo.id);
          expect(todo.tags, equals(originalTodo.tags));
        }
      });

      test('filteredTodos preserves tags when filtering by status', () {
        final state = TodosOverviewState(
          todos: mockTodos,
          filter: TodosViewFilter.activeOnly,
        );
        final expectedTodos = mockTodos.where((todo) => !todo.isCompleted).toList();
        expect(state.filteredTodos, equals(expectedTodos));

        for (var todo in state.filteredTodos) {
          final originalTodo = mockTodos.firstWhere((t) => t.id == todo.id);
          expect(todo.tags, equals(originalTodo.tags));
        }
      });
    });
  });
}
