import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/contact_directory_service.dart';
import 'package:pamoja_twalima/features/business/domain/entities/sale_entity.dart';
import 'package:pamoja_twalima/features/business/presentation/contacts/contacts_screen.dart';
import 'package:pamoja_twalima/features/business/domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';

class SaleDraftResult {
  final SaleEntity sale;
  final List<TaskResolutionRule> taskResolutionRules;

  const SaleDraftResult({
    required this.sale,
    this.taskResolutionRules = const [],
  });
}

class AddSaleScreen extends StatefulWidget {
  final String? initialType;
  final String? initialProductName;
  final double? initialQuantity;
  final String? initialUnit;
  final String? initialAnimal;
  final String? initialNotes;
  final String? automationMessage;
  final List<TaskResolutionRule> resolutionRules;

  const AddSaleScreen({
    super.key,
    this.initialType,
    this.initialProductName,
    this.initialQuantity,
    this.initialUnit,
    this.initialAnimal,
    this.initialNotes,
    this.automationMessage,
    this.resolutionRules = const [],
  });

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedType = 'Dairy';
  String _selectedUnit = 'liters';
  String _selectedAnimal = '';
  String _paymentStatus = 'Paid';
  DateTime? _saleDate;

  final List<String> _productTypes = ['Dairy', 'Poultry', 'Livestock', 'Other'];

  final Map<String, List<String>> _products = {
    'Dairy': ['Milk', 'Yogurt', 'Cheese', 'Butter'],
    'Poultry': ['Eggs', 'Chicken Meat', 'Manure'],
    'Livestock': ['Beef Cattle', 'Goat Meat', 'Sheep Meat', 'Pork'],
    'Other': ['Manure', 'Hay', 'Seeds', 'Other Products'],
  };

  final Map<String, List<String>> _units = {
    'Dairy': ['liters', 'kg', 'pieces'],
    'Poultry': ['pieces', 'kg', 'trays'],
    'Livestock': ['animal', 'kg'],
    'Other': ['kg', 'bags', 'liters', 'pieces'],
  };

  final Map<String, List<String>> _animals = {
    'Dairy': ['Daisy', 'Bella', 'All Cows'],
    'Poultry': ['Layer Flock A', 'Layer Flock B', 'Broiler Batch 1'],
    'Livestock': ['Rocky', 'Billy', 'Molly'],
    'Other': ['N/A'],
  };

  final List<String> _paymentOptions = ['Paid', 'Pending', 'Partial'];
  List<String> _customerNames = const [];
  Map<String, String> _customerIdByName = const {};

  @override
  void initState() {
    super.initState();
    _saleDate = DateTime.now();
    _dateController.text = _formatDate(_saleDate!);

    final initialType = widget.initialType;
    if (initialType != null && _productTypes.contains(initialType)) {
      _selectedType = initialType;
    }

    final defaultProduct =
        widget.initialProductName ?? _products[_selectedType]!.first;
    _productController.text = defaultProduct;
    _selectedUnit =
        widget.initialUnit ?? (_units[_selectedType]?.first ?? _selectedUnit);
    _selectedAnimal = widget.initialAnimal ?? _selectedAnimal;
    if (widget.initialQuantity != null) {
      _quantityController.text = widget.initialQuantity!.toStringAsFixed(
        widget.initialQuantity == widget.initialQuantity!.roundToDouble()
            ? 0
            : 1,
      );
    }
    if (widget.initialNotes != null && widget.initialNotes!.trim().isNotEmpty) {
      _notesController.text = widget.initialNotes!.trim();
    }
    _updateTotalAmount();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final rows = await ContactDirectoryService(ApiService())
          .list(ContactType.customer);
      if (!mounted) return;
      setState(() {
        final entries = rows
            .map((e) => (
                  name: (e['name'] ?? '').toString(),
                  id: (e['id'] ?? '').toString(),
                ))
            .where((entry) => entry.name.isNotEmpty && entry.id.isNotEmpty)
            .toList();
        _customerIdByName = {
          for (final entry in entries) entry.name: entry.id,
        };
        _customerNames = _customerIdByName.keys.toList()..sort();
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentProducts = _products[_selectedType] ?? ['Other'];
    final currentUnits = _units[_selectedType] ?? ['units'];
    final currentAnimals = _animals[_selectedType] ?? ['N/A'];

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title: 'Record Sale',
        variant: AppBarVariant.standard,
        actions: [
          TextButton(
            onPressed: _saveSale,
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
                          Icons.auto_awesome_outlined,
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
              // Sale Information
              _AnimatedCard(
                index: 1,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sale Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        items: _productTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Product Type *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          if (value == null) return;
                          // Compute new lists based on the newly selected type
                          final newProducts = _products[value] ?? ['Other'];
                          final newUnits = _units[value] ?? ['units'];
                          final newAnimals = _animals[value] ?? ['N/A'];

                          setState(() {
                            _selectedType = value;
                            // Reset dependent fields to sensible defaults for the new type
                            _productController.text =
                                newProducts.isNotEmpty ? newProducts.first : '';
                            _selectedUnit =
                                newUnits.isNotEmpty ? newUnits.first : '';
                            _selectedAnimal =
                                newAnimals.isNotEmpty ? newAnimals.first : '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        // Prefer explicit selected value from controller if present
                        initialValue: _productController.text.isNotEmpty
                            ? _productController.text
                            : (currentProducts.isNotEmpty
                                ? currentProducts.first
                                : null),
                        items: currentProducts.map((product) {
                          return DropdownMenuItem(
                            value: product,
                            child: Text(product),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Product *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _productController.text = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity *',
                                hintText: 'e.g., 18.5',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter quantity';
                                }
                                return null;
                              },
                              onChanged: (value) => _updateTotalAmount(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
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
                                setState(() {
                                  _selectedUnit = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Pricing Information
              _AnimatedCard(
                index: 2,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pricing',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price per Unit (KSh) *',
                          hintText: 'e.g., 50',
                          border: OutlineInputBorder(),
                          prefixText: 'KSh ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter price';
                          }
                          return null;
                        },
                        onChanged: (value) => _updateTotalAmount(),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalController,
                        decoration: const InputDecoration(
                          labelText: 'Total Amount (KSh)',
                          border: OutlineInputBorder(),
                          prefixText: 'KSh ',
                        ),
                        readOnly: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Customer & Date
              _AnimatedCard(
                index: 3,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer & Date',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Autocomplete<String>(
                        optionsBuilder: (textEditingValue) {
                          final query =
                              textEditingValue.text.trim().toLowerCase();
                          final options = <String>[
                            ..._customerNames,
                            'Walk-in Customer',
                          ];
                          if (query.isEmpty) return options.take(10);
                          return options.where(
                            (item) => item.toLowerCase().contains(query),
                          );
                        },
                        fieldViewBuilder:
                            (context, controller, focusNode, onSubmit) {
                          if (controller.text != _customerController.text) {
                            controller.text = _customerController.text;
                          }
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Customer *',
                              hintText: 'Search existing or type new customer',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter customer';
                              }
                              return null;
                            },
                            onChanged: (value) =>
                                _customerController.text = value,
                            onFieldSubmitted: (_) => onSubmit(),
                          );
                        },
                        onSelected: (selection) {
                          setState(() => _customerController.text = selection);
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() => _customerController.text =
                                  'Walk-in Customer');
                            },
                            icon: const Icon(Icons.storefront_outlined),
                            label: const Text('Walk-in'),
                          ),
                          const SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ContactsScreen(),
                                ),
                              );
                              await _loadCustomers();
                            },
                            icon: const Icon(Icons.person_add_alt_1_outlined),
                            label: const Text('Add Customer'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Sale Date *',
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
                            return 'Please select sale date';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Additional Information
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
                      if (_selectedType != 'Other')
                        DropdownButtonFormField<String>(
                          initialValue: currentAnimals.first,
                          items: currentAnimals.map((animal) {
                            return DropdownMenuItem(
                              value: animal,
                              child: Text(animal),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Source Animal/Group',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedAnimal = value!;
                            });
                          },
                        ),
                      if (_selectedType != 'Other') const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _paymentStatus,
                        items: _paymentOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Payment Status',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _paymentStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText:
                              'Any additional information about this sale...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sale Summary
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
                            Icons.receipt,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Sale Summary',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _SummaryRow(
                        label: 'Product',
                        value: '${_productController.text} ($_selectedType)',
                        theme: theme,
                      ),
                      _SummaryRow(
                        label: 'Quantity',
                        value: '${_quantityController.text} $_selectedUnit',
                        theme: theme,
                      ),
                      _SummaryRow(
                        label: 'Unit Price',
                        value: 'KSh ${_priceController.text}',
                        theme: theme,
                      ),
                      _SummaryRow(
                        label: 'Total Amount',
                        value: 'KSh ${_totalController.text}',
                        theme: theme,
                        isHighlighted: true,
                      ),
                      _SummaryRow(
                        label: 'Customer',
                        value: _customerController.text.isEmpty
                            ? 'Not set'
                            : _customerController.text,
                        theme: theme,
                      ),
                      _SummaryRow(
                        label: 'Payment Status',
                        value: _paymentStatus,
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
                  onPressed: _saveSale,
                  child: const Text('Save Sale'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTotalAmount() {
    final quantity = double.tryParse(_quantityController.text) ?? 0;
    final price = double.tryParse(_priceController.text) ?? 0;
    final total = quantity * price;

    setState(() {
      _totalController.text = total.toStringAsFixed(0);
    });
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
        _saleDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void _saveSale() {
    if (_formKey.currentState!.validate()) {
      final productName = _productController.text.trim();
      if (productName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product name is required')),
        );
        return;
      }

      final qty = double.tryParse(_quantityController.text) ?? 0;
      final unitPrice = double.tryParse(_priceController.text) ?? 0;
      final total = double.tryParse(_totalController.text) ?? (qty * unitPrice);

      final sale = SaleEntity(
        productName: productName,
        type: _selectedType,
        quantity: BusinessQuantity(qty),
        unit: _selectedUnit,
        pricePerUnit: Money(unitPrice),
        totalAmount: Money(total),
        customer: _customerController.text.trim().isEmpty
            ? '-'
            : _customerController.text.trim(),
        customerId: _customerIdByName[_customerController.text.trim()],
        paymentStatus: _paymentStatus,
        animal: _selectedAnimal.isEmpty ? null : _selectedAnimal,
        date: _saleDate ?? DateTime.now(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      // Return to parent screen
      Navigator.pop(
        context,
        SaleDraftResult(
          sale: sale,
          taskResolutionRules: widget.resolutionRules,
        ),
      );
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _totalController.dispose();
    _customerController.dispose();
    _dateController.dispose();
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
