import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'bloc/weather/weather_cubit.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<WeatherCubit>()..load(),
      child: const _WeatherView(),
    );
  }
}

class _WeatherView extends StatelessWidget {
  const _WeatherView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<WeatherCubit, WeatherState>(
      builder: (context, state) {
        if (state.loading) {
          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            includeDrawer: false,
            appBar: ModernAppBar(
              title: context.tr('weather_forecast'),
              variant: AppBarVariant.standard,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.error != null || state.snapshot == null) {
          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            includeDrawer: false,
            appBar: ModernAppBar(
              title: context.tr('weather_forecast'),
              variant: AppBarVariant.standard,
            ),
            body: Center(
              child: Text(state.error ?? context.tr('unable_load_weather')),
            ),
          );
        }

        final snapshot = state.snapshot!;
        final current = snapshot.current;
        final weekly = snapshot.weekly;

        return AppScaffold(
          backgroundColor: theme.colorScheme.surface,
          includeDrawer: false,
          appBar: ModernAppBar(
            title: context.tr('weather_forecast'),
            variant: AppBarVariant.standard,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AnimatedCard(
                  index: 0,
                  theme: theme,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('current_weather'),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${current.temperatureC}°C',
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  current.condition,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _iconForKey(current.iconKey),
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _WeatherStat(
                              icon: Icons.water_drop,
                              value: '${current.humidity}%',
                              label: context.tr('humidity'),
                              theme: theme,
                            ),
                            _WeatherStat(
                              icon: Icons.air,
                              value: '${current.windKph} km/h',
                              label: context.tr('wind'),
                              theme: theme,
                            ),
                            _WeatherStat(
                              icon: Icons.grain,
                              value: '${current.rainChance}%',
                              label: context.tr('rain'),
                              theme: theme,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.tips_and_updates,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  current.advice,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.tr('seven_day_forecast'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...weekly.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return _AnimatedCard(
                    index: index + 1,
                    theme: theme,
                    child: _ForecastCard(
                      day: day.day,
                      temp: '${day.temperatureC}°C',
                      condition: day.condition,
                      icon: _iconForKey(day.iconKey),
                      rainChance: day.rainChance,
                      theme: theme,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'cloudy_snowing':
        return Icons.cloudy_snowing;
      case 'wb_cloudy':
        return Icons.wb_cloudy;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'cloud':
        return Icons.cloud;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'grain':
        return Icons.grain;
      default:
        return Icons.wb_sunny;
    }
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _WeatherStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final String day;
  final String temp;
  final String condition;
  final IconData icon;
  final int rainChance;
  final ThemeData theme;

  const _ForecastCard({
    required this.day,
    required this.temp,
    required this.condition,
    required this.icon,
    required this.rainChance,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  condition,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                temp,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context
                    .tr('rain_percent')
                    .replaceFirst('{percent}', '$rainChance'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;
  final ThemeData theme;

  const _AnimatedCard({
    required this.child,
    required this.index,
    required this.theme,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
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
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
