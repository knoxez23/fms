import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/animal_entity.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/value_objects/value_objects.dart';

class AddAnimalScreen extends StatefulWidget {
  const AddAnimalScreen({super.key});

  @override
  State<AddAnimalScreen> createState() => _AddAnimalScreenState();
}

class _AddAnimalScreenState extends State<AddAnimalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _purchaseDateController = TextEditingController();
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _shedController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedType = 'Dairy Cow';
  String _selectedStatus = 'Healthy';
  String _selectedGroupType = 'Individual';
  int _quantity = 1;

  final List<String> _animalTypes = [
    'Dairy Cow',
    'Beef Cattle',
    'Layers',
    'Broilers',
    'Goat',
    'Sheep',
    'Pig',
    'Rabbit'
  ];

  final List<String> _statusOptions = [
    'Healthy',
    'Pregnant',
    'Sick',
    'Growing',
    'Laying',
    'In Milk'
  ];

  final List<String> _groupTypes = ['Individual', 'Group'];

  final Map<String, List<String>> _breeds = {
    'Dairy Cow': ['Friesian', 'Jersey', 'Ayrshire', 'Guernsey', 'Local'],
    'Beef Cattle': ['Borana', 'Sahiwal', 'Local'],
    'Layers': ['Kienyeji', 'Kuroiler', 'Rainbow Rooster', 'Local'],
    'Broilers': ['Cobb', 'Ross', 'Local'],
    'Goat': ['Galla', 'Boer', 'Local'],
    'Sheep': ['Dorper', 'Red Maasai', 'Local'],
    'Pig': ['Large White', 'Landrace', 'Local'],
    'Rabbit': ['New Zealand White', 'California', 'Local'],
  };

  final Map<String, List<String>> _sheds = {
    'Dairy Cow': ['Shed A', 'Shed B', 'Shed C', 'Pasture'],
    'Beef Cattle': ['Shed A', 'Shed B', 'Pasture'],
    'Layers': ['Coop 1', 'Coop 2', 'Free Range'],
    'Broilers': ['Broiler House 1', 'Broiler House 2'],
    'Goat': ['Goat Shed A', 'Goat Shed B', 'Pasture'],
    'Sheep': ['Sheep Pen A', 'Sheep Pen B', 'Pasture'],
    'Pig': ['Pig Sty 1', 'Pig Sty 2'],
    'Rabbit': ['Rabbit Hutch 1', 'Rabbit Hutch 2'],
  };

  @override
  void initState() {
    super.initState();
    _quantityController.text = _quantity.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentBreeds = _breeds[_selectedType] ?? ['Local'];
    final currentSheds = _sheds[_selectedType] ?? ['Default'];

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title:
            _selectedGroupType == 'Group' ? 'Add Animal Group' : 'Add Animal',
        variant: AppBarVariant.standard,
        actions: [
          TextButton(
            onPressed: _saveAnimal,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Group Type Selection
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
                      Row(
                        children: _groupTypes.map((type) {
                          final isSelected = type == _selectedGroupType;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedGroupType = type;
                                    if (type == 'Individual') {
                                      _quantity = 1;
                                      _quantityController.text = '1';
                                    }
                                  });
                                },
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? theme.colorScheme.primary
                                            .withValues(alpha: 0.1)
                                        : theme.cardTheme.color,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.dividerColor
                                              .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        type == 'Individual'
                                            ? Icons.pets
                                            : Icons.group,
                                        color: isSelected
                                            ? theme.colorScheme.primary
                                            : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        type,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: isSelected
                                              ? theme.colorScheme.primary
                                              : theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.6),
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Basic Information
              _AnimatedCard(
                index: 1,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedGroupType == 'Individual')
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Animal Name *',
                            hintText: 'e.g., Daisy, Bella, Rocky',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter animal name';
                            }
                            return null;
                          },
                        )
                      else
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Group Name *',
                            hintText: 'e.g., Layer Flock A, Goat Herd B',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter group name';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        items: _animalTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Animal Type *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                            _breedController.text = currentBreeds.first;
                            _shedController.text = currentSheds.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: currentBreeds.first,
                        items: currentBreeds.map((breed) {
                          return DropdownMenuItem(
                            value: breed,
                            child: Text(breed),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Breed *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _breedController.text = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quantity and Housing
              _AnimatedCard(
                index: 2,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity & Housing',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedGroupType == 'Group')
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Number of Animals *',
                            hintText: 'e.g., 20, 50, 100',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            final quantity = int.tryParse(value);
                            if (quantity == null || quantity < 1) {
                              return 'Please enter valid quantity';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _quantity = int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: currentSheds.first,
                        items: currentSheds.map((shed) {
                          return DropdownMenuItem(
                            value: shed,
                            child: Text(shed),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Housing/Location *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _shedController.text = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Purchase Information
              _AnimatedCard(
                index: 3,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Purchase Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _purchaseDateController,
                        decoration: InputDecoration(
                          labelText: 'Purchase/Acquisition Date *',
                          hintText: 'Select date',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDate,
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select purchase date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _purchasePriceController,
                        decoration: InputDecoration(
                          labelText: _selectedGroupType == 'Group'
                              ? 'Total Purchase Price (KSh)'
                              : 'Purchase Price (KSh) *',
                          hintText: _selectedGroupType == 'Group'
                              ? 'e.g., 50000'
                              : 'e.g., 2500',
                          border: const OutlineInputBorder(),
                          prefixText: 'KSh ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter purchase price';
                          }
                          return null;
                        },
                      ),
                      if (_selectedGroupType == 'Group' && _quantity > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Average price per animal: KSh ${(_purchasePriceController.text.isNotEmpty ? (double.tryParse(_purchasePriceController.text) ?? 0) / _quantity : 0).toStringAsFixed(0)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Details & Status
              _AnimatedCard(
                index: 4,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Details & Status',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ageController,
                        decoration: InputDecoration(
                          labelText: _selectedGroupType == 'Group'
                              ? 'Average Age'
                              : 'Age *',
                          hintText: _selectedGroupType == 'Group'
                              ? 'e.g., 6 months'
                              : 'e.g., 2 years, 8 months',
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (_selectedGroupType == 'Individual' &&
                              (value == null || value.isEmpty)) {
                            return 'Please enter age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: _selectedGroupType == 'Group'
                              ? 'Average Weight (kg)'
                              : 'Weight (kg)',
                          hintText: 'e.g., 450',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedStatus,
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Current Status',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Information
              _AnimatedCard(
                index: 5,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes & Instructions',
                          hintText:
                              'Any special care requirements, health history, or additional information...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Summary Card
              _AnimatedCard(
                index: 6,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.summarize,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Purchase Summary',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Type',
                        value: '$_selectedType ($_selectedGroupType)',
                        theme: theme,
                      ),
                      if (_selectedGroupType == 'Group')
                        _SummaryRow(
                          label: 'Quantity',
                          value: _quantity.toString(),
                          theme: theme,
                        ),
                      _SummaryRow(
                        label: 'Breed',
                        value: _breedController.text,
                        theme: theme,
                      ),
                      _SummaryRow(
                        label: 'Housing',
                        value: _shedController.text,
                        theme: theme,
                      ),
                      if (_purchasePriceController.text.isNotEmpty)
                        _SummaryRow(
                          label: _selectedGroupType == 'Group'
                              ? 'Total Cost'
                              : 'Purchase Price',
                          value: 'KSh ${_purchasePriceController.text}',
                          theme: theme,
                          isHighlighted: true,
                        ),
                      if (_selectedGroupType == 'Group' &&
                          _quantity > 1 &&
                          _purchasePriceController.text.isNotEmpty)
                        _SummaryRow(
                          label: 'Price per Animal',
                          value:
                              'KSh ${(double.tryParse(_purchasePriceController.text)! / _quantity).toStringAsFixed(0)}',
                          theme: theme,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _purchaseDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _saveAnimal() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final normalizedType = _normalizeAnimalType(_selectedType);
      final weight = double.tryParse(_weightController.text.trim());
      final ageYears = int.tryParse(_ageController.text.trim());
      final birthDate =
          ageYears == null ? null : DateTime(DateTime.now().year - ageYears);

      final newAnimal = AnimalEntity(
        name: AnimalName(name),
        type: AnimalType(normalizedType),
        breed: _breedController.text.trim().isEmpty
            ? null
            : _breedController.text.trim(),
        birthDate: birthDate,
        weight: weight,
      );

      // Navigate back with result or save to database
      Navigator.pop(context, newAnimal);
    }
  }

  String _normalizeAnimalType(String input) {
    final value = input.toLowerCase();
    if (value.contains('cow') ||
        value.contains('cattle') ||
        value.contains('dairy')) {
      return 'cattle';
    }
    if (value.contains('chicken') ||
        value.contains('poultry') ||
        value.contains('layer')) {
      return 'poultry';
    }
    if (value.contains('goat')) return 'goat';
    if (value.contains('sheep')) return 'sheep';
    if (value.contains('pig') || value.contains('pork')) return 'pig';
    return 'other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _purchaseDateController.dispose();
    _purchasePriceController.dispose();
    _quantityController.dispose();
    _shedController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final bool isHighlighted;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.theme,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
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
