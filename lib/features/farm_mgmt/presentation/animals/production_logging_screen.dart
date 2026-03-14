import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/models/task.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/features/business/application/sales_usecases.dart';
import 'package:pamoja_twalima/features/business/domain/entities/sale_entity.dart';
import 'package:pamoja_twalima/features/business/domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/features/business/presentation/sales/add_sale_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/animal_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/production_log_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/features/farm_mgmt/infrastructure/production_log_repository_impl.dart';
import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';
import 'package:pamoja_twalima/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pamoja_twalima/features/inventory/presentation/add_inventory_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/animals/animals_bloc.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/production/production_log_cubit.dart';

class ProductionLoggingScreen extends StatefulWidget {
  const ProductionLoggingScreen({super.key});

  @override
  State<ProductionLoggingScreen> createState() =>
      _ProductionLoggingScreenState();
}

class _ProductionLoggingScreenState extends State<ProductionLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  final SyncData _syncData = SyncData();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AnimalsBloc>()..add(const AnimalsEvent.load()),
        ),
        BlocProvider(
          create: (_) => getIt<ProductionLogCubit>()..load(),
        ),
      ],
      child: BlocBuilder<AnimalsBloc, AnimalsState>(
        builder: (context, animalsState) {
          return BlocConsumer<ProductionLogCubit, ProductionLogState>(
            listener: (context, logsState) {
              final message = logsState.error;
              if (message == null || message.isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            builder: (context, logsState) {
              final animals = animalsState.maybeWhen(
                loaded: (items) => items,
                orElse: () => <AnimalEntity>[],
              );
              final productionRecords = _mapLogsToView(logsState.logs, animals);

              if (_selectedAnimal.isEmpty && animals.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  setState(() {
                    _selectedAnimal = animals.first.name.value;
                  });
                });
              }

              // Calculate today's totals
              final today = DateTime.now().toString().substring(0, 10);
              final todayRecords = productionRecords
                  .where((record) => record.date == today)
                  .toList();

              final totalMilk = todayRecords
                  .where((record) => record.productType == 'Milk')
                  .fold(0.0, (sum, record) => sum + record.quantity);

              final totalEggs = todayRecords
                  .where((record) => record.productType == 'Eggs')
                  .fold(0, (sum, record) => sum + record.quantity.toInt());

              return AppScaffold(
                backgroundColor: theme.colorScheme.surface,
                includeDrawer: false,
                appBar: ModernAppBar(
                  title: 'Production Logging',
                  variant: AppBarVariant.standard,
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
                                  initialValue: _selectedAnimal.isNotEmpty
                                      ? _selectedAnimal
                                      : null,
                                  items: animals.map((animal) {
                                    return DropdownMenuItem(
                                      value: animal.name.value,
                                      child: Text(animal.name.value),
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
                                  items: _productTypes.entries
                                      .expand((entry) => entry.value)
                                      .map((product) {
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
                                      _selectedUnit =
                                          _units[value]?.first ?? 'units';
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
                                        items: (_units[_selectedProductType] ??
                                                ['units'])
                                            .map((unit) {
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
                                        initialValue:
                                            _qualityController.text.isNotEmpty
                                                ? _qualityController.text
                                                : 'Good',
                                        items: [
                                          'Excellent',
                                          'Good',
                                          'Fair',
                                          'Poor'
                                        ].map((quality) {
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
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Date & Time',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                color: theme
                                                    .colorScheme.onSurface
                                                    .withValues(alpha: 0.6),
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
                                    onPressed: () => _submitProduction(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
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
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
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
                              ...productionRecords.take(3).map((record) {
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
            },
          );
        },
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
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime,
      );

      if (pickedTime != null) {
        if (!mounted) return;
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
      }
    }
  }

  Future<void> _submitProduction(BuildContext blocContext) async {
    if (_formKey.currentState!.validate()) {
      final animalsState = blocContext.read<AnimalsBloc>().state;
      final animals = animalsState.maybeWhen(
        loaded: (items) => items,
        orElse: () => <AnimalEntity>[],
      );
      final selected = animals.cast<AnimalEntity?>().firstWhere(
            (a) => a?.name.value == _selectedAnimal,
            orElse: () => null,
          );
      if (selected?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected animal not found')),
        );
        return;
      }

      final combinedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final entity = ProductionLogEntity(
        animalId: selected!.id!,
        productType: _selectedProductType,
        quantity: Quantity(double.parse(_quantityController.text)),
        unit: MeasurementUnit(_selectedUnit),
        recordedAt: combinedDateTime,
        quality: _qualityController.text.isNotEmpty
            ? _qualityController.text
            : 'Good',
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await blocContext.read<ProductionLogCubit>().add(entity);
      await _createProductionFollowUpIfNeeded(entity, selected.name.value);

      // Reset form
      _quantityController.clear();
      _notesController.clear();
      _qualityController.clear();
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Production logged successfully!')),
      );

      await _suggestSaleDraft(entity, selected.name.value);
      final sourceId = selected.id;
      if (sourceId != null && sourceId.isNotEmpty) {
        await _syncData.completeTaskRules([
          TaskResolutionRule(
            sourceEventType: 'setup',
            sourceEventId: sourceId,
            titleContains: const [
              'production review',
              'feed efficiency',
              'sales readiness',
              'growth review',
              'market timing',
            ],
          ),
        ]);
      }
    }
  }

  Future<void> _createProductionFollowUpIfNeeded(
    ProductionLogEntity entity,
    String animalName,
  ) async {
    final quality = (entity.quality ?? '').toLowerCase();
    if (quality != 'poor' && quality != 'fair') return;
    await _syncData.insertTask(
      Task(
        title: 'Follow-up: production quality for $animalName',
        description:
            'Review ${entity.productType} production quality (${entity.quality}) and inspect animal health/feed.',
        dueDate: DateTime.now().add(const Duration(days: 1)).toIso8601String(),
        status: 'pending',
        sourceEventType: 'production',
        sourceEventId: entity.animalId,
      ),
    );
  }

  Future<void> _suggestSaleDraft(
    ProductionLogEntity entity,
    String animalName,
  ) async {
    final normalizedType = entity.productType.toLowerCase();
    if (normalizedType != 'milk' && normalizedType != 'eggs') return;
    if (!mounted) return;

    final draftAction = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final estimatedPrice = _suggestedUnitPrice(entity.productType);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What next for this output?',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${entity.quantity.value.toStringAsFixed(entity.quantity.value == entity.quantity.value.roundToDouble() ? 0 : 1)} '
                  '${entity.unit.value} of ${entity.productType.toLowerCase()} was just logged for $animalName.',
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a sale draft, move it into stock, or open a prefilled sale form. Suggested unit price: KSh ${estimatedPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop('quick'),
                        child: const Text('Quick Draft'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop('stock'),
                        child: const Text('Create Stock Draft'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop('review'),
                        child: const Text('Review First'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(sheetContext).pop('later'),
                        child: const Text('Later'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || draftAction == 'later' || draftAction == null) return;

    if (draftAction == 'quick') {
      final sale = _buildQuickSaleDraft(entity, animalName);
      try {
        await getIt<AddSale>().execute(sale);
        await _syncData.completeTaskRules([
          TaskResolutionRule(
            sourceEventType: 'production',
            sourceEventId: entity.animalId,
          ),
          TaskResolutionRule(
            sourceEventType: 'setup',
            sourceEventId: entity.animalId,
            titleContains: const ['sales readiness', 'market timing'],
          ),
        ]);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quick sale draft saved successfully.')),
        );
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save quick sale draft.')),
        );
      }
      return;
    }

    if (draftAction == 'stock') {
      await _openProductionStockDraft(entity, animalName);
      return;
    }

    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => AddSaleScreen(
          initialType: _saleTypeForProduct(entity.productType),
          initialProductName: entity.productType,
          initialQuantity: entity.quantity.value,
          initialUnit: entity.unit.value,
          initialAnimal: animalName,
          initialNotes:
              'Draft created from production log on ${_formatDate(entity.recordedAt)}.',
          automationMessage:
              'Prefilled from a ${entity.productType.toLowerCase()} production log for $animalName. Confirm pricing and customer details only if you need changes.',
          resolutionRules: [
            TaskResolutionRule(
              sourceEventType: 'production',
              sourceEventId: entity.animalId,
            ),
            TaskResolutionRule(
              sourceEventType: 'setup',
              sourceEventId: entity.animalId,
              titleContains: const ['sales readiness', 'market timing'],
            ),
          ],
        ),
      ),
    );

    final saleDraft = switch (result) {
      SaleDraftResult draft => draft,
      SaleEntity sale => SaleDraftResult(sale: sale),
      _ => null,
    };
    if (saleDraft == null) return;

    try {
      await getIt<AddSale>().execute(saleDraft.sale);
      await _syncData.completeTaskRules(saleDraft.taskResolutionRules);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale draft saved successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save sale draft.')),
      );
    }
  }

  SaleEntity _buildQuickSaleDraft(
    ProductionLogEntity entity,
    String animalName,
  ) {
    final price = _suggestedUnitPrice(entity.productType);
    final quantity = entity.quantity.value;
    return SaleEntity(
      productName: entity.productType,
      quantity: BusinessQuantity(quantity),
      unit: entity.unit.value,
      pricePerUnit: Money(price),
      totalAmount: Money(price * quantity),
      customer: 'Walk-in Customer',
      paymentStatus: 'Pending',
      type: _saleTypeForProduct(entity.productType),
      date: entity.recordedAt,
      animal: animalName,
      notes:
          'Quick draft created from production log on ${_formatDate(entity.recordedAt)}.',
    );
  }

  String _saleTypeForProduct(String productType) {
    switch (productType.toLowerCase()) {
      case 'milk':
        return 'Dairy';
      case 'eggs':
        return 'Poultry';
      default:
        return 'Other';
    }
  }

  double _suggestedUnitPrice(String productType) {
    switch (productType.toLowerCase()) {
      case 'milk':
        return 55;
      case 'eggs':
        return 15;
      default:
        return 0;
    }
  }

  Future<void> _openProductionStockDraft(
    ProductionLogEntity entity,
    String animalName,
  ) async {
    final result = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(
        builder: (_) => AddInventoryScreen(
          initialName: entity.productType,
          initialCategory: _inventoryCategoryForProduct(entity.productType),
          initialQuantity: entity.quantity.value.toStringAsFixed(
            entity.quantity.value == entity.quantity.value.roundToDouble()
                ? 0
                : 1,
          ),
          initialUnit: entity.unit.value,
          initialMinStock: '0',
          initialCost: _suggestedUnitPrice(entity.productType) > 0
              ? _suggestedUnitPrice(entity.productType).toStringAsFixed(0)
              : null,
          initialNotes:
              'Stock draft created from ${entity.productType.toLowerCase()} production log for $animalName on ${_formatDate(entity.recordedAt)}.',
          automationMessage:
              'Prefilled from a ${entity.productType.toLowerCase()} production log for $animalName. Confirm final stock quantity and value before saving.',
          resolutionRules: [
            TaskResolutionRule(
              sourceEventType: 'production',
              sourceEventId: entity.animalId,
            ),
            TaskResolutionRule(
              sourceEventType: 'setup',
              sourceEventId: entity.animalId,
              titleContains: const ['production review', 'feed efficiency'],
            ),
          ],
        ),
      ),
    );

    final draft = switch (result) {
      InventoryDraftResult inventoryDraft => inventoryDraft,
      Map<String, dynamic> item => InventoryDraftResult(item: item),
      _ => null,
    };
    if (draft == null) return;

    final item = InventoryItem(
      itemName: (draft.item['itemName'] ?? entity.productType).toString(),
      category: (draft.item['category'] ??
              _inventoryCategoryForProduct(entity.productType))
          .toString(),
      quantity: ((draft.item['quantity'] as num?) ?? entity.quantity.value)
          .toDouble(),
      unit: (draft.item['unit'] ?? entity.unit.value).toString(),
      minStock: (draft.item['minStock'] as int?) ?? 0,
      supplier: draft.item['supplier']?.toString(),
      supplierId: draft.item['supplierId']?.toString(),
      unitPrice: (draft.item['unitPrice'] as num?)?.toDouble(),
      totalValue: (draft.item['totalValue'] as num?)?.toDouble(),
      lastRestock: draft.item['lastRestock'] as DateTime? ?? entity.recordedAt,
      isSynced: false,
    );

    try {
      await getIt<InventoryRepository>().addItem(item);
      await _syncData.completeTaskRules(draft.taskResolutionRules);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Production stock draft saved successfully.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save production stock draft.')),
      );
    }
  }

  String _inventoryCategoryForProduct(String productType) {
    switch (productType.toLowerCase()) {
      case 'milk':
      case 'yogurt':
      case 'cheese':
      case 'butter':
        return 'Dairy';
      case 'eggs':
        return 'Poultry';
      default:
        return 'Other';
    }
  }

  void _viewAnalytics() {
    final logs = context.read<ProductionLogCubit>().state.logs;
    final byType = <String, double>{};
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    var recordsLast7Days = 0;

    for (final log in logs) {
      byType.update(log.productType, (v) => v + log.quantity.value,
          ifAbsent: () => log.quantity.value);
      if (log.recordedAt.isAfter(cutoff)) {
        recordsLast7Days++;
      }
    }

    final sorted = byType.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Production Analytics'),
        content: SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Records: ${logs.length}'),
              Text('Last 7 Days: $recordsLast7Days'),
              const SizedBox(height: 12),
              const Text(
                'Totals by Product',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (sorted.isEmpty) const Text('No production logs yet'),
              ...sorted.take(8).map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '${entry.key}: ${entry.value.toStringAsFixed(1)}',
                      ),
                    ),
                  ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _viewAllRecords() {
    final animalsState = context.read<AnimalsBloc>().state;
    final animals = animalsState.maybeWhen(
      loaded: (items) => items,
      orElse: () => <AnimalEntity>[],
    );
    final rows = _mapLogsToView(
        context.read<ProductionLogCubit>().state.logs, animals)
      ..sort((a, b) {
        final ad = DateTime.tryParse('${a.date} ${a.time}') ?? DateTime(1970);
        final bd = DateTime.tryParse('${b.date} ${b.time}') ?? DateTime(1970);
        return bd.compareTo(ad);
      });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'All Production Records',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            Expanded(
              child: rows.isEmpty
                  ? const Center(child: Text('No records found'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final record = rows[index];
                        return ListTile(
                          title: Text(
                            '${record.productType} • ${record.quantity.toStringAsFixed(1)} ${record.unit}',
                          ),
                          subtitle: Text(
                            '${record.animalName} • ${record.date} ${record.time}',
                          ),
                          trailing: Text(record.quality),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _editRecord(record);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editRecord(_ProductionRecordView record) async {
    final quantityController =
        TextEditingController(text: record.quantity.toStringAsFixed(1));
    final qualityController = TextEditingController(text: record.quality);
    final notesController = TextEditingController(text: record.notes);
    final formKey = GlobalKey<FormState>();
    var selectedUnit = record.unit;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Production Record'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity *'),
                  validator: (value) {
                    final parsed = double.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedUnit,
                  decoration: const InputDecoration(labelText: 'Unit'),
                  items: (_units[record.productType] ?? [record.unit])
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) selectedUnit = value;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: qualityController,
                  decoration: const InputDecoration(
                    labelText: 'Quality',
                    hintText: 'Excellent, Good, Fair, Poor',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.pop(dialogContext, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    if (!mounted) return;
    final id = int.tryParse(record.id);
    if (id == null) return;

    final updated = ProductionLogEntity(
      id: record.id,
      animalId: _resolveAnimalId(record.animalName),
      productType: record.productType,
      quantity: Quantity(double.parse(quantityController.text.trim())),
      unit: MeasurementUnit(selectedUnit),
      recordedAt: _parseDateTime(record.date, record.time),
      quality: qualityController.text.trim(),
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
    );
    await ProductionLogRepositoryImpl().updateLog(updated);
    if (!mounted) return;
    await context.read<ProductionLogCubit>().load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Production record updated')),
    );
  }

  String _resolveAnimalId(String animalName) {
    final animalsState = context.read<AnimalsBloc>().state;
    final animals = animalsState.maybeWhen(
      loaded: (items) => items,
      orElse: () => <AnimalEntity>[],
    );
    for (final animal in animals) {
      if (animal.name.value == animalName && animal.id != null) {
        return animal.id!;
      }
    }
    return '';
  }

  DateTime _parseDateTime(String date, String time) {
    final datePart = DateTime.tryParse(date) ?? DateTime.now();
    final pieces = time.split(':');
    final hour = pieces.isNotEmpty ? int.tryParse(pieces[0]) ?? 0 : 0;
    final minute = pieces.length > 1 ? int.tryParse(pieces[1]) ?? 0 : 0;
    return DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      hour,
      minute,
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  List<_ProductionRecordView> _mapLogsToView(
    List<ProductionLogEntity> logs,
    List<AnimalEntity> animals,
  ) {
    final nameById = <String, String>{
      for (final animal in animals)
        if (animal.id != null) animal.id!: animal.name.value,
    };

    return logs.map((log) {
      final localTime = log.recordedAt.toLocal();
      return _ProductionRecordView(
        id: log.id ?? '',
        animalName: nameById[log.animalId] ?? 'Unknown',
        productType: log.productType,
        quantity: log.quantity.value,
        unit: log.unit.value,
        quality: log.quality ?? 'Good',
        date: _formatDate(localTime),
        time:
            '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}',
        notes: log.notes ?? '',
      );
    }).toList();
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
  final _ProductionRecordView record;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ProductionRecordRow({
    required this.record,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getProductColor(record.productType).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getProductIcon(record.productType),
            color: _getProductColor(record.productType),
            size: 20,
          ),
        ),
        title: Text(
          record.animalName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${record.quantity} ${record.unit} • ${record.productType}'),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color:
                        _getQualityColor(record.quality).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    record.quality,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getQualityColor(record.quality),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${record.date} ${record.time}',
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

class _ProductionRecordView {
  final String id;
  final String animalName;
  final String productType;
  final double quantity;
  final String unit;
  final String quality;
  final String date;
  final String time;
  final String notes;

  const _ProductionRecordView({
    required this.id,
    required this.animalName,
    required this.productType,
    required this.quantity,
    required this.unit,
    required this.quality,
    required this.date,
    required this.time,
    required this.notes,
  });
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
