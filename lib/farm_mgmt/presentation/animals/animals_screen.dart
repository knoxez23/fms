import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/animations/animated_card.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/farm_mgmt/presentation/bloc/animals/animals_bloc.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/animal_entity.dart';
import 'add_animal_screen.dart';
import 'animal_detail_screen.dart';
import 'breeding_schedule_screen.dart';
import 'animal_feed_calculator_screen.dart';
import 'feed_formula_generator_screen.dart';
import 'animal_feeding_calendar_screen.dart';
import 'production_logging_screen.dart';

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});

  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  String _selectedFilter = 'All';
  int _selectedTab = 0;

  final List<String> _filters = [
    'All',
    'Cattle',
    'Poultry',
    'Goats',
    'Sheep',
    'Pigs'
  ];

  // Feed calculation data
  final Map<String, Map<String, double>> _feedRequirements = {
    'Dairy Cow': {
      'dryMatter': 3.0, // % of body weight
      'protein': 16.0, // %
      'energy': 1.7, // Mcal/kg
      'dailyIntake': 25.0, // kg
    },
    'Beef Cattle': {
      'dryMatter': 2.5,
      'protein': 12.0,
      'energy': 1.4,
      'dailyIntake': 18.0,
    },
    'Layers': {
      'dryMatter': 100.0, // grams per bird
      'protein': 16.0,
      'energy': 2.8,
      'dailyIntake': 0.12,
    },
    'Goat': {
      'dryMatter': 3.5,
      'protein': 14.0,
      'energy': 2.0,
      'dailyIntake': 2.5,
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => getIt<AnimalsBloc>()..add(const AnimalsEvent.load()),
      child: BlocConsumer<AnimalsBloc, AnimalsState>(
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
          final animals = state.maybeWhen<List<AnimalEntity>>(
            loaded: (items) => items,
            orElse: () => <AnimalEntity>[],
          );

          final filteredAnimals = _selectedFilter == 'All'
              ? animals
              : animals
                  .where(
                      (animal) => _getAnimalCategory(animal) == _selectedFilter)
                  .toList();

          return DefaultTabController(
            length: 4,
            child: AppScaffold(
              backgroundColor: theme.colorScheme.surface,
              appBar: ModernAppBar(
                bottom: TabBar(
                  tabs: const [
                    Tab(text: 'Animals', icon: Icon(Icons.pets)),
                    Tab(text: 'Feed Tools', icon: Icon(Icons.restaurant)),
                    Tab(text: 'Calendar', icon: Icon(Icons.calendar_today)),
                    Tab(text: 'Production', icon: Icon(Icons.analytics)),
                  ],
                  onTap: (index) {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                ),
                bottomHeight: 48,
              ),
              body: TabBarView(
                children: [
                  // Animals Tab
                  _buildAnimalsTab(
                    theme,
                    animals,
                    filteredAnimals,
                  ),

                  // Feed Tools Tab
                  _buildFeedToolsTab(theme, animals),

                  // Calendar Tab
                  _buildCalendarTab(theme, animals),

                  // Production Tab
                  _buildProductionTab(theme),
                ],
              ),
              floatingActionButton: _buildFloatingActionButtons(theme, animals),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimalsTab(
    ThemeData theme,
    List<AnimalEntity> animals,
    List<AnimalEntity> filteredAnimals,
  ) {
    return CustomScrollView(
      slivers: [
        // Header section with animal stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _AnimalStat(
                  value: '${animals.length}',
                  label: 'Total Animals',
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _AnimalStat(
                  value: '92%',
                  label: 'Avg Health',
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _AnimalStat(
                  value: '3',
                  label: 'Pregnant',
                  theme: theme,
                ),
              ],
            ),
          ),
        ),

        // Filter chips
        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    checkmarkColor: theme.colorScheme.primary,
                    selectedColor:
                        theme.colorScheme.primary.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _selectedFilter = filter),
                    backgroundColor: theme.cardTheme.color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 8)),

        // Animal cards list
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final animal = filteredAnimals[index];
                return AnimatedCard(
                  index: index,
                  child: _AnimalCard(
                    animal: animal,
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AnimalDetailScreen.fromEntity(entity: animal),
                        ),
                      );
                    },
                  ),
                );
              },
              childCount: filteredAnimals.length,
            ),
          ),
        ),

        // Bottom padding to make space for FABs and bottom bar
        const SliverToBoxAdapter(
          child: SizedBox(height: 120),
        ),
      ],
    );
  }

  Widget _buildFeedToolsTab(
    ThemeData theme,
    List<AnimalEntity> animals,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Feed Calculator Card
          AnimatedCard(
            index: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calculate, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Feed Calculator',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Calculate feed requirements based on animal type, weight, and production goals.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimalFeedCalculatorScreen(
                            animals: animals,
                            feedRequirements: _feedRequirements,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Open Feed Calculator'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Feed Formula Generator Card
          AnimatedCard(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: theme.colorScheme.secondary),
                      const SizedBox(width: 8),
                      Text(
                        'Feed Formula Generator',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Create custom feed mixes using local ingredients like Napier grass, maize, soybeans, etc.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FeedFormulaGeneratorScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Create Feed Formula'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Feed Calculations
          AnimatedCard(
            index: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Feed Estimates',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._feedRequirements.entries.map((entry) {
                    final animalType = entry.key;
                    final requirements = entry.value;
                    return _FeedEstimateRow(
                      animalType: animalType,
                      dailyIntake: requirements['dailyIntake'] ?? 0.0,
                      theme: theme,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab(
    ThemeData theme,
    List<AnimalEntity> animals,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedCard(
            index: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Feeding Schedule',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Manage daily feeding routines, track feed inventory, and set reminders.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnimalFeedingCalendarScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('View Feeding Calendar'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Today's Feeding Tasks
          AnimatedCard(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Feeding",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...animals.take(3).map((animal) {
                    return _FeedingTaskRow(
                      animal: animal,
                      theme: theme,
                    );
                  }),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AnimalFeedingCalendarScreen(),
                        ),
                      );
                    },
                    child: const Text('View All Feeding Tasks'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductionTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AnimatedCard(
            index: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Production Logging',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Track milk production, egg collection, weight gains, and other productivity metrics.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductionLoggingScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Log Production Data'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Production Summary
          AnimatedCard(
            index: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Production',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ProductionSummaryRow(
                    label: 'Total Milk Today',
                    value: '33L',
                    change: '+2L',
                    isPositive: true,
                    theme: theme,
                  ),
                  _ProductionSummaryRow(
                    label: 'Eggs Collected',
                    value: '102',
                    change: '+8',
                    isPositive: true,
                    theme: theme,
                  ),
                  _ProductionSummaryRow(
                    label: 'Feed Consumed',
                    value: '85 kg',
                    change: '-5 kg',
                    isPositive: false,
                    theme: theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons(
    ThemeData theme,
    List<AnimalEntity> animals,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_selectedTab == 0) ...[
            FloatingActionButton(
              heroTag: 'breeding',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BreedingScheduleScreen()),
                );
              },
              backgroundColor: theme.colorScheme.secondary,
              mini: true,
              child: const Icon(Icons.family_restroom, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'addAnimal',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAnimalScreen()),
                );
                if (result is! AnimalEntity) return;
                if (!mounted) return;
                context
                    .read<AnimalsBloc>()
                    .add(AnimalsEvent.add(animal: result));
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
          if (_selectedTab == 1) ...[
            FloatingActionButton(
              heroTag: 'formula',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FeedFormulaGeneratorScreen()),
                );
              },
              backgroundColor: theme.colorScheme.secondary,
              mini: true,
              child: const Icon(Icons.science, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'animalFeedCalculatorFAB',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnimalFeedCalculatorScreen(
                      animals: animals,
                      feedRequirements: _feedRequirements,
                    ),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.calculate, color: Colors.white),
            ),
          ],
          if (_selectedTab == 2) ...[
            FloatingActionButton(
              heroTag: 'schedule',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AnimalFeedingCalendarScreen()),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.calendar_today, color: Colors.white),
            ),
          ],
          if (_selectedTab == 3) ...[
            FloatingActionButton(
              heroTag: 'logProductionFAB',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProductionLoggingScreen()),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add_chart, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  String _getAnimalCategory(AnimalEntity animal) {
    final type = _displayType(animal.type.value);
    if (type.contains('Cow') || type.contains('Cattle')) return 'Cattle';
    if (type.contains('Chicken') || type == 'Layers') return 'Poultry';
    if (type.contains('Goat')) return 'Goats';
    if (type.contains('Sheep')) return 'Sheep';
    if (type.contains('Pig')) return 'Pigs';
    return 'Other';
  }

  String _displayType(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'cattle':
        return 'Cattle';
      case 'poultry':
        return 'Chicken';
      case 'goat':
        return 'Goat';
      case 'sheep':
        return 'Sheep';
      case 'pig':
        return 'Pig';
      default:
        if (rawType.trim().isEmpty) return 'Other';
        return rawType[0].toUpperCase() + rawType.substring(1);
    }
  }
}

// New Widgets for Feed Tools
class _FeedEstimateRow extends StatelessWidget {
  final String animalType;
  final double dailyIntake;
  final ThemeData theme;

  const _FeedEstimateRow({
    required this.animalType,
    required this.dailyIntake,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            animalType,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            '${dailyIntake.toStringAsFixed(1)} kg/day',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedingTaskRow extends StatelessWidget {
  final AnimalEntity animal;
  final ThemeData theme;

  const _FeedingTaskRow({
    required this.animal,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final type = _displayType(animal.type.value);
    final feedRequirement = animal.weight == null
        ? 'Not set'
        : '${(animal.weight! * 0.05).toStringAsFixed(1)} kg/day';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getAnimalColor(type).withValues(alpha: 0.1),
            child: Icon(
              _getAnimalIcon(type),
              color: _getAnimalColor(type),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal.name.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Feed: $feedRequirement',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Pending',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAnimalColor(String type) {
    switch (type.toLowerCase()) {
      case 'dairy cow':
        return Colors.blue;
      case 'beef cattle':
        return Colors.brown;
      case 'layers':
        return Colors.orange;
      case 'goat':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getAnimalIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dairy cow':
      case 'beef cattle':
        return Icons.agriculture;
      case 'layers':
        return Icons.egg;
      case 'goat':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  String _displayType(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'cattle':
        return 'Cattle';
      case 'poultry':
        return 'Chicken';
      case 'goat':
        return 'Goat';
      case 'sheep':
        return 'Sheep';
      case 'pig':
        return 'Pig';
      default:
        if (rawType.trim().isEmpty) return 'Other';
        return rawType[0].toUpperCase() + rawType.substring(1);
    }
  }
}

class _ProductionSummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final ThemeData theme;

  const _ProductionSummaryRow({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Row(
            children: [
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
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

class _AnimalStat extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _AnimalStat({
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.subtleShadow],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final AnimalEntity animal;
  final ThemeData theme;
  final VoidCallback onTap;

  const _AnimalCard({
    required this.animal,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = _displayType(animal.type.value);
    final breed = animal.breed ?? 'Unknown';
    const status = 'Healthy';
    const healthScore = 90;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: _getAnimalColor(type).withValues(alpha: 0.1),
              child: Icon(
                _getAnimalIcon(type),
                color: _getAnimalColor(type),
                size: 24,
              ),
            ),
          ],
        ),
        title: Text(
          animal.name.value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$type • $breed'),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Health: $healthScore%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getAnimalColor(String type) {
    switch (type.toLowerCase()) {
      case 'dairy cow':
        return Colors.blue;
      case 'beef cattle':
        return Colors.brown;
      case 'layers':
        return Colors.orange;
      case 'goat':
        return Colors.green;
      case 'sheep':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getAnimalIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dairy cow':
      case 'beef cattle':
        return Icons.agriculture;
      case 'layers':
        return Icons.egg;
      case 'goat':
        return Icons.pets;
      case 'sheep':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'laying':
        return Colors.green;
      case 'pregnant':
        return Colors.purple;
      case 'growing':
        return Colors.blue;
      case 'sick':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _displayType(String rawType) {
    switch (rawType.toLowerCase()) {
      case 'cattle':
        return 'Cattle';
      case 'poultry':
        return 'Chicken';
      case 'goat':
        return 'Goat';
      case 'sheep':
        return 'Sheep';
      case 'pig':
        return 'Pig';
      default:
        if (rawType.trim().isEmpty) return 'Other';
        return rawType[0].toUpperCase() + rawType.substring(1);
    }
  }
}
