import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/explore/bloc/explore_bloc.dart';
import 'package:todo_app/explore/widgets/tag_list_tile.dart';
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
      child: const ExploreView(),
    );
  }
}

class ExploreView extends StatelessWidget {
  const ExploreView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exploreTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Tags',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16.0),
            Expanded(
              child: BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                  switch (state.status) {
                    case ExploreStatus.initial:
                      return Center(child: Text(l10n.initialStateMessage));
                    case ExploreStatus.loading:
                      return const Center(child: CircularProgressIndicator());
                    case ExploreStatus.failure:
                      return Center(child: Text(l10n.failureStateMessage));
                    case ExploreStatus.success:
                      if (state.tags.isEmpty) {
                        return Center(child: Text(l10n.noTagsAvailable));
                      }
                      return ListView.separated(
                        itemCount: state.tags.length,
                        itemBuilder: (context, index) {
                          final tag = state.tags.elementAt(index);
                          return TagListTile(
                            tag: tag,
                            onTap: () {},
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(height: 0.0),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
