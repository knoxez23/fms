import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/crop_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/presentation/bloc/crops/crops_bloc.dart';
import 'package:pamoja_twalima/farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => getIt<CropsBloc>()..add(const CropsEvent.load())),
        BlocProvider(
            create: (_) => getIt<TasksBloc>()..add(const TasksEvent.load())),
      ],
      child: Builder(
        builder: (context) {
          final cropsState = context.watch<CropsBloc>().state;
          final tasksState = context.watch<TasksBloc>().state;

          final crops = cropsState.maybeWhen(
            loaded: (items) => items,
            orElse: () => <CropEntity>[],
          );

          final tasks = tasksState.maybeWhen(
            loaded: (items) => items,
            orElse: () => <TaskEntity>[],
          );

          final events = _buildEvents(crops, tasks);
          final dayEvents = events
              .where((event) => _sameDate(event.date, _selectedDate))
              .toList();

          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            includeDrawer: false,
            appBar: const ModernAppBar(
              title: 'Crop Calendar',
              variant: AppBarVariant.standard,
            ),
            body: Column(
              children: [
                _HeaderCard(
                  theme: theme,
                  selectedDate: _selectedDate,
                  onPrevious: _previousMonth,
                  onNext: _nextMonth,
                ),
                _MonthGrid(
                  theme: theme,
                  selectedDate: _selectedDate,
                  events: events,
                  onDateSelected: (date) =>
                      setState(() => _selectedDate = date),
                ),
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
                        if (dayEvents.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No events scheduled for this day',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                          )
                        else
                          Expanded(
                            child: ListView.builder(
                              itemCount: dayEvents.length,
                              itemBuilder: (_, index) {
                                final event = dayEvents[index];
                                return _EventCard(event: event, theme: theme);
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
        },
      ),
    );
  }

  List<_CropCalendarEvent> _buildEvents(
      List<CropEntity> crops, List<TaskEntity> tasks) {
    final events = <_CropCalendarEvent>[];

    for (final crop in crops) {
      final planted = crop.plantedAt;
      if (planted != null) {
        events.add(_CropCalendarEvent(
          cropName: crop.name.value,
          task: 'Planted',
          date: planted,
          type: 'planting',
        ));
      }

      final harvest = crop.expectedHarvest;
      if (harvest != null) {
        events.add(_CropCalendarEvent(
          cropName: crop.name.value,
          task: 'Expected harvest',
          date: harvest,
          type: 'harvest',
        ));
      }
    }

    for (final task in tasks) {
      final due = task.dueDate;
      if (due == null) continue;

      final title = task.title.value;
      final isCropTask = _looksLikeCropTask(title, task.description ?? '');
      if (!isCropTask) continue;

      events.add(_CropCalendarEvent(
        cropName: _extractCropName(title),
        task: title,
        date: due,
        type: task.isCompleted ? 'completed' : 'maintenance',
      ));
    }

    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  bool _looksLikeCropTask(String title, String description) {
    final text = '$title $description'.toLowerCase();
    return text.contains('crop') ||
        text.contains('harvest') ||
        text.contains('fertilizer') ||
        text.contains('plant') ||
        text.contains('irrigat') ||
        text.contains('weed') ||
        text.contains('pest');
  }

  String _extractCropName(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) return 'Crop Task';
    return normalized;
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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

  String _formatDate(DateTime date) {
    return '${date.day} ${_monthName(date.month)} ${date.year}';
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _CropCalendarEvent {
  final String cropName;
  final String task;
  final DateTime date;
  final String type;

  const _CropCalendarEvent({
    required this.cropName,
    required this.task,
    required this.date,
    required this.type,
  });
}

class _HeaderCard extends StatelessWidget {
  final ThemeData theme;
  final DateTime selectedDate;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _HeaderCard({
    required this.theme,
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_monthName(selectedDate.month)} ${selectedDate.year}',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              IconButton(
                  onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
              IconButton(
                  onPressed: onNext, icon: const Icon(Icons.chevron_right)),
            ],
          )
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}

class _MonthGrid extends StatelessWidget {
  final ThemeData theme;
  final DateTime selectedDate;
  final List<_CropCalendarEvent> events;
  final ValueChanged<DateTime> onDateSelected;

  const _MonthGrid({
    required this.theme,
    required this.selectedDate,
    required this.events,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final startOffset = firstDay.weekday % 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1.2,
        ),
        itemCount: 42,
        itemBuilder: (_, index) {
          final day = index - startOffset + 1;
          if (day < 1 || day > lastDay.day) return const SizedBox.shrink();

          final date = DateTime(selectedDate.year, selectedDate.month, day);
          final hasEvents = events.any((event) =>
              event.date.year == date.year &&
              event.date.month == date.month &&
              event.date.day == date.day);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _isToday(date)
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$day'),
                  if (hasEvents)
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
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return now.year == date.year &&
        now.month == date.month &&
        now.day == date.day;
  }
}

class _EventCard extends StatelessWidget {
  final _CropCalendarEvent event;
  final ThemeData theme;

  const _EventCard({required this.event, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _eventColor(event.type).withValues(alpha: 0.12),
          child: Icon(_eventIcon(event.type),
              color: _eventColor(event.type), size: 18),
        ),
        title: Text(event.cropName),
        subtitle: Text(event.task),
      ),
    );
  }

  Color _eventColor(String type) {
    switch (type) {
      case 'harvest':
        return Colors.orange;
      case 'planting':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _eventIcon(String type) {
    switch (type) {
      case 'harvest':
        return Icons.agriculture;
      case 'planting':
        return Icons.grass;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.event;
    }
  }
}
