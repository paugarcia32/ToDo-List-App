import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/l10n/l10n.dart';
import 'package:todo_app/stats/stats.dart';
import 'package:todos_repository/todos_repository.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StatsBloc(
        todosRepository: context.read<TodosRepository>(),
      )
        ..add(const TodosSubscriptionRequested())
        ..add(const TagsSubscriptionRequested()),
      child: const StatsView(),
    );
  }
}

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<StatsBloc>().state;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statsAppBarTitle),
      ),
      body: Column(
        children: [
          if (state.status == StatsStatus.loading) const Center(child: CircularProgressIndicator()),
          if (state.status == StatsStatus.failure) const Center(child: Text('Error loading data')),
          if (state.status == StatsStatus.success) ...[
            _buildStatsTile(
              key: const Key('statsView_completedTodos_listTile'),
              icon: Icons.check_rounded,
              label: l10n.statsCompletedTodoCountLabel,
              value: '${state.completedTodos}',
              textTheme: textTheme,
            ),
            _buildStatsTile(
              key: const Key('statsView_activeTodos_listTile'),
              icon: Icons.radio_button_unchecked_rounded,
              label: l10n.statsActiveTodoCountLabel,
              value: '${state.activeTodos}',
              textTheme: textTheme,
            ),
            _buildStatsTile(
              key: const Key('statsView_totalTags_listTile'),
              icon: Icons.tag,
              label: "Unique Tags Count",
              value: '${state.totalTags}',
              textTheme: textTheme,
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildStatsTile({
    required Key key,
    required IconData icon,
    required String label,
    required String value,
    required TextTheme textTheme,
  }) {
    return ListTile(
      key: key,
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: textTheme.headlineSmall,
      ),
    );
  }
}
