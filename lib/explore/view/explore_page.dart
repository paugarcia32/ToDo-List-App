import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/explore/bloc/explore_bloc.dart';
import 'package:todo_app/explore/widgets/addTagModal.dart';
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tags',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (bottomSheetContext) {
                          // Aquí obtenemos el ExploreBloc a partir del contexto principal
                          final exploreBloc = context.read<ExploreBloc>();

                          return BlocProvider.value(
                            value: exploreBloc,
                            child: const AddTagModal(),
                          );
                        },
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
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
                            onDelete: () {
                              context.read<ExploreBloc>().add(TagDeleted(tag.id));
                            },
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
