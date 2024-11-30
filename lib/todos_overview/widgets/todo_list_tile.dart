import 'package:flutter/material.dart';
import 'package:todo_app/todos_overview/widgets/todo_card.dart';
import 'package:todos_repository/todos_repository.dart';

class TodoListTile extends StatelessWidget {
  const TodoListTile({
    required this.todo,
    required this.isLast,
    this.onToggleCompleted,
    this.onDismissed,
    this.onTap,
    this.tagTitles,
    super.key,
  });

  final Todo todo;
  final bool isLast;
  final ValueChanged<bool>? onToggleCompleted;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;
  final List<String>? tagTitles;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('todoListTile_dismissible_${todo.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(context),
      child: TodoCard(
        todo: todo,
        isLast: isLast,
        onToggleCompleted: onToggleCompleted,
        onTap: onTap,
        tagTitles: tagTitles,
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
