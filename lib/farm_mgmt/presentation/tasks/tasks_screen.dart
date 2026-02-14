import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/animations/animated_card.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'task_calendar_screen.dart';
import 'package:pamoja_twalima/farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/task_entity.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'All';
  String _selectedStatus = 'All';

  final List<String> _filters = [
    'All',
    'Auto-generated',
    'Crops',
    'Animals',
    'Poultry',
    'Vegetables',
    'Maintenance',
    'Administrative'
  ];

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'Overdue',
    'Completed'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => getIt<TasksBloc>()..add(const TasksEvent.load()),
      child: BlocConsumer<TasksBloc, TasksState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        builder: (context, state) {
          final tasks = state.maybeWhen<List<TaskEntity>>(
            loaded: (items) => items,
            orElse: () => <TaskEntity>[],
          );

          final filteredTasks = tasks.where((task) {
            final categoryMatch = _selectedFilter == 'All'
                ? true
                : _selectedFilter == 'Auto-generated'
                    ? task.sourceEventType != null &&
                        task.sourceEventType!.isNotEmpty
                    : _taskCategory(task) == _selectedFilter;
            final statusMatch = _selectedStatus == 'All' ||
                _statusLabel(task) == _selectedStatus;
            return categoryMatch && statusMatch;
          }).toList();

          final pendingCount =
              tasks.where((task) => _statusKey(task) == 'pending').length;
          final overdueCount =
              tasks.where((task) => _statusKey(task) == 'overdue').length;
          final completedCount =
              tasks.where((task) => _statusKey(task) == 'completed').length;

          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            body: CustomScrollView(
              slivers: [
                // Header with task stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        _TaskStat(
                          count: pendingCount,
                          label: 'Pending',
                          color: Colors.orange,
                          theme: theme,
                        ),
                        const SizedBox(width: 12),
                        _TaskStat(
                          count: overdueCount,
                          label: 'Overdue',
                          color: Colors.red,
                          theme: theme,
                        ),
                        const SizedBox(width: 12),
                        _TaskStat(
                          count: completedCount,
                          label: 'Completed',
                          color: Colors.green,
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TaskFilterDropdown(
                            value: _selectedFilter,
                            items: _filters,
                            onChanged: (value) =>
                                setState(() => _selectedFilter = value!),
                            theme: theme,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TaskFilterDropdown(
                            value: _selectedStatus,
                            items: _statusOptions,
                            onChanged: (value) =>
                                setState(() => _selectedStatus = value!),
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Tasks List (SliverList instead of ListView)
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = filteredTasks[index];
                        return AnimatedCard(
                          index: index,
                          child: _TaskItem(
                            task: task,
                            theme: theme,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      TaskDetailScreen.fromEntity(entity: task),
                                ),
                              );
                            },
                            onToggleComplete: () {
                              final updated = TaskEntity(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                dueDate: task.dueDate,
                                isCompleted: !task.isCompleted,
                                sourceEventType: task.sourceEventType,
                                sourceEventId: task.sourceEventId,
                              );
                              context
                                  .read<TasksBloc>()
                                  .add(TasksEvent.update(task: updated));
                            },
                          ),
                        );
                      },
                      childCount: filteredTasks.length,
                    ),
                  ),
                ),

                // Add extra space at bottom so FABs don't overlap content
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),

            // Floating action buttons
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'calendar',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TaskCalendarScreen()),
                      );
                    },
                    backgroundColor: theme.colorScheme.secondary,
                    mini: true,
                    child:
                        const Icon(Icons.calendar_today, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'addTaskFAB',
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddTaskScreen()),
                      );
                      if (result is! TaskEntity) return;
                      if (!context.mounted) return;
                      context
                          .read<TasksBloc>()
                          .add(TasksEvent.add(task: result));
                    },
                    backgroundColor: theme.colorScheme.primary,
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusKey(TaskEntity task) {
    if (task.isCompleted) return 'completed';
    if (task.isOverdue) return 'overdue';
    return 'pending';
  }

  String _statusLabel(TaskEntity task) {
    switch (_statusKey(task)) {
      case 'pending':
        return 'Pending';
      case 'overdue':
        return 'Overdue';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  String _taskCategory(TaskEntity task) {
    final text = '${task.title.value} ${task.description ?? ''}'.toLowerCase();
    if (text.contains('crop') ||
        text.contains('harvest') ||
        text.contains('irrigat')) {
      return 'Crops';
    }
    if (text.contains('animal') || text.contains('livestock')) return 'Animals';
    if (text.contains('poultry') ||
        text.contains('chicken') ||
        text.contains('egg')) {
      return 'Poultry';
    }
    if (text.contains('vegetable') || text.contains('garden')) {
      return 'Vegetables';
    }
    if (text.contains('maint') ||
        text.contains('repair') ||
        text.contains('fix')) {
      return 'Maintenance';
    }
    return 'Administrative';
  }
}

class _TaskStat extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final ThemeData theme;

  const _TaskStat({
    required this.count,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.subtleShadow],
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskFilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final ThemeData theme;

  const _TaskFilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final TaskEntity task;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const _TaskItem({
    required this.task,
    required this.theme,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task.isOverdue;
    final isCompleted = task.isCompleted;
    final priority = _priorityFor(task);
    final status = _statusFor(task);
    final origin = _originLabel(task.sourceEventType);
    final dueDateText = task.dueDate == null
        ? '—'
        : '${task.dueDate!.year}-${task.dueDate!.month.toString().padLeft(2, '0')}-${task.dueDate!.day.toString().padLeft(2, '0')}';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            onToggleComplete();
          },
          activeColor: theme.colorScheme.primary,
        ),
        title: Text(
          task.title.value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description ?? '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    priority,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getPriorityColor(priority),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (origin != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      origin,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(dueDateText),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverdue
                    ? Colors.red
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '—',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'overdue':
        return 'Overdue';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}';
    }
    return date;
  }

  String _statusFor(TaskEntity task) {
    if (task.isCompleted) return 'completed';
    if (task.isOverdue) return 'overdue';
    return 'pending';
  }

  String _priorityFor(TaskEntity task) {
    final text = '${task.title.value} ${task.description ?? ''}'.toLowerCase();
    if (text.contains('urgent') ||
        text.contains('critical') ||
        text.contains('immediately')) {
      return 'High';
    }
    if (task.isOverdue) return 'High';
    return 'Medium';
  }

  String? _originLabel(String? sourceEventType) {
    switch (sourceEventType) {
      case 'AnimalBred':
        return 'Breeding';
      case 'CropHarvested':
        return 'Harvest';
      case 'InventoryLowStock':
        return 'Low Stock';
      default:
        return null;
    }
  }
}
