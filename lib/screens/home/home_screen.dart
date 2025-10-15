import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pamoja_twalima/data/local_data.dart';
import 'package:pamoja_twalima/data/weather_service.dart';
import 'package:pamoja_twalima/data/tip_data.dart';
import 'package:pamoja_twalima/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scrollController = ScrollController();
  final random = Random();

  double scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    scrollController.addListener(() {
      setState(() => scrollOffset = scrollController.offset);
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weather = WeatherService.getCurrentWeather();
    final summary = LocalData.getFarmSummary();
    final marketPrices = LocalData.getMarketPrices();
    final tip = TipData.getTipOfTheDay();

    final weatherIcon = {
      "Sunny": Icons.wb_sunny,
      "Cloudy": Icons.cloud,
      "Rainy": Icons.water_drop,
      "Windy": Icons.air,
    }[weather.condition] ?? Icons.wb_sunny;

    final fadeFactor = (scrollOffset / 200).clamp(0, 1);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Pamoja Twalima",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedOpacity(
              opacity: 1.0 - fadeFactor,
              duration: const Duration(milliseconds: 400),
              child: Text(
                "👋 Hi, Farmer!",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            _AnimatedCard(
              index: 0,
              child: Row(
                children: [
                  Icon(weatherIcon, size: 40, color: AppColors.primary),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${weather.temperature}°C | ${weather.condition}",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Rain chance: ${weather.rainChance}%",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),

            _AnimatedCard(
              index: 1,
              title: "Farm Summary",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(icon: Icons.agriculture, label: "Crops", value: "${summary['crops']}"),
                  _StatItem(icon: Icons.pets, label: "Livestock", value: "${summary['livestock']}"),
                  _StatItem(icon: Icons.attach_money, label: "Sales Today", value: "KSh ${summary['salesToday']}"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _AnimatedCard(
              index: 2,
              title: "Market Prices",
              child: Column(
                children: marketPrices
                    .map((m) => _MarketItem(m["item"]!, m["price"]!))
                    .toList(),
              ),
            ),

            const SizedBox(height: 16),

            _AnimatedCard(
              index: 3,
              title: "Quick Actions",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  _ActionButton(icon: Icons.add_circle, label: "Add Record"),
                  _ActionButton(icon: Icons.store, label: "Marketplace"),
                  _ActionButton(icon: Icons.insights, label: "Insights"),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _AnimatedCard(
              index: 4,
              title: "🌿 Tip of the Day",
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 800),
                child: Text(
                  "“$tip”",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final String? title;
  final int index;

  const _AnimatedCard({required this.child, this.title, required this.index});

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.1 * widget.index, 0.8, curve: Curves.easeOutCubic)),
    );

    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Interval(0.1 * widget.index, 1, curve: Curves.easeOutCubic)),
    );

    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
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
    final theme = Theme.of(context);
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                widget.child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 30),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
      ],
    );
  }
}

class _MarketItem extends StatelessWidget {
  final String product;
  final String price;
  const _MarketItem(this.product, this.price);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(product, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          Text(price, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final IconData icon;
  final String label;

  const _ActionButton({
    required this.icon,
    required this.label,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  double scale = 1.0;

  void _animateTap() async {
    setState(() => scale = 0.9);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => _animateTap(),
      onTapUp: (_) => _animateTap(),
      onTapCancel: () => setState(() => scale = 1.0),
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              child: Icon(widget.icon, color: theme.colorScheme.primary, size: 28),
            ),
            const SizedBox(height: 6),
            Text(widget.label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
