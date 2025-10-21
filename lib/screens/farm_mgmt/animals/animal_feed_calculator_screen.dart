import 'package:flutter/material.dart';
import 'package:pamoja_twalima/theme/app_colors.dart';

class AnimalFeedCalculatorScreen extends StatefulWidget {
  final List<Map<String, dynamic>> animals;
  final Map<String, Map<String, double>> feedRequirements;

  const AnimalFeedCalculatorScreen({
    super.key,
    required this.animals,
    required this.feedRequirements,
  });

  @override
  State<AnimalFeedCalculatorScreen> createState() => _AnimalFeedCalculatorScreenState();
}

class _AnimalFeedCalculatorScreenState extends State<AnimalFeedCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedAnimalType = 'Dairy Cow';
  double _animalWeight = 450.0;
  int _numberOfAnimals = 1;
  int _durationDays = 7;
  String _productionStage = 'Lactating';
  double _milkProduction = 0.0;

  // Calculation results
  double _dailyFeedRequired = 0.0;
  double _totalFeedRequired = 0.0;
  double _estimatedCost = 0.0;

  // Feed prices (KSh per kg)
  final Map<String, double> _feedPrices = {
    'Dairy Meal': 65.0,
    'Maize Germ': 45.0,
    'Wheat Bran': 35.0,
    'Napier Grass': 15.0,
    'Lucerne': 40.0,
    'Commercial Feed': 80.0,
  };

  // Animal requirements with proper double values
  final Map<String, Map<String, double>> _animalRequirements = {
    'Dairy Cow': {
      'maintenance': 2.5,  // % of body weight for maintenance
      'production': 0.3,   // additional % per liter of milk
      'pregnancy': 0.2,    // additional % in last trimester
      'growth': 0.15,      // additional % for growing animals
    },
    'Beef Cattle': {
      'maintenance': 2.2,
      'production': 0.0,
      'pregnancy': 0.15,
      'growth': 0.25,
    },
    'Layers': {
      'maintenance': 0.12, // kg per bird per day
      'production': 0.0,
      'pregnancy': 0.0,
      'growth': 0.0,
    },
    'Broilers': {
      'maintenance': 0.15,
      'production': 0.0,
      'pregnancy': 0.0,
      'growth': 0.1,
    },
    'Goats': {
      'maintenance': 3.0,
      'production': 0.25,
      'pregnancy': 0.15,
      'growth': 0.2,
    },
    'Pigs': {
      'maintenance': 2.8,
      'production': 0.0,
      'pregnancy': 0.2,
      'growth': 0.3,
    },
  };

  // Production stages
  final Map<String, List<String>> _productionStages = {
    'Dairy Cow': ['Lactating', 'Dry', 'Pregnant', 'Growing'],
    'Beef Cattle': ['Finishing', 'Growing', 'Maintenance', 'Pregnant'],
    'Layers': ['Laying', 'Molting', 'Growing'],
    'Broilers': ['Starter', 'Grower', 'Finisher'],
    'Goats': ['Lactating', 'Dry', 'Pregnant', 'Growing'],
    'Pigs': ['Gestation', 'Lactation', 'Growing', 'Finishing'],
  };

  @override
  void initState() {
    super.initState();
    _calculateRequirements();
  }

  void _calculateRequirements() {
    final requirements = _animalRequirements[_selectedAnimalType]!;
    double baseRequirement = 0.0;

    if (_selectedAnimalType == 'Layers' || _selectedAnimalType == 'Broilers') {
      // For poultry: fixed amount per bird
      baseRequirement = requirements['maintenance']!;
      if (_productionStage == 'Growing' || _productionStage == 'Starter' || _productionStage == 'Grower') {
        baseRequirement += requirements['growth']!;
      }
      _dailyFeedRequired = baseRequirement * _numberOfAnimals;
    } else {
      // For livestock: percentage of body weight
      baseRequirement = (_animalWeight * requirements['maintenance']! / 100);

      // Add production requirements
      if (_productionStage == 'Lactating' && _selectedAnimalType == 'Dairy Cow') {
        baseRequirement += (_milkProduction * requirements['production']!);
      }

      // Add pregnancy requirements
      if (_productionStage == 'Pregnant' || _productionStage == 'Gestation') {
        baseRequirement += (_animalWeight * requirements['pregnancy']! / 100);
      }

      // Add growth requirements
      if (_productionStage == 'Growing') {
        baseRequirement += (_animalWeight * requirements['growth']! / 100);
      }

      _dailyFeedRequired = baseRequirement * _numberOfAnimals;
    }

    _totalFeedRequired = _dailyFeedRequired * _durationDays;
    _estimatedCost = _totalFeedRequired * _feedPrices['Commercial Feed']!;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requirements = _animalRequirements[_selectedAnimalType]!;
    final availableStages = _productionStages[_selectedAnimalType] ?? ['General'];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Feed Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _viewCalculationHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Animal Information
              _AnimatedCard(
                index: 0,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Animal Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Animal Type
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAnimalType,
                        items: _animalRequirements.keys.map((animalType) {
                          return DropdownMenuItem(
                            value: animalType,
                            child: Text(animalType),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Animal Type *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedAnimalType = value!;
                            _productionStage = availableStages.first;
                            // Reset milk production when animal type changes
                            if (_selectedAnimalType != 'Dairy Cow') {
                              _milkProduction = 0.0;
                            }
                          });
                          _calculateRequirements();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Production Stage
                      DropdownButtonFormField<String>(
                        initialValue: _productionStage,
                        items: availableStages.map((stage) {
                          return DropdownMenuItem(
                            value: stage,
                            child: Text(stage),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Production Stage *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _productionStage = value!;
                          });
                          _calculateRequirements();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Animal Weight (for livestock)
                      if (_selectedAnimalType != 'Layers' && _selectedAnimalType != 'Broilers')
                        TextFormField(
                          initialValue: _animalWeight.toStringAsFixed(0),
                          decoration: const InputDecoration(
                            labelText: 'Animal Weight (kg) *',
                            border: OutlineInputBorder(),
                            suffixText: 'kg',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final weight = double.tryParse(value) ?? 0.0;
                            setState(() {
                              _animalWeight = weight;
                            });
                            _calculateRequirements();
                          },
                        ),

                      const SizedBox(height: 16),

                      // Number of Animals
                      TextFormField(
                        initialValue: _numberOfAnimals.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Number of Animals *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final count = int.tryParse(value) ?? 1;
                          setState(() {
                            _numberOfAnimals = count;
                          });
                          _calculateRequirements();
                        },
                      ),

                      const SizedBox(height: 16),

                      // Milk Production (for dairy cows)
                      if (_selectedAnimalType == 'Dairy Cow' && _productionStage == 'Lactating')
                        TextFormField(
                          initialValue: _milkProduction.toStringAsFixed(1),
                          decoration: const InputDecoration(
                            labelText: 'Daily Milk Production (liters)',
                            border: OutlineInputBorder(),
                            suffixText: 'liters/day',
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final production = double.tryParse(value) ?? 0.0;
                            setState(() {
                              _milkProduction = production;
                            });
                            _calculateRequirements();
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Calculation Period
              _AnimatedCard(
                index: 1,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calculation Period',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _durationDays.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Duration (days) *',
                          border: OutlineInputBorder(),
                          suffixText: 'days',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          final days = int.tryParse(value) ?? 7;
                          setState(() {
                            _durationDays = days;
                          });
                          _calculateRequirements();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Results
              _AnimatedCard(
                index: 2,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feed Requirements',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _ResultRow(
                        label: 'Daily Feed Required',
                        value: '${_dailyFeedRequired.toStringAsFixed(1)} kg',
                        theme: theme,
                      ),
                      _ResultRow(
                        label: 'Total Feed Required',
                        value: '${_totalFeedRequired.toStringAsFixed(1)} kg',
                        theme: theme,
                      ),
                      _ResultRow(
                        label: 'Estimated Cost',
                        value: 'KSh ${_estimatedCost.toStringAsFixed(0)}',
                        theme: theme,
                        isHighlighted: true,
                      ),

                      const SizedBox(height: 16),

                      // Feed Recommendations
                      Text(
                        'Recommended Feed Types:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: _getRecommendedFeeds().map((feed) {
                          return Chip(
                            label: Text(feed),
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Feed Price Reference
              _AnimatedCard(
                index: 3,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Feed Prices (KSh/kg)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._feedPrices.entries.map((entry) {
                        return _PriceRow(
                          feed: entry.key,
                          price: entry.value,
                          theme: theme,
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saveCalculation,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save Calculation'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _shareResults,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Share Results'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _getRecommendedFeeds() {
    switch (_selectedAnimalType) {
      case 'Dairy Cow':
        return ['Dairy Meal', 'Maize Germ', 'Napier Grass', 'Lucerne'];
      case 'Beef Cattle':
        return ['Beef Finisher', 'Maize Germ', 'Wheat Bran', 'Napier Grass'];
      case 'Layers':
        return ['Layer Mash', 'Maize', 'Wheat Bran'];
      case 'Broilers':
        return ['Starter Mash', 'Grower Mash', 'Finisher Mash'];
      case 'Goats':
        return ['Goat Pellets', 'Maize Germ', 'Lucerne'];
      case 'Pigs':
        return ['Pig Grower', 'Maize', 'Wheat Bran'];
      default:
        return ['Commercial Feed', 'Maize', 'Wheat Bran'];
    }
  }

  void _viewCalculationHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing calculation history...')),
    );
  }

  void _saveCalculation() {
    final calculation = {
      'animalType': _selectedAnimalType,
      'weight': _animalWeight,
      'numberOfAnimals': _numberOfAnimals,
      'durationDays': _durationDays,
      'productionStage': _productionStage,
      'milkProduction': _milkProduction,
      'dailyFeedRequired': _dailyFeedRequired,
      'totalFeedRequired': _totalFeedRequired,
      'estimatedCost': _estimatedCost,
      'calculatedAt': DateTime.now(),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calculation saved for $_selectedAnimalType')),
    );

    print('Saved calculation: $calculation');
  }

  void _shareResults() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing calculation results...')),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isHighlighted;

  const _ResultRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isHighlighted = false,
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
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              fontSize: isHighlighted ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String feed;
  final double price;
  final ThemeData theme;

  const _PriceRow({
    required this.feed,
    required this.price,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            feed,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            'KSh ${price.toStringAsFixed(0)}',
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
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: widget.theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.subtleShadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}