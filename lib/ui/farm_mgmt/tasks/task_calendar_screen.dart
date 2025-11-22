import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';

class TaskCalendarScreen extends StatefulWidget {
  const TaskCalendarScreen({super.key});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedView = 0; // 0: Day, 1: Week, 2: Month

  final List<Map<String, dynamic>> _taskEvents = [
    {
      'title': 'Irrigate maize field',
      'date': DateTime(2024, 3, 15),
      'time': '08:00',
      'priority': 'High',
      'category': 'Crops',
      'duration': '2 hours',
    },
    {
      'title': 'Vaccinate chickens',
      'date': DateTime(2024, 3, 15),
      'time': '14:00',
      'priority': 'Medium',
      'category': 'Poultry',
      'duration': '1 hour',
    },
    {
      'title': 'Apply fertilizer',
      'date': DateTime(2024, 3, 16),
      'time': '10:00',
      'priority': 'High',
      'category': 'Crops',
      'duration': '3 hours',
    },
    {
      'title': 'Harvest kale',
      'date': DateTime(2024, 3, 17),
      'time': '09:00',
      'priority': 'Medium',
      'category': 'Vegetables',
      'duration': '2 hours',
    },
    {
      'title': 'Clean animal shelters',
      'date': DateTime(2024, 3, 18),
      'time': '07:00',
      'priority': 'Medium',
      'category': 'Animals',
      'duration': '4 hours',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayEvents = _taskEvents.where((event) =>
    event['date'].year == _selectedDate.year &&
        event['date'].month == _selectedDate.month &&
        event['date'].day == _selectedDate.day).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Task Calendar',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Calendar Header
          _AnimatedCard(
            index: 0,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getDateHeader(_selectedDate),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _previousPeriod,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _nextPeriod,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // View Selector
                  Row(
                    children: [
                      _ViewOption(
                        label: 'Day',
                        isSelected: _selectedView == 0,
                        onTap: () => setState(() => _selectedView = 0),
                        theme: theme,
                      ),
                      _ViewOption(
                        label: 'Week',
                        isSelected: _selectedView == 1,
                        onTap: () => setState(() => _selectedView = 1),
                        theme: theme,
                      ),
                      _ViewOption(
                        label: 'Month',
                        isSelected: _selectedView == 2,
                        onTap: () => setState(() => _selectedView = 2),
                        theme: theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Calendar Grid
          if (_selectedView == 2) // Month View
            _AnimatedCard(
              index: 1,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _MonthCalendar(
                  selectedDate: _selectedDate,
                  events: _taskEvents,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _selectedView = 0; // Switch to day view
                    });
                  },
                  theme: theme,
                ),
              ),
            )
          else if (_selectedView == 1) // Week View
            _AnimatedCard(
              index: 1,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _WeekCalendar(
                  selectedDate: _selectedDate,
                  events: _taskEvents,
                  theme: theme,
                ),
              ),
            ),

          // Today's Tasks
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedView == 0
                            ? 'Tasks for ${_formatDate(_selectedDate)}'
                            : 'Upcoming Tasks',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${todayEvents.length} Tasks',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (todayEvents.isEmpty)
                    _AnimatedCard(
                      index: 2,
                      theme: theme,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text('No tasks scheduled for today'),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: todayEvents.length,
                        itemBuilder: (context, index) {
                          return _AnimatedCard(
                            index: index + 2,
                            theme: theme,
                            child: _CalendarTaskItem(
                              event: todayEvents[index],
                              theme: theme,
                            ),
                          );
                        },
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

  String _getDateHeader(DateTime date) {
    if (_selectedView == 0) {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } else if (_selectedView == 1) {
      final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${startOfWeek.day} - ${endOfWeek.day} ${_getMonthName(date.month)} ${date.year}';
    } else {
      return '${_getMonthName(date.month)} ${date.year}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  void _previousPeriod() {
    setState(() {
      if (_selectedView == 0) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      } else if (_selectedView == 1) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_selectedView == 0) {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
      } else if (_selectedView == 1) {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
      } else {
        _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
      }
    });
  }
}

class _ViewOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ViewOption({
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;
  final Function(DateTime) onDateSelected;
  final ThemeData theme;

  const _MonthCalendar({
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final startingWeekday = firstDay.weekday;

    return Column(
      children: [
        // Weekday headers
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar days
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: 42, // 6 weeks
          itemBuilder: (context, index) {
            final day = index - startingWeekday + 1;
            final date = DateTime(selectedDate.year, selectedDate.month, day);
            final hasEvents = events.any((event) =>
            event['date'].year == date.year &&
                event['date'].month == date.month &&
                event['date'].day == date.day);
            final isToday = _isToday(date);
            final isCurrentMonth = date.month == selectedDate.month;

            return GestureDetector(
              onTap: () => onDateSelected(date),
              child: Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isToday
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: theme.colorScheme.primary)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day > 0 && day <= lastDay.day ? day.toString() : '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isCurrentMonth
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (hasEvents && isCurrentMonth && day > 0)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class _WeekCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;
  final ThemeData theme;

  const _WeekCalendar({
    required this.selectedDate,
    required this.events,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final startOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    return Column(
      children: [
        // Day headers with dates
        Row(
          children: List.generate(7, (index) {
            final date = startOfWeek.add(Duration(days: index));
            final isToday = _isToday(date);
            final dayEvents = events.where((event) =>
            event['date'].year == date.year &&
                event['date'].month == date.month &&
                event['date'].day == date.day).toList();

            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isToday ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday ? Border.all(color: theme.colorScheme.primary) : null,
                ),
                child: Column(
                  children: [
                    Text(
                      _getWeekdayName(date.weekday),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      date.day.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (dayEvents.isNotEmpty)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // Time slots could be added here for a more detailed week view
        Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          child: const Center(
            child: Text(
              'Weekly schedule with time slots will be implemented here',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return weekdays[weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}

class _CalendarTaskItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final ThemeData theme;

  const _CalendarTaskItem({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getCategoryColor(event['category']).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getCategoryIcon(event['category']),
          color: _getCategoryColor(event['category']),
          size: 20,
        ),
      ),
      title: Text(
        event['title'],
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${event['time']} • ${event['duration']}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getPriorityColor(event['priority']).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              event['priority'],
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getPriorityColor(event['priority']),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Crops':
        return Colors.green;
      case 'Animals':
        return Colors.orange;
      case 'Poultry':
        return Colors.yellow;
      case 'Vegetables':
        return Colors.blue;
      case 'Maintenance':
        return Colors.brown;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Crops':
        return Icons.agriculture;
      case 'Animals':
        return Icons.pets;
      case 'Poultry':
        return Icons.egg;
      case 'Vegetables':
        return Icons.spa;
      case 'Maintenance':
        return Icons.build;
      default:
        return Icons.task;
    }
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