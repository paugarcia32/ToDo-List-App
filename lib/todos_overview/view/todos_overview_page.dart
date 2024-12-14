import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/edit_todo/bloc/edit_todo_bloc.dart';
import 'package:todo_app/edit_todo/view/edit_todo_page.dart';
import 'package:todo_app/l10n/l10n.dart';
import 'package:todo_app/todos_overview/bloc/tags_bloc.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosOverviewPage extends StatelessWidget {
  const TodosOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => TodosOverviewBloc(
            todosRepository: context.read<TodosRepository>(),
          )..add(const TodosOverviewSubscriptionRequested()),
        ),
        BlocProvider(
          create: (_) => TagsBloc(
            todosRepository: context.read<TodosRepository>(),
          )..add(const TagsSubscriptionRequested()),
        ),
      ],
      child: const TodosOverviewView(),
    );
  }
}

class TodosOverviewView extends StatefulWidget {
  const TodosOverviewView({super.key});

  @override
  State<TodosOverviewView> createState() => _TodosOverviewViewState();
}

class _TodosOverviewViewState extends State<TodosOverviewView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == TodosOverviewStatus.failure) {
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
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == TodosOverviewStatus.failure) {
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
          builder: (context, todosState) {
            if (todosState.status == TodosOverviewStatus.loading) {
              return const Center(child: CupertinoActivityIndicator());
            }

            if (todosState.status == TodosOverviewStatus.failure) {
              return Center(
                child: Text(
                  l10n.todosOverviewErrorSnackbarText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }

            if (todosState.todos.isEmpty) {
              return Center(
                child: Text(
                  l10n.todosOverviewEmptyText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }

            return CupertinoScrollbar(
              controller: _scrollController,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: todosState.filteredTodos.length,
                itemBuilder: (_, index) {
                  final todo = todosState.filteredTodos.elementAt(index);

                  return TodoListTile(
                    todo: todo,
                    isLast: index == todosState.filteredTodos.length - 1,
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
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        key: const Key('todosOverview_addTodo_floatingActionButton'),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (bottomSheetContext) {
            return BlocProvider(
              create: (context) => EditTodoBloc(
                todosRepository: context.read<TodosRepository>(),
                initialTodo: null,
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
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
