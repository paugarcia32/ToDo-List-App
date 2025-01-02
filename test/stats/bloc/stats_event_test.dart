import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/stats/stats.dart';

void main() {
  group('StatsEvent', () {
    group('TodosSubscriptionRequested', () {
      test('supports value equality', () {
        expect(
          TodosSubscriptionRequested(),
          equals(TodosSubscriptionRequested()),
        );
      });

      test('props are correct', () {
        expect(
          TodosSubscriptionRequested().props,
          equals(<Object?>[]),
        );
      });
    });

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
