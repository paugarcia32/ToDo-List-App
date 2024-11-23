import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/edit_todo/edit_todo.dart';
import 'package:todo_app/home/home.dart';
import 'package:todo_app/stats/stats.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);

    return Scaffold(
      body: IndexedStack(
        index: selectedTab.index,
        children: const [TodosOverviewPage(), StatsPage()],
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        key: const Key('homeView_addTodo_floatingActionButton'),
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
                  Navigator.of(bottomSheetContext).pop(); // Cierra el Bottom Sheet
                },
                child: const EditTodoView(),
              ),
            );
          },
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_rounded),
            label: 'Todos',
          ),
          NavigationDestination(
            icon: Icon(Icons.show_chart_rounded),
            label: 'Stats',
          ),
        ],
        selectedIndex: selectedTab.index,
        onDestinationSelected: (index) {
          context.read<HomeCubit>().setTab(HomeTab.values[index]);
        },
      ),
    );
  }
}
