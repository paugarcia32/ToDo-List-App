import 'package:flutter_test/flutter_test.dart';
import 'package:todos_api/todos_api.dart';

class FakeTodo extends Fake implements Todo {}

final mockTodos = [
  Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
    tagIds: {'1', '2'},
    date: DateTime.now(),
    isCompleted: true,
  ),
  Todo(
    id: '2',
    title: 'title 2',
    description: 'description 2',
    tagIds: {'3'},
  ),
  Todo(
    id: '3',
    title: 'title 3',
    description: 'description 3',
    isCompleted: true,
    tagIds: {'4'},
  ),
];
