import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/animations/animated_card.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'task_calendar_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Map<String, dynamic>> tasks = [
    {
      'id': '1',
      'title': 'Irrigate maize field',
      'description': 'Water the entire maize field in plot A',
      'dueDate': '2024-03-15',
      'priority': 'High',
      'status': 'pending',
      'category': 'Crops',
      'assignedTo': 'John M.',
      'estimatedTime': '2 hours',
    },
    {
      'id': '2',
      'title': 'Vaccinate chickens',
      'description': 'Administer Newcastle disease vaccine',
      'dueDate': '2024-03-16',
      'priority': 'Medium',
      'status': 'pending',
      'category': 'Poultry',
      'assignedTo': 'Self',
      'estimatedTime': '1 hour',
    },
    {
      'id': '3',
      'title': 'Apply fertilizer to tomatoes',
      'description': 'Apply NPK fertilizer to tomato greenhouse',
      'dueDate': '2024-03-14',
      'priority': 'High',
      'status': 'overdue',
      'category': 'Crops',
      'assignedTo': 'Self',
      'estimatedTime': '3 hours',
    },
    {
      'id': '4',
      'title': 'Clean animal shelters',
      'description': 'Clean and disinfect cow sheds',
      'dueDate': '2024-03-13',
      'priority': 'Medium',
      'status': 'completed',
      'category': 'Animals',
      'assignedTo': 'Peter K.',
      'estimatedTime': '4 hours',
    },
    {
      'id': '5',
      'title': 'Harvest kale',
      'description': 'Harvest mature kale from vegetable garden',
      'dueDate': '2024-03-17',
      'priority': 'Medium',
      'status': 'pending',
      'category': 'Vegetables',
      'assignedTo': 'Self',
      'estimatedTime': '2 hours',
    },
  ];

  String _selectedFilter = 'All';
  String _selectedStatus = 'All';

  final List<String> _filters = [
    'All',
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

    final filteredTasks = tasks.where((task) {
      final categoryMatch =
          _selectedFilter == 'All' || task['category'] == _selectedFilter;
      final statusMatch = _selectedStatus == 'All' ||
          _getStatusText(task['status']) == _selectedStatus;
      return categoryMatch && statusMatch;
    }).toList();

    final pendingCount =
        tasks.where((task) => task['status'] == 'pending').length;
    final overdueCount =
        tasks.where((task) => task['status'] == 'overdue').length;
    final completedCount =
        tasks.where((task) => task['status'] == 'completed').length;

    return Scaffold(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            builder: (_) => TaskDetailScreen(task: task),
                          ),
                        );
                      },
                      onStatusChange: (newStatus) {
                        setState(() {
                          task['status'] = newStatus;
                        });
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
              child: const Icon(Icons.calendar_today, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'addTaskFAB',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTaskScreen()),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );

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
  final Map<String, dynamic> task;
  final ThemeData theme;
  final VoidCallback onTap;
  final Function(String) onStatusChange;

  const _TaskItem({
    required this.task,
    required this.theme,
    required this.onTap,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final isOverdue = task['status'] == 'overdue';
    final isCompleted = task['status'] == 'completed';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: isCompleted,
          onChanged: (value) {
            onStatusChange(value! ? 'completed' : 'pending');
          },
          activeColor: theme.colorScheme.primary,
        ),
        title: Text(
          task['title'],
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task['description'],
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
                    color: _getPriorityColor(task['priority']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task['priority'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getPriorityColor(task['priority']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task['status']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getStatusText(task['status']),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(task['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatDate(task['dueDate']),
              style: theme.textTheme.bodySmall?.copyWith(
                color: isOverdue
                    ? Colors.red
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              task['estimatedTime'],
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
}