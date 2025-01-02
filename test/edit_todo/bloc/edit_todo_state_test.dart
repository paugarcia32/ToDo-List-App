import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/edit_todo/edit_todo.dart';
import 'package:todos_api/todos_api.dart';

import '../../fakers/fake_tags.dart';
import '../../fakers/fake_todos.dart';

void main() {
  group('EditTodoState', () {
    EditTodoState createSubject({
      EditTodoStatus status = EditTodoStatus.initial,
      Todo? initialTodo,
      String title = '',
      String description = '',
      Set<Tag> selectedTags = const {},
      DateTime? date,
    }) {
      return EditTodoState(
        status: status,
        initialTodo: initialTodo,
        title: title,
        description: description,
        selectedTags: selectedTags,
        date: date,
      );
    }

    test('supports value equality', () {
      expect(
        createSubject(),
        equals(createSubject()),
      );
    });

    test('props are correct', () {
      // Fijamos la fecha en una variable para poder compararla exactamente.
      final fixedDate = DateTime(2025, 1, 2);

      // Usamos mockTodos[0] en createSubject y esperamos lo mismo en equals
      expect(
        createSubject(
          status: EditTodoStatus.initial,
          initialTodo: mockTodos[0],
          title: 'title 1',
          description: 'description 1',
          // Dos tags simulados:
          selectedTags: {mockTags[0], mockTags[1]},
          date: fixedDate,
        ).props,
        equals(<Object?>[
          EditTodoStatus.initial,
          mockTodos[0], // Ojo: mismo Todo que en createSubject
          'title 1',
          'description 1',
          {mockTags[0], mockTags[1]}, // Se compara el Set exactamente
          fixedDate, // Misma instancia de la fecha
        ]),
      );
    });

    test('isNewTodo returns true when a new todo is being created', () {
      expect(
        createSubject(
          initialTodo: null,
        ).isNewTodo,
        isTrue,
      );
    });

    group('copyWith', () {
      test('returns the same object if not arguments are provided', () {
        expect(
          createSubject().copyWith(),
          equals(createSubject()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          createSubject().copyWith(
            status: null,
            initialTodo: null,
            title: null,
            description: null,
          ),
          equals(createSubject()),
        );
      });

      test('replaces every non-null parameter', () {
        final fixedDate = DateTime(2025, 1, 2);

        final newTags = {mockTags[0], mockTags[1]};

        expect(
          createSubject().copyWith(
            status: EditTodoStatus.success,
            initialTodo: mockTodos[0],
            title: 'title',
            description: 'description',
            selectedTags: newTags,
            date: fixedDate,
          ),
          equals(
            createSubject(
              status: EditTodoStatus.success,
              initialTodo: mockTodos[0],
              title: 'title',
              description: 'description',
              selectedTags: newTags,
              date: fixedDate,
            ),
          ),
        );
      });
    });
  });
}
