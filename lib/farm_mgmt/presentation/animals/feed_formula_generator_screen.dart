import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';

class FeedFormulaGeneratorScreen extends StatefulWidget {
  const FeedFormulaGeneratorScreen({super.key});

  @override
  State<FeedFormulaGeneratorScreen> createState() => _FeedFormulaGeneratorScreenState();
}

class _FeedFormulaGeneratorScreenState extends State<FeedFormulaGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Feed ingredients database with nutritional values
  final Map<String, Map<String, double>> _feedIngredients = {
    'Maize': {
      'protein': 8.5,
      'energy': 3.4,
      'fiber': 2.0,
      'fat': 3.8,
      'costPerKg': 45.0,
    },
    'Soybean Meal': {
      'protein': 44.0,
      'energy': 2.5,
      'fiber': 6.0,
      'fat': 1.5,
      'costPerKg': 120.0,
    },
    'Wheat Bran': {
      'protein': 15.0,
      'energy': 1.8,
      'fiber': 12.0,
      'fat': 4.0,
      'costPerKg': 35.0,
    },
    'Fish Meal': {
      'protein': 60.0,
      'energy': 2.8,
      'fiber': 1.0,
      'fat': 8.0,
      'costPerKg': 200.0,
    },
    'Sunflower Cake': {
      'protein': 28.0,
      'energy': 2.2,
      'fiber': 25.0,
      'fat': 1.5,
      'costPerKg': 60.0,
    },
    'Cotton Seed Cake': {
      'protein': 22.0,
      'energy': 2.1,
      'fiber': 20.0,
      'fat': 6.0,
      'costPerKg': 50.0,
    },
    'Napier Grass': {
      'protein': 8.0,
      'energy': 1.2,
      'fiber': 30.0,
      'fat': 2.0,
      'costPerKg': 15.0,
    },
    'Lucerne': {
      'protein': 18.0,
      'energy': 1.8,
      'fiber': 25.0,
      'fat': 2.5,
      'costPerKg': 40.0,
    },
    'Dicalcium Phosphate': {
      'protein': 0.0,
      'energy': 0.0,
      'fiber': 0.0,
      'fat': 0.0,
      'costPerKg': 150.0,
    },
    'Salt': {
      'protein': 0.0,
      'energy': 0.0,
      'fiber': 0.0,
      'fat': 0.0,
      'costPerKg': 25.0,
    },
    'Vitamin Premix': {
      'protein': 0.0,
      'energy': 0.0,
      'fiber': 0.0,
      'fat': 0.0,
      'costPerKg': 300.0,
    },
  };

  // Animal requirements
  final Map<String, Map<String, double>> _animalRequirements = {
    'Dairy Cow': {
      'protein': 16.0,
      'energy': 1.7,
      'fiber': 17.0,
      'fat': 3.0,
    },
    'Beef Cattle': {
      'protein': 12.0,
      'energy': 1.4,
      'fiber': 15.0,
      'fat': 2.5,
    },
    'Layers': {
      'protein': 16.0,
      'energy': 2.8,
      'fiber': 5.0,
      'fat': 3.5,
    },
    'Broilers': {
      'protein': 21.0,
      'energy': 3.2,
      'fiber': 4.0,
      'fat': 4.0,
    },
    'Goats': {
      'protein': 14.0,
      'energy': 2.0,
      'fiber': 20.0,
      'fat': 3.0,
    },
    'Pigs': {
      'protein': 18.0,
      'energy': 3.0,
      'fiber': 5.0,
      'fat': 3.5,
    },
  };

  String _selectedAnimal = 'Dairy Cow';
  final double _totalWeight = 100.0;
  final Map<String, double> _selectedIngredients = {};
  final Map<String, TextEditingController> _ingredientControllers = {};

  double _totalProtein = 0.0;
  double _totalEnergy = 0.0;
  double _totalFiber = 0.0;
  double _totalFat = 0.0;
  double _totalCost = 0.0;

  @override
  void initState() {
    super.initState();
    // Initialize with some default ingredients
    _selectedIngredients['Maize'] = 40.0;
    _selectedIngredients['Soybean Meal'] = 25.0;
    _selectedIngredients['Wheat Bran'] = 20.0;
    _selectedIngredients['Napier Grass'] = 10.0;
    _selectedIngredients['Salt'] = 0.5;
    _selectedIngredients['Vitamin Premix'] = 0.5;

    // Create controllers
    for (var ingredient in _selectedIngredients.keys) {
      _ingredientControllers[ingredient] =
          TextEditingController(text: _selectedIngredients[ingredient]!.toStringAsFixed(1));
    }

    _calculateFormula();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _ingredientControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateFormula() {
    setState(() {
      _totalProtein = 0.0;
      _totalEnergy = 0.0;
      _totalFiber = 0.0;
      _totalFat = 0.0;
      _totalCost = 0.0;

      double totalPercentage = 0.0;

      for (var entry in _selectedIngredients.entries) {
        final ingredient = entry.key;
        final percentage = entry.value;
        final nutrition = _feedIngredients[ingredient]!;

        totalPercentage += percentage;
        _totalProtein += (percentage / 100) * nutrition['protein']!;
        _totalEnergy += (percentage / 100) * nutrition['energy']!;
        _totalFiber += (percentage / 100) * nutrition['fiber']!;
        _totalFat += (percentage / 100) * nutrition['fat']!;
        _totalCost += (percentage / 100) * nutrition['costPerKg']!;
      }

      // Normalize if total percentage is not 100
      if (totalPercentage != 100.0 && totalPercentage > 0) {
        final factor = 100.0 / totalPercentage;
        _totalProtein *= factor;
        _totalEnergy *= factor;
        _totalFiber *= factor;
        _totalFat *= factor;
        _totalCost *= factor;
      }
    });
  }

  void _addIngredient(String ingredient) {
    setState(() {
      _selectedIngredients[ingredient] = 0.0;
      _ingredientControllers[ingredient] = TextEditingController(text: '0.0');
    });
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _selectedIngredients.remove(ingredient);
      _ingredientControllers[ingredient]?.dispose();
      _ingredientControllers.remove(ingredient);
      _calculateFormula();
    });
  }

  void _updateIngredientPercentage(String ingredient, String value) {
    final percentage = double.tryParse(value) ?? 0.0;
    setState(() {
      _selectedIngredients[ingredient] = percentage;
    });
    _calculateFormula();
  }

  void _autoBalanceFormula() {
    // Simple auto-balancing logic
    final requirements = _animalRequirements[_selectedAnimal]!;
    final currentIngredients = Map<String, double>.from(_selectedIngredients);

    // Reset all percentages
    for (var ingredient in currentIngredients.keys) {
      _selectedIngredients[ingredient] = 0.0;
    }

    // Simple distribution based on protein content
    double remaining = 100.0;
    final highProteinIngredients = _selectedIngredients.keys
        .where((ing) => _feedIngredients[ing]!['protein']! > 20.0)
        .toList();

    final mediumProteinIngredients = _selectedIngredients.keys
        .where((ing) => _feedIngredients[ing]!['protein']! >= 10.0 &&
        _feedIngredients[ing]!['protein']! <= 20.0)
        .toList();

    final lowProteinIngredients = _selectedIngredients.keys
        .where((ing) => _feedIngredients[ing]!['protein']! < 10.0)
        .toList();

    // Distribute percentages (this is a simplified algorithm)
    if (highProteinIngredients.isNotEmpty) {
      final share = (requirements['protein']! * 0.4).clamp(10.0, 30.0);
      _selectedIngredients[highProteinIngredients.first] = share;
      remaining -= share;
    }

    if (mediumProteinIngredients.isNotEmpty) {
      final share = (remaining * 0.6).clamp(20.0, 50.0);
      _selectedIngredients[mediumProteinIngredients.first] = share;
      remaining -= share;
    }

    if (lowProteinIngredients.isNotEmpty) {
      _selectedIngredients[lowProteinIngredients.first] = remaining;
    }

    // Update controllers
    for (var entry in _selectedIngredients.entries) {
      _ingredientControllers[entry.key]?.text = entry.value.toStringAsFixed(1);
    }

    _calculateFormula();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final requirements = _animalRequirements[_selectedAnimal]!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Feed Formula Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveFormula,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Animal Selection
              _AnimatedCard(
                index: 0,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Animal Type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAnimal,
                        items: _animalRequirements.keys.map((animal) {
                          return DropdownMenuItem(
                            value: animal,
                            child: Text(animal),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAnimal = value!;
                          });
                          _calculateFormula();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select Animal Type',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Available Ingredients
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
                          Text(
                            'Available Ingredients',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: _autoBalanceFormula,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Auto Balance'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _feedIngredients.keys.map((ingredient) {
                          final isSelected = _selectedIngredients.containsKey(ingredient);
                          return FilterChip(
                            label: Text(ingredient),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                _addIngredient(ingredient);
                              } else {
                                _removeIngredient(ingredient);
                              }
                            },
                            backgroundColor: theme.cardTheme.color,
                            selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                            checkmarkColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Formula Composition
              _AnimatedCard(
                index: 2,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formula Composition',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._selectedIngredients.entries.map((entry) {
                        final ingredient = entry.key;
                        final nutrition = _feedIngredients[ingredient]!;
                        return _IngredientRow(
                          ingredient: ingredient,
                          protein: nutrition['protein']!,
                          energy: nutrition['energy']!,
                          percentage: entry.value,
                          controller: _ingredientControllers[ingredient]!,
                          onChanged: (value) => _updateIngredientPercentage(ingredient, value),
                          onRemove: () => _removeIngredient(ingredient),
                          theme: theme,
                        );
                      }),
                      const SizedBox(height: 8),
                      Text(
                        'Total: ${_selectedIngredients.values.fold(0.0, (sum, value) => sum + value).toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _selectedIngredients.values.fold(0.0, (sum, value) => sum + value) == 100.0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Nutritional Analysis
              _AnimatedCard(
                index: 3,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nutritional Analysis',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _NutritionRow(
                        nutrient: 'Protein',
                        current: _totalProtein,
                        required: requirements['protein']!,
                        unit: '%',
                        theme: theme,
                      ),
                      _NutritionRow(
                        nutrient: 'Energy',
                        current: _totalEnergy,
                        required: requirements['energy']!,
                        unit: 'Mcal/kg',
                        theme: theme,
                      ),
                      _NutritionRow(
                        nutrient: 'Fiber',
                        current: _totalFiber,
                        required: requirements['fiber']!,
                        unit: '%',
                        theme: theme,
                      ),
                      _NutritionRow(
                        nutrient: 'Fat',
                        current: _totalFat,
                        required: requirements['fat']!,
                        unit: '%',
                        theme: theme,
                      ),
                      const SizedBox(height: 12),
                      Divider(color: theme.dividerColor),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cost per kg:',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'KSh ${_totalCost.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Save Formula Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveFormula,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Feed Formula'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _saveFormula() {
    if (_selectedIngredients.values.fold(0.0, (sum, value) => sum + value) != 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total percentage must equal 100%')),
      );
      return;
    }

    // Save formula logic here
    final formula = {
      'animalType': _selectedAnimal,
      'ingredients': _selectedIngredients,
      'nutrition': {
        'protein': _totalProtein,
        'energy': _totalEnergy,
        'fiber': _totalFiber,
        'fat': _totalFat,
      },
      'costPerKg': _totalCost,
      'createdAt': DateTime.now(),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Formula saved for $_selectedAnimal')),
    );

    // Navigate back or show success
    print('Saved formula: $formula');
  }
}

class _IngredientRow extends StatelessWidget {
  final String ingredient;
  final double protein;
  final double energy;
  final double percentage;
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onRemove;
  final ThemeData theme;

  const _IngredientRow({
    required this.ingredient,
    required this.protein,
    required this.energy,
    required this.percentage,
    required this.controller,
    required this.onChanged,
    required this.onRemove,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'P: ${protein.toStringAsFixed(1)}%, E: ${energy.toStringAsFixed(1)} Mcal/kg',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '%',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String nutrient;
  final double current;
  final double required;
  final String unit;
  final ThemeData theme;

  const _NutritionRow({
    required this.nutrient,
    required this.current,
    required this.required,
    required this.unit,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final difference = current - required;
    final isOptimal = difference.abs() <= (required * 0.1); // Within 10% of requirement
    final isDeficient = current < required;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(nutrient),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${current.toStringAsFixed(1)}$unit',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isOptimal ? Colors.green : (isDeficient ? Colors.orange : Colors.blue),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Req: ${required.toStringAsFixed(1)}$unit',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isOptimal
                    ? Colors.green.withValues(alpha: 0.1)
                    : (isDeficient ? Colors.orange.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isOptimal ? 'Good' : (isDeficient ? 'Low' : 'High'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isOptimal ? Colors.green : (isDeficient ? Colors.orange : Colors.blue),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
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