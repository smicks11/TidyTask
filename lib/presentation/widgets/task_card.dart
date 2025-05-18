import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration: task.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      task.isCompleted 
                          ? Icons.check_circle 
                          : Icons.check_circle_outline,
                      color: task.isCompleted 
                          ? theme.colorScheme.primary 
                          : null,
                    ),
                    onPressed: onComplete,
                  ),
                ],
              ),
              if (task.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPriorityChip(theme),
                  if (task.deadline != null) ...[
                    const SizedBox(width: 8),
                    _buildDeadlineChip(theme),
                  ],
                ],
              ),
              if (task.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: task.tags.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: theme.textTheme.bodySmall,
                    ),
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(ThemeData theme) {
    final color = _getPriorityColor(theme);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        task.priority.toString().split('.').last,
        style: theme.textTheme.bodySmall?.copyWith(color: color),
      ),
    );
  }

  Widget _buildDeadlineChip(ThemeData theme) {
    final isOverdue = task.deadline!.isBefore(DateTime.now());
    final color = isOverdue ? theme.colorScheme.error : theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '${task.deadline!.day}/${task.deadline!.month}/${task.deadline!.year}',
            style: theme.textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(ThemeData theme) {
    switch (task.priority) {
      case TaskPriority.high:
        return theme.colorScheme.error;
      case TaskPriority.medium:
        return theme.colorScheme.tertiary;
      case TaskPriority.low:
        return theme.colorScheme.secondary;
      case TaskPriority.urgent:
        
        throw UnimplementedError();
    }
  }
}