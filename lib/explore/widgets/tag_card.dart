import 'package:flutter/material.dart';
import 'package:todos_api/todos_api.dart';

class TagCard extends StatelessWidget {
  const TagCard({
    required this.tag,
    this.onTap,
    this.onDelete,
    this.onEdit,
    super.key,
  });

  final Tag tag;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

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
                Icon(
                  Icons.tag,
                  size: 20,
                  color: Color(int.parse(tag.color.substring(1), radix: 16) | 0xFF000000),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tag.title,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onEdit,
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
