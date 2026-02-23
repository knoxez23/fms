import 'package:flutter/material.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';

class TaskListItemCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final bool compact;
  final bool showOriginBadge;

  const TaskListItemCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.compact = false,
    this.showOriginBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = task.isOverdue;
    final isCompleted = task.isCompleted;
    final origin = _originLabel(task.sourceEventType);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 2 : 4,
        ),
        leading: Checkbox(
          value: isCompleted,
          onChanged: onToggleComplete == null ? null : (_) => onToggleComplete!(),
          activeColor: theme.colorScheme.primary,
        ),
        title: Text(
          task.title.value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!compact && (task.description?.isNotEmpty ?? false))
              Text(
                task.description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (!compact && (task.assignedTo?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 2),
              Text(
                'Assigned: ${task.assignedTo}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (!compact) const SizedBox(height: 4),
            Row(
              children: [
                _Badge(
                  label: _statusText(task),
                  color: _statusColor(task),
                ),
                if (showOriginBadge && origin != null && !compact) ...[
                  const SizedBox(width: 8),
                  _Badge(
                    label: origin,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Text(
          _dueLabel(task.dueDate),
          style: theme.textTheme.bodySmall?.copyWith(
            color: isOverdue ? Colors.red : theme.colorScheme.onSurface.withValues(alpha: 0.65),
            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  String _statusText(TaskEntity task) {
    if (task.isCompleted) return 'Completed';
    if (task.isOverdue) return 'Overdue';
    return 'Pending';
  }

  Color _statusColor(TaskEntity task) {
    if (task.isCompleted) return Colors.green;
    if (task.isOverdue) return Colors.red;
    return Colors.orange;
  }

  String? _originLabel(String? sourceEventType) {
    switch (sourceEventType) {
      case 'breeding':
      case 'AnimalBred':
        return 'Breeding';
      case 'feeding':
        return 'Feeding';
      case 'production':
        return 'Production';
      case 'CropHarvested':
        return 'Harvest';
      case 'InventoryLowStock':
        return 'Low Stock';
      default:
        return null;
    }
  }

  String _dueLabel(DateTime? date) {
    if (date == null) return 'No date';
    final today = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final t = DateTime(today.year, today.month, today.day);
    final delta = d.difference(t).inDays;
    if (delta == 0) return 'Today';
    if (delta == 1) return 'Tomorrow';
    if (delta == -1) return 'Yesterday';
    if (delta > 1) return 'In $delta days';
    return '${delta.abs()}d ago';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
