// test/todos_overview/bloc/tags_state_test.dart

// ignore_for_file: prefer_const_constructors, avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/todos_overview/bloc/tags_bloc/tags_bloc.dart';
import 'package:todos_api/todos_api.dart';
import 'package:mocktail/mocktail.dart';
import '../../../fakers/fake_tags.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTag());
  });

  group('TagsState', () {
    TagsState createSubject({
      TagsStatus status = TagsStatus.initial,
      List<Tag>? tags,
      Map<String, String>? tagIdToTitleMap,
    }) {
      return TagsState(
        status: status,
        tags: tags ?? mockTags,
        tagIdToTitleMap: tagIdToTitleMap ??
            {
              for (var tag in mockTags) tag.id: tag.title,
            },
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
          status: TagsStatus.initial,
          tags: mockTags,
          tagIdToTitleMap: {
            '1': 'Urgente',
            '2': 'Personal',
            '3': 'Trabajo',
          },
        ).props,
        equals(<Object>[
          TagsStatus.initial,
          mockTags,
          {
            '1': 'Urgente',
            '2': 'Personal',
            '3': 'Trabajo',
          },
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
            tags: null,
            tagIdToTitleMap: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        final newTags = [
          Tag(
            id: '4',
            title: 'Estudio',
            isArchived: false,
            color: '#FFFF00',
            todoIds: {'6'},
          ),
        ];
        final newTagIdToTitleMap = {
          '4': 'Estudio',
        };

        expect(
          createSubject().copyWith(
            status: TagsStatus.success,
            tags: newTags,
            tagIdToTitleMap: newTagIdToTitleMap,
          ),
          equals(
            createSubject(
              status: TagsStatus.success,
              tags: newTags,
              tagIdToTitleMap: newTagIdToTitleMap,
            ),
          ),
        );
      });
    });

    test('can copyWith null tagIdToTitleMap', () {
      expect(
        createSubject(tagIdToTitleMap: {
          '1': 'Urgente',
          '2': 'Personal',
          '3': 'Trabajo',
        }).copyWith(
          tagIdToTitleMap: null,
        ),
        equals(createSubject(tagIdToTitleMap: {
          '1': 'Urgente',
          '2': 'Personal',
          '3': 'Trabajo',
        })),
      );
    });
  });
}
