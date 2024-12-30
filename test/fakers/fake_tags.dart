import 'package:flutter_test/flutter_test.dart';
import 'package:todos_api/todos_api.dart';

class FakeTag extends Fake implements Tag {}

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
