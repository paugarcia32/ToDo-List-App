import 'package:flutter/material.dart';
import 'package:todos_repository/todos_repository.dart';

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
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                      value: todo.isCompleted,
                      onChanged: onToggleCompleted == null ? null : (value) => onToggleCompleted!(value!),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                      if (todo.tagIds.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            children: tagTitles!
                                .map((tag) => Text(
                                      tag,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontSize: 12,
                                        color: captionColor,
                                      ),
                                    ))
                                .toList(),
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
}
