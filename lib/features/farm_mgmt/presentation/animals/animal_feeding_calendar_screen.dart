import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/core/services/local_notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/data/models/feeding_schedule.dart';
import 'package:pamoja_twalima/data/models/feeding_log.dart';
import 'package:pamoja_twalima/data/models/task.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/feeding/feeding_bloc.dart';
// Feeding entities are provided via the farm_mgmt domain entities barrel.
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/entities.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FeedInventoryOption {
  final int id;
  final String itemName;
  final String unit;

  const _FeedInventoryOption({
    required this.id,
    required this.itemName,
    required this.unit,
  });
}

class AnimalFeedingCalendarScreen extends StatefulWidget {
  const AnimalFeedingCalendarScreen({super.key});

  @override
  State<AnimalFeedingCalendarScreen> createState() =>
      _AnimalFeedingCalendarScreenState();
}

class _AnimalFeedingCalendarScreenState
    extends State<AnimalFeedingCalendarScreen> {
  final SyncData _syncData = SyncData();
  late final FeedingBloc _feedingBloc;
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'Daily';
  String _selectedAnimalFilter = 'All';
  bool _showCompleted = true;

  final List<String> _viewOptions = ['Daily', 'Weekly', 'Monthly'];
  final List<String> _animalFilters = [
    'All',
    'Cattle',
    'Poultry',
    'Goats',
    'Sheep'
  ];

  @override
  void initState() {
    super.initState();
    _feedingBloc = getIt<FeedingBloc>()..add(const FeedingEvent.load());
    _syncReminderScheduleFromPrefs();
  }

  @override
  void dispose() {
    _feedingBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocConsumer<FeedingBloc, FeedingState>(
      bloc: _feedingBloc,
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
        if (state is FeedingLoading || state is FeedingInitial) {
          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            includeDrawer: false,
            appBar: const ModernAppBar(
              title: 'Feeding Calendar',
              variant: AppBarVariant.standard,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final loaded = state.maybeWhen(
          loaded: (schedules, logs, animals) => (schedules, logs, animals),
          orElse: () => (
            <FeedingScheduleEntity>[],
            <FeedingLogEntity>[],
            <AnimalEntity>[]
          ),
        );

        final schedules = loaded.$1;
        final logs = loaded.$2;
        final animals = loaded.$3;

        final filteredSchedules = _getFilteredSchedules(schedules, animals);
        final todaysFeedings = _getTodaysFeedings(schedules);

        return AppScaffold(
          backgroundColor: theme.colorScheme.surface,
          includeDrawer: false,
          appBar: ModernAppBar(
            title: 'Feeding Calendar',
            variant: AppBarVariant.standard,
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
              _buildTodaysSummary(theme, todaysFeedings, schedules),

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
                          unselectedLabelColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
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
                            _buildScheduleTab(
                              theme,
                              filteredSchedules,
                              animals,
                            ),

                            // History Tab
                            _buildHistoryTab(theme, logs, animals),
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
            heroTag: 'logFeedingFAB',
            onPressed: _logFeeding,
            backgroundColor: theme.colorScheme.primary,
            child: const Icon(Icons.restaurant, color: Colors.white),
          ),
        );
      },
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

  Widget _buildTodaysSummary(
    ThemeData theme,
    List<FeedingScheduleEntity> todaysFeedings,
    List<FeedingScheduleEntity> allSchedules,
  ) {
    final completed = todaysFeedings.where((f) => f.completed).length;
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
                  value: '${_getUpcomingFeedings(allSchedules).length}',
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

  Widget _buildScheduleTab(
    ThemeData theme,
    List<FeedingScheduleEntity> schedules,
    List<AnimalEntity> animals,
  ) {
    final morningFeedings =
        schedules.where((s) => s.timeOfDay == 'Morning').toList();
    final afternoonFeedings =
        schedules.where((s) => s.timeOfDay == 'Afternoon').toList();
    final eveningFeedings =
        schedules.where((s) => s.timeOfDay == 'Evening').toList();

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
              getAnimalName: (id) => _getAnimalNameById(id, animals),
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
              getAnimalName: (id) => _getAnimalNameById(id, animals),
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
              getAnimalName: (id) => _getAnimalNameById(id, animals),
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
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
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

  Widget _buildHistoryTab(
    ThemeData theme,
    List<FeedingLogEntity> history,
    List<AnimalEntity> animals,
  ) {
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
          if (history.isNotEmpty)
            ...history.map((history) {
              return _FeedingHistoryCard(
                history: history,
                theme: theme,
                onDelete: _deleteFeedingHistory,
                getAnimalName: (id) => _getAnimalNameById(id, animals),
              );
            }),

          if (history.isEmpty)
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
  List<FeedingScheduleEntity> _getFilteredSchedules(
    List<FeedingScheduleEntity> schedules,
    List<AnimalEntity> animals,
  ) {
    return schedules.where((schedule) {
      // For now, filter by time of day since we don't have date in model
      final matchesFilter = _selectedAnimalFilter == 'All' ||
          _getAnimalCategoryById(schedule.animalId, animals) ==
              _selectedAnimalFilter;
      return matchesFilter;
    }).toList();
  }

  List<FeedingScheduleEntity> _getTodaysFeedings(
    List<FeedingScheduleEntity> schedules,
  ) {
    // For now, return all schedules
    return schedules;
  }

  List<FeedingScheduleEntity> _getUpcomingFeedings(
    List<FeedingScheduleEntity> schedules,
  ) {
    // For now, return all schedules
    return schedules;
  }

  double _calculateTotalFeed(List<FeedingScheduleEntity> feedings) {
    return feedings.fold(0.0, (sum, feeding) => sum + feeding.quantity);
  }

  String _getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getDayName(DateTime date) {
    final days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];
    return days[date.weekday % 7];
  }

  String _getAnimalCategory(String type) {
    if (type.contains('Cow') || type.contains('Cattle')) return 'Cattle';
    if (type.contains('Chicken') || type == 'Layers') return 'Poultry';
    if (type.contains('Goat')) return 'Goats';
    if (type.contains('Sheep')) return 'Sheep';
    return 'Other';
  }

  String _getAnimalCategoryById(
    int animalId,
    List<AnimalEntity> animals,
  ) {
    final animal = animals.firstWhere(
      (a) => int.tryParse(a.id ?? '') == animalId,
      orElse: () => AnimalEntity(
        id: null,
        name: AnimalName('Unknown'),
        type: AnimalType('other'),
      ),
    );
    return _getAnimalCategory(animal.type.value);
  }

  String _getAnimalNameById(int animalId, List<AnimalEntity> animals) {
    final animal = animals.firstWhere(
      (a) => int.tryParse(a.id ?? '') == animalId,
      orElse: () => AnimalEntity(
        id: null,
        name: AnimalName('Unknown'),
        type: AnimalType('other'),
      ),
    );
    return animal.name.value;
  }

  // Action Methods
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }

  void _toggleFeedingComplete(int scheduleId) {
    _feedingBloc.add(FeedingEvent.toggleComplete(scheduleId: scheduleId));
  }

  Future<List<_FeedInventoryOption>> _loadFeedInventoryOptions() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'inventory',
      columns: ['id', 'item_name', 'unit'],
      where: 'LOWER(category) LIKE ? OR LOWER(item_name) LIKE ?',
      whereArgs: ['%feed%', '%feed%'],
      orderBy: 'item_name ASC',
      limit: 200,
    );

    return rows
        .where((row) => row['id'] != null)
        .map(
          (row) => _FeedInventoryOption(
            id: row['id'] as int,
            itemName: (row['item_name'] ?? 'Feed').toString(),
            unit: (row['unit'] ?? 'kg').toString(),
          ),
        )
        .toList();
  }

  Future<void> _addFeedingSchedule() async {
    final state = _feedingBloc.state;
    final animals = state.maybeWhen(
      loaded: (_, __, animals) => animals,
      orElse: () => <AnimalEntity>[],
    );
    if (animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add animals first before scheduling feed')),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final feedOptions = await _loadFeedInventoryOptions();
    if (!mounted) return;
    int animalId = int.tryParse(animals.first.id ?? '') ?? 0;
    int? selectedInventoryId;
    final feedTypeController = TextEditingController(text: 'General Feed');
    final quantityController = TextEditingController(text: '2');
    String unit = 'kg';
    String timeOfDay = 'Morning';
    String frequency = 'Daily';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Feeding Schedule'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: animalId,
                items: animals
                    .where((a) => int.tryParse(a.id ?? '') != null)
                    .map(
                      (a) => DropdownMenuItem<int>(
                        value: int.parse(a.id!),
                        child: Text(a.name.value),
                      ),
                    )
                    .toList(),
                onChanged: (v) => animalId = v ?? animalId,
                decoration: const InputDecoration(labelText: 'Animal'),
              ),
              DropdownButtonFormField<int?>(
                initialValue: selectedInventoryId,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Custom feed (not linked)'),
                  ),
                  ...feedOptions.map(
                    (item) => DropdownMenuItem<int?>(
                      value: item.id,
                      child: Text(item.itemName),
                    ),
                  ),
                ],
                onChanged: (v) {
                  selectedInventoryId = v;
                  final selected = feedOptions.where((f) => f.id == v).toList();
                  if (selected.isNotEmpty) {
                    feedTypeController.text = selected.first.itemName;
                    unit = selected.first.unit;
                  }
                },
                decoration:
                    const InputDecoration(labelText: 'Feed inventory item'),
              ),
              TextFormField(
                controller: feedTypeController,
                decoration: const InputDecoration(labelText: 'Feed Type'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Feed type required'
                    : null,
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                    ? 'Enter valid quantity'
                    : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: unit,
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'grams', child: Text('grams')),
                  DropdownMenuItem(value: 'liters', child: Text('liters')),
                ],
                onChanged: (v) => unit = v ?? unit,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              DropdownButtonFormField<String>(
                initialValue: timeOfDay,
                items: const [
                  DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                  DropdownMenuItem(
                      value: 'Afternoon', child: Text('Afternoon')),
                  DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                ],
                onChanged: (v) => timeOfDay = v ?? timeOfDay,
                decoration: const InputDecoration(labelText: 'Time of Day'),
              ),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(
                      value: 'Twice daily', child: Text('Twice daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                ],
                onChanged: (v) => frequency = v ?? frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final scheduleId = await _syncData.insertFeedingSchedule(
      FeedingSchedule(
        animalId: animalId,
        inventoryId: selectedInventoryId,
        feedType: feedTypeController.text.trim(),
        quantity: double.parse(quantityController.text.trim()),
        unit: unit,
        timeOfDay: timeOfDay,
        frequency: frequency,
        startDate: DateTime.now().toIso8601String(),
        notes: null,
      ),
    );

    final selectedAnimal = animals.firstWhere(
      (a) => int.tryParse(a.id ?? '') == animalId,
      orElse: () => AnimalEntity(
        name: AnimalName('Animal'),
        type: AnimalType('other'),
      ),
    );

    await _syncData.insertTask(
      Task(
        title:
            'Feeding: ${feedTypeController.text.trim()} (${selectedAnimal.name.value})',
        description:
            'Scheduled $timeOfDay feeding (${quantityController.text.trim()} $unit, $frequency).',
        dueDate: DateTime.now().toIso8601String(),
        status: 'pending',
        sourceEventType: 'feeding',
        sourceEventId: scheduleId.toString(),
      ),
    );

    if (!mounted) return;
    _feedingBloc.add(const FeedingEvent.load());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feeding schedule created')),
    );
  }

  Future<void> _editFeedingSchedule(int scheduleId) async {
    final state = _feedingBloc.state;
    final schedules = state.maybeWhen(
      loaded: (s, _, __) => s,
      orElse: () => <FeedingScheduleEntity>[],
    );
    final existing = schedules.where((s) => s.id == scheduleId).toList();
    if (existing.isEmpty) return;
    final schedule = existing.first;

    final formKey = GlobalKey<FormState>();
    final feedOptions = await _loadFeedInventoryOptions();
    if (!mounted) return;
    int? selectedInventoryId = schedule.inventoryId;
    final feedTypeController = TextEditingController(text: schedule.feedType);
    final quantityController =
        TextEditingController(text: schedule.quantity.toStringAsFixed(2));
    String unit = schedule.unit;
    String timeOfDay = schedule.timeOfDay;
    String frequency = schedule.frequency ?? 'Daily';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Feeding Schedule'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: feedTypeController,
                decoration: const InputDecoration(labelText: 'Feed Type'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              DropdownButtonFormField<int?>(
                initialValue: selectedInventoryId,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Custom feed (not linked)'),
                  ),
                  ...feedOptions.map(
                    (item) => DropdownMenuItem<int?>(
                      value: item.id,
                      child: Text(item.itemName),
                    ),
                  ),
                ],
                onChanged: (v) {
                  selectedInventoryId = v;
                  final selected = feedOptions.where((f) => f.id == v).toList();
                  if (selected.isNotEmpty) {
                    feedTypeController.text = selected.first.itemName;
                    unit = selected.first.unit;
                  }
                },
                decoration:
                    const InputDecoration(labelText: 'Feed inventory item'),
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    ((double.tryParse(v ?? '') ?? 0) <= 0) ? 'Invalid' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: unit,
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'grams', child: Text('grams')),
                  DropdownMenuItem(value: 'liters', child: Text('liters')),
                ],
                onChanged: (v) => unit = v ?? unit,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              DropdownButtonFormField<String>(
                initialValue: timeOfDay,
                items: const [
                  DropdownMenuItem(value: 'Morning', child: Text('Morning')),
                  DropdownMenuItem(
                      value: 'Afternoon', child: Text('Afternoon')),
                  DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                ],
                onChanged: (v) => timeOfDay = v ?? timeOfDay,
                decoration: const InputDecoration(labelText: 'Time of Day'),
              ),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(
                      value: 'Twice daily', child: Text('Twice daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                ],
                onChanged: (v) => frequency = v ?? frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true) return;

    await _syncData.updateFeedingSchedule(
      FeedingSchedule(
        id: schedule.id,
        animalId: schedule.animalId,
        inventoryId: selectedInventoryId,
        feedType: feedTypeController.text.trim(),
        quantity: double.parse(quantityController.text.trim()),
        unit: unit,
        timeOfDay: timeOfDay,
        frequency: frequency,
        startDate: schedule.startDate?.toIso8601String(),
        endDate: schedule.endDate?.toIso8601String(),
        notes: schedule.notes,
        completed: schedule.completed,
      ),
    );
    if (!mounted) return;
    _feedingBloc.add(const FeedingEvent.load());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feeding schedule updated')),
    );
  }

  Future<void> _logFeeding() async {
    final state = _feedingBloc.state;
    final animals = state.maybeWhen(
      loaded: (_, __, animals) => animals,
      orElse: () => <AnimalEntity>[],
    );
    if (animals.isEmpty) return;

    final formKey = GlobalKey<FormState>();
    final feedOptions = await _loadFeedInventoryOptions();
    if (!mounted) return;
    int animalId = int.tryParse(animals.first.id ?? '') ?? 0;
    int? selectedInventoryId;
    final feedTypeController = TextEditingController(text: 'General Feed');
    final quantityController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    String unit = 'kg';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Manual Feeding Log'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                initialValue: animalId,
                items: animals
                    .where((a) => int.tryParse(a.id ?? '') != null)
                    .map(
                      (a) => DropdownMenuItem<int>(
                        value: int.parse(a.id!),
                        child: Text(a.name.value),
                      ),
                    )
                    .toList(),
                onChanged: (v) => animalId = v ?? animalId,
                decoration: const InputDecoration(labelText: 'Animal'),
              ),
              DropdownButtonFormField<int?>(
                initialValue: selectedInventoryId,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Custom feed (not linked)'),
                  ),
                  ...feedOptions.map(
                    (item) => DropdownMenuItem<int?>(
                      value: item.id,
                      child: Text(item.itemName),
                    ),
                  ),
                ],
                onChanged: (v) {
                  selectedInventoryId = v;
                  final selected = feedOptions.where((f) => f.id == v).toList();
                  if (selected.isNotEmpty) {
                    feedTypeController.text = selected.first.itemName;
                    unit = selected.first.unit;
                  }
                },
                decoration:
                    const InputDecoration(labelText: 'Feed inventory item'),
              ),
              TextFormField(
                controller: feedTypeController,
                decoration: const InputDecoration(labelText: 'Feed Type'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    ((double.tryParse(v ?? '') ?? 0) <= 0) ? 'Invalid' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: unit,
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'grams', child: Text('grams')),
                  DropdownMenuItem(value: 'liters', child: Text('liters')),
                ],
                onChanged: (v) => unit = v ?? unit,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Log'),
          ),
        ],
      ),
    );
    if (saved != true) return;

    await _syncData.insertFeedingLog(
      FeedingLog(
        animalId: animalId,
        scheduleId: null,
        inventoryId: selectedInventoryId,
        feedType: feedTypeController.text.trim(),
        quantity: double.parse(quantityController.text.trim()),
        unit: unit,
        fedAt: DateTime.now().toIso8601String(),
        fedBy: 'User',
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      ),
    );
    if (!mounted) return;
    final selectedAnimalName = _getAnimalNameById(animalId, animals);
    _feedingBloc.add(const FeedingEvent.load());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feeding log recorded')),
    );
    await _maybeCreateFeedExpense(
      inventoryId: selectedInventoryId,
      quantity: double.parse(quantityController.text.trim()),
      unit: unit,
      animalName: selectedAnimalName,
      feedType: feedTypeController.text.trim(),
    );
  }

  Future<void> _maybeCreateFeedExpense({
    required int? inventoryId,
    required double quantity,
    required String unit,
    required String animalName,
    required String feedType,
  }) async {
    if (inventoryId == null || !mounted) return;

    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'inventory',
      columns: ['item_name', 'unit_price', 'unit'],
      where: 'id = ?',
      whereArgs: [inventoryId],
      limit: 1,
    );
    if (rows.isEmpty || !mounted) return;

    final row = rows.first;
    final unitPrice = (row['unit_price'] as num?)?.toDouble();
    if (unitPrice == null || unitPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set a unit price on the feed inventory item to auto-capture feeding costs.',
          ),
        ),
      );
      return;
    }

    final itemName = (row['item_name'] ?? feedType).toString();
    final inventoryUnit = (row['unit'] ?? unit).toString();
    final estimatedAmount = quantity * unitPrice;

    final shouldCreate = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Record feed cost?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$animalName was fed $quantity $unit of $itemName.',
                ),
                const SizedBox(height: 8),
                Text(
                  'Using the inventory price of KSh ${unitPrice.toStringAsFixed(0)} per $inventoryUnit, the estimated cost is KSh ${estimatedAmount.toStringAsFixed(0)}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(false),
                        child: const Text('Later'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        child: const Text('Record Cost'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (shouldCreate != true || !mounted) return;

    await LocalData.insertExpense({
      'category': 'Feed',
      'item_name': itemName,
      'amount': estimatedAmount,
      'expense_date': DateTime.now().toIso8601String(),
      'payment_method': 'Auto from feeding log',
      'notes':
          'Auto-created from feeding log for $animalName: $quantity $unit of $feedType.',
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Feed cost recorded: KSh ${estimatedAmount.toStringAsFixed(0)}',
        ),
      ),
    );
  }

  Future<void> _showFeedInventory() async {
    final db = await DatabaseHelper().database;
    final rows = await db.query(
      'inventory',
      where: 'LOWER(category) LIKE ? OR LOWER(item_name) LIKE ?',
      whereArgs: ['%feed%', '%feed%'],
      orderBy: 'item_name ASC',
      limit: 100,
    );

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Feed Inventory'),
        content: SizedBox(
          width: double.maxFinite,
          child: rows.isEmpty
              ? const Text('No feed inventory items found.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: rows.length,
                  itemBuilder: (_, i) {
                    final row = rows[i];
                    final qty = (row['quantity'] as num?)?.toDouble() ?? 0;
                    final min = (row['min_stock'] as num?)?.toDouble() ?? 0;
                    final low = min > 0 && qty <= min;
                    return ListTile(
                      dense: true,
                      title: Text((row['item_name'] ?? 'Item').toString()),
                      subtitle: Text(
                        '${qty.toStringAsFixed(1)} ${(row['unit'] ?? '')} • Min ${min.toStringAsFixed(0)}',
                      ),
                      trailing: Text(
                        low ? 'Low' : 'OK',
                        style: TextStyle(
                          color: low ? Colors.red : Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _startAllFeedings(String timeOfDay) {
    final state = _feedingBloc.state;
    final schedules = state.maybeWhen(
      loaded: (s, _, __) => s,
      orElse: () => <FeedingScheduleEntity>[],
    );
    var count = 0;
    for (final schedule in schedules) {
      if ((schedule.timeOfDay == timeOfDay) &&
          !schedule.completed &&
          schedule.id != null) {
        count++;
        _feedingBloc.add(FeedingEvent.toggleComplete(scheduleId: schedule.id!));
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Started $count $timeOfDay feeding(s)')),
    );
  }

  void _completeAllTodaysFeedings() async {
    final state = _feedingBloc.state;
    final schedules = state.maybeWhen(
      loaded: (s, _, __) => s,
      orElse: () => <FeedingScheduleEntity>[],
    );
    final todaysSchedules = _getTodaysFeedings(schedules);
    for (final schedule in todaysSchedules) {
      if (schedule.completed) continue;
      _feedingBloc
          .add(FeedingEvent.toggleComplete(scheduleId: schedule.id ?? 0));
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('All today\'s feedings marked as completed!')),
    );
  }

  Future<void> _setFeedingReminders() async {
    const keyEnabled = 'feeding_reminders_enabled';
    const keyTimes = 'feeding_reminder_times';
    final prefs = await SharedPreferences.getInstance();
    var enabled = prefs.getBool(keyEnabled) ?? true;
    final saved = prefs.getStringList(keyTimes) ?? <String>[];
    var morning = saved.contains('Morning');
    var afternoon = saved.contains('Afternoon');
    var evening = saved.contains('Evening');

    if (!mounted) return;
    final changed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setLocalState) => AlertDialog(
          title: const Text('Feeding Reminders'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: enabled,
                title: const Text('Enable Reminders'),
                onChanged: (v) => setLocalState(() => enabled = v),
              ),
              CheckboxListTile(
                value: morning,
                title: const Text('Morning'),
                onChanged: enabled
                    ? (v) => setLocalState(() => morning = v ?? false)
                    : null,
              ),
              CheckboxListTile(
                value: afternoon,
                title: const Text('Afternoon'),
                onChanged: enabled
                    ? (v) => setLocalState(() => afternoon = v ?? false)
                    : null,
              ),
              CheckboxListTile(
                value: evening,
                title: const Text('Evening'),
                onChanged: enabled
                    ? (v) => setLocalState(() => evening = v ?? false)
                    : null,
              ),
            ],
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
        ),
      ),
    );
    if (changed != true) return;
    await prefs.setBool(keyEnabled, enabled);
    final times = <String>[
      if (morning) 'Morning',
      if (afternoon) 'Afternoon',
      if (evening) 'Evening',
    ];
    await prefs.setStringList(keyTimes, times);
    await LocalNotificationService.instance.scheduleFeedingReminders(
      enabled: enabled,
      times: times,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          enabled
              ? 'Reminders saved (${times.isEmpty ? 'no times selected' : times.join(', ')})'
              : 'Reminders disabled',
        ),
      ),
    );
  }

  Future<void> _syncReminderScheduleFromPrefs() async {
    const keyEnabled = 'feeding_reminders_enabled';
    const keyTimes = 'feeding_reminder_times';
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(keyEnabled) ?? true;
    final times = prefs.getStringList(keyTimes) ?? const <String>[];
    await LocalNotificationService.instance.scheduleFeedingReminders(
      enabled: enabled,
      times: times,
    );
  }

  void _deleteFeedingHistory(int historyId) {
    _feedingBloc.add(FeedingEvent.deleteHistory(logId: historyId));
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to clear all feeding history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _feedingBloc.add(const FeedingEvent.load());
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

  // Data loading is now handled in _loadData()
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
  final List<FeedingScheduleEntity> feedings;
  final ThemeData theme;
  final Function(int) onToggleComplete;
  final Function(int) onEdit;
  final String Function(int) getAnimalName;

  const _FeedingTimeSection({
    required this.timeOfDay,
    required this.feedings,
    required this.theme,
    required this.onToggleComplete,
    required this.onEdit,
    required this.getAnimalName,
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
                  getAnimalName: getAnimalName,
                )),
          ],
        ),
      ),
    );
  }

  int _getTimeOfDayIndex(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return 1;
      case 'Afternoon':
        return 2;
      case 'Evening':
        return 3;
      default:
        return 0;
    }
  }

  IconData _getTimeOfDayIcon(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return Icons.wb_sunny;
      case 'Afternoon':
        return Icons.brightness_5;
      case 'Evening':
        return Icons.nights_stay;
      default:
        return Icons.schedule;
    }
  }

  Color _getTimeOfDayColor(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return Colors.orange;
      case 'Afternoon':
        return Colors.blue;
      case 'Evening':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

class _FeedingScheduleCard extends StatelessWidget {
  final FeedingScheduleEntity feeding;
  final ThemeData theme;
  final Function(int) onToggleComplete;
  final Function(int) onEdit;
  final String Function(int) getAnimalName;

  const _FeedingScheduleCard({
    required this.feeding,
    required this.theme,
    required this.onToggleComplete,
    required this.onEdit,
    required this.getAnimalName,
  });

  @override
  Widget build(BuildContext context) {
    final animalName = getAnimalName(feeding.animalId);
    final timeString = _getTimeString(feeding.timeOfDay);

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
            value: feeding.completed,
            onChanged: (_) => onToggleComplete(feeding.id!),
            activeColor: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animalName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: feeding.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: feeding.completed
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${feeding.feedType} • ${feeding.quantity} ${feeding.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (feeding.notes != null && feeding.notes!.isNotEmpty)
                  Text(
                    'Note: ${feeding.notes}',
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
                timeString,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => onEdit(feeding.id!),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeString(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return '6:30 AM';
      case 'Afternoon':
        return '2:00 PM';
      case 'Evening':
        return '5:30 PM';
      default:
        return 'Unknown';
    }
  }
}

class _FeedingHistoryCard extends StatelessWidget {
  final FeedingLogEntity history;
  final ThemeData theme;
  final Function(int) onDelete;
  final String Function(int) getAnimalName;

  const _FeedingHistoryCard({
    required this.history,
    required this.theme,
    required this.onDelete,
    required this.getAnimalName,
  });

  @override
  Widget build(BuildContext context) {
    final animalName = getAnimalName(history.animalId);
    final fedDate = history.fedAt.toLocal();
    final timeString =
        '${fedDate.hour}:${fedDate.minute.toString().padLeft(2, '0')}';

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
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.pets,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animalName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${history.feedType} • ${history.quantity} ${history.unit} • $timeString',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  fedDate.toString().split(' ')[0],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            onPressed: () => onDelete(history.id!),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
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
            boxShadow: [AppColors.subtleShadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
