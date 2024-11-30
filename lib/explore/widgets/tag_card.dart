import 'package:flutter/material.dart';

class TagCard extends StatelessWidget {
  const TagCard({
    required this.tag,
    this.onTap,
    this.onDelete,
    super.key,
  });

  final String tag;
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
                    tag,
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
