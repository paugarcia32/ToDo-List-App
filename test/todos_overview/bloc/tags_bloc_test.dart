import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/todos_overview/bloc/tags_bloc.dart';
import 'package:todos_api/todos_api.dart';
import 'package:todos_repository/todos_repository.dart';

class MockTodosRepository extends Mock implements TodosRepository {}

class FakeTag extends Fake implements Tag {}

void main() {
  final mockTags = [
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

  group('TagsBloc', () {
    late TodosRepository todosRepository;

    setUpAll(() {
      registerFallbackValue(FakeTag());
    });

    setUp(() {
      todosRepository = MockTodosRepository();
      when(() => todosRepository.getTags()).thenAnswer((_) => Stream.value(mockTags));
      when(() => todosRepository.saveTag(any())).thenAnswer((_) async {});
      when(() => todosRepository.deleteTag(any())).thenAnswer((_) async {});
    });

    TagsBloc buildBloc() {
      return TagsBloc(todosRepository: todosRepository);
    }

    group('constructor', () {
      test('works properly', () => expect(buildBloc, returnsNormally));

      test('has correct initial state', () {
        expect(
          buildBloc().state,
          equals(const TagsState()),
        );
      });
    });

    group('TagsSubscriptionRequested', () {
      blocTest<TagsBloc, TagsState>(
        'starts listening to repository getTodos stream',
        build: buildBloc,
        act: (bloc) => bloc.add(const TagsSubscriptionRequested()),
        verify: (_) {
          verify(() => todosRepository.getTags()).called(1);
        },
      );

      blocTest<TagsBloc, TagsState>(
        'emits state with updated status and tags '
        'when repository getTags stream emits new tags',
        build: buildBloc,
        act: (bloc) => bloc.add(const TagsSubscriptionRequested()),
        expect: () => [
          const TagsState(
            status: TagsStatus.loading,
          ),
          TagsState(
            status: TagsStatus.success,
            tags: mockTags,
            tagIdToTitleMap: {
              '1': 'title 1',
              '2': 'title 2',
              '3': 'title 3',
            },
          )
        ],
      );
    });

    blocTest<TagsBloc, TagsState>(
      'emits state with updated status and tags '
      'when repository getTags stream emits new tags',
      build: buildBloc,
      act: (bloc) => bloc.add(const TagsSubscriptionRequested()),
      expect: () => [
        const TagsState(
          status: TagsStatus.loading,
        ),
        TagsState(
          status: TagsStatus.success,
          tags: mockTags,
          tagIdToTitleMap: {
            '1': 'title 1',
            '2': 'title 2',
            '3': 'title 3',
          },
        ),
      ],
    );

    blocTest<TagsBloc, TagsState>(
      'emits state with failure status '
      'when repository getTags stream emits error',
      setUp: () {
        when(() => todosRepository.getTags()).thenAnswer((_) => Stream.error(Exception('oops')));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(const TagsSubscriptionRequested()),
      expect: () => [
        const TagsState(status: TagsStatus.loading),
        const TagsState(status: TagsStatus.failure),
      ],
    );
  });
}
