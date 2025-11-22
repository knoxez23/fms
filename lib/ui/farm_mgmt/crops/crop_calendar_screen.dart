import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _cropEvents = [
    {
      'crop': 'Maize Field A',
      'task': 'Apply fertilizer',
      'date': DateTime(2024, 3, 15),
      'type': 'fertilizer',
    },
    {
      'crop': 'Tomato Greenhouse',
      'task': 'Harvest tomatoes',
      'date': DateTime(2024, 3, 18),
      'type': 'harvest',
    },
    {
      'crop': 'Maize Field A',
      'task': 'Weed control',
      'date': DateTime(2024, 3, 20),
      'type': 'maintenance',
    },
    {
      'crop': 'Tomato Greenhouse',
      'task': 'Pest control',
      'date': DateTime(2024, 3, 22),
      'type': 'pest_control',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayEvents = _cropEvents.where((event) =>
    event['date'].year == _selectedDate.year &&
        event['date'].month == _selectedDate.month &&
        event['date'].day == _selectedDate.day).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Crop Calendar',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getMonthYear(_selectedDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousMonth,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Calendar Grid
          _AnimatedCard(
            index: 1,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _CalendarGrid(
                selectedDate: _selectedDate,
                events: _cropEvents,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                theme: theme,
              ),
            ),
          ),

          // Today's Events
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Events for ${_formatDate(_selectedDate)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (todayEvents.isEmpty)
                    _AnimatedCard(
                      index: 2,
                      theme: theme,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: Text('No events scheduled for today'),
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
                            child: _EventItem(
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

  String _getMonthYear(DateTime date) {
    return '${_getMonthName(date.month)} ${date.year}';
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

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime selectedDate;
  final List<Map<String, dynamic>> events;
  final Function(DateTime) onDateSelected;
  final ThemeData theme;

  const _CalendarGrid({
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

class _EventItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final ThemeData theme;

  const _EventItem({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getEventColor(event['type']).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getEventIcon(event['type']),
          color: _getEventColor(event['type']),
          size: 20,
        ),
      ),
      title: Text(
        event['task'],
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        event['crop'],
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Text(
        _formatTime(event['date']),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'fertilizer':
        return Colors.green;
      case 'harvest':
        return Colors.orange;
      case 'pest_control':
        return Colors.red;
      case 'maintenance':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventIcon(String type) {
    switch (type) {
      case 'fertilizer':
        return Icons.eco;
      case 'harvest':
        return Icons.agriculture;
      case 'pest_control':
        return Icons.bug_report;
      case 'maintenance':
        return Icons.build;
      default:
        return Icons.event;
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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