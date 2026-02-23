import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/overview_summary_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/navigation/farm_nav_cubit.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/overview/overview_bloc.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/tasks/tasks_bloc.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/tasks/widgets/task_list_item_card.dart';
import 'package:pamoja_twalima/features/business/presentation/sales/sales_screen.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<OverviewBloc>()..add(const OverviewEvent.load()),
        ),
        BlocProvider(
          create: (_) => getIt<TasksBloc>()..add(const TasksEvent.load()),
        ),
      ],
      child: BlocBuilder<OverviewBloc, OverviewState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (summary) => BlocBuilder<TasksBloc, TasksState>(
              builder: (context, tasksState) {
                final allTasks = tasksState.maybeWhen<List<TaskEntity>>(
                  loaded: (tasks) => tasks,
                  orElse: () => const <TaskEntity>[],
                );
                return _buildContent(theme, summary, allTasks);
              },
            ),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(message),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context
                        .read<OverviewBloc>()
                        .add(const OverviewEvent.load()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    OverviewSummaryEntity summary,
    List<TaskEntity> tasks,
  ) {
    final pendingTaskCount = tasks.where((task) => !task.isCompleted).length;
    final upcomingTasks = List<TaskEntity>.from(
      tasks.where((task) => !task.isCompleted),
    )..sort((a, b) {
        final aDue = a.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDue = b.dueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aDue.compareTo(bDue);
      });

    return FutureBuilder<_OverviewFeedData>(
      future: _loadFeedData(),
      builder: (context, snapshot) {
        final feed = snapshot.data ?? const _OverviewFeedData();

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Crops',
                        value: '${summary.totalCrops}',
                        icon: Icons.agriculture,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Animals',
                        value: '${summary.totalAnimals}',
                        icon: Icons.pets,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Sales',
                        value: 'KSh ${summary.balance.toStringAsFixed(0)}',
                        icon: Icons.attach_money,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        count: pendingTaskCount,
                        label: 'Pending Tasks',
                        color: Colors.orange,
                        icon: Icons.task_alt,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        count: summary.lowStockItems,
                        label: 'Low Stock',
                        color: Colors.red,
                        icon: Icons.warning_amber,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Production Overview',
                      icon: Icons.bar_chart,
                      actionLabel: '7 Days',
                      onActionTap: () {
                        context.read<FarmNavCubit>().select(2);
                      },
                    ),
                    const SizedBox(height: 8),
                    _ProductionTrendCard(values: feed.productionTrend, theme: theme),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Upcoming Tasks',
                icon: Icons.schedule,
                actionLabel: 'View All',
                onActionTap: () {
                  final navCubit = context.read<FarmNavCubit>();
                  navCubit.select(3);
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= upcomingTasks.length) {
                      return ListItemCard(
                        icon: Icons.task_alt,
                        iconColor: AppColors.primary,
                        title: 'No upcoming tasks',
                        subtitle: 'New tasks will appear here.',
                      );
                    }

                    final task = upcomingTasks[index];
                    return TaskListItemCard(
                      key: ValueKey('overview_task_${task.id ?? index}'),
                      task: task,
                      compact: true,
                      showOriginBadge: false,
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
                        );
                        context.read<TasksBloc>().add(TasksEvent.update(task: updated));
                        context.read<OverviewBloc>().add(const OverviewEvent.load());
                      },
                      onTap: () {
                        context.read<FarmNavCubit>().select(3);
                      },
                    );
                  },
                  childCount: upcomingTasks.isEmpty ? 1 : upcomingTasks.take(4).length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recent Sales',
                icon: Icons.receipt_long,
                actionLabel: 'Business',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SalesScreen()),
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final sale = feed.sales[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ListItemCard(
                        icon: Icons.paid,
                        iconColor: Colors.green,
                        title: sale.item,
                        subtitle: sale.dateLabel,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'KSh ${sale.amount.toStringAsFixed(0)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              sale.status,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: sale.status.toLowerCase() == 'paid'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: feed.sales.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Future<_OverviewFeedData> _loadFeedData() async {
    final salesRows = await LocalData.getRecentSales(limit: 4);
    final productionRows = await LocalData.getProductionTrend(days: 7);

    final sales = salesRows.map((row) {
      final saleDate = DateTime.tryParse((row['sale_date'] ?? '').toString());
      return _OverviewSaleItem(
        item: (row['product_name'] ?? 'Sale').toString(),
        amount: (row['total_amount'] as num?)?.toDouble() ?? 0.0,
        dateLabel: _relativeDate(saleDate),
        status: ((row['payment_status'] ?? 'pending').toString()),
      );
    }).toList();

    final trend = productionRows
        .map((row) => (row['total'] as num?)?.toDouble() ?? 0.0)
        .toList();

    return _OverviewFeedData(
      sales: sales,
      productionTrend: trend,
    );
  }

  String _relativeDate(DateTime? date) {
    if (date == null) return 'No date';
    final now = DateTime.now();
    final dayOnly = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final delta = dayOnly.difference(today).inDays;
    if (delta == 0) return 'Today';
    if (delta == 1) return 'Tomorrow';
    if (delta == -1) return 'Yesterday';
    if (delta > 1) return 'In $delta days';
    return '${delta.abs()} days ago';
  }
}

class _OverviewSaleItem {
  final String item;
  final double amount;
  final String dateLabel;
  final String status;

  const _OverviewSaleItem({
    required this.item,
    required this.amount,
    required this.dateLabel,
    required this.status,
  });
}

class _OverviewFeedData {
  final List<_OverviewSaleItem> sales;
  final List<double> productionTrend;

  const _OverviewFeedData({
    this.sales = const [],
    this.productionTrend = const [],
  });
}

class _ProductionTrendCard extends StatelessWidget {
  final List<double> values;
  final ThemeData theme;

  const _ProductionTrendCard({
    required this.values,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isEmpty
        ? 1.0
        : values.reduce((a, b) => a > b ? a : b).clamp(1, double.infinity);
    final now = DateTime.now();

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: values.isEmpty
          ? Center(
              child: Text(
                'No production logs yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final value = values[index];
                final ratio = (value / maxValue).clamp(0.05, 1.0);
                final day = now.subtract(Duration(days: values.length - 1 - index));

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 85 * ratio,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _weekday(day.weekday),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
    );
  }

  String _weekday(int day) {
    switch (day) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '-';
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.2),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
