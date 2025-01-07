import 'package:bloc_test/bloc_test.dart';
import 'package:todo_app/todos_overview/bloc/tags_bloc/tags_bloc.dart';
import 'package:todo_app/todos_overview/bloc/todos_overview_bloc/todos_overview_bloc.dart';

class MockTodosOverviewBloc extends MockBloc<TodosOverviewEvent, TodosOverviewState> implements TodosOverviewBloc {}

class MockTagsBloc extends MockBloc<TagsEvent, TagsState> implements TagsBloc {}
