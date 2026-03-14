import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/animations/animated_card.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/contact_directory_service.dart';
import 'package:pamoja_twalima/features/business/presentation/sales/sales_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/animals/animal_feeding_calendar_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/animals/production_logging_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/tasks/widgets/task_list_item_card.dart';
import 'package:pamoja_twalima/features/inventory/presentation/inventory_screen.dart';
import 'add_task_screen.dart';
import 'task_detail_screen.dart';
import 'task_calendar_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final ContactDirectoryService _contactService =
      ContactDirectoryService(ApiService());
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String _selectedFilter = 'All';
  String _selectedStatus = 'All';
  String _selectedAssignee = 'Anyone';
  String _queueMode = 'Overview';
  String _currentUserName = 'Self';
  Map<String, dynamic>? _farmContext;
  List<String> _staffNames = const [];

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
    'Waiting approval',
    'Overdue',
    'Completed'
  ];

  List<String> get _assigneeOptions => [
        'Anyone',
        'Unassigned',
        'Self',
        ..._staffNames.where((name) => name != 'Self'),
      ];

  List<String> get _queueModes => [
        if (!_isWorkerRole) 'Overview',
        'My Queue',
        'Team Queue',
        if (_canApproveRole) 'Approval Queue',
      ];

  bool get _isWorkerRole {
    final membership = _coerceMap(_farmContext?['membership']);
    final role = (membership['role'] ?? 'owner').toString().toLowerCase();
    return role == 'worker' || role == 'staff';
  }

  bool get _canApproveRole {
    final membership = _coerceMap(_farmContext?['membership']);
    final role = (membership['role'] ?? 'owner').toString().toLowerCase();
    return const {'owner', 'manager', 'accountant'}.contains(role);
  }

  @override
  void initState() {
    super.initState();
    _loadTeamContext();
  }

  Future<void> _loadTeamContext() async {
    try {
      final rows = await _contactService.list(ContactType.staffMember);
      final contextData = await _contactService.farmContext();
      final currentUserName = await _storage.read(key: 'user_name');
      if (!mounted) return;
      final membership = _coerceMap(contextData['membership']);
      final membershipRole =
          (membership['role'] ?? 'owner').toString().toLowerCase();
      setState(() {
        _farmContext = contextData;
        _currentUserName = currentUserName?.trim().isNotEmpty == true
            ? currentUserName!.trim()
            : 'Self';
        _staffNames = rows
            .map((row) => (row['name'] ?? '').toString().trim())
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
        if (membershipRole == 'worker' || membershipRole == 'staff') {
          _queueMode = 'My Queue';
          _selectedAssignee = _currentUserName;
        } else if (_canApproveRole) {
          _queueMode = 'Approval Queue';
          _selectedStatus = 'Waiting approval';
        }
      });
    } catch (_) {}
  }

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
            final assignee = task.assignedTo?.trim();
            final assigneeMatch = switch (_selectedAssignee) {
              'Anyone' => true,
              'Unassigned' => assignee == null || assignee.isEmpty,
              'Self' => assignee == 'Self',
              _ => assignee == _selectedAssignee,
            };
            final queueMatch = switch (_queueMode) {
              'My Queue' => assignee == _currentUserName ||
                  assignee == 'Self' ||
                  assignee == null ||
                  assignee.isEmpty,
              'Team Queue' =>
                assignee != _currentUserName && assignee != 'Self',
              'Approval Queue' => task.isAwaitingApproval,
              _ => true,
            };
            return categoryMatch && statusMatch && assigneeMatch && queueMatch;
          }).toList();

          final pendingCount =
              tasks.where((task) => _statusKey(task) == 'pending').length;
          final overdueCount =
              tasks.where((task) => _statusKey(task) == 'overdue').length;
          final completedCount =
              tasks.where((task) => _statusKey(task) == 'completed').length;
          final waitingApprovalCount =
              tasks.where((task) => task.isAwaitingApproval).length;
          final approvedThisWeekCount = tasks.where((task) {
            final approvedAt = task.approvedAt;
            if (approvedAt == null || !task.isApproved) return false;
            return DateTime.now().difference(approvedAt).inDays <= 7;
          }).length;
          final sentBackThisWeekCount = tasks.where((task) {
            final approvedAt = task.approvedAt;
            if (!task.isRejected) return false;
            if (approvedAt != null) {
              return DateTime.now().difference(approvedAt).inDays <= 7;
            }
            return (task.approvalComment ?? '').trim().isNotEmpty;
          }).length;
          final reviewerCounts = <String, int>{};
          for (final task in tasks) {
            final reviewer = (task.approvedBy ?? '').trim();
            if (reviewer.isEmpty) continue;
            reviewerCounts.update(reviewer, (value) => value + 1,
                ifAbsent: () => 1);
          }
          String topReviewer = '';
          if (reviewerCounts.isNotEmpty) {
            final sorted = reviewerCounts.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            topReviewer = sorted.first.key;
          }
          final myQueueTasks = tasks.where((task) {
            final assignee = task.assignedTo?.trim();
            return assignee == _currentUserName ||
                assignee == 'Self' ||
                assignee == null ||
                assignee.isEmpty;
          }).toList();
          final myDueTodayCount = myQueueTasks
              .where((task) =>
                  task.dueDate != null &&
                  !_isDifferentDay(task.dueDate!, DateTime.now()))
              .length;
          final myReadyToFinishCount = myQueueTasks
              .where((task) => !task.isCompleted && !task.isAwaitingApproval)
              .length;
          final assignedCount = tasks
              .where((task) => (task.assignedTo?.trim().isNotEmpty ?? false))
              .length;
          final unassignedCount = tasks.length - assignedCount;
          final staffSummary = _coerceMap(_farmContext?['team_summary']);
          final roleSummary = _coerceMap(staffSummary['roles']);
          final membership = _coerceMap(_farmContext?['membership']);
          final currentRole =
              (membership['role'] ?? 'owner').toString().toLowerCase();

          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            body: CustomScrollView(
              slivers: [
                // Header with task stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 170,
                          child: _TaskStat(
                            count: pendingCount,
                            label: 'Pending',
                            color: Colors.orange,
                            theme: theme,
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: _TaskStat(
                            count: overdueCount,
                            label: 'Overdue',
                            color: Colors.red,
                            theme: theme,
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: _TaskStat(
                            count: completedCount,
                            label: 'Completed',
                            color: Colors.green,
                            theme: theme,
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: _TaskStat(
                            count: waitingApprovalCount,
                            label: 'Waiting approval',
                            color: Colors.deepPurple,
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: CollapsibleCardSection(
                      title: 'Role focus',
                      icon: Icons.person_search_outlined,
                      child: _TaskRoleFocusCard(
                        theme: theme,
                        currentRole: currentRole,
                        queueMode: _queueMode,
                        currentUserName: _currentUserName,
                        waitingApprovalCount: waitingApprovalCount,
                        myDueTodayCount: myDueTodayCount,
                        myReadyToFinishCount: myReadyToFinishCount,
                        onJumpToMyQueue: () => setState(() {
                          _queueMode = 'My Queue';
                          _selectedAssignee = _currentUserName;
                          _selectedStatus = 'All';
                        }),
                        onJumpToApproval: _canApproveRole
                            ? () => setState(() {
                                  _queueMode = 'Approval Queue';
                                  _selectedStatus = 'Waiting approval';
                                  _selectedAssignee = 'Anyone';
                                })
                            : null,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: CollapsibleCardSection(
                      title: 'Task desk',
                      icon: Icons.space_dashboard_outlined,
                      initiallyExpanded: false,
                      child: _TaskOperationsCard(
                        theme: theme,
                        farmContext: _farmContext,
                        assignedCount: assignedCount,
                        unassignedCount: unassignedCount,
                        waitingApprovalCount: waitingApprovalCount,
                        approvedThisWeekCount: approvedThisWeekCount,
                        sentBackThisWeekCount: sentBackThisWeekCount,
                        topReviewer: topReviewer,
                        roleSummary: roleSummary,
                      ),
                    ),
                  ),
                ),

                // Filter Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _QueueModeBar(
                      theme: theme,
                      currentUserName: _currentUserName,
                      currentRole: currentRole,
                      selectedMode: _queueMode,
                      modes: _queueModes,
                      onSelected: (mode) {
                        setState(() {
                          _queueMode = mode;
                          if (mode == 'My Queue') {
                            _selectedAssignee = _currentUserName;
                            _selectedStatus = 'All';
                          } else if (mode == 'Approval Queue') {
                            _selectedStatus = 'Waiting approval';
                            _selectedAssignee = 'Anyone';
                          } else if (mode == 'Team Queue' &&
                              _selectedAssignee == _currentUserName) {
                            _selectedAssignee = 'Anyone';
                          }
                        });
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 220,
                          child: _TaskFilterDropdown(
                            value: _selectedFilter,
                            items: _filters,
                            onChanged: _queueMode == 'Approval Queue'
                                ? null
                                : (value) =>
                                    setState(() => _selectedFilter = value!),
                            theme: theme,
                          ),
                        ),
                        SizedBox(
                          width: 180,
                          child: _TaskFilterDropdown(
                            value: _selectedStatus,
                            items: _statusOptions,
                            onChanged: _queueMode == 'Approval Queue'
                                ? null
                                : (value) =>
                                    setState(() => _selectedStatus = value!),
                            theme: theme,
                          ),
                        ),
                        SizedBox(
                          width: 200,
                          child: _TaskFilterDropdown(
                            value: _queueMode == 'My Queue'
                                ? (_assigneeOptions.contains(_currentUserName)
                                    ? _currentUserName
                                    : 'Self')
                                : _assigneeOptions.contains(_selectedAssignee)
                                    ? _selectedAssignee
                                    : _assigneeOptions.first,
                            items: _assigneeOptions,
                            onChanged: _queueMode == 'My Queue' ||
                                    _queueMode == 'Approval Queue'
                                ? null
                                : (value) => setState(
                                      () => _selectedAssignee = value!,
                                    ),
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
                          child: TaskListItemCard(
                            task: task,
                            quickActionLabel: _quickActionLabel(task),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<TasksBloc>(),
                                    child: TaskDetailScreen.fromEntity(
                                      entity: task,
                                      currentRole: currentRole,
                                      currentUserName: _currentUserName,
                                    ),
                                  ),
                                ),
                              );
                            },
                            onQuickAction: () => _openTaskWorkflow(task),
                            onToggleComplete: () {
                              final updated = TaskEntity(
                                id: task.id,
                                title: task.title,
                                description: task.description,
                                dueDate: task.dueDate,
                                isCompleted: !task.isCompleted,
                                assignedTo: task.assignedTo,
                                staffMemberId: task.staffMemberId,
                                sourceEventType: task.sourceEventType,
                                sourceEventId: task.sourceEventId,
                                approvalRequired: task.approvalRequired,
                                approvalStatus: task.approvalStatus,
                                approvedBy: task.approvedBy,
                                approvedAt: task.approvedAt,
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
            floatingActionButton: AppFabStack(
              actions: [
                AppFabAction(
                  heroTag: 'calendar',
                  icon: Icons.calendar_today,
                  tooltip: 'Task calendar',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TaskCalendarScreen(),
                      ),
                    );
                  },
                  backgroundColor: theme.colorScheme.secondary,
                  mini: true,
                ),
                AppFabAction(
                  heroTag: 'addTaskFAB',
                  icon: Icons.add,
                  tooltip: 'Add task',
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTaskScreen(
                          currentRole: currentRole,
                          currentUserName: _currentUserName,
                        ),
                      ),
                    );
                    if (result is! TaskEntity) return;
                    if (!context.mounted) return;
                    context.read<TasksBloc>().add(TasksEvent.add(task: result));
                  },
                  backgroundColor: theme.colorScheme.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _statusKey(TaskEntity task) {
    if (task.isAwaitingApproval) return 'waiting_approval';
    if (task.isCompleted) return 'completed';
    if (task.isOverdue) return 'overdue';
    return 'pending';
  }

  String _statusLabel(TaskEntity task) {
    switch (_statusKey(task)) {
      case 'pending':
        return 'Pending';
      case 'waiting_approval':
        return 'Waiting approval';
      case 'overdue':
        return 'Overdue';
      case 'completed':
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  String _taskCategory(TaskEntity task) {
    switch ((task.sourceEventType ?? '').toLowerCase()) {
      case 'crop':
      case 'crops':
        return 'Crops';
      case 'animal':
      case 'animals':
        return 'Animals';
      case 'breeding':
      case 'feeding':
        return 'Animals';
    }
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

  Map<String, dynamic> _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }

  bool _isDifferentDay(DateTime left, DateTime right) {
    return left.year != right.year ||
        left.month != right.month ||
        left.day != right.day;
  }

  String? _quickActionLabel(TaskEntity task) {
    switch (_workflowType(task)) {
      case _TaskWorkflowType.feeding:
        return 'Open Feeding';
      case _TaskWorkflowType.production:
        return 'Log Production';
      case _TaskWorkflowType.inventory:
        return 'Open Inventory';
      case _TaskWorkflowType.sales:
        return 'Open Sales';
      case _TaskWorkflowType.farm:
        return null;
      case _TaskWorkflowType.none:
        return null;
    }
  }

  Future<void> _openTaskWorkflow(TaskEntity task) async {
    final workflow = _workflowType(task);
    Widget? screen;
    switch (workflow) {
      case _TaskWorkflowType.feeding:
        screen = const AnimalFeedingCalendarScreen();
        break;
      case _TaskWorkflowType.production:
        screen = const ProductionLoggingScreen();
        break;
      case _TaskWorkflowType.inventory:
        screen = const InventoryScreen();
        break;
      case _TaskWorkflowType.sales:
        screen = const SalesScreen();
        break;
      case _TaskWorkflowType.farm:
      case _TaskWorkflowType.none:
        return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen!),
    );
    if (!mounted) return;
    context.read<TasksBloc>().add(const TasksEvent.load());
  }

  _TaskWorkflowType _workflowType(TaskEntity task) {
    final source = (task.sourceEventType ?? '').trim().toLowerCase();
    final text =
        '${task.title.value} ${task.description ?? ''}'.trim().toLowerCase();

    if (source == 'feeding' ||
        text.contains('feeding') ||
        text.contains('ration') ||
        text.contains('feed plan')) {
      return _TaskWorkflowType.feeding;
    }
    if (source == 'production' ||
        text.contains('production') ||
        text.contains('milk') ||
        text.contains('eggs')) {
      return _TaskWorkflowType.production;
    }
    if (source == 'inventory' ||
        text.contains('stock') ||
        text.contains('restock') ||
        text.contains('inventory')) {
      return _TaskWorkflowType.inventory;
    }
    if (source == 'sale' ||
        source == 'marketplace' ||
        text.contains('sale') ||
        text.contains('buyer') ||
        text.contains('collection') ||
        text.contains('payment')) {
      return _TaskWorkflowType.sales;
    }
    if (source == 'harvest' || source == 'crop' || source == 'animal') {
      return _TaskWorkflowType.farm;
    }
    return _TaskWorkflowType.none;
  }
}

enum _TaskWorkflowType { none, feeding, production, inventory, sales, farm }

class _TaskRoleFocusCard extends StatelessWidget {
  const _TaskRoleFocusCard({
    required this.theme,
    required this.currentRole,
    required this.queueMode,
    required this.currentUserName,
    required this.waitingApprovalCount,
    required this.myDueTodayCount,
    required this.myReadyToFinishCount,
    required this.onJumpToMyQueue,
    this.onJumpToApproval,
  });

  final ThemeData theme;
  final String currentRole;
  final String queueMode;
  final String currentUserName;
  final int waitingApprovalCount;
  final int myDueTodayCount;
  final int myReadyToFinishCount;
  final VoidCallback onJumpToMyQueue;
  final VoidCallback? onJumpToApproval;

  @override
  Widget build(BuildContext context) {
    final role = currentRole.toLowerCase();
    final isWorker = role == 'worker' || role == 'staff';
    final headline = isWorker
        ? 'Work from your queue and finish what is on your hands first.'
        : waitingApprovalCount > 0
            ? '$waitingApprovalCount task${waitingApprovalCount == 1 ? '' : 's'} need sign-off.'
            : 'Team work is flowing. Review queue health and reassign when needed.';
    final detail = isWorker
        ? '$myReadyToFinishCount task${myReadyToFinishCount == 1 ? '' : 's'} are ready for you to finish, and $myDueTodayCount are due today.'
        : queueMode == 'Approval Queue'
            ? 'Approve clear work quickly and send back anything that still needs changes.'
            : 'Use the approval queue for repairs, stock movement, spending, and other sensitive work.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWorker
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.deepPurple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isWorker ? '$currentUserName work queue' : 'Manager review lane',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onJumpToMyQueue,
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('My Queue'),
              ),
              if (!isWorker && onJumpToApproval != null)
                ElevatedButton.icon(
                  onPressed: onJumpToApproval,
                  icon: const Icon(Icons.verified_outlined),
                  label: const Text('Approval Queue'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskOperationsCard extends StatelessWidget {
  const _TaskOperationsCard({
    required this.theme,
    required this.farmContext,
    required this.assignedCount,
    required this.unassignedCount,
    required this.waitingApprovalCount,
    required this.approvedThisWeekCount,
    required this.sentBackThisWeekCount,
    required this.topReviewer,
    required this.roleSummary,
  });

  final ThemeData theme;
  final Map<String, dynamic>? farmContext;
  final int assignedCount;
  final int unassignedCount;
  final int waitingApprovalCount;
  final int approvedThisWeekCount;
  final int sentBackThisWeekCount;
  final String topReviewer;
  final Map<String, dynamic> roleSummary;

  @override
  Widget build(BuildContext context) {
    final farm = _coerceMap(farmContext?['farm']);
    final membership = _coerceMap(farmContext?['membership']);
    final teamSummary = _coerceMap(farmContext?['team_summary']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${(farm['name'] ?? 'Farm').toString()} task desk',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Signed in as ${(membership['role'] ?? 'owner').toString()}. Assign work clearly so workers see exactly what is theirs and managers can spot bottlenecks quickly.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TaskMetaChip(
                label: '${teamSummary['staff_count'] ?? 0} team members',
                color: theme.colorScheme.primary,
              ),
              _TaskMetaChip(
                label: '$assignedCount assigned tasks',
                color: Colors.green,
              ),
              _TaskMetaChip(
                label: '$unassignedCount unassigned tasks',
                color: Colors.orange,
              ),
              if (waitingApprovalCount > 0)
                _TaskMetaChip(
                  label: '$waitingApprovalCount waiting approval',
                  color: Colors.deepPurple,
                ),
              _TaskMetaChip(
                label: '$approvedThisWeekCount approved this week',
                color: Colors.teal,
              ),
              if (sentBackThisWeekCount > 0)
                _TaskMetaChip(
                  label: '$sentBackThisWeekCount sent back',
                  color: Colors.redAccent,
                ),
              ...roleSummary.entries.take(3).map(
                    (entry) => _TaskMetaChip(
                      label: '${entry.key}: ${entry.value}',
                      color: Colors.blueGrey,
                    ),
                  ),
            ],
          ),
          if (approvedThisWeekCount > 0 ||
              sentBackThisWeekCount > 0 ||
              topReviewer.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              topReviewer.isEmpty
                  ? 'Recent reviews are moving through the desk. Keep sign-off comments specific so workers know exactly what changed.'
                  : 'Recent approvals are moving through $topReviewer most often. Use that review history to coach workers and balance manager load.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, dynamic> _coerceMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return const <String, dynamic>{};
  }
}

class _QueueModeBar extends StatelessWidget {
  const _QueueModeBar({
    required this.theme,
    required this.currentUserName,
    required this.currentRole,
    required this.selectedMode,
    required this.modes,
    required this.onSelected,
  });

  final ThemeData theme;
  final String currentUserName;
  final String currentRole;
  final String selectedMode;
  final List<String> modes;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final roleLabel = currentRole.isEmpty ? 'owner' : currentRole;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$currentUserName • ${_titleCase(roleLabel)} mode',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedMode == 'My Queue'
                ? 'Focused on the tasks that need your attention first.'
                : selectedMode == 'Team Queue'
                    ? 'Review what is sitting with the wider team and where workload may be uneven.'
                    : 'See the whole farm task picture before drilling into individual queues.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: modes
                .map(
                  (mode) => ChoiceChip(
                    label: Text(mode),
                    selected: selectedMode == mode,
                    onSelected: (_) => onSelected(mode),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _TaskMetaChip extends StatelessWidget {
  const _TaskMetaChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
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
    return MetricTile(
      label: label,
      value: count.toString(),
      icon: Icons.assignment_outlined,
      color: color,
      compact: true,
    );
  }
}

class _TaskFilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;
  final ThemeData theme;

  const _TaskFilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onChanged == null ? 0.65 : 1,
      child: IgnorePointer(
        ignoring: onChanged == null,
        child: FilterDropdown(
          value: value,
          items: items,
          onChanged: onChanged ?? (_) {},
        ),
      ),
    );
  }
}
