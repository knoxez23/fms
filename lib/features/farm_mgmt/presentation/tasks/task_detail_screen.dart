import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/contact_directory_service.dart';
import 'package:pamoja_twalima/features/business/presentation/sales/sales_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/animals/animal_feeding_calendar_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/animals/production_logging_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart';
import 'package:pamoja_twalima/features/inventory/presentation/inventory_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskEntity entity;
  final String currentRole;
  final String currentUserName;

  const TaskDetailScreen({
    super.key,
    required this.entity,
    this.currentRole = 'owner',
    this.currentUserName = 'Self',
  });

  const TaskDetailScreen.fromEntity({
    Key? key,
    required TaskEntity entity,
    String currentRole = 'owner',
    String currentUserName = 'Self',
  }) : this(
          key: key,
          entity: entity,
          currentRole: currentRole,
          currentUserName: currentUserName,
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = entity;
    final canApprove = _canApprove(currentRole);
    final canManageTask = _canManageTask(currentRole);
    final canCompleteTask = _canCompleteTask(item);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title: 'Task Details',
        variant: AppBarVariant.standard,
        actions: [
          if (canManageTask)
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
              task: item,
              originLabel: _originLabel(item.sourceEventType),
            ),
            const SizedBox(height: 16),
            if (item.approvalRequired) ...[
              _ApprovalCard(
                theme: theme,
                task: item,
                canApprove: canApprove,
                onApprove: item.isAwaitingApproval
                    ? () => _setApprovalStatus(context, item, 'approved')
                    : null,
                onReject: item.isAwaitingApproval
                    ? () => _setApprovalStatus(context, item, 'rejected')
                    : null,
              ),
              const SizedBox(height: 16),
            ],
            if (_workflowLabel(item) != null) ...[
              _WorkflowActionCard(
                theme: theme,
                label: _workflowLabel(item)!,
                message: _workflowMessage(item),
                onOpen: () => _openWorkflow(context, item),
              ),
              const SizedBox(height: 16),
            ],
            _ActionRow(
              theme: theme,
              task: item,
              canManageTask: canManageTask,
              canCompleteTask: canCompleteTask,
              onToggleStatus:
                  canCompleteTask ? () => _toggleStatus(context, item) : null,
              onDelete: canManageTask ? () => _deleteTask(context, item) : null,
              onAddCompletionNote: () => _captureCompletion(context, item),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleStatus(BuildContext context, TaskEntity task) {
    if (!task.isCompleted && task.approvalRequired && !task.isApproved) {
      _captureCompletion(context, task);
      return;
    }
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
      completionNotes: task.completionNotes,
      approvalRequired: task.approvalRequired,
      approvalStatus: task.approvalStatus,
      approvedBy: task.approvedBy,
      approvedAt: task.approvedAt,
      approvalComment: task.approvalComment,
    );
    context.read<TasksBloc>().add(TasksEvent.update(task: updated));
    Navigator.pop(context);
  }

  void _setApprovalStatus(
    BuildContext context,
    TaskEntity task,
    String status,
  ) async {
    final comment = await _promptForNote(
      context,
      title: status == 'approved' ? 'Approve Task' : 'Send Back for Changes',
      label:
          status == 'approved' ? 'Manager note' : 'What needs to be changed?',
      hint: status == 'approved'
          ? 'Optional sign-off note for the worker'
          : 'Tell the worker what still needs attention',
      required: status == 'rejected',
      initialValue: task.approvalComment,
    );
    if (comment == null) return;
    final updated = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      assignedTo: task.assignedTo,
      staffMemberId: task.staffMemberId,
      sourceEventType: task.sourceEventType,
      sourceEventId: task.sourceEventId,
      completionNotes: task.completionNotes,
      approvalRequired: task.approvalRequired,
      approvalStatus: status,
      approvedBy: status == 'approved' ? currentRole : null,
      approvedAt: status == 'approved' ? DateTime.now() : null,
      approvalComment: comment.trim().isEmpty ? null : comment.trim(),
    );
    if (!context.mounted) return;
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
      completionNotes: task.completionNotes,
      approvalRequired: task.approvalRequired,
      approvalStatus: task.approvalStatus,
      approvedBy: task.approvedBy,
      approvedAt: task.approvedAt,
      approvalComment: task.approvalComment,
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

  bool _canApprove(String role) {
    return const {'owner', 'manager', 'accountant'}
        .contains(role.trim().toLowerCase());
  }

  bool _canManageTask(String role) {
    return _canApprove(role);
  }

  bool _canCompleteTask(TaskEntity task) {
    if (_canManageTask(currentRole)) return true;
    if (task.assignedTo == null || task.assignedTo!.trim().isEmpty) return true;
    final assignee = task.assignedTo!.trim().toLowerCase();
    return assignee == 'self' ||
        assignee == currentUserName.trim().toLowerCase();
  }

  String? _workflowLabel(TaskEntity task) {
    switch (_workflowType(task)) {
      case _TaskWorkflowType.feeding:
        return 'Open feeding workspace';
      case _TaskWorkflowType.production:
        return 'Open production logging';
      case _TaskWorkflowType.inventory:
        return 'Open inventory workspace';
      case _TaskWorkflowType.sales:
        return 'Open business sales';
      case _TaskWorkflowType.none:
        return null;
    }
  }

  String _workflowMessage(TaskEntity task) {
    switch (_workflowType(task)) {
      case _TaskWorkflowType.feeding:
        return 'Log ration work directly from the feeding calendar so stock and care records stay linked.';
      case _TaskWorkflowType.production:
        return 'Go straight into production logging and turn output into stock or sales faster.';
      case _TaskWorkflowType.inventory:
        return 'Check stock levels or restock from the inventory workspace tied to this task.';
      case _TaskWorkflowType.sales:
        return 'Open the business workspace to follow up buyers, collections, or output sales.';
      case _TaskWorkflowType.none:
        return '';
    }
  }

  Future<void> _openWorkflow(BuildContext context, TaskEntity task) async {
    Widget? screen;
    switch (_workflowType(task)) {
      case _TaskWorkflowType.feeding:
        screen = const AnimalFeedingCalendarScreen();
        break;
      case _TaskWorkflowType.production:
        screen = const ProductionLoggingScreen();
        break;
      case _TaskWorkflowType.inventory:
        screen = const InventoryScreen();
        break;
      case _TaskWorkflowType.sales:
        screen = const SalesScreen();
        break;
      case _TaskWorkflowType.none:
        return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen!),
    );
    if (!context.mounted) return;
    context.read<TasksBloc>().add(const TasksEvent.load());
  }

  _TaskWorkflowType _workflowType(TaskEntity task) {
    final source = (task.sourceEventType ?? '').trim().toLowerCase();
    final text =
        '${task.title.value} ${task.description ?? ''}'.trim().toLowerCase();
    if (source == 'feeding' ||
        text.contains('feeding') ||
        text.contains('ration') ||
        text.contains('feed plan')) {
      return _TaskWorkflowType.feeding;
    }
    if (source == 'production' ||
        text.contains('production') ||
        text.contains('milk') ||
        text.contains('eggs')) {
      return _TaskWorkflowType.production;
    }
    if (source == 'inventory' ||
        text.contains('inventory') ||
        text.contains('stock') ||
        text.contains('restock')) {
      return _TaskWorkflowType.inventory;
    }
    if (source == 'sale' ||
        source == 'marketplace' ||
        text.contains('sale') ||
        text.contains('buyer') ||
        text.contains('collection') ||
        text.contains('payment')) {
      return _TaskWorkflowType.sales;
    }
    return _TaskWorkflowType.none;
  }

  Future<void> _captureCompletion(BuildContext context, TaskEntity task) async {
    final note = await _promptForNote(
      context,
      title: task.approvalRequired && !task.isApproved
          ? 'Mark Work Done'
          : (task.isCompleted ? 'Reopen Task' : 'Complete Task'),
      label: task.approvalRequired && !task.isApproved
          ? 'What was completed?'
          : 'Completion note',
      hint: task.approvalRequired && !task.isApproved
          ? 'Tell the manager what was done so they can review it quickly'
          : 'Optional note about what was done',
      required: task.approvalRequired && !task.isApproved && !task.isCompleted,
      initialValue: task.completionNotes,
    );
    if (note == null) return;

    final isCompleting = !task.isCompleted;
    final updated = TaskEntity(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: isCompleting,
      assignedTo: task.assignedTo,
      staffMemberId: task.staffMemberId,
      sourceEventType: task.sourceEventType,
      sourceEventId: task.sourceEventId,
      completionNotes: note.trim().isEmpty ? null : note.trim(),
      approvalRequired: task.approvalRequired,
      approvalStatus: task.approvalRequired
          ? (isCompleting ? 'pending' : task.approvalStatus)
          : task.approvalStatus,
      approvedBy:
          isCompleting && task.approvalRequired ? null : task.approvedBy,
      approvedAt:
          isCompleting && task.approvalRequired ? null : task.approvedAt,
      approvalComment:
          isCompleting && task.approvalRequired ? null : task.approvalComment,
    );
    if (!context.mounted) return;
    context.read<TasksBloc>().add(TasksEvent.update(task: updated));
    Navigator.pop(context);
  }

  Future<String?> _promptForNote(
    BuildContext context, {
    required String title,
    required String label,
    required String hint,
    required bool required,
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue ?? '');
    try {
      return await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          String? errorText;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text(title),
                content: TextField(
                  controller: controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    errorText: errorText,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, null),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (required && controller.text.trim().isEmpty) {
                        setDialogState(() {
                          errorText = 'Please add a note before continuing';
                        });
                        return;
                      }
                      Navigator.pop(dialogContext, controller.text);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }
  }
}

enum _TaskWorkflowType { none, feeding, production, inventory, sales }

class _TaskCard extends StatelessWidget {
  final ThemeData theme;
  final TaskEntity task;
  final String? originLabel;

  const _TaskCard({
    required this.theme,
    required this.task,
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
            task.title.value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            (task.description ?? '').isEmpty
                ? 'No description provided.'
                : task.description!,
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _badge(
                theme,
                task.isCompleted ? 'Completed' : 'Pending',
                task.isCompleted ? Colors.green : Colors.orange,
              ),
              if (task.isOverdue) _badge(theme, 'Overdue', Colors.red),
              if (task.approvalRequired)
                _badge(theme, _approvalLabel(task), _approvalColor(task)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                task.dueDate == null
                    ? 'No due date'
                    : '${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: task.isOverdue ? Colors.red : null,
                ),
              ),
            ],
          ),
          if (task.approvedAt != null && task.isApproved) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.verified, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Approved on ${task.approvedAt!.year}-${task.approvedAt!.month.toString().padLeft(2, '0')}-${task.approvedAt!.day.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
          if ((task.completionNotes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoPanel(
              icon: Icons.task_alt_outlined,
              title: 'Completion note',
              body: task.completionNotes!.trim(),
            ),
          ],
          if ((task.approvalComment ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            _InfoPanel(
              icon: Icons.feedback_outlined,
              title: task.isRejected ? 'Manager feedback' : 'Approval note',
              body: task.approvalComment!.trim(),
            ),
          ],
          const SizedBox(height: 10),
          _ReviewTimelineCard(
            theme: theme,
            task: task,
          ),
          if (task.assignedTo != null &&
              task.assignedTo!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Assigned to: ${task.assignedTo}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _approvalLabel(TaskEntity task) {
    switch (task.approvalStatus.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Needs changes';
      default:
        return 'Waiting approval';
    }
  }

  Color _approvalColor(TaskEntity task) {
    switch (task.approvalStatus.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.deepPurple;
    }
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

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.theme,
    required this.task,
    required this.canApprove,
    this.onApprove,
    this.onReject,
  });

  final ThemeData theme;
  final TaskEntity task;
  final bool canApprove;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  @override
  Widget build(BuildContext context) {
    final status = task.approvalStatus.toLowerCase();
    final headline = switch (status) {
      'approved' => 'This task has already been approved.',
      'rejected' => 'This task was sent back for changes before it can close.',
      _ => 'This task needs manager sign-off before it is fully cleared.',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Approval',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          if (!canApprove)
            Text(
              'A manager, owner, or accountant can review this from their queue.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          if (canApprove && task.isAwaitingApproval)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(Icons.reply_outlined),
                    label: const Text('Send Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('Approve'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ReviewTimelineCard extends StatelessWidget {
  const _ReviewTimelineCard({
    required this.theme,
    required this.task,
  });

  final ThemeData theme;
  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    final steps = <({IconData icon, String title, String detail, Color color})>[
      (
        icon: Icons.event_note_outlined,
        title: 'Scheduled',
        detail: task.dueDate == null
            ? 'No due date set yet.'
            : 'Due ${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}',
        color: theme.colorScheme.primary,
      ),
      if ((task.completionNotes ?? '').trim().isNotEmpty)
        (
          icon: Icons.task_alt_outlined,
          title: 'Worker submitted update',
          detail: task.completionNotes!.trim(),
          color: Colors.teal,
        ),
      if (task.isAwaitingApproval)
        (
          icon: Icons.hourglass_top_outlined,
          title: 'Waiting approval',
          detail: 'This task is complete on the worker side and now needs manager review.',
          color: Colors.deepPurple,
        ),
      if (task.isApproved && task.approvedAt != null)
        (
          icon: Icons.verified_outlined,
          title: 'Approved',
          detail:
              '${(task.approvedBy ?? 'Manager').trim().isEmpty ? 'Manager' : task.approvedBy} signed off on ${task.approvedAt!.year}-${task.approvedAt!.month.toString().padLeft(2, '0')}-${task.approvedAt!.day.toString().padLeft(2, '0')}.',
          color: Colors.green,
        ),
      if (task.isRejected)
        (
          icon: Icons.reply_outlined,
          title: 'Sent back',
          detail: (task.approvalComment ?? '').trim().isEmpty
              ? 'This task needs changes before it can close.'
              : task.approvalComment!.trim(),
          color: Colors.redAccent,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review timeline',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: step.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(step.icon, size: 17, color: step.color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step.detail,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowActionCard extends StatelessWidget {
  const _WorkflowActionCard({
    required this.theme,
    required this.label,
    required this.message,
    required this.onOpen,
  });

  final ThemeData theme;
  final String label;
  final String message;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Best next step',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(message, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new),
            label: Text(label),
          ),
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final ThemeData theme;
  final TaskEntity task;
  final bool canManageTask;
  final bool canCompleteTask;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;
  final VoidCallback onAddCompletionNote;

  const _ActionRow({
    required this.theme,
    required this.task,
    required this.canManageTask,
    required this.canCompleteTask,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onAddCompletionNote,
  });

  @override
  Widget build(BuildContext context) {
    final showComplete = canCompleteTask;
    final completeLabel = task.isCompleted
        ? 'Reopen'
        : task.approvalRequired && !task.isApproved
            ? 'Mark Done for Review'
            : 'Complete';
    return Column(
      children: [
        Row(
          children: [
            if (showComplete)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                      task.isCompleted ? Icons.refresh : Icons.check_circle),
                  label: Text(completeLabel),
                ),
              ),
            if (showComplete && canManageTask) const SizedBox(width: 12),
            if (canManageTask)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDelete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  label: const Text('Delete',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
          ],
        ),
        if (!task.isCompleted) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onAddCompletionNote,
              icon: const Icon(Icons.note_add_outlined),
              label: Text(
                (task.completionNotes ?? '').trim().isEmpty
                    ? 'Add worker note'
                    : 'Update worker note',
              ),
            ),
          ),
        ],
      ],
    );
  }
}
