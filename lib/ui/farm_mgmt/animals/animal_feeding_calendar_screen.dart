import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';

class AnimalFeedingCalendarScreen extends StatefulWidget {
  final List<Map<String, dynamic>> animals;

  const AnimalFeedingCalendarScreen({super.key, required this.animals});

  @override
  State<AnimalFeedingCalendarScreen> createState() => _AnimalFeedingCalendarScreenState();
}

class _AnimalFeedingCalendarScreenState extends State<AnimalFeedingCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'Daily';
  String _selectedAnimalFilter = 'All';
  bool _showCompleted = true;

  final List<String> _viewOptions = ['Daily', 'Weekly', 'Monthly'];
  final List<String> _animalFilters = ['All', 'Cattle', 'Poultry', 'Goats', 'Sheep'];

  List<Map<String, dynamic>> _feedingSchedules = [];
  List<Map<String, dynamic>> _feedingHistory = [];

  @override
  void initState() {
    super.initState();
    _loadFeedingSchedules();
    _loadFeedingHistory();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredSchedules = _getFilteredSchedules();
    final todaysFeedings = _getTodaysFeedings();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Feeding Calendar',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm),
            onPressed: _addFeedingSchedule,
          ),
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: _showFeedInventory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Header & Filters
          _buildCalendarHeader(theme),

          // Today's Summary
          _buildTodaysSummary(theme, todaysFeedings),

          // Main Content
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  // Tabs
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      border: Border(
                        bottom: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: TabBar(
                      labelColor: theme.colorScheme.primary,
                      unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      indicatorColor: theme.colorScheme.primary,
                      tabs: const [
                        Tab(text: 'Schedule'),
                        Tab(text: 'History'),
                      ],
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Schedule Tab
                        _buildScheduleTab(theme, filteredSchedules),

                        // History Tab
                        _buildHistoryTab(theme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _logFeeding,
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.restaurant, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          // Date Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDate(-1),
              ),
              Column(
                children: [
                  Text(
                    _getFormattedDate(_selectedDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _getDayName(_selectedDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeDate(1),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // View Options & Filters
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedView,
                      items: _viewOptions.map((view) {
                        return DropdownMenuItem(
                          value: view,
                          child: Text(view),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedView = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedAnimalFilter,
                      items: _animalFilters.map((filter) {
                        return DropdownMenuItem(
                          value: filter,
                          child: Text(filter),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAnimalFilter = value!;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysSummary(ThemeData theme, List<Map<String, dynamic>> todaysFeedings) {
    final completed = todaysFeedings.where((f) => f['completed'] == true).length;
    final total = todaysFeedings.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.schedule,
                  value: '$completed/$total',
                  label: 'Completed',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.local_dining,
                  value: '${_calculateTotalFeed(todaysFeedings)} kg',
                  label: 'Total Feed',
                  theme: theme,
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.notifications_active,
                  value: '${_getUpcomingFeedings().length}',
                  label: 'Upcoming',
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress == 1.0 ? Colors.green : theme.colorScheme.primary,
            ),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab(ThemeData theme, List<Map<String, dynamic>> schedules) {
    final morningFeedings = schedules.where((s) => s['timeOfDay'] == 'Morning').toList();
    final afternoonFeedings = schedules.where((s) => s['timeOfDay'] == 'Afternoon').toList();
    final eveningFeedings = schedules.where((s) => s['timeOfDay'] == 'Evening').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (morningFeedings.isNotEmpty) ...[
            _FeedingTimeSection(
              timeOfDay: 'Morning',
              feedings: morningFeedings,
              theme: theme,
              onToggleComplete: _toggleFeedingComplete,
              onEdit: _editFeedingSchedule,
            ),
            const SizedBox(height: 16),
          ],

          if (afternoonFeedings.isNotEmpty) ...[
            _FeedingTimeSection(
              timeOfDay: 'Afternoon',
              feedings: afternoonFeedings,
              theme: theme,
              onToggleComplete: _toggleFeedingComplete,
              onEdit: _editFeedingSchedule,
            ),
            const SizedBox(height: 16),
          ],

          if (eveningFeedings.isNotEmpty) ...[
            _FeedingTimeSection(
              timeOfDay: 'Evening',
              feedings: eveningFeedings,
              theme: theme,
              onToggleComplete: _toggleFeedingComplete,
              onEdit: _editFeedingSchedule,
            ),
            const SizedBox(height: 16),
          ],

          if (schedules.isEmpty)
            _EmptyState(
              icon: Icons.restaurant,
              title: 'No Feeding Schedules',
              message: 'Add feeding schedules to see them here',
              theme: theme,
            ),

          // Quick Actions
          _AnimatedCard(
            index: 0,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Start All Morning'),
                        onPressed: () => _startAllFeedings('Morning'),
                        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.check, size: 18),
                        label: const Text('Complete All'),
                        onPressed: _completeAllTodaysFeedings,
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.notifications, size: 18),
                        label: const Text('Set Reminders'),
                        onPressed: _setFeedingReminders,
                        backgroundColor: Colors.orange.withValues(alpha: 0.1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter Options
          Row(
            children: [
              Switch(
                value: _showCompleted,
                onChanged: (value) => setState(() => _showCompleted = value),
                activeThumbColor: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Show Completed',
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearHistory,
                child: const Text('Clear History'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Feeding History
          if (_feedingHistory.isNotEmpty)
            ..._feedingHistory.where((history) => _showCompleted || !history['completed']).map((history) {
              return _FeedingHistoryCard(
                history: history,
                theme: theme,
                onDelete: _deleteFeedingHistory,
              );
            }),

          if (_feedingHistory.isEmpty)
            _EmptyState(
              icon: Icons.history,
              title: 'No Feeding History',
              message: 'Completed feedings will appear here',
              theme: theme,
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Helper Methods
  List<Map<String, dynamic>> _getFilteredSchedules() {
    return _feedingSchedules.where((schedule) {
      final matchesDate = schedule['date'] == _getFormattedDate(_selectedDate);
      final matchesFilter = _selectedAnimalFilter == 'All' ||
          _getAnimalCategory(schedule['animalType']) == _selectedAnimalFilter;
      return matchesDate && matchesFilter;
    }).toList();
  }

  List<Map<String, dynamic>> _getTodaysFeedings() {
    return _feedingSchedules.where((schedule) {
      return schedule['date'] == _getFormattedDate(DateTime.now());
    }).toList();
  }

  List<Map<String, dynamic>> _getUpcomingFeedings() {
    final now = TimeOfDay.now();
    return _feedingSchedules.where((schedule) {
      if (schedule['date'] != _getFormattedDate(DateTime.now())) return false;
      if (schedule['completed'] == true) return false;

      final scheduleTime = _parseTimeOfDay(schedule['time']);
      return scheduleTime.hour > now.hour ||
          (scheduleTime.hour == now.hour && scheduleTime.minute > now.minute);
    }).toList();
  }

  double _calculateTotalFeed(List<Map<String, dynamic>> feedings) {
    return feedings.fold(0.0, (sum, feeding) => sum + (feeding['quantity'] ?? 0.0));
  }

  String _getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getDayName(DateTime date) {
    final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[date.weekday % 7];
  }

  String _getAnimalCategory(String type) {
    if (type.contains('Cow') || type.contains('Cattle')) return 'Cattle';
    if (type.contains('Chicken') || type == 'Layers') return 'Poultry';
    if (type.contains('Goat')) return 'Goats';
    if (type.contains('Sheep')) return 'Sheep';
    return 'Other';
  }

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(' ');
    final timeParts = parts[0].split(':');
    final isPM = parts[1] == 'PM';

    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    if (isPM && hour != 12) hour += 12;
    if (!isPM && hour == 12) hour = 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  // Action Methods
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _toggleFeedingComplete(String scheduleId) {
    setState(() {
      final schedule = _feedingSchedules.firstWhere((s) => s['id'] == scheduleId);
      schedule['completed'] = !(schedule['completed'] ?? false);

      if (schedule['completed'] == true) {
        // Add to history
        _feedingHistory.insert(0, {
          ...schedule,
          'completedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  void _addFeedingSchedule() {
    // TODO: Implement add feeding schedule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add feeding schedule feature coming soon!')),
    );
  }

  void _editFeedingSchedule(String scheduleId) {
    // TODO: Implement edit feeding schedule
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit feeding schedule feature coming soon!')),
    );
  }

  void _logFeeding() {
    // TODO: Implement manual feeding log
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log manual feeding feature coming soon!')),
    );
  }

  void _showFeedInventory() {
    // TODO: Implement feed inventory
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feed inventory feature coming soon!')),
    );
  }

  void _startAllFeedings(String timeOfDay) {
    // TODO: Implement start all feedings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting all $timeOfDay feedings...')),
    );
  }

  void _completeAllTodaysFeedings() {
    setState(() {
      for (var schedule in _getTodaysFeedings()) {
        schedule['completed'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All today\'s feedings marked as completed!')),
    );
  }

  void _setFeedingReminders() {
    // TODO: Implement feeding reminders
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Setting feeding reminders...')),
    );
  }

  void _deleteFeedingHistory(String historyId) {
    setState(() {
      _feedingHistory.removeWhere((history) => history['id'] == historyId);
    });
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all feeding history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _feedingHistory.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Feeding history cleared!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _loadFeedingSchedules() {
    // TODO: Load from database
    setState(() {
      _feedingSchedules = [
        {
          'id': '1',
          'animal': 'Daisy',
          'animalType': 'Dairy Cow',
          'feedType': 'Dairy Meal + Napier Grass',
          'quantity': 12.5,
          'time': '06:30 AM',
          'timeOfDay': 'Morning',
          'date': _getFormattedDate(DateTime.now()),
          'completed': false,
          'notes': 'Add mineral mix',
        },
        {
          'id': '2',
          'animal': 'Chicken Flock A',
          'animalType': 'Layers',
          'feedType': 'Layers Mash',
          'quantity': 8.0,
          'time': '07:00 AM',
          'timeOfDay': 'Morning',
          'date': _getFormattedDate(DateTime.now()),
          'completed': true,
          'notes': 'Provide grit separately',
        },
        {
          'id': '3',
          'animal': 'All Goats',
          'animalType': 'Goat',
          'feedType': 'Goat Pellets + Lucerne',
          'quantity': 6.0,
          'time': '02:00 PM',
          'timeOfDay': 'Afternoon',
          'date': _getFormattedDate(DateTime.now()),
          'completed': false,
          'notes': 'Check water availability',
        },
        {
          'id': '4',
          'animal': 'Daisy',
          'animalType': 'Dairy Cow',
          'feedType': 'Evening Concentrate',
          'quantity': 8.0,
          'time': '05:30 PM',
          'timeOfDay': 'Evening',
          'date': _getFormattedDate(DateTime.now()),
          'completed': false,
          'notes': 'Milking after feeding',
        },
      ];
    });
  }

  void _loadFeedingHistory() {
    // TODO: Load from database
    setState(() {
      _feedingHistory = [
        {
          'id': 'h1',
          'animal': 'Bella',
          'animalType': 'Dairy Cow',
          'feedType': 'Dairy Meal',
          'quantity': 10.0,
          'time': '06:30 AM',
          'date': _getFormattedDate(DateTime.now().subtract(const Duration(days: 1))),
          'completed': true,
          'completedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
      ];
    });
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FeedingTimeSection extends StatelessWidget {
  final String timeOfDay;
  final List<Map<String, dynamic>> feedings;
  final ThemeData theme;
  final Function(String) onToggleComplete;
  final Function(String) onEdit;

  const _FeedingTimeSection({
    required this.timeOfDay,
    required this.feedings,
    required this.theme,
    required this.onToggleComplete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedCard(
      index: _getTimeOfDayIndex(timeOfDay),
      theme: theme,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTimeOfDayIcon(timeOfDay),
                  color: _getTimeOfDayColor(timeOfDay),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  timeOfDay,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getTimeOfDayColor(timeOfDay),
                  ),
                ),
                const Spacer(),
                Text(
                  '${feedings.length} feeding${feedings.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...feedings.map((feeding) => _FeedingScheduleCard(
              feeding: feeding,
              theme: theme,
              onToggleComplete: onToggleComplete,
              onEdit: onEdit,
            )),
          ],
        ),
      ),
    );
  }

  int _getTimeOfDayIndex(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning': return 1;
      case 'Afternoon': return 2;
      case 'Evening': return 3;
      default: return 0;
    }
  }

  IconData _getTimeOfDayIcon(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning': return Icons.wb_sunny;
      case 'Afternoon': return Icons.brightness_5;
      case 'Evening': return Icons.nights_stay;
      default: return Icons.schedule;
    }
  }

  Color _getTimeOfDayColor(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning': return Colors.orange;
      case 'Afternoon': return Colors.blue;
      case 'Evening': return Colors.purple;
      default: return Colors.grey;
    }
  }
}

class _FeedingScheduleCard extends StatelessWidget {
  final Map<String, dynamic> feeding;
  final ThemeData theme;
  final Function(String) onToggleComplete;
  final Function(String) onEdit;

  const _FeedingScheduleCard({
    required this.feeding,
    required this.theme,
    required this.onToggleComplete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = feeding['completed'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isCompleted,
            onChanged: (_) => onToggleComplete(feeding['id']),
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feeding['animal'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    color: isCompleted ? theme.colorScheme.onSurface.withValues(alpha: 0.5) : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${feeding['feedType']} • ${feeding['quantity']} kg',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (feeding['notes'] != null && feeding['notes'].isNotEmpty)
                  Text(
                    'Note: ${feeding['notes']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                feeding['time'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => onEdit(feeding['id']),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedingHistoryCard extends StatelessWidget {
  final Map<String, dynamic> history;
  final ThemeData theme;
  final Function(String) onDelete;

  const _FeedingHistoryCard({
    required this.history,
    required this.theme,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getAnimalColor(history['animalType']).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAnimalIcon(history['animalType']),
              color: _getAnimalColor(history['animalType']),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history['animal'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${history['feedType']} • ${history['quantity']} kg • ${history['time']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  history['date'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => onDelete(history['id']),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  Color _getAnimalColor(String type) {
    switch (type) {
      case 'Dairy Cow': return Colors.blue;
      case 'Layers': return Colors.orange;
      case 'Goat': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getAnimalIcon(String type) {
    switch (type) {
      case 'Dairy Cow': return Icons.agriculture;
      case 'Layers': return Icons.egg;
      case 'Goat': return Icons.pets;
      default: return Icons.pets;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final ThemeData theme;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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