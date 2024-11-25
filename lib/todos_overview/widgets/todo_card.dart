import 'package:flutter/material.dart';
import 'package:todos_repository/todos_repository.dart';

class TodoCard extends StatelessWidget {
  const TodoCard({
    required this.todo,
    this.onToggleCompleted,
    this.onTap,
    super.key,
  });

  final Todo todo;
  final ValueChanged<bool>? onToggleCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.bodySmall?.color;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
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
              const SizedBox(width: 8),
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
                        if (onTap != null) const Icon(Icons.chevron_right),
                      ],
                    ),
                    if (todo.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          todo.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    if (todo.tags!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          children: todo.tags!
                              .map((tag) => InputChip(
                                    avatar: Icon(Icons.tag),
                                    label: Text(tag),
                                    labelStyle: TextStyle(color: captionColor),
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
    );
  }
}
