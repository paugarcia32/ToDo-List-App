import 'package:flutter/material.dart';
import 'package:todos_api/todos_api.dart';

class TagCard extends StatelessWidget {
  const TagCard({
    required this.tag,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final Tag tag;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.tag,
                  size: 20,
                  color: Colors.purple,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tag.title,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  iconSize: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
