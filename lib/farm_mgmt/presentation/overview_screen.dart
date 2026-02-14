import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/overview_summary_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/presentation/bloc/overview/overview_bloc.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<_OverviewTaskItem> recentTasks = const [
    _OverviewTaskItem(title: "Irrigate maize field", due: "Today", done: false),
    _OverviewTaskItem(
        title: "Vaccinate chickens", due: "Tomorrow", done: false),
    _OverviewTaskItem(title: "Harvest tomatoes", due: "In 2 days", done: false),
  ];

  final List<_OverviewExpenseItem> recentExpenses = const [
    _OverviewExpenseItem(
        item: "Fertilizer purchase", amount: 1500, date: "2 days ago"),
    _OverviewExpenseItem(item: "Animal feed", amount: 800, date: "1 week ago"),
    _OverviewExpenseItem(item: "Seeds", amount: 1200, date: "2 weeks ago"),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => getIt<OverviewBloc>()..add(const OverviewEvent.load()),
      child: BlocBuilder<OverviewBloc, OverviewState>(
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: CircularProgressIndicator()),
            loading: () => const Center(child: CircularProgressIndicator()),
            loaded: (summary) {
              return _buildContent(context, theme, summary);
            },
            error: (message) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade300),
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
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    OverviewSummaryEntity summary,
  ) {
    return CustomScrollView(
      slivers: [
        // Summary Cards
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: "Crops",
                    value: "${summary.totalCrops}",
                    icon: Icons.agriculture,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: "Animals",
                    value: "${summary.totalAnimals}",
                    icon: Icons.pets,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    title: "Sales",
                    value: "KSh ${summary.balance}",
                    icon: Icons.attach_money,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Quick Stats
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    count: summary.pendingTasks,
                    label: "Pending Tasks",
                    color: Colors.orange,
                    icon: Icons.task_alt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    count: summary.lowStockItems,
                    label: "Low Stock",
                    color: Colors.red,
                    icon: Icons.warning_amber,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Production Overview
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: "Production Overview",
                  icon: Icons.bar_chart,
                  actionLabel: "View All",
                  onActionTap: () {},
                ),
                const SizedBox(height: 8),
                Container(
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.insights,
                          size: 48,
                          color: AppColors.primary.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Production charts coming soon",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Upcoming Tasks
        SliverToBoxAdapter(
          child: SectionHeader(
            title: "Upcoming Tasks",
            icon: Icons.schedule,
            actionLabel: "View All",
            onActionTap: () {},
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final task = recentTasks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListItemCard(
                    icon: Icons.task_alt,
                    iconColor: AppColors.primary,
                    title: task.title,
                    subtitle: "Due: ${task.due}",
                    badges: [
                      if (!task.done)
                        StatusBadge(
                          label: 'Pending',
                          color: Colors.orange,
                        ),
                    ],
                    trailing: Checkbox(
                      value: task.done,
                      onChanged: (value) {},
                      activeColor: AppColors.primary,
                    ),
                    onTap: () {},
                  ),
                );
              },
              childCount: recentTasks.length,
            ),
          ),
        ),

        // Recent Expenses
        SliverToBoxAdapter(
          child: SectionHeader(
            title: "Recent Expenses",
            icon: Icons.receipt_long,
            actionLabel: "View All",
            onActionTap: () {},
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final expense = recentExpenses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListItemCard(
                    icon: Icons.money_off,
                    iconColor: Colors.red,
                    title: expense.item,
                    subtitle: expense.date,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "KSh ${expense.amount}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: recentExpenses.length,
            ),
          ),
        ),

        // Bottom Padding
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _OverviewTaskItem {
  final String title;
  final String due;
  final bool done;

  const _OverviewTaskItem({
    required this.title,
    required this.due,
    required this.done,
  });
}

class _OverviewExpenseItem {
  final String item;
  final int amount;
  final String date;

  const _OverviewExpenseItem({
    required this.item,
    required this.amount,
    required this.date,
  });
}

// Custom Summary Card (different from StatCard - shows value at bottom)
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
