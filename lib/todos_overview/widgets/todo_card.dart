import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/todos_overview/bloc/tags_bloc.dart';
import 'package:todos_api/todos_api.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    required this.todo,
    required this.isLast,
    this.onToggleCompleted,
    this.onTap,
    super.key,
    this.tagTitles,
  });

  final Todo todo;
  final bool isLast;
  final ValueChanged<bool>? onToggleCompleted;
  final VoidCallback? onTap;
  final List<String>? tagTitles;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.bodySmall?.color?.withOpacity(0.6);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  value: todo.isCompleted,
                  onChanged: onToggleCompleted == null ? null : (value) => onToggleCompleted!(value!),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              todo.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: !todo.isCompleted
                                  ? theme.textTheme.titleMedium
                                  : theme.textTheme.titleMedium?.copyWith(
                                      color: captionColor,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                            ),
                          ),
                          if (onTap != null) const Icon(Icons.chevron_right, size: 18),
                        ],
                      ),
                      if (todo.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            todo.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      if (todo.tagIds.isNotEmpty || todo.date != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: todo.tagIds.isNotEmpty ? TagChips(tagIds: todo.tagIds) : const SizedBox.shrink(),
                              ),
                              if (todo.date != null)
                                Text(
                                  _formatDate(todo.date!),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontSize: 12,
                                    color: captionColor,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(thickness: 0.5, indent: 16, endIndent: 16),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

class TagChips extends StatelessWidget {
  const TagChips({required this.tagIds, Key? key}) : super(key: key);

  final Set<String> tagIds;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.bodySmall?.color?.withOpacity(0.6);

    return BlocSelector<TagsBloc, TagsState, Map<String, String>>(
      selector: (state) => state.tagIdToTitleMap,
      builder: (context, tagIdToTitleMap) {
        final tagTitles = tagIds.map((id) => tagIdToTitleMap[id] ?? 'Unknown').toList();

        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: tagTitles
              .map(
                (tag) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      color: captionColor,
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
