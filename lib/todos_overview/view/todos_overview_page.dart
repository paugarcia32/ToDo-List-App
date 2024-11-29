import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:todo_app/edit_todo/view/edit_todo_page.dart';
import 'package:todo_app/l10n/l10n.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosOverviewPage extends StatelessWidget {
  const TodosOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final todosOverviewBloc = TodosOverviewBloc(
      todosRepository: context.read<TodosRepository>(),
    );

    todosOverviewBloc.add(const TodosOverviewTodosSubscriptionRequested());
    todosOverviewBloc.add(const TodosOverviewTagsSubscriptionRequested());

    return BlocProvider(
      create: (context) => todosOverviewBloc,
      child: const TodosOverviewView(),
    );
  }
}

class TodosOverviewView extends StatelessWidget {
  const TodosOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todosOverviewAppBarTitle),
        actions: const [
          TodosOverviewFilterButton(),
          TodosOverviewOptionsButton(),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) => previous.todosStatus != current.todosStatus,
            listener: (context, state) {
              if (state.todosStatus == TodosOverviewStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(l10n.todosOverviewErrorSnackbarText),
                    ),
                  );
              }
            },
          ),
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) => previous.tagsStatus != current.tagsStatus,
            listener: (context, state) {
              if (state.tagsStatus == TodosOverviewStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text('Error al cargar las etiquetas.'),
                    ),
                  );
              }
            },
          ),
        ],
        child: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
          builder: (context, state) {
            if (state.todosStatus == TodosOverviewStatus.loading || state.tagsStatus == TodosOverviewStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            } else if (state.todosStatus == TodosOverviewStatus.failure ||
                state.tagsStatus == TodosOverviewStatus.failure) {
              return Center(
                child: Text(
                  l10n.todosOverviewErrorSnackbarText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            } else if (state.todosWithTags.isEmpty) {
              return Center(
                child: Text(
                  l10n.todosOverviewEmptyText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }

            return CupertinoScrollbar(
              child: ListView.builder(
                itemCount: state.todosWithTags.length,
                itemBuilder: (_, index) {
                  final todoWithTags = state.todosWithTags[index];
                  final todo = todoWithTags.todo;
                  final tagTitles = todoWithTags.tagTitles;

                  return TodoListTile(
                    todo: todo,
                    isLast: index == state.todosWithTags.length - 1,
                    tagTitles: tagTitles,
                    onToggleCompleted: (isCompleted) {
                      context.read<TodosOverviewBloc>().add(
                            TodosOverviewTodoCompletionToggled(
                              todo: todo,
                              isCompleted: isCompleted,
                            ),
                          );
                    },
                    onDismissed: (_) {
                      context.read<TodosOverviewBloc>().add(TodosOverviewTodoDeleted(todo));
                    },
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (bottomSheetContext) {
                          return BlocProvider(
                            create: (context) => EditTodoBloc(
                              todosRepository: context.read<TodosRepository>(),
                              initialTodo: todo,
                            ),
                            child: BlocListener<EditTodoBloc, EditTodoState>(
                              listenWhen: (previous, current) =>
                                  previous.status != current.status && current.status == EditTodoStatus.success,
                              listener: (context, state) {
                                Navigator.of(bottomSheetContext).pop();
                              },
                              child: const EditTodoView(),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
