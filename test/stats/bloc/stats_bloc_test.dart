import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/stats/stats.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../fakers/fake_tags.dart';
import '../../fakers/fake_todos.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

void main() {
  group('StatsBloc', () {
    late TodosRepository todosRepository;
    setUpAll(() {
      registerFallbackValue(mockTodos);
      registerFallbackValue(mockTags);
    });

    setUp(() {
      todosRepository = MockTodosRepository();
      when(() => todosRepository.getTodos()).thenAnswer((_) => const Stream.empty());
      when(() => todosRepository.getTags()).thenAnswer((_) => const Stream.empty());
    });

    StatsBloc buildBloc() => StatsBloc(todosRepository: todosRepository);

    group('constructor', () {
      test('funciona correctamente', () {
        expect(buildBloc, returnsNormally);
      });

      test('tiene el estado inicial correcto', () {
        expect(buildBloc().state, equals(const StatsState()));
      });
    });

    group('TodosSubscriptionRequested', () {
      blocTest<StatsBloc, StatsState>(
        'inicia la suscripción al stream de getTodos() del repositorio',
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosSubscriptionRequested()),
        verify: (_) {
          verify(() => todosRepository.getTodos()).called(1);
        },
      );

      blocTest<StatsBloc, StatsState>(
        'emite [loading, success] con completedTodos y activeTodos actualizados '
        'cuando getTodos() emite nuevos todos',
        setUp: () {
          when(() => todosRepository.getTodos()).thenAnswer((_) => Stream.value([mockTodos[1]]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosSubscriptionRequested()),
        expect: () => <StatsState>[
          const StatsState(status: StatsStatus.loading),
          const StatsState(status: StatsStatus.success, activeTodos: 1, completedTodos: 0),
        ],
      );

      blocTest<StatsBloc, StatsState>(
        'emite [loading, failure] cuando getTodos() emite un error',
        setUp: () {
          when(() => todosRepository.getTodos()).thenAnswer((_) => Stream.error(Exception('oops')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TodosSubscriptionRequested()),
        expect: () => <StatsState>[
          const StatsState(status: StatsStatus.loading),
          const StatsState(status: StatsStatus.failure),
        ],
      );
    });

    group('TagsSubscriptionRequested', () {
      blocTest<StatsBloc, StatsState>(
        'inicia la suscripción al stream de getTags() del repositorio',
        build: buildBloc,
        act: (bloc) => bloc.add(const TagsSubscriptionRequested()),
        verify: (_) {
          verify(() => todosRepository.getTags()).called(1);
        },
      );

      blocTest<StatsBloc, StatsState>(
        'emite [loading, success] con totalTags actualizado '
        'cuando getTags() emite nuevas tags',
        setUp: () {
          when(() => todosRepository.getTags()).thenAnswer((_) => Stream.value([mockTags[1]]));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TagsSubscriptionRequested()),
        expect: () => <StatsState>[
          const StatsState(status: StatsStatus.loading),
          const StatsState(status: StatsStatus.success, totalTags: 1),
        ],
      );

      blocTest<StatsBloc, StatsState>(
        'emite [loading, failure] cuando getTags() emite un error',
        setUp: () {
          when(() => todosRepository.getTags()).thenAnswer((_) => Stream.error(Exception('oops')));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TagsSubscriptionRequested()),
        expect: () => <StatsState>[
          const StatsState(status: StatsStatus.loading),
          const StatsState(status: StatsStatus.failure),
        ],
      );
    });
  });
}
