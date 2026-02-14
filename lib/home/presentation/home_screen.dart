import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/weather/domain/entities/weather_entities.dart';
import 'package:pamoja_twalima/home/presentation/bloc/home/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const HomeEvent.load()),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  // Cache data to prevent rebuilds
  Map<String, dynamic>? _cachedSummary;
  WeatherSnapshot? _weatherSnapshot;
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
              appBar: HomeAppBar(
                title: 'Pamoja Twalima',
                notificationCount: 3,
                onNotificationTap: () {},
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (_hasError) {
            return AppScaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: HomeAppBar(
                title: 'Pamoja Twalima',
                notificationCount: 3,
                onNotificationTap: () {},
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

          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: HomeAppBar(
              title: 'Pamoja Twalima',
              notificationCount: 3,
              onNotificationTap: () {
                // Navigate to notifications
              },
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$label coming soon')),
                          );
                        },
                      ),
                    ),
                  ),

                  // Greeting Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: const SectionHeader(
                        title: 'Today',
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
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Quick Stats Grid
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Farm Snapshot',
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
                            // Navigate to crops
                          },
                        ),
                        _QuickStatCard(
                          icon: Icons.pets,
                          label: 'Livestock',
                          value: '${summary['livestock'] ?? 0}',
                          subtitle: 'Animals',
                          color: Colors.blue,
                          onTap: () {
                            // Navigate to livestock
                          },
                        ),
                        _QuickStatCard(
                          icon: Icons.inventory,
                          label: 'Inventory',
                          value: '${summary['inventory'] ?? 0}',
                          subtitle: 'Items',
                          color: Colors.orange,
                          onTap: () {
                            // Navigate to inventory
                          },
                        ),
                        _QuickStatCard(
                          icon: Icons.task_alt,
                          label: 'Tasks',
                          value: '${summary['pendingTasks'] ?? 0}',
                          subtitle: 'Pending',
                          color: Colors.purple,
                          onTap: () {
                            // Navigate to tasks
                          },
                        ),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Financial Overview
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Financial Overview',
                      icon: Icons.payments,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _FinancialOverview(summary: summary, theme: theme),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Critical Alerts
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Critical Alerts',
                      icon: Icons.warning_amber,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _CriticalAlerts(theme: theme),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 16)),

                  // Quick Actions
                  const SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Quick Actions',
                      icon: Icons.bolt,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _QuickActions(theme: theme),
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
          Row(
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
              const SizedBox(width: 8),
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

  const _WeatherCard({required this.weather, required this.theme});

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
            onPressed: () {},
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

  const _FinancialOverview({required this.summary, required this.theme});

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
                'Financial Summary',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // Navigate to full financial report
                },
                icon: const Icon(Icons.bar_chart, size: 18),
                label: const Text('View All'),
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
                  label: "Today's Sales",
                  value: 'KSh ${summary['salesToday'] ?? 0}',
                  icon: Icons.trending_up,
                  color: Colors.green,
                  theme: theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinancialMetric(
                  label: 'This Month',
                  value: 'KSh ${summary['monthlySales'] ?? 0}',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                  theme: theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, color: Colors.purple, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Profit Margin',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                Text(
                  '32%',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
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

  const _CriticalAlerts({required this.theme});

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
                'Critical Alerts',
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
                  '3',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _AlertItem(
            icon: Icons.warning_amber_rounded,
            title: 'Feed Low Stock',
            subtitle: 'Chicken feed: 2 days remaining',
            color: Colors.orange,
            theme: theme,
          ),
          const Divider(height: 20),
          _AlertItem(
            icon: Icons.vaccines_rounded,
            title: 'Health Check Due',
            subtitle: '2 animals need vaccination',
            color: Colors.red,
            theme: theme,
          ),
          const Divider(height: 20),
          _AlertItem(
            icon: Icons.schedule_rounded,
            title: 'Task Overdue',
            subtitle: 'Fertilizer application delayed',
            color: Colors.deepOrange,
            theme: theme,
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

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}

// Quick Actions
class _QuickActions extends StatelessWidget {
  final ThemeData theme;

  const _QuickActions({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
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
              label: 'Add Record',
              onTap: () {},
            ),
            _ActionButton(
              icon: Icons.storefront,
              label: 'Sell',
              onTap: () {},
            ),
            _ActionButton(
              icon: Icons.shopping_cart,
              label: 'Purchase',
              onTap: () {},
            ),
            _ActionButton(
              icon: Icons.task_alt,
              label: 'Tasks',
              onTap: () {},
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
