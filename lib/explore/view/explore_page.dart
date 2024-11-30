import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/explore/bloc/explore_bloc.dart';
import 'package:todo_app/l10n/l10n.dart';
import 'package:todos_repository/todos_repository.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreBloc(
        todosRepository: context.read<TodosRepository>(),
      )..add(const TagsSubscriptionRequested()),
      child: ExploreView(),
    );
  }
}

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<ExploreBloc>().state;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("data"),
      ),
      body: BlocBuilder<ExploreBloc, ExploreState>(
        builder: (context, state) {
          switch (state.status) {
            case ExploreStatus.initial:
              return Center(
                child: Text(
                  "l10n.initialStateMessage",
                  // style: textTheme.subtitle1,
                ),
              );
            case ExploreStatus.loading:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ExploreStatus.success:
              if (state.tags.isEmpty) {
                return Center(
                  child: Text(
                    "l10n.noTagsAvailable",
                    // style: textTheme.subtitle1,
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.tags.length,
                itemBuilder: (context, index) {
                  final tag = state.tags.elementAt(index);
                  return Text(
                    tag,
                    // style: textTheme.subtitle1,
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 8.0),
              );
            case ExploreStatus.failure:
              return Center(
                child: Text(
                  "l10n.failureStateMessage",
                  // style: textTheme.subtitle1?.copyWith(color: Colors.red),
                ),
              );
          }
        },
      ),
    );
  }
}
