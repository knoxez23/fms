import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/crop_entity.dart';

class CropDetailScreen extends StatefulWidget {
  final CropEntity entity;

  const CropDetailScreen({
    super.key,
    required this.entity,
  });

  const CropDetailScreen.fromEntity({
    Key? key,
    required CropEntity entity,
  }) : this(key: key, entity: entity);

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final crop = _CropDetailView.fromEntity(widget.entity);
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title: crop.name,
        variant: AppBarVariant.standard,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Crop Overview Card
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
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.agriculture,
                          color: theme.colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              crop.type,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(crop.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          crop.status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(crop.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _DetailItem(
                        icon: Icons.square_foot,
                        label: 'Area',
                        value: crop.area,
                        theme: theme,
                      ),
                      _DetailItem(
                        icon: Icons.calendar_today,
                        label: 'Planted',
                        value: _formatDate(crop.plantedDate),
                        theme: theme,
                      ),
                      _DetailItem(
                        icon: Icons.assessment,
                        label: 'Est. Yield',
                        value: crop.yieldEstimate,
                        theme: theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.subtleShadow],
            ),
            child: Row(
              children: [
                _DetailTab(
                  label: 'Growth',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                  theme: theme,
                ),
                _DetailTab(
                  label: 'Tasks',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                  theme: theme,
                ),
                _DetailTab(
                  label: 'History',
                  isSelected: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                  theme: theme,
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _GrowthTab(theme: theme),
                _TasksTab(theme: theme),
                _HistoryTab(theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String date) {
    // Simple date formatting - replace with proper date formatting
    return date.split('-').reversed.join('/');
  }
}

class _CropDetailView {
  final String id;
  final String name;
  final String type;
  final String status;
  final String area;
  final String plantedDate;
  final String yieldEstimate;

  const _CropDetailView({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.area,
    required this.plantedDate,
    required this.yieldEstimate,
  });

  factory _CropDetailView.fromEntity(CropEntity entity) {
    return _CropDetailView(
      id: entity.id ?? '',
      name: entity.name.value,
      type: entity.variety ?? 'General',
      status: entity.isReadyForHarvest ? 'Excellent' : 'Good',
      area: 'Not set',
      plantedDate: (entity.plantedAt ?? DateTime.now())
          .toIso8601String()
          .split('T')
          .first,
      yieldEstimate: 'Not set',
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _DetailTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _DetailTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _GrowthTab extends StatelessWidget {
  final ThemeData theme;

  const _GrowthTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Growth Stage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.65, // Mock progress
                  backgroundColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Vegetative Stage',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '65%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 2,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Metrics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _HealthMetric(
                  label: 'Soil Moisture',
                  value: '36%',
                  status: 'Optimal',
                  theme: theme,
                ),
                _HealthMetric(
                  label: 'Nutrient Level',
                  value: 'Medium',
                  status: 'Good',
                  theme: theme,
                ),
                _HealthMetric(
                  label: 'Pest Pressure',
                  value: 'Low',
                  status: 'Good',
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedCard(
          index: 3,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Observations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _ObservationItem(
                  date: '2 days ago',
                  note: 'Applied fertilizer to entire field',
                  theme: theme,
                ),
                _ObservationItem(
                  date: '1 week ago',
                  note: 'Minor pest activity detected',
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthMetric extends StatelessWidget {
  final String label;
  final String value;
  final String status;
  final ThemeData theme;

  const _HealthMetric({
    required this.label,
    required this.value,
    required this.status,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStatusColor(status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'optimal':
      case 'good':
        return Colors.green;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _ObservationItem extends StatelessWidget {
  final String date;
  final String note;
  final ThemeData theme;

  const _ObservationItem({
    required this.date,
    required this.note,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
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
}

class _TasksTab extends StatelessWidget {
  final ThemeData theme;

  const _TasksTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    const tasks = <_CropTaskView>[
      _CropTaskView(
        title: 'Apply fertilizer',
        due: 'Tomorrow',
        priority: 'High',
        completed: false,
      ),
      _CropTaskView(
        title: 'Check irrigation',
        due: 'In 3 days',
        priority: 'Medium',
        completed: false,
      ),
      _CropTaskView(
        title: 'Weed control',
        due: '1 week ago',
        priority: 'Medium',
        completed: true,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Crop Tasks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Add task
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...tasks.map((task) => _TaskItem(task: task, theme: theme)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final _CropTaskView task;
  final ThemeData theme;

  const _TaskItem({required this.task, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: task.completed,
            onChanged: (value) {},
            activeColor: theme.colorScheme.primary,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration:
                        task.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  'Due: ${task.due}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(task.priority).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              task.priority,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getPriorityColor(task.priority),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
}

class _HistoryTab extends StatelessWidget {
  final ThemeData theme;

  const _HistoryTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    const history = <_CropHistoryEntry>[
      _CropHistoryEntry(
        date: '2024-02-15',
        action: 'Fertilizer Application',
        details: 'Applied NPK fertilizer',
        amount: '50 kg',
      ),
      _CropHistoryEntry(
        date: '2024-02-01',
        action: 'Planting',
        details: 'Planted maize seeds',
        amount: '5 kg seeds',
      ),
      _CropHistoryEntry(
        date: '2024-01-20',
        action: 'Land Preparation',
        details: 'Plowed and prepared field',
        amount: '2 acres',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...history
                    .map((entry) => _HistoryItem(entry: entry, theme: theme)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final _CropHistoryEntry entry;
  final ThemeData theme;

  const _HistoryItem({required this.entry, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.action,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entry.details,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      entry.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.amount,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CropTaskView {
  final String title;
  final String due;
  final String priority;
  final bool completed;

  const _CropTaskView({
    required this.title,
    required this.due,
    required this.priority,
    required this.completed,
  });
}

class _CropHistoryEntry {
  final String date;
  final String action;
  final String details;
  final String amount;

  const _CropHistoryEntry({
    required this.date,
    required this.action,
    required this.details,
    required this.amount,
  });
}

// Reuse the _AnimatedCard widget from overview_screen.dart
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
            boxShadow: [AppColors.subtleShadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
