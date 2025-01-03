import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/explore/bloc/explore_bloc.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../fakers/fake_tags.dart';
import '../../helpers/helpers.dart';

void main() {
  group('ExploreBloc', () {
    late TodosRepository todosRepository;

    setUpAll(() {
      registerFallbackValue(FakeTag());
    });
    setUp(() {
      todosRepository = MockTodosRepository();
    });

    ExploreBloc buildBloc() {
      return ExploreBloc(
        todosRepository: todosRepository,
        initialTag: null,
      );
    }

    group('constructor', () {
      test('works properly', () {
        expect(buildBloc, returnsNormally);
      });
    });

    test('has correct initial state', () {
      expect(
        buildBloc().state,
        equals(const ExploreState()),
      );
    });

    group('TagsSubscriptionRequested', () {
      blocTest<ExploreBloc, ExploreState>(
        'emits [loading, success] when getTags succeeds',
        setUp: () {
          when(() => todosRepository.getTags()).thenAnswer((_) => Stream.value(mockTags));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(const TagsSubscriptionRequested()),
        expect: () => [
          ExploreState(status: ExploreStatus.loading),
          ExploreState(
            status: ExploreStatus.success,
            tags: mockTags.toSet(),
          ),
        ],
        verify: (_) {
          verify(() => todosRepository.getTags()).called(1);
        },
      );
    });

    blocTest<ExploreBloc, ExploreState>(
      'emits [loading, failure] when getTags throws',
      setUp: () {
        when(() => todosRepository.getTags()).thenAnswer((_) => Stream.error(Exception('Error fetching tags')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(TagsSubscriptionRequested()),
      expect: () => [
        ExploreState(status: ExploreStatus.loading),
        ExploreState(status: ExploreStatus.failure),
      ],
      verify: (_) {
        verify(() => todosRepository.getTags()).called(1);
      },
    );

    group('TagDeleted', () {
      const tagIdToDelete = '1';

      blocTest<ExploreBloc, ExploreState>(
        'does not emit new states when deleteTag succeeds',
        setUp: () {
          when(() => todosRepository.deleteTag(tagIdToDelete)).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(TagDeleted(tagIdToDelete)),
        expect: () => [],
        verify: (_) {
          verify(() => todosRepository.deleteTag(tagIdToDelete)).called(1);
        },
      );

      blocTest<ExploreBloc, ExploreState>(
        'emits [failure] when deleteTag throws',
        setUp: () {
          when(() => todosRepository.deleteTag(tagIdToDelete)).thenThrow(Exception('Error deleting tag'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(TagDeleted(tagIdToDelete)),
        expect: () => [
          ExploreState(status: ExploreStatus.failure),
        ],
        verify: (_) {
          verify(() => todosRepository.deleteTag(tagIdToDelete)).called(1);
        },
      );
    });

    group('TagAdded', () {
      final tagToAdd = mockTags.first;

      blocTest<ExploreBloc, ExploreState>(
        'does not emit new states when saveTag succeeds',
        setUp: () {
          when(() => todosRepository.saveTag(tagToAdd)).thenAnswer((_) async {});
        },
        build: buildBloc,
        act: (bloc) => bloc.add(TagAdded(tagToAdd)),
        expect: () => [],
        verify: (_) {
          verify(() => todosRepository.saveTag(tagToAdd)).called(1);
        },
      );

      blocTest<ExploreBloc, ExploreState>(
        'emits [failure] when saveTag throws',
        setUp: () {
          when(() => todosRepository.saveTag(tagToAdd)).thenThrow(Exception('Error saving tag'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(TagAdded(tagToAdd)),
        expect: () => [
          ExploreState(status: ExploreStatus.failure),
        ],
        verify: (_) {
          verify(() => todosRepository.saveTag(tagToAdd)).called(1);
        },
      );
    });

    group('TagEdited', () {
      final tagToEdit = mockTags.first.copyWith(title: 'Updated Title');

      blocTest<ExploreBloc, ExploreState>(
        'emits failure state when saveTag throws',
        setUp: () {
          when(() => todosRepository.saveTag(any())).thenThrow(Exception('Error saving tag'));
        },
        build: buildBloc,
        act: (bloc) => bloc.add(TagEdited(mockTags.first.copyWith(title: 'Updated Title'))),
        expect: () => [
          ExploreState(status: ExploreStatus.failure),
        ],
      );

      blocTest<ExploreBloc, ExploreState>(
        'emits [failure] when an exception is thrown during TagEdited processing',
        build: () => ExploreBloc(
          todosRepository: todosRepository,
          initialTag: null,
        ),
        setUp: () {
          when(() => todosRepository.saveTag(tagToEdit)).thenThrow(Exception('Error editing tag'));
        },
        act: (bloc) => bloc.add(TagEdited(tagToEdit)),
        expect: () => [
          ExploreState(status: ExploreStatus.failure),
        ],
        verify: (_) {
          verify(() => todosRepository.saveTag(tagToEdit)).called(1);
        },
      );
    });

    group('AddTagName', () {
      const newTagName = 'New Tag Name';

      blocTest<ExploreBloc, ExploreState>(
        'emits state with updated title when AddTagName is added',
        build: buildBloc,
        act: (bloc) => bloc.add(AddTagName(newTagName)),
        expect: () => [
          ExploreState(
            title: newTagName,
            status: ExploreStatus.initial,
            tags: const {},
            color: '#FFFFFFFF',
            initialTag: null,
          ),
        ],
      );
    });

    group('AddTagSubmitted', () {
      const newTagName = 'New Tag Name';
      const newTagColor = '#FF0000';

      blocTest<ExploreBloc, ExploreState>(
        'creates a new tag when initialTag is null',
        setUp: () {
          when(() => todosRepository.saveTag(any())).thenAnswer((_) async {});
        },
        build: () => buildBloc(),
        seed: () => ExploreState(
          title: newTagName,
          color: newTagColor,
        ),
        act: (bloc) => bloc.add(AddTagSubmitted()),
        expect: () => [
          ExploreState(
            status: ExploreStatus.loading,
            title: newTagName,
            color: newTagColor,
          ),
          ExploreState(
            status: ExploreStatus.success,
            title: "",
            color: "#FFFFFFFF",
            initialTag: null,
          ),
        ],
        verify: (_) {
          // ÚNICA verificación que hace ambas cosas:
          final verification = verify(() => todosRepository.saveTag(captureAny()));
          verification.called(1);

          // Capturamos el argumento con el que se llamó
          final capturedArgs = verification.captured;
          expect(capturedArgs, hasLength(1));

          final capturedTag = capturedArgs.first as Tag;
          expect(capturedTag.title, equals(newTagName));
          expect(capturedTag.color, equals(newTagColor));
          expect(capturedTag.isArchived, isFalse);
          expect(capturedTag.todoIds, isEmpty);
        },
      );
    });
  });

  ;
}
