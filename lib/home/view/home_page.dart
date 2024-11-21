import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/edit_todo/edit_todo.dart';
import 'package:todo_app/home/home.dart';
import 'package:todo_app/stats/stats.dart';
import 'package:todo_app/todos_overview/todos_overview.dart';

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
        body:
            // NavigationBar(destinations: const [TodosOverviewPage(), StatsPage()]),
            IndexedStack(
          index: selectedTab.index,
          children: const [TodosOverviewPage(), StatsPage()],
        ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          key: const Key('homeView_addTodo_floatingActionButton'),
          onPressed: () => Navigator.of(context).push(EditTodoPage.route()),
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
        ));
  }
}
