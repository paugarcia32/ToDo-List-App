import 'package:flutter/material.dart';
import 'package:todos_api/todos_api.dart';
import 'tag_card.dart';

class TagListTile extends StatelessWidget {
  const TagListTile({
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
    return Dismissible(
      key: Key('tagListTile_dismissible_${tag.id}'),
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(context),
      child: TagCard(
        tag: tag,
        onTap: onTap,
        onDelete: onDelete,
      ),
    );
  }

  Widget _buildDismissBackground(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      alignment: Alignment.centerRight,
      color: theme.colorScheme.error,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: const Icon(
        Icons.delete,
        color: Color(0xAAFFFFFF),
      ),
    );
  }
}
