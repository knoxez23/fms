import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';

class ProductionLoggingScreen extends StatefulWidget {
  final List<Map<String, dynamic>> animals;

  const ProductionLoggingScreen({super.key, required this.animals});

  @override
  State<ProductionLoggingScreen> createState() => _ProductionLoggingScreenState();
}

class _ProductionLoggingScreenState extends State<ProductionLoggingScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedAnimal = '';
  String _selectedProductType = 'Milk';
  String _selectedUnit = 'liters';
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _qualityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Production types and their units
  final Map<String, List<String>> _productTypes = {
    'Dairy': ['Milk', 'Yogurt', 'Cheese', 'Butter'],
    'Poultry': ['Eggs', 'Meat', 'Manure'],
    'Livestock': ['Meat', 'Manure', 'Wool'],
    'Other': ['Honey', 'Manure', 'Other'],
  };

  final Map<String, List<String>> _units = {
    'Milk': ['liters', 'ml'],
    'Yogurt': ['kg', 'grams', 'containers'],
    'Cheese': ['kg', 'grams', 'wheels'],
    'Butter': ['kg', 'grams', 'blocks'],
    'Eggs': ['pieces', 'trays', 'crates'],
    'Meat': ['kg', 'grams'],
    'Manure': ['kg', 'bags', 'wheelbarrows'],
    'Wool': ['kg', 'grams'],
    'Honey': ['kg', 'grams', 'jars'],
    'Other': ['kg', 'liters', 'pieces'],
  };

  // Recent production records
  final List<Map<String, dynamic>> _productionRecords = [
    {
      'id': '1',
      'animalName': 'Daisy',
      'productType': 'Milk',
      'quantity': 18.5,
      'unit': 'liters',
      'quality': 'Good',
      'date': '2024-03-15',
      'time': '08:30',
    },
    {
      'id': '2',
      'animalName': 'Chicken Flock A',
      'productType': 'Eggs',
      'quantity': 120,
      'unit': 'pieces',
      'quality': 'Excellent',
      'date': '2024-03-15',
      'time': '10:15',
    },
    {
      'id': '3',
      'animalName': 'Bella',
      'productType': 'Milk',
      'quantity': 15.0,
      'unit': 'liters',
      'quality': 'Good',
      'date': '2024-03-15',
      'time': '08:45',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set default animal if available
    if (widget.animals.isNotEmpty) {
      _selectedAnimal = widget.animals.first['name'] as String;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dairyAnimals = widget.animals.where((animal) =>
    (animal['type'] as String).contains('Cow') ||
        (animal['type'] as String).contains('Dairy')).toList();
    final poultryAnimals = widget.animals.where((animal) =>
    (animal['type'] as String).contains('Layers') ||
        (animal['type'] as String).contains('Chicken')).toList();

    // Calculate today's totals
    final today = DateTime.now().toString().substring(0, 10);
    final todayRecords = _productionRecords.where((record) =>
    (record['date'] as String) == today).toList();

    final totalMilk = todayRecords
        .where((record) => (record['productType'] as String) == 'Milk')
        .fold(0.0, (sum, record) => sum + (record['quantity'] as double));

    final totalEggs = todayRecords
        .where((record) => (record['productType'] as String) == 'Eggs')
        .fold(0, (sum, record) => sum + (record['quantity'] as int));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Production Logging'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: _viewAnalytics,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Today's Summary
            _AnimatedCard(
              index: 0,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Today's Production",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _ProductionSummaryItem(
                          value: '${totalMilk.toStringAsFixed(1)}L',
                          label: 'Milk',
                          color: Colors.blue,
                          theme: theme,
                        ),
                        const SizedBox(width: 12),
                        _ProductionSummaryItem(
                          value: '$totalEggs',
                          label: 'Eggs',
                          color: Colors.orange,
                          theme: theme,
                        ),
                        const SizedBox(width: 12),
                        _ProductionSummaryItem(
                          value: todayRecords.length.toString(),
                          label: 'Records',
                          color: theme.colorScheme.primary,
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Production Log Form
            _AnimatedCard(
              index: 1,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Production',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Animal Selection
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAnimal.isNotEmpty ? _selectedAnimal : null,
                        items: widget.animals.map((animal) {
                          return DropdownMenuItem(
                            value: animal['name'] as String,
                            child: Text(animal['name'] as String),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Animal/Group *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedAnimal = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select an animal';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Product Type
                      DropdownButtonFormField<String>(
                        initialValue: _selectedProductType,
                        items: _productTypes.entries.expand((entry) => entry.value).map((product) {
                          return DropdownMenuItem(
                            value: product,
                            child: Text(product),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Product Type *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedProductType = value!;
                            _selectedUnit = _units[value]?.first ?? 'units';
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Quantity and Unit
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Please enter a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedUnit,
                              items: (_units[_selectedProductType] ?? ['units']).map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnit = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Quality and Date/Time
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _qualityController.text.isNotEmpty
                                  ? _qualityController.text
                                  : 'Good',
                              items: ['Excellent', 'Good', 'Fair', 'Poor'].map((quality) {
                                return DropdownMenuItem(
                                  value: quality,
                                  child: Text(quality),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: 'Quality',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                _qualityController.text = value!;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextButton(
                              onPressed: _selectDateTime,
                              style: TextButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date & Time',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  Text(
                                    '${_formatDate(_selectedDate)} ${_selectedTime.format(context)}',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Any additional observations...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 16),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitProduction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Log Production'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recent Production Records
            _AnimatedCard(
              index: 2,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Recent Records',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _viewAllRecords,
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._productionRecords.take(3).map((record) {
                      return _ProductionRecordRow(
                        record: record,
                        theme: theme,
                        onTap: () => _editRecord(record),
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  void _submitProduction() {
    if (_formKey.currentState!.validate()) {
      final newRecord = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'animalName': _selectedAnimal,
        'productType': _selectedProductType,
        'quantity': double.parse(_quantityController.text),
        'unit': _selectedUnit,
        'quality': _qualityController.text.isNotEmpty ? _qualityController.text : 'Good',
        'date': _formatDate(_selectedDate),
        'time': _selectedTime.format(context),
        'notes': _notesController.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      setState(() {
        _productionRecords.insert(0, newRecord);
      });

      // Reset form
      _quantityController.clear();
      _notesController.clear();
      _qualityController.clear();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Production logged successfully!')),
      );
    }
  }

  void _viewAnalytics() {
    // Navigate to analytics screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening production analytics...')),
    );
  }

  void _viewAllRecords() {
    // Navigate to all records screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Viewing all production records...')),
    );
  }

  void _editRecord(Map<String, dynamic> record) {
    // Edit record functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Production Record'),
        content: const Text('Edit functionality would go here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}

class _ProductionSummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final ThemeData theme;

  const _ProductionSummaryItem({
    required this.value,
    required this.label,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductionRecordRow extends StatelessWidget {
  final Map<String, dynamic> record;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ProductionRecordRow({
    required this.record,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final animalName = record['animalName'] as String;
    final productType = record['productType'] as String;
    final quantity = record['quantity'];
    final unit = record['unit'] as String;
    final quality = record['quality'] as String;
    final date = record['date'] as String;
    final time = record['time'] as String;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getProductColor(productType).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getProductIcon(productType),
            color: _getProductColor(productType),
            size: 20,
          ),
        ),
        title: Text(
          animalName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$quantity $unit • $productType'),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getQualityColor(quality).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    quality,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getQualityColor(quality),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$date $time',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, size: 18),
          onPressed: onTap,
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getProductColor(String productType) {
    switch (productType.toLowerCase()) {
      case 'milk':
      case 'yogurt':
      case 'cheese':
      case 'butter':
        return Colors.blue;
      case 'eggs':
        return Colors.orange;
      case 'meat':
        return Colors.red;
      case 'manure':
        return Colors.brown;
      case 'wool':
        return Colors.grey;
      case 'honey':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  IconData _getProductIcon(String productType) {
    switch (productType.toLowerCase()) {
      case 'milk':
        return Icons.local_drink;
      case 'eggs':
        return Icons.egg;
      case 'meat':
        return Icons.agriculture;
      case 'manure':
        return Icons.eco;
      case 'wool':
        return Icons.brush;
      case 'honey':
        return Icons.emoji_nature;
      default:
        return Icons.inventory;
    }
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
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
            boxShadow: [AppColors.subtleShadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}