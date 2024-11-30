import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/edit_todo/edit_todo.dart';
import 'package:mockingjay/mockingjay.dart';
import 'package:todos_repository/todos_repository.dart';

import '../../helpers/helpers.dart';

class MockEditTodoBloc extends MockBloc<EditTodoEvent, EditTodoState> implements EditTodoBloc {}

void main() {
  late TodosRepository todosRepository;

  final mockTodo = Todo(
    id: '1',
    title: 'title 1',
    description: 'description 1',
    tags: ["work"],
  );

  late MockNavigator navigator;
  late EditTodoBloc editTodoBloc;

  setUp(() {
    todosRepository = MockTodosRepository();
    navigator = MockNavigator();
    when(() => navigator.canPop()).thenReturn(false);
    when(() => navigator.push<void>(any())).thenAnswer((_) async {});

    when(() => todosRepository.getTodos()).thenAnswer((_) => Stream.value([]));

    editTodoBloc = MockEditTodoBloc();
    when(() => editTodoBloc.state).thenReturn(
      EditTodoState(
        initialTodo: mockTodo,
        title: mockTodo.title,
        description: mockTodo.description,
        tags: [],
      ),
    );
  });

  group('EditTodoPage', () {
    Widget buildSubject() {
      return MockNavigatorProvider(
        navigator: navigator,
        child: BlocProvider.value(
          value: editTodoBloc,
          child: const EditTodoPage(),
        ),
      );
    }

    group('route', () {
      testWidgets('renders EditTodoPage', (tester) async {
        await tester.pumpRoute(EditTodoPage.route());
        expect(find.byType(EditTodoPage), findsOneWidget);
      });

      testWidgets('supports providing an initial todo', (tester) async {
        await tester.pumpRoute(
          EditTodoPage.route(
            initialTodo: Todo(
              id: 'initial-id',
              title: 'initial',
            ),
          ),
        );
        expect(find.byType(EditTodoPage), findsOneWidget);
        expect(
          find.widgetWithText(EditableText, 'initial'),
          findsOneWidget,
        );
      });
    });

    testWidgets('renders EditTodoView', (tester) async {
      await tester.pumpApp(buildSubject());

      expect(find.byType(EditTodoView), findsOneWidget);
    });

    testWidgets(
      'pops when a todo was saved successfully',
      (tester) async {
        whenListen<EditTodoState>(
          editTodoBloc,
          Stream.fromIterable([
            EditTodoState(),
            EditTodoState(
              status: EditTodoStatus.success,
            ),
          ]),
        );
        await tester.pumpApp(buildSubject());
        await tester.pumpAndSettle(); // Wait for any pending animations

        verify(() => navigator.pop<void>(any())).called(1);
      },
    );
  });

  group('EditTodoView', () {
    const titleTextFormFieldKey = Key('editTodoView_title_textFormField');
    const descriptionTextFormFieldKey = Key('editTodoView_description_textFormField');

    Widget buildSubject() {
      return BlocProvider.value(
        value: editTodoBloc,
        child: const EditTodoView(),
      );
    }

    testWidgets(
      'renders title text for new todos '
      'when a new todo is being created',
      (tester) async {
        when(() => editTodoBloc.state).thenReturn(const EditTodoState());
        await tester.pumpApp(buildSubject());

        expect(find.text(l10n.editTodoAddAppBarTitle), findsOneWidget);
      },
    );

    testWidgets(
      'renders title text for editing todos '
      'when an existing todo is being edited',
      (tester) async {
        when(() => editTodoBloc.state).thenReturn(
          EditTodoState(
            initialTodo: Todo(title: 'title'),
          ),
        );
        await tester.pumpApp(buildSubject());

        expect(find.text(l10n.editTodoEditAppBarTitle), findsOneWidget);
      },
    );

    group('title text form field', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byKey(titleTextFormFieldKey), findsOneWidget);
      });

      testWidgets('is disabled when loading', (tester) async {
        when(() => editTodoBloc.state).thenReturn(
          const EditTodoState(
            status: EditTodoStatus.loading,
          ),
        );
        await tester.pumpApp(buildSubject());

        final textField = tester.widget<TextFormField>(
          find.byKey(titleTextFormFieldKey),
        );
        expect(textField.enabled, false);
      });

      testWidgets(
        'adds EditTodoTitleChanged '
        'to EditTodoBloc '
        'when a new value is entered',
        (tester) async {
          await tester.pumpApp(buildSubject());
          await tester.enterText(
            find.byKey(titleTextFormFieldKey),
            'newtitle',
          );

          verify(
            () => editTodoBloc.add(const EditTodoTitleChanged('newtitle')),
          ).called(1);
        },
      );
    });

    group('description text form field', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byKey(descriptionTextFormFieldKey), findsOneWidget);
      });

      testWidgets('is disabled when loading', (tester) async {
        when(() => editTodoBloc.state).thenReturn(
          const EditTodoState(
            status: EditTodoStatus.loading,
          ),
        );
        await tester.pumpApp(buildSubject());

        final textField = tester.widget<TextFormField>(
          find.byKey(descriptionTextFormFieldKey),
        );
        expect(textField.enabled, false);
      });

      testWidgets(
        'adds EditTodoDescriptionChanged '
        'to EditTodoBloc '
        'when a new value is entered',
        (tester) async {
          await tester.pumpApp(buildSubject());
          await tester.enterText(
            find.byKey(descriptionTextFormFieldKey),
            'newdescription',
          );

          verify(
            () => editTodoBloc.add(const EditTodoDescriptionChanged('newdescription')),
          ).called(1);
        },
      );
    });

    group('tags field', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(find.byKey(const Key('editTodoView_tags_field')), findsOneWidget);
      });

      testWidgets('displays existing tags', (tester) async {
        when(() => editTodoBloc.state).thenReturn(
          EditTodoState(
            tags: ['work', 'urgent'],
          ),
        );

        await tester.pumpApp(buildSubject());

        expect(find.widgetWithText(InputChip, 'work'), findsOneWidget);
        expect(find.widgetWithText(InputChip, 'urgent'), findsOneWidget);
      });

      testWidgets('adds EditTodoTagsChanged when a tag is removed', (tester) async {
        when(() => editTodoBloc.state).thenReturn(
          EditTodoState(tags: ['work', 'urgent']),
        );

        await tester.pumpApp(buildSubject());

        // Find the InputChip for the 'work' tag
        final inputChipFinder = find.widgetWithText(InputChip, 'work');

        expect(inputChipFinder, findsOneWidget);

        // Find the delete icon within the InputChip
        final deleteIconFinder = find.descendant(
          of: inputChipFinder,
          matching: find.byIcon(Icons.cancel),
        );

        expect(deleteIconFinder, findsOneWidget);

        // Tap the delete icon
        await tester.tap(deleteIconFinder);

        await tester.pump();

        verify(
          () => editTodoBloc.add(EditTodoTagsChanged(['urgent'])),
        ).called(1);
      });
    });

    group('save button', () {
      testWidgets('is rendered', (tester) async {
        await tester.pumpApp(buildSubject());

        expect(
          find.widgetWithText(ElevatedButton, l10n.editTodoSaveButtonTooltip),
          findsOneWidget,
        );
      });

      testWidgets('is disabled when loading', (tester) async {
        when(() => editTodoBloc.state).thenReturn(
          const EditTodoState(
            status: EditTodoStatus.loading,
          ),
        );
        await tester.pumpApp(buildSubject());

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets(
        'adds EditTodoSubmitted '
        'to EditTodoBloc '
        'when tapped',
        (tester) async {
          await tester.pumpApp(buildSubject());
          await tester.tap(find.byType(ElevatedButton));

          verify(() => editTodoBloc.add(const EditTodoSubmitted())).called(1);
        },
      );
    });
  });
}
