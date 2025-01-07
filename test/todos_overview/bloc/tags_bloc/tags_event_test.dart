import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/todos_overview/bloc/tags_bloc/tags_bloc.dart';

void main() {
  group('TagsEvent', () {
    group('TagsSubscriptionRequested', () {
      test('supports value equality', () {
        expect(
          TagsSubscriptionRequested(),
          equals(TagsSubscriptionRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TagsSubscriptionRequested().props,
          equals(<Object?>[]),
        );
      });
    });
  });
}
