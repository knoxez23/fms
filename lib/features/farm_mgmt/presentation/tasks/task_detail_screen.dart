import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/contact_directory_service.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskEntity entity;

  const TaskDetailScreen({
    super.key,
    required this.entity,
  });

  const TaskDetailScreen.fromEntity({
    Key? key,
    required TaskEntity entity,
  }) : this(key: key, entity: entity);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entity;
    final isCompleted = item.isCompleted;

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title: 'Task Details',
        variant: AppBarVariant.standard,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editTask(context, item),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TaskCard(
              theme: theme,
              title: item.title.value,
              description: item.description ?? '',
              dueDate: item.dueDate,
              isCompleted: item.isCompleted,
              isOverdue: item.isOverdue,
              assignedTo: item.assignedTo,
              originLabel: _originLabel(item.sourceEventType),
            ),
            const SizedBox(height: 16),
            _ActionRow(
              theme: theme,
              isCompleted: isCompleted,
              onToggleStatus: () => _toggleStatus(context, item),
              onDelete: () => _deleteTask(context, item),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleStatus(BuildContext context, TaskEntity task) {
    final updated = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: !task.isCompleted,
      assignedTo: task.assignedTo,
      staffMemberId: task.staffMemberId,
      sourceEventType: task.sourceEventType,
      sourceEventId: task.sourceEventId,
    );
    context.read<TasksBloc>().add(TasksEvent.update(task: updated));
    Navigator.pop(context);
  }

  void _deleteTask(BuildContext context, TaskEntity task) {
    final id = task.id;
    if (id == null || id.isEmpty) return;
    context.read<TasksBloc>().add(TasksEvent.delete(id: id));
    Navigator.pop(context);
  }

  Future<void> _editTask(BuildContext context, TaskEntity task) async {
    final service = ContactDirectoryService(ApiService());
    final rows = await service.list(ContactType.staffMember);
    final staffIdByName = {
      for (final row in rows)
        if ((row['name'] ?? '').toString().isNotEmpty &&
            (row['id'] ?? '').toString().isNotEmpty)
          (row['name'] ?? '').toString(): (row['id'] ?? '').toString(),
    };
    final names = {...staffIdByName.keys, 'Self'}.toList()..sort();
    String selected = task.assignedTo ?? 'Self';

    if (!context.mounted) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Task'),
              content: DropdownButtonFormField<String>(
                initialValue: names.contains(selected) ? selected : names.first,
                items: names
                    .map(
                      (name) => DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      ),
                    )
                    .toList(),
                decoration: const InputDecoration(labelText: 'Assign To'),
                onChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => selected = value);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
    if (ok != true) return;

    final updated = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      assignedTo: selected,
      staffMemberId: staffIdByName[selected],
      sourceEventType: task.sourceEventType,
      sourceEventId: task.sourceEventId,
    );
    if (!context.mounted) return;
    context.read<TasksBloc>().add(TasksEvent.update(task: updated));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task updated')),
    );
  }

  String? _originLabel(String? sourceEventType) {
    switch (sourceEventType) {
      case 'AnimalBred':
        return 'Breeding Follow-up';
      case 'CropHarvested':
        return 'Harvest Follow-up';
      case 'InventoryLowStock':
        return 'Low Stock Alert';
      default:
        return null;
    }
  }
}

class _TaskCard extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String description;
  final DateTime? dueDate;
  final bool isCompleted;
  final bool isOverdue;
  final String? assignedTo;
  final String? originLabel;

  const _TaskCard({
    required this.theme,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    required this.isOverdue,
    required this.assignedTo,
    required this.originLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description.isEmpty ? 'No description provided.' : description,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (originLabel != null) ...[
            Row(
              children: [
                Icon(Icons.link, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Origin: $originLabel',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              _badge(theme, isCompleted ? 'Completed' : 'Pending',
                  isCompleted ? Colors.green : Colors.orange),
              const SizedBox(width: 8),
              if (isOverdue) _badge(theme, 'Overdue', Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                dueDate == null
                    ? 'No due date'
                    : '${dueDate!.year}-${dueDate!.month.toString().padLeft(2, '0')}-${dueDate!.day.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isOverdue ? Colors.red : null,
                ),
              ),
            ],
          ),
          if (assignedTo != null && assignedTo!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.person_outline,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Assigned to: $assignedTo',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _badge(ThemeData theme, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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

class _ActionRow extends StatelessWidget {
  final ThemeData theme;
  final bool isCompleted;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;

  const _ActionRow({
    required this.theme,
    required this.isCompleted,
    required this.onToggleStatus,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onToggleStatus,
            icon: Icon(isCompleted ? Icons.refresh : Icons.check_circle),
            label: Text(isCompleted ? 'Reopen' : 'Complete'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onDelete,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            label: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
