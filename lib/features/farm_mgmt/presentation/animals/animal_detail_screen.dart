import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/models/animal.dart';
import 'package:pamoja_twalima/data/models/task.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/animal_health_record_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/production_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/animal_health_record_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/animal_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/features/farm_mgmt/infrastructure/animal_health_record_repository_impl.dart';
import 'package:pamoja_twalima/features/farm_mgmt/infrastructure/production_log_repository_impl.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/animal_health/animal_health_records_cubit.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/animals/animals_bloc.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/production/production_log_cubit.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/tasks/add_task_screen.dart';

class AnimalDetailScreen extends StatefulWidget {
  final AnimalEntity entity;
  final Future<int> Function(Animal animal) updateAnimal;

  const AnimalDetailScreen.fromEntity({
    Key? key,
    required AnimalEntity entity,
    Future<int> Function(Animal animal)? updateAnimal,
  }) : this(
          key: key,
          entity: entity,
          updateAnimal: updateAnimal,
        );

  const AnimalDetailScreen({
    super.key,
    required this.entity,
    Future<int> Function(Animal animal)? updateAnimal,
  }) : updateAnimal = updateAnimal ?? _defaultUpdateAnimal;

  static Future<int> _defaultUpdateAnimal(Animal animal) {
    return SyncData().updateAnimal(animal);
  }

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  int _selectedTab = 0;
  late AnimalEntity _currentAnimal;

  @override
  void initState() {
    super.initState();
    _currentAnimal = widget.entity;
  }

  @override
  Widget build(BuildContext context) {
    final animal = _AnimalDetailView.fromEntity(_currentAnimal);
    final theme = Theme.of(context);
    final isGroup = animal.groupType == 'Group';
    final quantity = animal.quantity;
    final purchasePrice = animal.purchasePrice;

    final healthRepository = AnimalHealthRecordRepositoryImpl(SyncData());

    final productionRepository = ProductionLogRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AnimalHealthRecordsCubit(
            GetAnimalHealthRecords(healthRepository),
            AddAnimalHealthRecord(healthRepository),
            UpdateAnimalHealthRecord(healthRepository),
            DeleteAnimalHealthRecord(healthRepository),
          )..load(),
        ),
        BlocProvider(
          create: (_) => ProductionLogCubit(
            GetProductionLogs(productionRepository),
            AddProductionLog(productionRepository),
            DeleteProductionLog(productionRepository),
          )..load(),
        ),
      ],
      child: AppScaffold(
        backgroundColor: theme.colorScheme.surface,
        includeDrawer: false,
        appBar: ModernAppBar(
          title: animal.name,
          variant: AppBarVariant.standard,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showEditAnimalDialog(),
            ),
          ],
        ),
        body: Column(
          children: [
            // Animal Overview Card
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
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: _getAnimalColor(animal.type)
                                  .withValues(alpha: 0.1),
                              child: Icon(
                                _getAnimalIcon(animal.type),
                                color: _getAnimalColor(animal.type),
                                size: 30,
                              ),
                            ),
                            if (isGroup && quantity > 1)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    quantity.toString(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                animal.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${animal.type} • ${animal.breed}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(animal.status)
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      animal.status,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: _getStatusColor(animal.status),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (isGroup)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Group',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 12),
                    // Enhanced detail items with purchase info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _DetailItem(
                          icon: Icons.cake,
                          label: isGroup ? 'Avg Age' : 'Age',
                          value: animal.age,
                          theme: theme,
                        ),
                        _DetailItem(
                          icon: Icons.monitor_heart,
                          label: 'Health',
                          value: '${animal.healthScore}%',
                          theme: theme,
                        ),
                        if (purchasePrice > 0)
                          _DetailItem(
                            icon: Icons.attach_money,
                            label: isGroup ? 'Total Cost' : 'Price',
                            value: 'KSh ${purchasePrice.toStringAsFixed(0)}',
                            theme: theme,
                          ),
                        if (isGroup && quantity > 1)
                          _DetailItem(
                            icon: Icons.group,
                            label: 'Quantity',
                            value: quantity.toString(),
                            theme: theme,
                          ),
                      ],
                    ),
                    if (animal.shed != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Location: ${animal.shed}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tab Bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [AppColors.subtleShadow],
              ),
              child: Row(
                children: [
                  _DetailTab(
                    label: 'Health',
                    isSelected: _selectedTab == 0,
                    onTap: () => setState(() => _selectedTab = 0),
                    theme: theme,
                  ),
                  _DetailTab(
                    label: 'Production',
                    isSelected: _selectedTab == 1,
                    onTap: () => setState(() => _selectedTab = 1),
                    theme: theme,
                  ),
                  _DetailTab(
                    label: 'Tasks',
                    isSelected: _selectedTab == 2,
                    onTap: () => setState(() => _selectedTab = 2),
                    theme: theme,
                  ),
                  _DetailTab(
                    label: 'History',
                    isSelected: _selectedTab == 3,
                    onTap: () => setState(() => _selectedTab = 3),
                    theme: theme,
                  ),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _HealthTab(animal: animal, theme: theme),
                  _ProductionTab(animal: animal, theme: theme),
                  _AnimalTasksTab(animal: animal, theme: theme),
                  _HistoryTab(animal: animal, theme: theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAnimalColor(String type) {
    final theme = Theme.of(context);
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

  Future<void> _showEditAnimalDialog() async {
    final nameController = TextEditingController(text: _currentAnimal.name.value);
    final typeController = TextEditingController(text: _currentAnimal.type.value);
    final breedController = TextEditingController(text: _currentAnimal.breed ?? '');
    final weightController = TextEditingController(
      text: _currentAnimal.weight?.toStringAsFixed(1) ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Animal'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name *'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: typeController,
                    decoration: const InputDecoration(labelText: 'Type *'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Type is required';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: breedController,
                    decoration: const InputDecoration(labelText: 'Breed'),
                  ),
                  TextFormField(
                    controller: weightController,
                    decoration: const InputDecoration(labelText: 'Weight (kg)'),
                    keyboardType: TextInputType.number,
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
        );
      },
    );

    if (saved != true) return;
    if (!mounted) return;
    final id = int.tryParse(_currentAnimal.id ?? '');
    if (id == null) return;

    final weight = weightController.text.trim().isEmpty
        ? null
        : double.tryParse(weightController.text.trim());

    final updatedModel = Animal(
      id: id,
      name: nameController.text.trim(),
      type: typeController.text.trim(),
      breed:
          breedController.text.trim().isEmpty ? null : breedController.text.trim(),
      weight: weight,
      age: null,
      healthStatus: null,
      dateAcquired: null,
      notes: null,
      userId: null,
    );

    await widget.updateAnimal(updatedModel);
    if (!mounted) return;

    AnimalsBloc? parentAnimalsBloc;
    try {
      parentAnimalsBloc = BlocProvider.of<AnimalsBloc>(context);
    } catch (_) {
      parentAnimalsBloc = null;
    }
    parentAnimalsBloc?.add(const AnimalsEvent.load());

    setState(() {
      _currentAnimal = AnimalEntity(
        id: _currentAnimal.id,
        name: AnimalName(nameController.text.trim()),
        type: AnimalType(typeController.text.trim()),
        breed:
            breedController.text.trim().isEmpty ? null : breedController.text.trim(),
        birthDate: _currentAnimal.birthDate,
        weight: weight,
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Animal updated')),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _DetailTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _DetailTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimalDetailView {
  final String id;
  final String name;
  final String type;
  final String breed;
  final String status;
  final int healthScore;
  final String age;
  final String groupType;
  final int quantity;
  final double purchasePrice;
  final String? shed;
  final String? production;
  final String? weight;

  const _AnimalDetailView({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.status,
    required this.healthScore,
    required this.age,
    required this.groupType,
    required this.quantity,
    required this.purchasePrice,
    required this.shed,
    required this.production,
    required this.weight,
  });

  factory _AnimalDetailView.fromEntity(AnimalEntity entity) {
    final rawType = entity.type.value.trim();
    final type = rawType.isEmpty
        ? 'Other'
        : rawType[0].toUpperCase() + rawType.substring(1);
    final age = entity.birthDate == null
        ? 'Not set'
        : '${DateTime.now().difference(entity.birthDate!).inDays ~/ 365}y';

    return _AnimalDetailView(
      id: entity.id ?? '',
      name: entity.name.value,
      type: type,
      breed: entity.breed ?? 'Unknown',
      status: 'Healthy',
      healthScore: 90,
      age: age,
      groupType: 'Single',
      quantity: 1,
      purchasePrice: 0,
      shed: null,
      production: null,
      weight: entity.weight == null
          ? null
          : '${entity.weight!.toStringAsFixed(1)} kg',
    );
  }
}

class _HealthTab extends StatelessWidget {
  final _AnimalDetailView animal;
  final ThemeData theme;

  const _HealthTab({required this.animal, required this.theme});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimalHealthRecordsCubit, AnimalHealthRecordsState>(
      builder: (context, state) {
        final records = state.records
            .where((r) => r.animalId.toString() == animal.id)
            .toList()
          ..sort((a, b) {
            final aDate = a.treatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.treatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          });

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
                        Expanded(
                          child: Text(
                            'Health Overview',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _showAddHealthRecordDialog(context, animal),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Record'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: animal.healthScore / 100,
                      backgroundColor:
                          theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      color: _getHealthColor(animal.healthScore),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${animal.healthScore}% health score • ${records.length} record(s)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (records.isEmpty)
              _AnimatedCard(
                index: 2,
                theme: theme,
                child: const ListTile(
                  leading: Icon(Icons.monitor_heart_outlined),
                  title: Text('No health records yet'),
                  subtitle:
                      Text('Tap "Add Record" to track treatments/checks.'),
                ),
              )
            else
              ...records.map(
                (record) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AnimatedCard(
                    index: 2,
                    theme: theme,
                    child: ListTile(
                      leading: Icon(
                        _healthTypeIcon(record.type),
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(record.name),
                      subtitle: Text(
                        '${record.type} • ${_formatDate(record.treatedAt)}'
                        '${record.notes == null || record.notes!.isEmpty ? '' : '\n${record.notes}'}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: record.id == null
                            ? null
                            : () => context
                                .read<AnimalHealthRecordsCubit>()
                                .delete(record.id!),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showAddHealthRecordDialog(
    BuildContext context,
    _AnimalDetailView animal,
  ) async {
    final formKey = GlobalKey<FormState>();
    final typeController = TextEditingController(text: 'checkup');
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    DateTime treatedAt = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Health Record'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: typeController,
                decoration: const InputDecoration(labelText: 'Type'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Type is required' : null,
              ),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Record Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16),
                  const SizedBox(width: 8),
                  Text(_formatDate(treatedAt)),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate: treatedAt,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        treatedAt = picked;
                      }
                    },
                    child: const Text('Change'),
                  ),
                ],
              ),
            ],
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

    if (result != true) return;
    if (!context.mounted) return;

    final animalId = int.tryParse(animal.id);
    if (animalId == null) return;

    context.read<AnimalHealthRecordsCubit>().add(
          AnimalHealthRecordEntity(
            animalId: animalId,
            type: typeController.text.trim(),
            name: nameController.text.trim(),
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
            treatedAt: treatedAt,
          ),
        );
  }

  String _formatDate(DateTime? value) {
    if (value == null) return 'No date';
    final d = value.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Color _getHealthColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    return Colors.red;
  }

  IconData _healthTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'vaccine':
      case 'vaccination':
        return Icons.vaccines;
      case 'treatment':
        return Icons.medication;
      case 'checkup':
        return Icons.monitor_heart;
      default:
        return Icons.medical_services_outlined;
    }
  }
}

class _ProductionTab extends StatelessWidget {
  final _AnimalDetailView animal;
  final ThemeData theme;

  const _ProductionTab({required this.animal, required this.theme});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductionLogCubit, ProductionLogState>(
      builder: (context, state) {
        final animalLogs = state.logs
            .where((log) => log.animalId == animal.id)
            .toList()
          ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

        final totalQuantity = animalLogs.fold<double>(
          0,
          (sum, log) => sum + log.quantity.value,
        );
        final byType = <String, int>{};
        for (final log in animalLogs) {
          byType.update(log.productType, (value) => value + 1,
              ifAbsent: () => 1);
        }
        final topType = byType.entries.isEmpty
            ? 'N/A'
            : (byType.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value)))
                .first
                .key;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AnimatedCard(
              index: 1,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Production Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ProductionMetric(
                      label: 'Records',
                      value: animalLogs.length.toString(),
                      trend: animalLogs.isEmpty ? 'No data' : 'Tracked',
                      theme: theme,
                    ),
                    _ProductionMetric(
                      label: 'Total Quantity',
                      value: totalQuantity.toStringAsFixed(1),
                      trend: animalLogs.isEmpty ? 'No data' : 'Captured',
                      theme: theme,
                    ),
                    _ProductionMetric(
                      label: 'Top Product',
                      value: topType,
                      trend: animalLogs.isEmpty ? 'No data' : 'Primary',
                      theme: theme,
                    ),
                    if (animal.weight != null)
                      _ProductionMetric(
                        label: 'Current Weight',
                        value: animal.weight!,
                        trend: 'Recorded',
                        theme: theme,
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
                      'Recent Production Records',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (state.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (animalLogs.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.analytics_outlined),
                        title: Text('No production logs yet'),
                        subtitle: Text(
                            'Use the production logging screen to add entries.'),
                      )
                    else
                      ...animalLogs.take(10).map(
                            (log) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor:
                                    theme.colorScheme.primary.withValues(
                                  alpha: 0.1,
                                ),
                                child: Icon(
                                  Icons.insights,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              title: Text(
                                '${log.productType} • ${log.quantity.value.toStringAsFixed(1)} ${log.unit.value}',
                              ),
                              subtitle: Text(
                                '${_formatDate(log.recordedAt)}${log.quality == null ? '' : ' • ${log.quality}'}',
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductionMetric extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final ThemeData theme;

  const _ProductionMetric({
    required this.label,
    required this.value,
    required this.trend,
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
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTrendColor(trend).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trend,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getTrendColor(trend),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    if (trend.startsWith('+') || trend.toLowerCase() == 'good') {
      return Colors.green;
    }
    if (trend.startsWith('-')) {
      return Colors.red;
    }
    return Colors.orange;
  }
}

class _HistoryTab extends StatelessWidget {
  final _AnimalDetailView animal;
  final ThemeData theme;

  const _HistoryTab({required this.animal, required this.theme});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimalHealthRecordsCubit, AnimalHealthRecordsState>(
      builder: (context, healthState) => BlocBuilder<ProductionLogCubit,
          ProductionLogState>(
        builder: (context, productionState) {
          final history = _buildHistoryEntries(healthState, productionState);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AnimatedCard(
                index: 1,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Animal History',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (history.isEmpty)
                        const ListTile(
                          leading: Icon(Icons.history),
                          title: Text('No history yet'),
                          subtitle: Text(
                            'Health and production actions for this animal will appear here.',
                          ),
                        )
                      else
                        ...history
                            .map((entry) => _HistoryItem(entry: entry, theme: theme)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<_HistoryEntry> _buildHistoryEntries(
    AnimalHealthRecordsState healthState,
    ProductionLogState productionState,
  ) {
    final entries = <_HistoryEntry>[];
    final healthRecords = healthState.records
        .where((r) => r.animalId.toString() == animal.id)
        .toList();
    final productionLogs = productionState.logs
        .where((r) => r.animalId == animal.id)
        .toList();

    for (final record in healthRecords) {
      final when = record.treatedAt ?? DateTime.now();
      entries.add(
        _HistoryEntry(
          date: _formatDate(when),
          timestamp: when,
          event: 'Health: ${record.type}',
          details: record.name,
          notes: record.notes,
        ),
      );
    }

    for (final log in productionLogs) {
      entries.add(
        _HistoryEntry(
          date: _formatDate(log.recordedAt),
          timestamp: log.recordedAt,
          event: 'Production: ${log.productType}',
          details:
              '${log.quantity.value.toStringAsFixed(1)} ${log.unit.value}',
          notes: log.notes,
        ),
      );
    }

    if (animal.weight != null) {
      entries.add(
        _HistoryEntry(
          date: 'Current',
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          event: 'Weight',
          details: animal.weight!,
        ),
      );
    }

    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }
}

class _AnimalTasksTab extends StatefulWidget {
  final _AnimalDetailView animal;
  final ThemeData theme;

  const _AnimalTasksTab({required this.animal, required this.theme});

  @override
  State<_AnimalTasksTab> createState() => _AnimalTasksTabState();
}

class _AnimalTasksTabState extends State<_AnimalTasksTab> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;
  final SyncData _syncData = SyncData();

  @override
  void initState() {
    super.initState();
    _tasksFuture = LocalData.getUpcomingTasks(limit: 30);
  }

  void _reload() {
    setState(() {
      _tasksFuture = LocalData.getUpcomingTasks(limit: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <Map<String, dynamic>>[];
        final linkedTasks = rows.where((task) {
          final sourceType = (task['source_event_type'] ?? '').toString();
          final sourceId = (task['source_event_id'] ?? '').toString();
          final title = (task['title'] ?? '').toString().toLowerCase();
          return (sourceType.toLowerCase() == 'animal' &&
                  sourceId == widget.animal.id) ||
              title.contains(widget.animal.name.toLowerCase());
        }).toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _AnimatedCard(
              index: 1,
              theme: widget.theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Animal Tasks',
                            style: widget.theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddTaskScreen(
                                  sourceEventType: 'animal',
                                  sourceEventId: widget.animal.id,
                                  initialTitle:
                                      'Task for ${widget.animal.name}',
                                  initialDescription:
                                      'Linked task for ${widget.animal.name}',
                                ),
                              ),
                            );
                            if (result is! TaskEntity) return;
                            await _syncData.insertTask(
                              Task(
                                title: result.title.value,
                                description: result.description,
                                dueDate: result.dueDate?.toIso8601String(),
                                status:
                                    result.isCompleted ? 'completed' : 'pending',
                                sourceEventType: result.sourceEventType,
                                sourceEventId: result.sourceEventId,
                              ),
                            );
                            _reload();
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (linkedTasks.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.task_alt_outlined),
                        title: Text('No linked tasks'),
                        subtitle: Text(
                          'Tap Add to create a task linked to this animal.',
                        ),
                      )
                    else
                      ...linkedTasks.take(10).map(
                            (task) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.task_alt),
                              title: Text((task['title'] ?? 'Untitled').toString()),
                              subtitle: Text(
                                'Due: ${_formatDate(DateTime.tryParse((task['due_date'] ?? '').toString()))}',
                              ),
                              trailing: Text(
                                ((task['status'] ?? 'pending').toString()),
                                style:
                                    widget.theme.textTheme.bodySmall?.copyWith(
                                  color: ((task['status'] ?? '')
                                              .toString()
                                              .toLowerCase() ==
                                          'completed')
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final _HistoryEntry entry;
  final ThemeData theme;

  const _HistoryItem({required this.entry, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEventIcon(entry.event),
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.event,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entry.details,
                  style: theme.textTheme.bodySmall,
                ),
                if (entry.notes != null && entry.notes!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      entry.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      entry.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String event) {
    final lower = event.toLowerCase();
    if (lower.contains('health') || lower.contains('vaccine')) {
      return Icons.medical_services;
    }
    if (lower.contains('production')) return Icons.insights;
    if (lower.contains('weight')) return Icons.monitor_weight_outlined;
    return Icons.history;
  }
}

class _HistoryEntry {
  final String date;
  final DateTime timestamp;
  final String event;
  final String details;
  final String? notes;

  _HistoryEntry({
    required this.date,
    required this.timestamp,
    required this.event,
    required this.details,
    this.notes,
  });
}

String _formatDate(DateTime? value) {
  if (value == null) return 'No date';
  final d = value.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
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
