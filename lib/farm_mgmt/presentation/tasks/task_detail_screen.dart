import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = widget.task['status'] == 'completed';
    final isOverdue = widget.task['status'] == 'overdue';

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Task Details',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header
            _AnimatedCard(
              index: 0,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.task['title'],
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        Checkbox(
                          value: isCompleted,
                          onChanged: (value) {
                            setState(() {
                              widget.task['status'] = value! ? 'completed' : 'pending';
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.task['description'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _TaskBadge(
                          label: widget.task['priority'],
                          color: _getPriorityColor(widget.task['priority']),
                          theme: theme,
                        ),
                        const SizedBox(width: 8),
                        _TaskBadge(
                          label: _getStatusText(widget.task['status']),
                          color: _getStatusColor(widget.task['status']),
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Task Details
            _AnimatedCard(
              index: 1,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Task Details',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      icon: Icons.category,
                      label: 'Category',
                      value: widget.task['category'],
                      theme: theme,
                    ),
                    _DetailRow(
                      icon: Icons.person,
                      label: 'Assigned To',
                      value: widget.task['assignedTo'],
                      theme: theme,
                    ),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Estimated Time',
                      value: widget.task['estimatedTime'],
                      theme: theme,
                    ),
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: 'Due Date',
                      value: _formatDate(widget.task['dueDate']),
                      theme: theme,
                      valueColor: isOverdue ? Colors.red : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Progress & Notes
            _AnimatedCard(
              index: 2,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress & Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!isCompleted)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: 0.3, // Mock progress
                            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '30% Complete',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Notes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        widget.task['notes'] ?? 'No additional notes for this task.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            _AnimatedCard(
              index: 3,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Actions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Mark as complete/incomplete
                              setState(() {
                                widget.task['status'] = isCompleted ? 'pending' : 'completed';
                              });
                            },
                            icon: Icon(
                              isCompleted ? Icons.refresh : Icons.check_circle,
                              size: 16,
                            ),
                            label: Text(isCompleted ? 'Reopen Task' : 'Mark Complete'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Start/stop timer
                            },
                            icon: const Icon(Icons.timer, size: 16),
                            label: const Text('Start Timer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        // Add note
                      },
                      icon: const Icon(Icons.note_add, size: 16),
                      label: const Text('Add Note'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Related Tasks (if any)
            if (_hasRelatedTasks(widget.task['category']))
              _AnimatedCard(
                index: 4,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Related Tasks',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _RelatedTaskItem(
                        title: 'Weed control in maize field',
                        dueDate: '2024-03-18',
                        theme: theme,
                      ),
                      _RelatedTaskItem(
                        title: 'Apply second round of fertilizer',
                        dueDate: '2024-03-25',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
      return '${parts[2]}/${parts[1]}/${parts[0]}';
    }
    return date;
  }

  bool _hasRelatedTasks(String category) {
    return category == 'Crops'; // Mock condition
  }
}

class _TaskBadge extends StatelessWidget {
  final String label;
  final Color color;
  final ThemeData theme;

  const _TaskBadge({
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedTaskItem extends StatelessWidget {
  final String title;
  final String dueDate;
  final ThemeData theme;

  const _RelatedTaskItem({
    required this.title,
    required this.dueDate,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'Due: ${_formatDate(dueDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    final parts = date.split('-');
    if (parts.length == 3) {
      return '${parts[2]}/${parts[1]}';
    }
    return date;
  }
}

// Reuse the _AnimatedCard widget
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final ThemeData theme;
  final int index;

  const _AnimatedCard({
    required this.child,
    required this.theme,
    required this.index,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final start = (0.1 * widget.index).clamp(0.0, 0.6);
    final end = (0.3 + 0.1 * widget.index).clamp(0.4, 1.0);

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: widget.theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.subtleShadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}