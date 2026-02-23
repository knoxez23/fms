import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/animations/animated_card.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/data/database/database_helper.dart';
import 'package:pamoja_twalima/data/models/animal.dart';
import 'package:pamoja_twalima/data/models/animal_health_record.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/animals/animals_bloc.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/animal_entity.dart';
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
  final DatabaseHelper _dbHelper = DatabaseHelper();
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
              body: Column(
                children: [
                  Material(
                    color: theme.cardTheme.color,
                    child: TabBar(
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
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildAnimalsTab(
                          theme,
                          animals,
                          filteredAnimals,
                        ),
                        _buildFeedToolsTab(theme, animals),
                        _buildCalendarTab(theme, animals),
                        _buildProductionTab(theme),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton:
                  _buildFloatingActionButtons(context, theme, animals),
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
    final healthDataFuture = _loadAnimalHealthData(animals);
    return CustomScrollView(
      slivers: [
        // Header section with animal stats
        SliverToBoxAdapter(
          child: FutureBuilder<_AnimalHealthData>(
            future: healthDataFuture,
            builder: (context, snapshot) {
              final data = snapshot.data ??
                  _AnimalHealthData(
                    totalAnimals: animals.length,
                    avgHealthPercent: animals.isEmpty ? 0 : 100,
                    pregnantCount: 0,
                    insightsByAnimalId: const <String, _AnimalHealthInsight>{},
                  );

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _AnimalStat(
                      value: '${data.totalAnimals}',
                      label: 'Total Animals',
                      theme: theme,
                    ),
                    const SizedBox(width: 12),
                    _AnimalStat(
                      value: '${data.avgHealthPercent}%',
                      label: 'Avg Health',
                      theme: theme,
                    ),
                    const SizedBox(width: 12),
                    _AnimalStat(
                      value: '${data.pregnantCount}',
                      label: 'Pregnant',
                      theme: theme,
                    ),
                  ],
                ),
              );
            },
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
          sliver: FutureBuilder<_AnimalHealthData>(
            future: healthDataFuture,
            builder: (context, snapshot) {
              final insights = snapshot.data?.insightsByAnimalId ??
                  const <String, _AnimalHealthInsight>{};
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final animal = filteredAnimals[index];
                    final insight = insights[animal.id ?? ''] ??
                        const _AnimalHealthInsight(
                          status: 'Healthy',
                          score: 95,
                        );
                    return AnimatedCard(
                      index: index,
                      child: _AnimalCard(
                        animal: animal,
                        health: insight,
                        theme: theme,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AnimalDetailScreen.fromEntity(entity: animal),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {});
                        },
                        onHealthStatusSelected: (status) =>
                            _updateAnimalHealthStatus(
                          animal: animal,
                          status: status,
                        ),
                      ),
                    );
                  },
                  childCount: filteredAnimals.length,
                ),
              );
            },
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
    return FutureBuilder<_ProductionMetrics>(
      future: _loadProductionMetrics(),
      builder: (context, snapshot) {
        final metrics = snapshot.data ?? const _ProductionMetrics();

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
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductionLoggingScreen(),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {});
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
                      ...metrics.rows.map((row) => _ProductionSummaryRow(
                            label: row.label,
                            value: row.value,
                            change: row.change,
                            isPositive: row.isPositive,
                            theme: theme,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButtons(
    BuildContext blocContext,
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
                final animalsBloc = blocContext.read<AnimalsBloc>();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAnimalScreen()),
                );
                if (result is! AnimalEntity) return;
                if (!mounted) return;
                animalsBloc.add(AnimalsEvent.add(animal: result));
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

  Future<void> _updateAnimalHealthStatus({
    required AnimalEntity animal,
    required String status,
  }) async {
    final animalId = int.tryParse((animal.id ?? '').trim());
    if (animalId == null) return;

    try {
      final existingAnimals = await SyncData().getAnimals();
      final existing = existingAnimals.where((item) => item.id == animalId);
      if (existing.isEmpty) return;

      final current = existing.first;
      final updated = Animal(
        id: current.id,
        name: current.name,
        type: current.type,
        breed: current.breed,
        age: current.age,
        weight: current.weight,
        healthStatus: status,
        dateAcquired: current.dateAcquired,
        notes: current.notes,
        userId: current.userId,
      );
      await SyncData().updateAnimal(updated);

      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Updated ${animal.name.value} health to $status')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update health status')),
      );
    }
  }

  Future<_AnimalHealthData> _loadAnimalHealthData(List<AnimalEntity> animals) async {
    final total = animals.length;
    if (total == 0) {
      return const _AnimalHealthData(
        totalAnimals: 0,
        avgHealthPercent: 0,
        pregnantCount: 0,
        insightsByAnimalId: <String, _AnimalHealthInsight>{},
      );
    }

    try {
      final records = await SyncData().getAnimalHealthRecords();
      final latestByAnimal = _latestHealthByAnimal(records);
      final currentAnimals = await SyncData().getAnimals();
      final statusByAnimalId = <int, String>{
        for (final animal in currentAnimals)
          if (animal.id != null && (animal.healthStatus ?? '').trim().isNotEmpty)
            animal.id!: animal.healthStatus!.trim(),
      };

      var scoreSum = 0;
      final insightsByAnimalId = <String, _AnimalHealthInsight>{};
      for (final animal in animals) {
        final animalId = int.tryParse((animal.id ?? '').trim());
        final latest = animalId == null ? null : latestByAnimal[animalId];
        final insight = _resolveHealthInsight(
          overrideStatus: animalId == null ? null : statusByAnimalId[animalId],
          latestRecord: latest,
        );
        scoreSum += insight.score;
        if (animal.id != null) {
          insightsByAnimalId[animal.id!] = insight;
        }
      }

      final db = await _dbHelper.database;
      final pregnantRows = await db.rawQuery(
        '''
        SELECT COUNT(DISTINCT dam_animal_id) AS count
        FROM breeding_records
        WHERE LOWER(COALESCE(status, '')) != 'completed'
        ''',
      );
      final pregnantCount = Sqflite.firstIntValue(pregnantRows) ?? 0;

      return _AnimalHealthData(
        totalAnimals: total,
        avgHealthPercent: (scoreSum / total).round(),
        pregnantCount: pregnantCount,
        insightsByAnimalId: insightsByAnimalId,
      );
    } catch (_) {
      return _AnimalHealthData(
        totalAnimals: total,
        avgHealthPercent: 100,
        pregnantCount: 0,
        insightsByAnimalId: <String, _AnimalHealthInsight>{
          for (final animal in animals)
            if (animal.id != null)
              animal.id!: const _AnimalHealthInsight(
                status: 'Healthy',
                score: 95,
              ),
        },
      );
    }
  }

  Map<int, AnimalHealthRecord> _latestHealthByAnimal(
    List<AnimalHealthRecord> records,
  ) {
    final map = <int, AnimalHealthRecord>{};
    final timeMap = <int, DateTime>{};

    for (final record in records) {
      final recordedAt = DateTime.tryParse(record.treatedAt ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final existing = timeMap[record.animalId];
      if (existing == null || recordedAt.isAfter(existing)) {
        timeMap[record.animalId] = recordedAt;
        map[record.animalId] = record;
      }
    }
    return map;
  }

  _AnimalHealthInsight _resolveHealthInsight({
    required String? overrideStatus,
    required AnimalHealthRecord? latestRecord,
  }) {
    final normalized = _normalizeStatus(overrideStatus);
    if (normalized != null) {
      return _insightForStatus(normalized);
    }

    if (latestRecord == null) {
      return const _AnimalHealthInsight(status: 'Healthy', score: 95);
    }

    final text =
        '${latestRecord.type} ${latestRecord.name} ${latestRecord.notes ?? ''}'
            .toLowerCase();
    if (text.contains('critical') ||
        text.contains('severe') ||
        text.contains('emergency')) {
      return const _AnimalHealthInsight(status: 'Critical', score: 30);
    }
    if (text.contains('sick') ||
        text.contains('ill') ||
        text.contains('disease') ||
        text.contains('injur')) {
      return const _AnimalHealthInsight(status: 'At Risk', score: 55);
    }
    if (text.contains('recover') ||
        text.contains('monitor') ||
        text.contains('treatment')) {
      return const _AnimalHealthInsight(status: 'Monitoring', score: 75);
    }
    return const _AnimalHealthInsight(status: 'Healthy', score: 95);
  }

  String? _normalizeStatus(String? raw) {
    final text = raw?.trim().toLowerCase();
    if (text == null || text.isEmpty) return null;
    if (text.contains('critical')) return 'Critical';
    if (text.contains('risk') || text.contains('sick') || text.contains('ill')) {
      return 'At Risk';
    }
    if (text.contains('monitor') || text.contains('recover')) {
      return 'Monitoring';
    }
    return 'Healthy';
  }

  _AnimalHealthInsight _insightForStatus(String status) {
    switch (status) {
      case 'Critical':
        return const _AnimalHealthInsight(status: 'Critical', score: 30);
      case 'At Risk':
        return const _AnimalHealthInsight(status: 'At Risk', score: 55);
      case 'Monitoring':
        return const _AnimalHealthInsight(status: 'Monitoring', score: 75);
      default:
        return const _AnimalHealthInsight(status: 'Healthy', score: 95);
    }
  }

  Future<_ProductionMetrics> _loadProductionMetrics() async {
    final db = await _dbHelper.database;

    Future<double> sumForType(String type, int dayOffset) async {
      final rows = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(quantity), 0) AS total
        FROM production_logs
        WHERE LOWER(COALESCE(production_type, '')) = ?
          AND DATE(date_produced) = DATE('now', ?)
        ''',
        [type.toLowerCase(), '$dayOffset day'],
      );
      return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
    }

    Future<double> sumFeed(int dayOffset) async {
      final rows = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(quantity), 0) AS total
        FROM feeding_logs
        WHERE DATE(fed_at) = DATE('now', ?)
        ''',
        ['$dayOffset day'],
      );
      return (rows.first['total'] as num?)?.toDouble() ?? 0.0;
    }

    final todayMilk = await sumForType('milk', 0);
    final yesterdayMilk = await sumForType('milk', -1);
    final todayEggs = await sumForType('eggs', 0);
    final yesterdayEggs = await sumForType('eggs', -1);
    final todayFeed = await sumFeed(0);
    final yesterdayFeed = await sumFeed(-1);

    String diffLabel(double today, double yesterday, {String suffix = ''}) {
      final diff = today - yesterday;
      final sign = diff >= 0 ? '+' : '';
      return '$sign${diff.toStringAsFixed(diff.abs() < 1 ? 1 : 0)}$suffix';
    }

    return _ProductionMetrics(
      rows: [
        _ProductionSummaryMetric(
          label: 'Total Milk Today',
          value: '${todayMilk.toStringAsFixed(todayMilk < 10 ? 1 : 0)}L',
          change: diffLabel(todayMilk, yesterdayMilk, suffix: 'L'),
          isPositive: todayMilk >= yesterdayMilk,
        ),
        _ProductionSummaryMetric(
          label: 'Eggs Collected',
          value: todayEggs.toStringAsFixed(0),
          change: diffLabel(todayEggs, yesterdayEggs),
          isPositive: todayEggs >= yesterdayEggs,
        ),
        _ProductionSummaryMetric(
          label: 'Feed Consumed',
          value: '${todayFeed.toStringAsFixed(todayFeed < 10 ? 1 : 0)} kg',
          change: diffLabel(todayFeed, yesterdayFeed, suffix: ' kg'),
          isPositive: todayFeed <= yesterdayFeed,
        ),
      ],
    );
  }
}

class _AnimalTopStats {
  final int totalAnimals;
  final int avgHealthPercent;
  final int pregnantCount;

  const _AnimalTopStats({
    required this.totalAnimals,
    required this.avgHealthPercent,
    required this.pregnantCount,
  });
}

class _AnimalHealthData extends _AnimalTopStats {
  final Map<String, _AnimalHealthInsight> insightsByAnimalId;

  const _AnimalHealthData({
    required super.totalAnimals,
    required super.avgHealthPercent,
    required super.pregnantCount,
    required this.insightsByAnimalId,
  });
}

class _AnimalHealthInsight {
  final String status;
  final int score;

  const _AnimalHealthInsight({
    required this.status,
    required this.score,
  });
}

class _ProductionMetrics {
  final List<_ProductionSummaryMetric> rows;

  const _ProductionMetrics({this.rows = const []});
}

class _ProductionSummaryMetric {
  final String label;
  final String value;
  final String change;
  final bool isPositive;

  const _ProductionSummaryMetric({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
  });
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
  final _AnimalHealthInsight health;
  final ThemeData theme;
  final VoidCallback onTap;
  final ValueChanged<String>? onHealthStatusSelected;

  const _AnimalCard({
    required this.animal,
    required this.health,
    required this.theme,
    required this.onTap,
    this.onHealthStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final type = _displayType(animal.type.value);
    final breed = animal.breed ?? 'Unknown';
    final status = health.status;
    final healthScore = health.score;

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
            PopupMenuButton<String>(
              tooltip: 'Set health status',
              onSelected: onHealthStatusSelected,
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'Healthy', child: Text('Healthy')),
                PopupMenuItem(value: 'Monitoring', child: Text('Monitoring')),
                PopupMenuItem(value: 'At Risk', child: Text('At Risk')),
                PopupMenuItem(value: 'Critical', child: Text('Critical')),
              ],
              icon: Icon(
                Icons.tune,
                size: 18,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
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
