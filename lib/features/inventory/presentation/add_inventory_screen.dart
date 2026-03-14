import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/data/services/contact_directory_service.dart';
import 'package:pamoja_twalima/features/business/presentation/contacts/contacts_screen.dart';

class InventoryDraftResult {
  final Map<String, dynamic> item;
  final List<TaskResolutionRule> taskResolutionRules;

  const InventoryDraftResult({
    required this.item,
    this.taskResolutionRules = const [],
  });
}

class AddInventoryScreen extends StatefulWidget {
  final String? initialName;
  final String? initialCategory;
  final String? initialQuantity;
  final String? initialUnit;
  final String? initialMinStock;
  final String? initialSupplier;
  final String? initialCost;
  final String? initialNotes;
  final String? initialLotCode;
  final String? initialSourceType;
  final String? initialSourceRef;
  final String? initialSourceLabel;
  final String? initialFreshnessHours;
  final String? automationMessage;
  final List<TaskResolutionRule> resolutionRules;

  const AddInventoryScreen({
    super.key,
    this.initialName,
    this.initialCategory,
    this.initialQuantity,
    this.initialUnit,
    this.initialMinStock,
    this.initialSupplier,
    this.initialCost,
    this.initialNotes,
    this.initialLotCode,
    this.initialSourceType,
    this.initialSourceRef,
    this.initialSourceLabel,
    this.initialFreshnessHours,
    this.automationMessage,
    this.resolutionRules = const [],
  });

  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minStockController = TextEditingController();
  final TextEditingController _supplierController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _lotCodeController = TextEditingController();
  final TextEditingController _sourceLabelController = TextEditingController();
  final TextEditingController _freshnessHoursController =
      TextEditingController();

  String _selectedCategory = 'Fertilizers';
  String _selectedUnit = 'kg';
  String _selectedSourceType = 'Manual';
  List<String> _supplierNames = const [];
  Map<String, String> _supplierIdByName = const {};

  final List<String> _categories = [
    'Crops',
    'Vegetables',
    'Fruits',
    'Dairy',
    'Poultry',
    'Livestock',
    'Fertilizers',
    'Seeds',
    'Animal Feed',
    'Chemicals',
    'Animal Health',
    'Equipment',
    'Tools',
    'Other'
  ];

  final Map<String, List<String>> _units = {
    'Crops': ['kg', 'bags', 'crates', 'tons', 'pieces'],
    'Vegetables': ['kg', 'crates', 'pieces'],
    'Fruits': ['kg', 'crates', 'pieces'],
    'Dairy': ['liters', 'kg', 'pieces'],
    'Poultry': ['pieces', 'crates', 'kg'],
    'Livestock': ['pieces', 'kg'],
    'Fertilizers': ['kg', 'bags', 'liters'],
    'Seeds': ['packets', 'kg', 'grams'],
    'Animal Feed': [
      'bags',
      'kg',
      'grams',
      'liters',
      'buckets',
      'sufurias',
      'plates',
      'cups',
      'tins',
      'scoops',
      'bundles',
      'pieces',
    ],
    'Chemicals': ['liters', 'kg', 'packets'],
    'Animal Health': ['doses', 'bottles', 'packets'],
    'Equipment': ['pieces', 'meters', 'sets'],
    'Tools': ['pieces', 'sets'],
    'Other': [
      'units',
      'kg',
      'liters',
      'pieces',
      'buckets',
      'sufurias',
      'plates',
      'cups',
      'tins',
      'scoops',
    ],
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? _selectedCategory;
    final availableUnits = _units[_selectedCategory] ?? const ['units'];
    _selectedUnit = availableUnits.contains(widget.initialUnit)
        ? widget.initialUnit!
        : availableUnits.first;
    _nameController.text = widget.initialName ?? '';
    _quantityController.text = widget.initialQuantity ?? '';
    _minStockController.text = widget.initialMinStock ?? '';
    _supplierController.text = widget.initialSupplier ?? '';
    _costController.text = widget.initialCost ?? '';
    _notesController.text = widget.initialNotes ?? '';
    _lotCodeController.text = widget.initialLotCode ?? _buildSuggestedLotCode();
    _selectedSourceType = widget.initialSourceType ?? _selectedSourceType;
    _sourceLabelController.text = widget.initialSourceLabel ?? '';
    _freshnessHoursController.text = widget.initialFreshnessHours ?? '';
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final rows = await ContactDirectoryService(ApiService())
          .list(ContactType.supplier);
      if (!mounted) return;
      setState(() {
        final entries = rows
            .map((e) => (
                  name: (e['name'] ?? '').toString(),
                  id: (e['id'] ?? '').toString(),
                ))
            .where((entry) => entry.name.isNotEmpty && entry.id.isNotEmpty)
            .toList();
        _supplierIdByName = {
          for (final entry in entries) entry.name: entry.id,
        };
        _supplierNames = _supplierIdByName.keys.toList()..sort();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUnits = _units[_selectedCategory] ?? ['units'];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Add Inventory Item',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveItem,
            child: Text(
              'Save',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.automationMessage != null &&
                  widget.automationMessage!.trim().isNotEmpty) ...[
                _AnimatedCard(
                  index: 0,
                  theme: theme,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.automationMessage!.trim(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _AnimatedCard(
                index: 1,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Item Name *',
                          hintText: 'e.g., NPK Fertilizer, Maize Seeds',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter item name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: ValueKey(_selectedCategory),
                        initialValue: _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value != null) {
                            final newUnits = _units[value] ?? ['units'];
                            setState(() {
                              _selectedCategory = value;
                              _selectedUnit = newUnits.first;
                            });
                          }
                        },
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
                        'Stock Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_selectedCategory == 'Animal Feed') ...[
                        const SizedBox(height: 8),
                        Text(
                          'Use whatever unit the farmer actually measures with, including buckets, sufurias, cups, or plates. Keeping the same unit across stock and feeding logs preserves automation.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.68),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity *',
                                hintText: 'e.g., 25',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(_selectedUnit),
                              initialValue: _selectedUnit,
                              items: currentUnits.map((unit) {
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
                                if (value != null) {
                                  setState(() {
                                    _selectedUnit = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _minStockController,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Stock Level *',
                          hintText: 'e.g., 10',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter minimum stock level';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _lotCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Lot / Batch Code',
                          hintText: 'e.g., MILK-14MAR-AM',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSourceType,
                        items: const [
                          DropdownMenuItem(
                            value: 'Manual',
                            child: Text('Manual entry'),
                          ),
                          DropdownMenuItem(
                            value: 'Production',
                            child: Text('Animal production'),
                          ),
                          DropdownMenuItem(
                            value: 'Harvest',
                            child: Text('Crop harvest'),
                          ),
                          DropdownMenuItem(
                            value: 'Purchase',
                            child: Text('Supplier purchase'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Stock Source',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedSourceType = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _sourceLabelController,
                        decoration: const InputDecoration(
                          labelText: 'Source Label',
                          hintText: 'e.g., Morning milking, Plot B harvest',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _freshnessHoursController,
                        decoration: const InputDecoration(
                          labelText: 'Freshness Window (hours)',
                          hintText: 'e.g., 8 for milk, 72 for eggs',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _AnimatedCard(
                index: 3,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier & Cost',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _supplierController,
                        decoration: InputDecoration(
                          labelText: 'Supplier *',
                          hintText: 'e.g., AgroSupplies Ltd',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: 'Manage suppliers',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ContactsScreen(),
                                ),
                              );
                              await _loadSuppliers();
                            },
                            icon: const Icon(Icons.contacts_outlined),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter supplier name';
                          }
                          return null;
                        },
                      ),
                      if (_supplierNames.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue:
                              _supplierNames.contains(_supplierController.text)
                                  ? _supplierController.text
                                  : null,
                          decoration: const InputDecoration(
                            labelText: 'Pick Existing Supplier',
                            border: OutlineInputBorder(),
                          ),
                          items: _supplierNames
                              .map(
                                (name) => DropdownMenuItem<String>(
                                  value: name,
                                  child: Text(name),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _supplierController.text = value;
                            });
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _costController,
                        decoration: const InputDecoration(
                          labelText: 'Unit Cost (KSh)',
                          hintText: 'e.g., 1500',
                          border: OutlineInputBorder(),
                          prefixText: 'KSh ',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _AnimatedCard(
                index: 4,
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
                          labelText: 'Notes',
                          hintText:
                              'Any special storage instructions, usage notes...',
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
                index: 5,
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
                            'Inventory Management Tips',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Set realistic minimum stock levels to avoid shortages\n'
                        '• Record supplier information for easy reordering\n'
                        '• Track costs for better budget management\n'
                        '• Note any special storage requirements',
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveItem,
                  child: const Text('Save Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      final quantity = int.parse(_quantityController.text);
      final minStock = int.parse(_minStockController.text);
      final unitPrice = _costController.text.isNotEmpty
          ? double.parse(_costController.text)
          : null;
      final freshnessHours = _freshnessHoursController.text.trim().isNotEmpty
          ? int.tryParse(_freshnessHoursController.text.trim())
          : null;
      final totalValue = (unitPrice != null) ? (unitPrice * quantity) : null;
      final lastRestock = DateTime.now();
      final expiryDate = freshnessHours == null
          ? null
          : lastRestock.add(Duration(hours: freshnessHours));

      final newItem = {
        'itemName': _nameController.text,
        'category': _selectedCategory,
        'lotCode': _lotCodeController.text.trim(),
        'sourceType': _selectedSourceType,
        'sourceRef': widget.initialSourceRef,
        'sourceLabel': _sourceLabelController.text.trim(),
        'quantity': quantity,
        'reservedQuantity': 0.0,
        'unit': _selectedUnit,
        'minStock': minStock,
        'supplier': _supplierController.text,
        'supplierId': _supplierIdByName[_supplierController.text.trim()],
        'unitPrice': unitPrice,
        'totalValue': totalValue,
        'notes': _notesController.text,
        'freshnessHours': freshnessHours,
        'expiryDate': expiryDate,
        'lastRestock': lastRestock,

        // Also include API-compatible field names for when this gets sent to the backend
        // 'item_name': _nameController.text,
        // 'min_stock': minStock,
        // 'unit_price': unitPrice,
        // 'total_value': totalValue,
      };

      // Return to parent screen
      Navigator.pop(
        context,
        InventoryDraftResult(
          item: newItem,
          taskResolutionRules: widget.resolutionRules,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _minStockController.dispose();
    _supplierController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _lotCodeController.dispose();
    _sourceLabelController.dispose();
    _freshnessHoursController.dispose();
    super.dispose();
  }

  String _buildSuggestedLotCode() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return 'LOT-$day${months[now.month - 1]}';
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
