import 'package:flutter/material.dart';
import 'package:todo_app/todos_overview/widgets/todo_card.dart';
import 'package:todos_repository/todos_repository.dart';

class TodoListTile extends StatelessWidget {
  const TodoListTile({
    required this.todo,
    super.key,
    this.onToggleCompleted,
    this.onDismissed,
    this.onTap,
  });

  final Todo todo;
  final ValueChanged<bool>? onToggleCompleted;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('todoListTile_dismissible_${todo.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(context),
      child: TodoCard(
        todo: todo,
        onToggleCompleted: onToggleCompleted,
        onTap: onTap,
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
