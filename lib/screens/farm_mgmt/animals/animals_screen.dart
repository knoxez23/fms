import 'package:flutter/material.dart';
import 'package:pamoja_twalima/theme/app_colors.dart';
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
  final List<Map<String, dynamic>> animals = [
    {
      'id': '1',
      'name': 'Daisy',
      'type': 'Dairy Cow',
      'breed': 'Friesian',
      'age': '3 years',
      'status': 'Healthy',
      'lastMilking': '4 hours ago',
      'production': '18L/day',
      'healthScore': 95,
      'weight': '450 kg',
      'feedRequirement': '25 kg/day',
    },
    {
      'id': '2',
      'name': 'Bella',
      'type': 'Dairy Cow',
      'breed': 'Jersey',
      'age': '4 years',
      'status': 'Pregnant',
      'lastMilking': '6 hours ago',
      'production': '15L/day',
      'healthScore': 88,
      'weight': '380 kg',
      'feedRequirement': '22 kg/day',
    },
    {
      'id': '3',
      'name': 'Rocky',
      'type': 'Beef Cattle',
      'breed': 'Borana',
      'age': '2 years',
      'status': 'Growing',
      'weight': '320 kg',
      'healthScore': 92,
      'feedRequirement': '18 kg/day',
    },
    {
      'id': '4',
      'name': 'Chicken Flock A',
      'type': 'Layers',
      'breed': 'Kienyeji',
      'age': '8 months',
      'status': 'Laying',
      'eggProduction': '85%',
      'healthScore': 90,
      'quantity': 120,
      'feedRequirement': '15 kg/day',
    },
    {
      'id': '5',
      'name': 'Billy',
      'type': 'Goat',
      'breed': 'Galla',
      'age': '1 year',
      'status': 'Healthy',
      'weight': '45 kg',
      'healthScore': 96,
      'feedRequirement': '2.5 kg/day',
    },
  ];

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

    final filteredAnimals = _selectedFilter == 'All'
        ? animals
        : animals
        .where((animal) =>
    _getAnimalCategory(animal['type']) == _selectedFilter)
        .toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Animal Management'),
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
        ),
        body: TabBarView(
          children: [
            // Animals Tab
            _buildAnimalsTab(theme, filteredAnimals),

            // Feed Tools Tab
            _buildFeedToolsTab(theme),

            // Calendar Tab
            _buildCalendarTab(theme),

            // Production Tab
            _buildProductionTab(theme),
          ],
        ),
        floatingActionButton: _buildFloatingActionButtons(theme),
      ),
    );
  }

  Widget _buildAnimalsTab(ThemeData theme, List<Map<String, dynamic>> filteredAnimals) {
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
                    selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.8),
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
                            : theme.dividerColor.withOpacity(0.3),
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
                return _AnimatedCard(
                  index: index,
                  theme: theme,
                  child: _AnimalCard(
                    animal: animal,
                    theme: theme,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimalDetailScreen(animal: animal),
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

  Widget _buildFeedToolsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Feed Calculator Card
          _AnimatedCard(
            index: 0,
            theme: theme,
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
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
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
          _AnimatedCard(
            index: 1,
            theme: theme,
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
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
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
          _AnimatedCard(
            index: 2,
            theme: theme,
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

  Widget _buildCalendarTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _AnimatedCard(
            index: 0,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: theme.colorScheme.primary),
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
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnimalFeedingCalendarScreen(animals: animals),
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
          _AnimatedCard(
            index: 1,
            theme: theme,
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
                          builder: (_) => AnimalFeedingCalendarScreen(animals: animals),
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
          _AnimatedCard(
            index: 0,
            theme: theme,
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
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductionLoggingScreen(animals: animals),
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
          _AnimatedCard(
            index: 1,
            theme: theme,
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

  Widget _buildFloatingActionButtons(ThemeData theme) {
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
                  MaterialPageRoute(builder: (_) => const BreedingScheduleScreen()),
                );
              },
              backgroundColor: theme.colorScheme.secondary,
              mini: true,
              child: const Icon(Icons.family_restroom, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAnimalScreen()),
                );
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
                  MaterialPageRoute(builder: (_) => const FeedFormulaGeneratorScreen()),
                );
              },
              backgroundColor: theme.colorScheme.secondary,
              mini: true,
              child: const Icon(Icons.science, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
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
                  MaterialPageRoute(builder: (_) => AnimalFeedingCalendarScreen(animals: animals)),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.calendar_today, color: Colors.white),
            ),
          ],
          if (_selectedTab == 3) ...[
            FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProductionLoggingScreen(animals: animals)),
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

  String _getAnimalCategory(String type) {
    if (type.contains('Cow') || type.contains('Cattle')) return 'Cattle';
    if (type.contains('Chicken') || type == 'Layers') return 'Poultry';
    if (type.contains('Goat')) return 'Goats';
    if (type.contains('Sheep')) return 'Sheep';
    if (type.contains('Pig')) return 'Pigs';
    return 'Other';
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
  final Map<String, dynamic> animal;
  final ThemeData theme;

  const _FeedingTaskRow({
    required this.animal,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getAnimalColor(animal['type']).withOpacity(0.1),
            child: Icon(
              _getAnimalIcon(animal['type']),
              color: _getAnimalColor(animal['type']),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Feed: ${animal['feedRequirement'] ?? 'Not set'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
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
                  color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
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
          boxShadow: const [AppColors.subtleShadow],
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
                color: theme.colorScheme.onSurface.withOpacity(0.6),
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
  final Map<String, dynamic> animal;
  final ThemeData theme;
  final VoidCallback onTap;

  const _AnimalCard({
    required this.animal,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGroup = animal['groupType'] == 'Group';
    final quantity = animal['quantity'] ?? 1;
    final purchasePrice = animal['purchasePrice'] ?? 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: _getAnimalColor(animal['type']).withOpacity(0.1),
              child: Icon(
                _getAnimalIcon(animal['type']),
                color: _getAnimalColor(animal['type']),
                size: 24,
              ),
            ),
            if (isGroup && quantity > 1)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    quantity.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          animal['name'],
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${animal['type']} • ${animal['breed']}'),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(animal['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    animal['status'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(animal['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isGroup)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Group',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            if (animal['shed'] != null)
              Text(
                'Location: ${animal['shed']}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (purchasePrice > 0)
              Text(
                'KSh ${purchasePrice.toStringAsFixed(0)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (isGroup && quantity > 1)
              Text(
                '$quantity animals',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            Text(
              'Health: ${animal['healthScore']}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
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
}

// Reuse the _AnimatedCard widget
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
        child: widget.child,
      ),
    );
  }
}
