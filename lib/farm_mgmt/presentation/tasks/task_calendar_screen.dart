import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart';

class TaskCalendarScreen extends StatefulWidget {
  const TaskCalendarScreen({super.key});

  @override
  State<TaskCalendarScreen> createState() => _TaskCalendarScreenState();
}

class _TaskCalendarScreenState extends State<TaskCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  int _selectedView = 0; // 0: Day, 1: Week, 2: Month

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => getIt<TasksBloc>()..add(const TasksEvent.load()),
      child: BlocBuilder<TasksBloc, TasksState>(
        builder: (context, state) {
          final tasks = state.maybeWhen(
            loaded: (items) => items,
            orElse: () => <TaskEntity>[],
          );

          final dayTasks = _tasksForDate(tasks, _selectedDate);
          final periodTasks = _selectedView == 0
              ? dayTasks
              : _tasksForPeriod(tasks, _selectedDate, _selectedView);

          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            includeDrawer: false,
            appBar: const ModernAppBar(
              title: 'Task Calendar',
              variant: AppBarVariant.standard,
            ),
            body: Column(
              children: [
                _CalendarHeader(
                  theme: theme,
                  selectedDate: _selectedDate,
                  selectedView: _selectedView,
                  onPrevious: _previousPeriod,
                  onNext: _nextPeriod,
                  onViewChanged: (view) => setState(() => _selectedView = view),
                ),
                if (_selectedView == 2)
                  _MonthCalendar(
                    selectedDate: _selectedDate,
                    tasks: tasks,
                    theme: theme,
                    onDateSelected: (date) {
                      setState(() {
                        _selectedDate = date;
                        _selectedView = 0;
                      });
                    },
                  ),
                if (_selectedView == 1)
                  _WeekCalendar(
                    selectedDate: _selectedDate,
                    tasks: tasks,
                    theme: theme,
                    onDateSelected: (date) =>
                        setState(() => _selectedDate = date),
                  ),
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
                                  : 'Tasks in ${_viewLabel(_selectedView).toLowerCase()}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${periodTasks.length} Tasks',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (periodTasks.isEmpty)
                          Expanded(
                            child: Center(
                              child: Text(
                                'No tasks scheduled',
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
                              itemCount: periodTasks.length,
                              itemBuilder: (context, index) {
                                return _TaskTile(
                                    task: periodTasks[index], theme: theme);
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

  List<TaskEntity> _tasksForDate(List<TaskEntity> tasks, DateTime date) {
    return tasks.where((task) {
      final due = task.dueDate;
      if (due == null) return false;
      return due.year == date.year &&
          due.month == date.month &&
          due.day == date.day;
    }).toList();
  }

  List<TaskEntity> _tasksForPeriod(
      List<TaskEntity> tasks, DateTime date, int view) {
    if (view == 1) {
      final start = date.subtract(Duration(days: date.weekday - 1));
      final end = start.add(const Duration(days: 7));
      return tasks.where((task) {
        final due = task.dueDate;
        if (due == null) return false;
        return due.isAfter(start.subtract(const Duration(seconds: 1))) &&
            due.isBefore(end);
      }).toList();
    }

    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 1);
    return tasks.where((task) {
      final due = task.dueDate;
      if (due == null) return false;
      return due.isAfter(start.subtract(const Duration(seconds: 1))) &&
          due.isBefore(end);
    }).toList();
  }

  void _previousPeriod() {
    setState(() {
      if (_selectedView == 0) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      } else if (_selectedView == 1) {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
      } else {
        _selectedDate = DateTime(
            _selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
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
        _selectedDate = DateTime(
            _selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
      }
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _viewLabel(int view) {
    switch (view) {
      case 1:
        return 'Week';
      case 2:
        return 'Month';
      default:
        return 'Day';
    }
  }
}

class _CalendarHeader extends StatelessWidget {
  final ThemeData theme;
  final DateTime selectedDate;
  final int selectedView;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onViewChanged;

  const _CalendarHeader({
    required this.theme,
    required this.selectedDate,
    required this.selectedView,
    required this.onPrevious,
    required this.onNext,
    required this.onViewChanged,
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: onPrevious),
                  IconButton(
                      icon: const Icon(Icons.chevron_right), onPressed: onNext),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _ViewButton(
                  label: 'Day',
                  selected: selectedView == 0,
                  onTap: () => onViewChanged(0),
                  theme: theme),
              _ViewButton(
                  label: 'Week',
                  selected: selectedView == 1,
                  onTap: () => onViewChanged(1),
                  theme: theme),
              _ViewButton(
                  label: 'Month',
                  selected: selectedView == 2,
                  onTap: () => onViewChanged(2),
                  theme: theme),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _ViewButton({
    required this.label,
    required this.selected,
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
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: selected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<TaskEntity> tasks;
  final ThemeData theme;
  final ValueChanged<DateTime> onDateSelected;

  const _MonthCalendar({
    required this.selectedDate,
    required this.tasks,
    required this.theme,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(selectedDate.year, selectedDate.month, 1);
    final offset = firstDay.weekday % 7;

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
        itemBuilder: (context, index) {
          final dayNum = index - offset + 1;
          if (dayNum < 1 ||
              dayNum >
                  DateTime(selectedDate.year, selectedDate.month + 1, 0).day) {
            return const SizedBox.shrink();
          }
          final date = DateTime(selectedDate.year, selectedDate.month, dayNum);
          final hasTask = tasks.any((task) {
            final due = task.dueDate;
            return due != null &&
                due.year == date.year &&
                due.month == date.month &&
                due.day == date.day;
          });

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
                  Text('$dayNum'),
                  if (hasTask)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle),
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

class _WeekCalendar extends StatelessWidget {
  final DateTime selectedDate;
  final List<TaskEntity> tasks;
  final ThemeData theme;
  final ValueChanged<DateTime> onDateSelected;

  const _WeekCalendar({
    required this.selectedDate,
    required this.tasks,
    required this.theme,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final weekStart =
        selectedDate.subtract(Duration(days: selectedDate.weekday - 1));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Row(
        children: List.generate(7, (index) {
          final date = weekStart.add(Duration(days: index));
          final count = tasks.where((task) {
            final due = task.dueDate;
            return due != null &&
                due.year == date.year &&
                due.month == date.month &&
                due.day == date.day;
          }).length;

          return Expanded(
            child: InkWell(
              onTap: () => onDateSelected(date),
              child: Column(
                children: [
                  Text(
                      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index]),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          _isToday(date) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$count', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          );
        }),
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

class _TaskTile extends StatelessWidget {
  final TaskEntity task;
  final ThemeData theme;

  const _TaskTile({required this.task, required this.theme});

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.schedule,
          color: task.isCompleted ? Colors.green : theme.colorScheme.primary,
        ),
        title: Text(task.title.value),
        subtitle: Text(due == null
            ? 'No due date'
            : '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')} ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}'),
        trailing: task.isOverdue
            ? Text(
                'Overdue',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              )
            : null,
      ),
    );
  }
}
