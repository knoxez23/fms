import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/crop_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';

class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _plantedDateController = TextEditingController();
  final TextEditingController _expectedHarvestDateController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedStatus = 'Planted';
  DateTime? _selectedDate = DateTime.now();
  DateTime? _selectedExpectedHarvestDate;

  final List<String> _cropTypes = [
    'Maize',
    'Tomatoes',
    'Beans',
    'Potatoes',
    'Cabbage',
    'Kale',
    'Spinach',
    'Carrots',
    'Onions',
    'Other'
  ];

  final List<String> _statusOptions = [
    'Planted',
    'Germinating',
    'Vegetative',
    'Flowering',
    'Fruiting',
    'Harvesting',
    'Harvested'
  ];

  @override
  void initState() {
    super.initState();
    _typeController.text = _cropTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title: 'Add New Crop',
        variant: AppBarVariant.standard,
        actions: [
          TextButton(
            onPressed: _saveCrop,
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
              _AnimatedCard(
                index: 0,
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
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Crop Name *',
                          hintText: 'e.g., Maize Field A, Tomato Greenhouse',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a crop name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _cropTypes.first,
                        items: _cropTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Crop Type *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _typeController.text = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _varietyController,
                        decoration: const InputDecoration(
                          labelText: 'Variety (Optional)',
                          hintText: 'e.g., H614, Roma VF',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _AnimatedCard(
                index: 1,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Field Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _areaController,
                        decoration: const InputDecoration(
                          labelText: 'Field Area *',
                          hintText: 'e.g., 2, 0.5 (in acres)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter field area';
                          }

                          final parsed = double.tryParse(value);
                          if (parsed == null) {
                            return 'Enter numbers only (e.g. 2 or 0.5)';
                          }

                          if (parsed <= 0) {
                            return 'Area must be greater than zero';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _plantedDateController,
                        decoration: InputDecoration(
                          labelText: 'Planted Date *',
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
                            return 'Please select planted date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _expectedHarvestDateController,
                        decoration: InputDecoration(
                          labelText: 'Expected Harvest Date',
                          hintText: 'Select date (optional)',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.event_available),
                            onPressed: _selectExpectedHarvestDate,
                          ),
                        ),
                        readOnly: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _AnimatedCard(
                index: 2,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status & Notes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          hintText:
                              'Any special instructions or observations...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _AnimatedCard(
                index: 3,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Tips',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Record accurate planting dates for better growth tracking\n'
                        '• Update status regularly to monitor progress\n'
                        '• Add notes for important observations',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
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
        _selectedDate = picked;
        _plantedDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selectExpectedHarvestDate() async {
    final baseDate = _selectedDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpectedHarvestDate ?? baseDate,
      firstDate: baseDate,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _selectedExpectedHarvestDate = picked;
        _expectedHarvestDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _saveCrop() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final cropType = _typeController.text.trim();
    final variety = _varietyController.text.trim().isEmpty
        ? null
        : _varietyController.text.trim();
    final area = double.tryParse(_areaController.text.trim()) ?? 0;

    final crop = CropEntity(
      name: CropName(name),
      variety: variety ?? cropType,
      plantedAt: _selectedDate ?? DateTime.now(),
      expectedHarvest: _selectedExpectedHarvestDate,
      area: area,
      status: _selectedStatus,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crop added successfully')),
    );

    Navigator.pop(context, crop);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _varietyController.dispose();
    _areaController.dispose();
    _plantedDateController.dispose();
    _expectedHarvestDateController.dispose();
    _notesController.dispose();
    super.dispose();
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
