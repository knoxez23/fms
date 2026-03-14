import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/tasks/add_task_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/animals/production_logging_screen.dart';
import 'package:pamoja_twalima/features/weather/domain/entities/weather_entities.dart';
import 'package:pamoja_twalima/features/home/presentation/bloc/home/home_bloc.dart';
import 'package:pamoja_twalima/features/home/domain/entities/dashboard_data.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeEvent.load()),
      child: HomeView(onNavigateTab: onNavigateTab),
    );
  }
}

class HomeView extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeView({super.key, this.onNavigateTab});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  // Cache data to prevent rebuilds
  Map<String, dynamic>? _cachedSummary;
  WeatherSnapshot? _weatherSnapshot;
  List<OperationalInsight> _insights = const [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true; // Preserve state

  Future<void> _refresh() async {
    context.read<HomeBloc>().add(const HomeEvent.refresh());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final theme = Theme.of(context);
    final weather = _weatherSnapshot?.current;

    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          loaded: (data) {
            if (!mounted) return;
            setState(() {
              _cachedSummary = data.summary;
              _weatherSnapshot = data.weatherSnapshot;
              _insights = data.insights;
              _isLoading = false;
              _hasError = false;
            });
          },
          error: (message) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        );
      },
      child: Builder(
        builder: (context) {
          if (_isLoading) {
            return AppScaffold(
              backgroundColor: theme.colorScheme.surface,
              includeDrawer: false,
              appBar: HomeAppBar(
                title: context.tr('app_name'),
                notificationCount: 0,
                onNotificationTap: () => _openNotifications(const {}),
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (_hasError) {
            return AppScaffold(
              backgroundColor: theme.colorScheme.surface,
              includeDrawer: false,
              appBar: HomeAppBar(
                title: context.tr('app_name'),
                notificationCount: 1,
                onNotificationTap: () =>
                    _openNotifications(const {'error': true}),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    const Text('Failed to load data'),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final summary = _cachedSummary ?? {};
          final greeting = _getGreeting();
          final notificationCount = _notificationCount(summary);

          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            includeDrawer: false,
            appBar: HomeAppBar(
              title: context.tr('app_name'),
              notificationCount: notificationCount,
              onNotificationTap: () => _openNotifications(summary),
            ),
            body: RefreshIndicator(
              onRefresh: _refresh,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: _HomeHeroCard(
                        greeting: greeting,
                        dateText: _formatDate(DateTime.now()),
                        weatherText: weather == null
                            ? 'Weather unavailable'
                            : '${weather.temperatureC}° • ${weather.condition}',
                        onQuickAction: (label) {
                          if (label == 'Record Sale') {
                            widget.onNavigateTab?.call(3);
                            return;
                          }
                          if (label == 'Log Production') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductionLoggingScreen(),
                              ),
                            ).then((_) => _refresh());
                            return;
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddTaskScreen(),
                            ),
                          ).then((_) => _refresh());
                        },
                      ),
                    ),
                  ),

                  // Greeting Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: SectionHeader(
                        title: context.tr('home_today'),
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ),

                  // Weather Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _WeatherCard(
                        weather: weather,
                        theme: theme,
                        onRefresh: _refresh,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Quick Stats Grid
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: context.tr('home_farm_snapshot'),
                      icon: Icons.dashboard,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.5,
                      ),
                      delegate: SliverChildListDelegate([
                        _QuickStatCard(
                          icon: Icons.agriculture,
                          label: 'Crops',
                          value: '${summary['crops'] ?? 0}',
                          subtitle: 'Active',
                          color: Colors.green,
                          onTap: () {
                            widget.onNavigateTab?.call(1);
                          },
                        ),
                        _QuickStatCard(
                          icon: Icons.pets,
                          label: 'Livestock',
                          value: '${summary['livestock'] ?? 0}',
                          subtitle: 'Animals',
                          color: Colors.blue,
                          onTap: () {
                            widget.onNavigateTab?.call(1);
                          },
                        ),
                        _QuickStatCard(
                          icon: Icons.inventory,
                          label: 'Inventory',
                          value: '${summary['inventory'] ?? 0}',
                          subtitle: 'Items',
                          color: Colors.orange,
                          onTap: () {
                            widget.onNavigateTab?.call(2);
                          },
                        ),
                        _QuickStatCard(
                          icon: Icons.task_alt,
                          label: 'Tasks',
                          value: '${summary['pendingTasks'] ?? 0}',
                          subtitle: 'Pending',
                          color: Colors.purple,
                          onTap: () {
                            widget.onNavigateTab?.call(1);
                          },
                        ),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Financial Overview
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: context.tr('home_financial'),
                      icon: Icons.payments,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _FinancialOverview(
                        summary: summary,
                        theme: theme,
                        onOpenBusiness: () => widget.onNavigateTab?.call(3),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Today\'s Blockers',
                      icon: Icons.rule_folder_outlined,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _TodayBlockersSection(
                        theme: theme,
                        summary: summary,
                        onOpenFarm: () => widget.onNavigateTab?.call(1),
                        onOpenInventory: () => widget.onNavigateTab?.call(2),
                        onOpenBusiness: () => widget.onNavigateTab?.call(3),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Smart Focus',
                      icon: Icons.auto_awesome,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _OperationalInsightsSection(
                        theme: theme,
                        insights: _insights,
                        onInsightTap: _handleInsightTap,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Setup Momentum',
                      icon: Icons.playlist_add_check_circle_outlined,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _SetupMomentumSection(
                        theme: theme,
                        summary: summary,
                        onOpenFarm: () => widget.onNavigateTab?.call(1),
                        onOpenInventory: () => widget.onNavigateTab?.call(2),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Critical Alerts
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: context.tr('home_alerts'),
                      icon: Icons.warning_amber,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _CriticalAlerts(
                        theme: theme,
                        summary: summary,
                        onOpenInventory: () => widget.onNavigateTab?.call(2),
                        onOpenTasks: () => widget.onNavigateTab?.call(1),
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Quick Actions
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: context.tr('home_quick_actions'),
                      icon: Icons.bolt,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _QuickActions(
                        theme: theme,
                        onNavigateTab: (index) =>
                            widget.onNavigateTab?.call(index),
                        onAddTask: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddTaskScreen(),
                            ),
                          ).then((_) => _refresh());
                        },
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '🌅 Good Morning, Farmer!';
    if (hour < 17) return '☀️ Good Afternoon!';
    return '🌙 Good Evening!';
  }

  String _formatDate(DateTime date) {
    final days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  int _notificationCount(Map<String, dynamic> summary) {
    final lowStock = (summary['lowStockItems'] as num?)?.toInt() ?? 0;
    final pendingTasks = (summary['pendingTasks'] as num?)?.toInt() ?? 0;
    final smartReminders = (summary['smartReminderCount'] as num?)?.toInt() ?? 0;
    final freshnessRisk = (summary['freshnessRiskCount'] as num?)?.toInt() ?? 0;
    return (lowStock > 0 ? 1 : 0) +
        (pendingTasks > 0 ? 1 : 0) +
        (smartReminders > 0 ? 1 : 0) +
        (freshnessRisk > 0 ? 1 : 0) +
        (_weatherSnapshot?.current == null ? 1 : 0);
  }

  void _openNotifications(Map<String, dynamic> summary) {
    final lowStock = (summary['lowStockItems'] as num?)?.toInt() ?? 0;
    final pendingTasks = (summary['pendingTasks'] as num?)?.toInt() ?? 0;
    final smartReminders = (summary['smartReminderCount'] as num?)?.toInt() ?? 0;
    final smartReminderPreview =
        (summary['smartReminderPreview'] ?? '').toString().trim();
    final freshnessRisk = (summary['freshnessRiskCount'] as num?)?.toInt() ?? 0;
    final pendingCollections =
        (summary['pendingCollectionsCount'] as num?)?.toInt() ?? 0;
    final weatherMissing = _weatherSnapshot?.current == null;
    final hasError = summary['error'] == true;
    final items = <({IconData icon, String title, String subtitle})>[
      if (hasError)
        (
          icon: Icons.error_outline,
          title: 'Dashboard Error',
          subtitle: 'Could not load dashboard data. Pull to refresh.',
        ),
      if (lowStock > 0)
        (
          icon: Icons.inventory_2_outlined,
          title: context.tr('low_stock_alert'),
          subtitle: '$lowStock inventory item(s) are below minimum stock.',
        ),
      if (pendingTasks > 0)
        (
          icon: Icons.schedule_outlined,
          title: context.tr('pending_tasks_alert'),
          subtitle: '$pendingTasks task(s) are still pending completion.',
        ),
      if (smartReminders > 0)
        (
          icon: Icons.notifications_active_outlined,
          title: 'Operational reminders',
          subtitle: smartReminderPreview.isEmpty
              ? '$smartReminders farm reminders need attention.'
              : smartReminderPreview,
        ),
      if (freshnessRisk > 0)
        (
          icon: Icons.timelapse_outlined,
          title: 'Fresh output should move now',
          subtitle:
              '$freshnessRisk milk/egg stock lot(s) are aging in inventory.',
        ),
      if (pendingCollections > 0)
        (
          icon: Icons.payments_outlined,
          title: 'Collections follow-up',
          subtitle:
              '$pendingCollections sale${pendingCollections == 1 ? '' : 's'} still await payment confirmation.',
        ),
      if (weatherMissing)
        (
          icon: Icons.cloud_off_outlined,
          title: 'Weather Unavailable',
          subtitle: 'Could not fetch latest weather snapshot.',
        ),
    ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      context.tr('notifications'),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: Text(context.tr('close')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(context.tr('no_new_notifications')),
                    subtitle: Text(context.tr('all_modules_healthy')),
                  )
                else
                  ...items.map(
                    (item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(item.icon),
                      title: Text(item.title),
                      subtitle: Text(item.subtitle),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleInsightTap(OperationalInsight insight) {
    switch (insight.action) {
      case OperationalInsightAction.farm:
        widget.onNavigateTab?.call(1);
        break;
      case OperationalInsightAction.tasks:
        widget.onNavigateTab?.call(1);
        break;
      case OperationalInsightAction.inventory:
        widget.onNavigateTab?.call(2);
        break;
      case OperationalInsightAction.business:
        widget.onNavigateTab?.call(3);
        break;
    }
  }
}

class _SetupMomentumSection extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic> summary;
  final VoidCallback onOpenFarm;
  final VoidCallback onOpenInventory;

  const _SetupMomentumSection({
    required this.theme,
    required this.summary,
    required this.onOpenFarm,
    required this.onOpenInventory,
  });

  @override
  Widget build(BuildContext context) {
    final todaysFeedings = (summary['todaysFeedings'] as num?)?.toInt() ?? 0;
    final setupTasks7 = (summary['setupTasksNext7Days'] as num?)?.toInt() ?? 0;
    final setupTasks30 =
        (summary['setupTasksNext30Days'] as num?)?.toInt() ?? 0;
    final activeFieldCrops =
        (summary['activeFieldCrops'] as num?)?.toInt() ?? 0;
    final productionReviews =
        (summary['productionReviewsNext7Days'] as num?)?.toInt() ?? 0;
    final harvestReadyCrops =
        (summary['harvestReadyCrops'] as num?)?.toInt() ?? 0;
    final todaysFeedingPreview =
        (summary['todaysFeedingPreview'] ?? '').toString().trim();
    final feedGaps = (summary['feedReadinessGaps'] as num?)?.toInt() ?? 0;
    final cropInputGaps = (summary['cropInputGaps'] as num?)?.toInt() ?? 0;
    final totalReadinessGaps = feedGaps + cropInputGaps;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SetupMomentumCard(
                theme: theme,
                title: 'Today\'s Feeding',
                value: '$todaysFeedings',
                subtitle: feedGaps > 0
                    ? '$feedGaps feed item${feedGaps == 1 ? '' : 's'} need sourcing'
                    : todaysFeedingPreview.isNotEmpty
                        ? todaysFeedingPreview
                        : todaysFeedings == 0
                            ? 'No active schedules yet'
                            : 'Feeding sessions ready',
                icon: Icons.local_dining_outlined,
                color: Colors.teal,
                onTap: onOpenFarm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SetupMomentumCard(
                theme: theme,
                title: 'Next 7 Days',
                value:
                    '${productionReviews > 0 ? productionReviews : setupTasks7}',
                subtitle: productionReviews > 0
                    ? 'Production reviews queued'
                    : 'Setup tasks due soon',
                icon: Icons.event_available_outlined,
                color: Colors.indigo,
                onTap: onOpenFarm,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _SetupMomentumCard(
                theme: theme,
                title: 'Field Crops',
                value:
                    '${harvestReadyCrops > 0 ? harvestReadyCrops : activeFieldCrops}',
                subtitle: harvestReadyCrops > 0
                    ? 'Harvest window approaching'
                    : cropInputGaps > 0
                        ? '$cropInputGaps crop input gap${cropInputGaps == 1 ? '' : 's'} to fix'
                        : activeFieldCrops == 0
                            ? 'No crops marked active'
                            : 'Crops already in motion',
                icon: Icons.grass_outlined,
                color: Colors.green,
                onTap: onOpenFarm,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SetupMomentumCard(
                theme: theme,
                title: '30-Day Plan',
                value: '$setupTasks30',
                subtitle: totalReadinessGaps > 0
                    ? '$totalReadinessGaps startup blocker${totalReadinessGaps == 1 ? '' : 's'} visible'
                    : 'Operational checklist seeded',
                icon: Icons.fact_check_outlined,
                color: Colors.deepOrange,
                onTap: onOpenInventory,
              ),
            ),
          ],
        ),
        if (totalReadinessGaps > 0) ...[
          const SizedBox(height: 12),
          _SetupReadinessBanner(
            theme: theme,
            feedGaps: feedGaps,
            cropInputGaps: cropInputGaps,
            onOpenInventory: onOpenInventory,
          ),
        ],
      ],
    );
  }
}

class _TodayBlockersSection extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic> summary;
  final VoidCallback onOpenFarm;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenBusiness;

  const _TodayBlockersSection({
    required this.theme,
    required this.summary,
    required this.onOpenFarm,
    required this.onOpenInventory,
    required this.onOpenBusiness,
  });

  @override
  Widget build(BuildContext context) {
    final feedGaps = (summary['feedReadinessGaps'] as num?)?.toInt() ?? 0;
    final cropInputGaps = (summary['cropInputGaps'] as num?)?.toInt() ?? 0;
    final lowStockItems = (summary['lowStockItems'] as num?)?.toInt() ?? 0;
    final productionReviews =
        (summary['productionReviewsNext7Days'] as num?)?.toInt() ?? 0;
    final harvestReadyCrops =
        (summary['harvestReadyCrops'] as num?)?.toInt() ?? 0;
    final unsoldMilkToday =
        (summary['unsoldMilkToday'] as num?)?.toDouble() ?? 0.0;
    final unsoldEggsToday =
        (summary['unsoldEggsToday'] as num?)?.toDouble() ?? 0.0;
    final milkStockOnHand =
        (summary['milkStockOnHand'] as num?)?.toDouble() ?? 0.0;
    final eggsStockOnHand =
        (summary['eggsStockOnHand'] as num?)?.toDouble() ?? 0.0;
    final readyOutputUnits =
        unsoldMilkToday + unsoldEggsToday + milkStockOnHand + eggsStockOnHand;
    final freshnessRiskCount =
        (summary['freshnessRiskCount'] as num?)?.toInt() ?? 0;
    final freshnessPriorityLabel =
        (summary['freshnessPriorityLabel'] ?? '').toString().trim();
    final pendingCollectionsCount =
        (summary['pendingCollectionsCount'] as num?)?.toInt() ?? 0;

    final blockers = <_TodayBlockerItem>[
      if (freshnessRiskCount > 0)
        _TodayBlockerItem(
          label:
              '$freshnessRiskCount fresh-output lot${freshnessRiskCount == 1 ? '' : 's'} aging',
          detail: freshnessPriorityLabel.isEmpty
              ? 'Move the oldest milk or eggs into a sale first.'
              : freshnessPriorityLabel,
          color: Colors.deepOrange,
          icon: Icons.timelapse_outlined,
          onTap: onOpenBusiness,
        ),
      if (readyOutputUnits > 0)
        _TodayBlockerItem(
          label: readyOutputUnits == readyOutputUnits.roundToDouble()
              ? '${readyOutputUnits.toInt()} output unit${readyOutputUnits == 1 ? '' : 's'} ready'
              : '${readyOutputUnits.toStringAsFixed(1)} output units ready',
          detail: _readyOutputDetail(
            milkStockOnHand: milkStockOnHand,
            eggsStockOnHand: eggsStockOnHand,
            unsoldMilkToday: unsoldMilkToday,
            unsoldEggsToday: unsoldEggsToday,
          ),
          color: Colors.amber.shade800,
          icon: Icons.storefront_outlined,
          onTap: onOpenBusiness,
        ),
      if (feedGaps > 0)
        _TodayBlockerItem(
          label: '$feedGaps feed gap${feedGaps == 1 ? '' : 's'}',
          detail: 'Restock feed before rations slip.',
          color: Colors.teal,
          icon: Icons.local_dining_outlined,
          onTap: onOpenInventory,
        ),
      if (cropInputGaps > 0)
        _TodayBlockerItem(
          label:
              '$cropInputGaps crop input gap${cropInputGaps == 1 ? '' : 's'}',
          detail: 'Seeds or inputs are still missing.',
          color: Colors.green,
          icon: Icons.grass_outlined,
          onTap: onOpenInventory,
        ),
      if (productionReviews > 0)
        _TodayBlockerItem(
          label:
              '$productionReviews production review${productionReviews == 1 ? '' : 's'}',
          detail: 'Output and feed efficiency need attention.',
          color: Colors.indigo,
          icon: Icons.insights_outlined,
          onTap: onOpenFarm,
        ),
      if (harvestReadyCrops > 0)
        _TodayBlockerItem(
          label:
              '$harvestReadyCrops harvest-ready crop${harvestReadyCrops == 1 ? '' : 's'}',
          detail: 'Move crop to stock or market soon.',
          color: Colors.orange,
          icon: Icons.agriculture_outlined,
          onTap: onOpenFarm,
        ),
      if (lowStockItems > 0)
        _TodayBlockerItem(
          label:
              '$lowStockItems low-stock item${lowStockItems == 1 ? '' : 's'}',
          detail: 'Inventory needs a quick check.',
          color: Colors.redAccent,
          icon: Icons.inventory_2_outlined,
          onTap: onOpenInventory,
        ),
      if (pendingCollectionsCount > 0)
        _TodayBlockerItem(
          label:
              '$pendingCollectionsCount collection${pendingCollectionsCount == 1 ? '' : 's'} to follow up',
          detail: 'Close unpaid sales so cashflow stays reliable.',
          color: Colors.indigo,
          icon: Icons.payments_outlined,
          onTap: onOpenBusiness,
        ),
    ];

    if (blockers.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.teal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.withValues(alpha: 0.18)),
        ),
        child: Text(
          'No urgent blockers right now. Focus on today’s production and record-keeping rhythm.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Column(
      children: blockers
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TodayBlockerCard(theme: theme, item: item),
            ),
          )
          .toList(),
    );
  }

  String _readyOutputDetail({
    required double milkStockOnHand,
    required double eggsStockOnHand,
    required double unsoldMilkToday,
    required double unsoldEggsToday,
  }) {
    final parts = <String>[];
    if (milkStockOnHand > 0) {
      parts.add(
        milkStockOnHand == milkStockOnHand.roundToDouble()
            ? '${milkStockOnHand.toInt()} milk in stock'
            : '${milkStockOnHand.toStringAsFixed(1)} milk in stock',
      );
    }
    if (eggsStockOnHand > 0) {
      parts.add(
        eggsStockOnHand == eggsStockOnHand.roundToDouble()
            ? '${eggsStockOnHand.toInt()} eggs in stock'
            : '${eggsStockOnHand.toStringAsFixed(1)} eggs in stock',
      );
    }
    if (unsoldMilkToday > 0 || unsoldEggsToday > 0) {
      parts.add('today’s output is not fully moved yet');
    }
    if (parts.isEmpty) {
      return 'Move fresh output into sales while buyers and quality window are still in your favor.';
    }
    return '${parts.join(' • ')}. Move fresh output into sales soon.';
  }
}

class _TodayBlockerItem {
  final String label;
  final String detail;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _TodayBlockerItem({
    required this.label,
    required this.detail,
    required this.color,
    required this.icon,
    required this.onTap,
  });
}

class _TodayBlockerCard extends StatelessWidget {
  final ThemeData theme;
  final _TodayBlockerItem item;

  const _TodayBlockerCard({
    required this.theme,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: item.color.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.detail,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: item.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupMomentumCard extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SetupMomentumCard({
    required this.theme,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupReadinessBanner extends StatelessWidget {
  final ThemeData theme;
  final int feedGaps;
  final int cropInputGaps;
  final VoidCallback onOpenInventory;

  const _SetupReadinessBanner({
    required this.theme,
    required this.feedGaps,
    required this.cropInputGaps,
    required this.onOpenInventory,
  });

  @override
  Widget build(BuildContext context) {
    final blockers = <String>[
      if (feedGaps > 0)
        '$feedGaps feed item${feedGaps == 1 ? '' : 's'} below starter level',
      if (cropInputGaps > 0)
        '$cropInputGaps crop input${cropInputGaps == 1 ? '' : 's'} still missing',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              blockers.join(' • '),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onOpenInventory,
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
  }
}

class _OperationalInsightsSection extends StatelessWidget {
  final ThemeData theme;
  final List<OperationalInsight> insights;
  final ValueChanged<OperationalInsight> onInsightTap;

  const _OperationalInsightsSection({
    required this.theme,
    required this.insights,
    required this.onInsightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: insights
          .map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _OperationalInsightCard(
                theme: theme,
                insight: insight,
                onTap: () => onInsightTap(insight),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _OperationalInsightCard extends StatelessWidget {
  final ThemeData theme;
  final OperationalInsight insight;
  final VoidCallback onTap;

  const _OperationalInsightCard({
    required this.theme,
    required this.insight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = switch (insight.severity) {
      OperationalInsightSeverity.critical => (
          icon: Icons.priority_high,
          color: Colors.red,
          label: 'Critical',
        ),
      OperationalInsightSeverity.warning => (
          icon: Icons.warning_amber_rounded,
          color: Colors.orange,
          label: 'Watch',
        ),
      OperationalInsightSeverity.info => (
          icon: Icons.lightbulb_outline,
          color: AppColors.primary,
          label: 'Next',
        ),
    };

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: config.color.withValues(alpha: 0.25),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: config.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(config.icon, color: config.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            insight.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: config.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            config.label,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: config.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      insight.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      insight.actionLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: config.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  final String greeting;
  final String dateText;
  final String weatherText;
  final void Function(String label) onQuickAction;

  const _HomeHeroCard({
    required this.greeting,
    required this.dateText,
    required this.weatherText,
    required this.onQuickAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dateText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                weatherText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => onQuickAction('Record Sale'),
                icon: const Icon(Icons.paid, size: 18),
                label: const Text('Record Sale'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => onQuickAction('Log Production'),
                icon: const Icon(Icons.insights_outlined, size: 18),
                label: const Text('Log Production'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => onQuickAction('Add Task'),
                icon: const Icon(Icons.task_alt, size: 18),
                label: const Text('Add Task'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Weather Card Widget
class _WeatherCard extends StatelessWidget {
  final CurrentWeather? weather;
  final ThemeData theme;
  final VoidCallback onRefresh;

  const _WeatherCard({
    required this.weather,
    required this.theme,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final weatherIcon = _iconForKey(weather?.iconKey ?? 'wb_sunny');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(weatherIcon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weather == null ? '--' : "${weather!.temperatureC}°C",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  weather == null
                      ? 'Weather unavailable'
                      : "${weather!.condition} • ${weather!.rainChance}% rain",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'cloudy_snowing':
        return Icons.cloudy_snowing;
      case 'wb_cloudy':
        return Icons.wb_cloudy;
      case 'cloud':
        return Icons.cloud;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'grain':
        return Icons.grain;
      case 'air':
        return Icons.air;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.wb_sunny;
    }
  }
}

// Quick Stat Card
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  // const SizedBox(height: 0.5),
                  Text(
                    '$label $subtitle',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Financial Overview
class _FinancialOverview extends StatelessWidget {
  final Map<String, dynamic> summary;
  final ThemeData theme;
  final VoidCallback onOpenBusiness;

  const _FinancialOverview({
    required this.summary,
    required this.theme,
    required this.onOpenBusiness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('financial_summary'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: onOpenBusiness,
                icon: const Icon(Icons.bar_chart, size: 18),
                label: Text(context.tr('view_all')),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _FinancialMetric(
                  label: 'Monthly income',
                  value:
                      'KSh ${((summary['monthlySales'] as num?) ?? 0).toStringAsFixed(0)}',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialMetric(
                  label: 'Monthly expenses',
                  value:
                      'KSh ${((summary['monthlyExpenses'] as num?) ?? 0).toStringAsFixed(0)}',
                  icon: Icons.trending_down,
                  color: Colors.redAccent,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (((summary['monthlyNetCashFlow'] as num?) ?? 0) >= 0
                      ? Colors.teal
                      : Colors.deepOrange)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      (((summary['monthlyNetCashFlow'] as num?) ?? 0) >= 0)
                          ? Icons.account_balance_wallet
                          : Icons.warning_amber_rounded,
                      color:
                          (((summary['monthlyNetCashFlow'] as num?) ?? 0) >= 0)
                              ? Colors.teal
                              : Colors.deepOrange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Monthly net flow',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Text(
                  'KSh ${((summary['monthlyNetCashFlow'] as num?) ?? 0).toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: (((summary['monthlyNetCashFlow'] as num?) ?? 0) >= 0)
                        ? Colors.teal
                        : Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Today: '
            'KSh ${((summary['salesToday'] as num?) ?? 0).toStringAsFixed(0)} sales • '
            'KSh ${((summary['expensesToday'] as num?) ?? 0).toStringAsFixed(0)} expenses • '
            'KSh ${((summary['netCashFlowToday'] as num?) ?? 0).toStringAsFixed(0)} net'
            '\nProduction: '
            '${((summary['milkToday'] as num?) ?? 0).toStringAsFixed(1)}L milk • '
            '${((summary['eggsToday'] as num?) ?? 0).toStringAsFixed(0)} eggs',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _FinancialMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// Critical Alerts
class _CriticalAlerts extends StatelessWidget {
  final ThemeData theme;
  final Map<String, dynamic> summary;
  final VoidCallback onOpenInventory;
  final VoidCallback onOpenTasks;

  const _CriticalAlerts({
    required this.theme,
    required this.summary,
    required this.onOpenInventory,
    required this.onOpenTasks,
  });

  @override
  Widget build(BuildContext context) {
    final lowStock = (summary['lowStockItems'] as num?)?.toInt() ?? 0;
    final pendingTasks = (summary['pendingTasks'] as num?)?.toInt() ?? 0;
    final alerts = <({
      IconData icon,
      String title,
      String subtitle,
      Color color,
      VoidCallback onTap,
    })>[
      if (lowStock > 0)
        (
          icon: Icons.inventory_2_outlined,
          title: 'Low Stock Alert',
          subtitle: '$lowStock inventory item(s) below minimum stock',
          color: Colors.orange,
          onTap: onOpenInventory,
        ),
      if (pendingTasks > 0)
        (
          icon: Icons.schedule_rounded,
          title: 'Pending Tasks',
          subtitle: '$pendingTasks farm task(s) still pending',
          color: Colors.deepOrange,
          onTap: onOpenTasks,
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('critical_alerts'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alerts.length.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (alerts.isEmpty)
            _AlertItem(
              icon: Icons.check_circle_outline,
              title: context.tr('no_critical_alerts'),
              subtitle: context.tr('everything_good'),
              color: Colors.green,
              theme: theme,
              onTap: onOpenTasks,
            )
          else
            ...alerts.map(
              (alert) => Column(
                children: [
                  _AlertItem(
                    icon: alert.icon,
                    title: alert.title,
                    subtitle: alert.subtitle,
                    color: alert.color,
                    theme: theme,
                    onTap: alert.onTap,
                  ),
                  const Divider(height: 20),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final ThemeData theme;
  final VoidCallback onTap;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}

// Quick Actions
class _QuickActions extends StatelessWidget {
  final ThemeData theme;
  final ValueChanged<int> onNavigateTab;
  final VoidCallback onAddTask;

  const _QuickActions({
    required this.theme,
    required this.onNavigateTab,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('home_quick_actions'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _ActionButton(
              icon: Icons.add_circle_outline,
              label: context.tr('quick_add_record'),
              onTap: () => onNavigateTab(1),
            ),
            _ActionButton(
              icon: Icons.storefront,
              label: context.tr('quick_sell'),
              onTap: () => onNavigateTab(3),
            ),
            _ActionButton(
              icon: Icons.shopping_cart,
              label: context.tr('quick_purchase'),
              onTap: () => onNavigateTab(2),
            ),
            _ActionButton(
              icon: Icons.task_alt,
              label: context.tr('quick_tasks'),
              onTap: onAddTask,
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
