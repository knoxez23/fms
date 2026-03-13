import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/services/farm_setup_service.dart';
import 'package:pamoja_twalima/features/auth/application/auth_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/animal_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/crop_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/feeding_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/application/task_usecases.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/animal_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/crop_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/feeding_schedule_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';
import 'package:pamoja_twalima/features/inventory/domain/repositories/inventory_repository.dart';

class FarmSetupScreen extends StatefulWidget {
  final int userId;
  final String? farmerName;
  final String? farmName;

  const FarmSetupScreen({
    super.key,
    required this.userId,
    this.farmerName,
    this.farmName,
  });

  @override
  State<FarmSetupScreen> createState() => _FarmSetupScreenState();
}

class FarmSetupGate extends StatelessWidget {
  const FarmSetupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<GetCurrentUser>().execute(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data!;
        return FarmSetupScreen(
          userId: user.id ?? 0,
          farmerName: user.name,
          farmName: user.farmName,
        );
      },
    );
  }
}

class _FarmSetupScreenState extends State<FarmSetupScreen> {
  final Set<_AnimalPreset> _selectedAnimals = {};
  final Set<_CropPreset> _selectedCrops = {};
  final Set<_MaterialPreset> _selectedMaterials = {};
  final Map<_AnimalPreset, _FarmScale> _animalScales = {};
  final Map<_CropPreset, _CropSetupMode> _cropModes = {};
  final Map<_MaterialPreset, _MaterialAvailability> _materialAvailability = {};
  bool _saving = false;

  static const List<_AnimalPreset> _animalPresets = [
    _AnimalPreset(
      title: 'Dairy Cows',
      subtitle: 'Milk production, feed planning, breeding, vet care',
      animalType: 'cow',
      defaultName: 'Dairy Cow Group',
      breedHint: 'Friesian / Ayrshire',
      starterMaterials: ['Napier Grass', 'Hay', 'Dairy Meal'],
    ),
    _AnimalPreset(
      title: 'Beef Cattle',
      subtitle: 'Meat growth tracking, feed cost, sale readiness',
      animalType: 'cow',
      defaultName: 'Beef Cattle Group',
      breedHint: 'Boran / Sahiwal',
      starterMaterials: ['Hay', 'Silage', 'Mineral Lick'],
    ),
    _AnimalPreset(
      title: 'Dairy Goats',
      subtitle: 'Milk yield, kidding reminders, low-input dairy',
      animalType: 'goat',
      defaultName: 'Dairy Goat Group',
      breedHint: 'Toggenburg / Alpine',
      starterMaterials: ['Napier Grass', 'Hay', 'Goat Dairy Mix'],
    ),
    _AnimalPreset(
      title: 'Meat Goats',
      subtitle: 'Weight gain, herd records, sale timing',
      animalType: 'goat',
      defaultName: 'Meat Goat Group',
      breedHint: 'Boer Cross',
      starterMaterials: ['Hay', 'Browse Feed', 'Mineral Lick'],
    ),
    _AnimalPreset(
      title: 'Layers',
      subtitle: 'Egg output, feed conversion, laying alerts',
      animalType: 'chicken',
      defaultName: 'Layer Flock',
      breedHint: 'Kienyeji / Isa Brown',
      starterMaterials: ['Layer Mash', 'Chick Starter', 'Clean Water'],
    ),
    _AnimalPreset(
      title: 'Broilers',
      subtitle: 'Growth cycles, feed usage, market readiness',
      animalType: 'chicken',
      defaultName: 'Broiler Flock',
      breedHint: 'Cobb / Ross',
      starterMaterials: ['Broiler Starter', 'Broiler Finisher', 'Clean Water'],
    ),
    _AnimalPreset(
      title: 'Pigs',
      subtitle: 'Feed cost, weight gain, health and sale prep',
      animalType: 'pig',
      defaultName: 'Pig Unit',
      breedHint: 'Large White / Landrace',
      starterMaterials: ['Pig Grower Feed', 'Maize Bran', 'Clean Water'],
    ),
  ];

  static const List<_CropPreset> _cropPresets = [
    _CropPreset(
      title: 'Maize',
      subtitle: 'Staple grain with strong planning and harvest cycles',
      varietyHint: 'Hybrid maize',
      daysToHarvest: 120,
      starterMaterials: ['Maize Seed', 'DAP Fertilizer'],
    ),
    _CropPreset(
      title: 'Beans',
      subtitle: 'Shorter cycle cash and food crop',
      varietyHint: 'Rosecoco / Nyota',
      daysToHarvest: 90,
      starterMaterials: ['Bean Seed', 'Top Dress Fertilizer'],
    ),
    _CropPreset(
      title: 'Potatoes',
      subtitle: 'High-value crop with input and harvest planning',
      varietyHint: 'Shangi',
      daysToHarvest: 110,
      starterMaterials: ['Potato Seed', 'Fungicide'],
    ),
    _CropPreset(
      title: 'Onions',
      subtitle: 'Market crop with nursery and transplant stages',
      varietyHint: 'Red Creole',
      daysToHarvest: 120,
      starterMaterials: ['Onion Seed', 'Fertilizer'],
    ),
    _CropPreset(
      title: 'Tomatoes',
      subtitle: 'High-touch crop suited for task automation',
      varietyHint: 'Rio Grande',
      daysToHarvest: 95,
      starterMaterials: ['Tomato Seedlings', 'Fungicide'],
    ),
    _CropPreset(
      title: 'Cabbages',
      subtitle: 'Fast market crop with repeatable harvest cycles',
      varietyHint: 'Gloria',
      daysToHarvest: 90,
      starterMaterials: ['Cabbage Seedlings', 'CAN Fertilizer'],
    ),
    _CropPreset(
      title: 'Kale',
      subtitle: 'Frequent harvest vegetable for steady income',
      varietyHint: 'Sukuma Wiki',
      daysToHarvest: 60,
      starterMaterials: ['Kale Seedlings', 'Manure'],
    ),
    _CropPreset(
      title: 'Spinach',
      subtitle: 'Fast leafy crop for short sales cycles',
      varietyHint: 'Hybrid spinach',
      daysToHarvest: 45,
      starterMaterials: ['Spinach Seed', 'Manure'],
    ),
  ];

  static const List<_MaterialPreset> _materialPresets = [
    _MaterialPreset(name: 'Napier Grass', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(name: 'Hay', category: 'Animal Feed', unit: 'bales'),
    _MaterialPreset(name: 'Silage', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(name: 'Dairy Meal', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(name: 'Layer Mash', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(
        name: 'Broiler Starter', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(name: 'Maize Bran', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(
        name: 'Mineral Lick', category: 'Animal Health', unit: 'pieces'),
    _MaterialPreset(name: 'Maize Seed', category: 'Seeds', unit: 'kg'),
    _MaterialPreset(name: 'Bean Seed', category: 'Seeds', unit: 'kg'),
    _MaterialPreset(
        name: 'Tomato Seedlings', category: 'Seeds', unit: 'pieces'),
    _MaterialPreset(name: 'Kale Seedlings', category: 'Seeds', unit: 'pieces'),
    _MaterialPreset(
        name: 'DAP Fertilizer', category: 'Fertilizers', unit: 'kg'),
    _MaterialPreset(
        name: 'CAN Fertilizer', category: 'Fertilizers', unit: 'kg'),
    _MaterialPreset(name: 'Manure', category: 'Fertilizers', unit: 'bags'),
    _MaterialPreset(name: 'Fungicide', category: 'Chemicals', unit: 'liters'),
  ];

  @override
  Widget build(BuildContext context) {
    final farmerLabel = widget.farmName?.trim().isNotEmpty == true
        ? widget.farmName!.trim()
        : (widget.farmerName?.trim().isNotEmpty == true
            ? "${widget.farmerName!.trim()}'s Farm"
            : 'your farm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Your Farm'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroSetupCard(
              title: 'Start $farmerLabel with structure',
              subtitle:
                  'Choose what you rear, what you grow, and what materials you already have. The app will seed your farm so the dashboard, tasks, and operations are useful immediately.',
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Animals You Rear',
              subtitle:
                  'Pick the main livestock systems you manage. You can add more later.',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _animalPresets
                    .map(
                      (preset) => _SelectableChipCard(
                        title: preset.title,
                        subtitle: preset.subtitle,
                        selected: _selectedAnimals.contains(preset),
                        onTap: () => _toggleAnimal(preset),
                        footer: _selectedAnimals.contains(preset)
                            ? _InlineChoiceBar<_FarmScale>(
                                value:
                                    _animalScales[preset] ?? _FarmScale.small,
                                options: _FarmScale.values,
                                labelBuilder: (value) => value.label,
                                onChanged: (value) {
                                  setState(() {
                                    _animalScales[preset] = value;
                                  });
                                },
                              )
                            : null,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Crops You Grow',
              subtitle:
                  'Pick the main crops to seed planting and harvest workflows.',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _cropPresets
                    .map(
                      (preset) => _SelectableChipCard(
                        title: preset.title,
                        subtitle: preset.subtitle,
                        selected: _selectedCrops.contains(preset),
                        onTap: () => _toggleCrop(preset),
                        footer: _selectedCrops.contains(preset)
                            ? _InlineChoiceBar<_CropSetupMode>(
                                value: _cropModes[preset] ??
                                    _CropSetupMode.planned,
                                options: _CropSetupMode.values,
                                labelBuilder: (value) => value.label,
                                onChanged: (value) {
                                  setState(() {
                                    _cropModes[preset] = value;
                                  });
                                },
                              )
                            : null,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Starter Feed & Materials',
              subtitle:
                  'The app suggests what this farm likely needs. Mark each item as already available or as something to source soon.',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _materialPresets
                    .map(
                      (material) => _SelectableChipCard(
                        title: material.name,
                        subtitle: material.category,
                        selected: _selectedMaterials.contains(material),
                        onTap: () => _toggleMaterial(material),
                        footer: _selectedMaterials.contains(material)
                            ? _InlineChoiceBar<_MaterialAvailability>(
                                value: _materialAvailability[material] ??
                                    _MaterialAvailability.needSoon,
                                options: _MaterialAvailability.values,
                                labelBuilder: (value) => value.label,
                                onChanged: (value) {
                                  setState(() {
                                    _materialAvailability[material] = value;
                                  });
                                },
                              )
                            : null,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'What This Setup Will Create',
              subtitle: 'This keeps the app from feeling empty on day one.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryLine(
                    label: 'Starter animal groups',
                    value: '${_selectedAnimals.length}',
                  ),
                  _SummaryLine(
                    label: 'Starter crop records',
                    value: '${_selectedCrops.length}',
                  ),
                  _SummaryLine(
                    label: 'Starter material inventory items',
                    value: '${_selectedMaterials.length}',
                  ),
                  _SummaryLine(
                    label: 'Ready on hand now',
                    value:
                        '${_selectedMaterials.where((item) => (_materialAvailability[item] ?? _MaterialAvailability.needSoon) == _MaterialAvailability.availableNow).length}',
                  ),
                  _SummaryLine(
                    label: 'Source soon tasks',
                    value:
                        '${_selectedMaterials.where((item) => (_materialAvailability[item] ?? _MaterialAvailability.needSoon) == _MaterialAvailability.needSoon).length}',
                  ),
                  _SummaryLine(
                    label: 'Starter operational tasks',
                    value:
                        '${(_selectedAnimals.length * 2) + (_selectedCrops.length * 2) + _selectedMaterials.where((item) => (_materialAvailability[item] ?? _MaterialAvailability.needSoon) == _MaterialAvailability.needSoon).length}',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving ? null : _skipMinimalSetup,
                  child: const Text('Skip For Now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _saving ? null : _applySetup,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create My Farm Workspace'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleAnimal(_AnimalPreset preset) {
    setState(() {
      if (_selectedAnimals.remove(preset)) {
        _animalScales.remove(preset);
        return;
      }
      _selectedAnimals.add(preset);
      _animalScales[preset] = _animalScales[preset] ?? _FarmScale.small;
      _applyRecommendedMaterials();
    });
  }

  void _toggleCrop(_CropPreset preset) {
    setState(() {
      if (_selectedCrops.remove(preset)) {
        _cropModes.remove(preset);
        return;
      }
      _selectedCrops.add(preset);
      _cropModes[preset] = _cropModes[preset] ?? _CropSetupMode.planned;
      _applyRecommendedMaterials();
    });
  }

  void _toggleMaterial(_MaterialPreset material) {
    setState(() {
      if (_selectedMaterials.remove(material)) {
        _materialAvailability.remove(material);
      } else {
        _selectedMaterials.add(material);
        _materialAvailability[material] =
            _materialAvailability[material] ?? _MaterialAvailability.needSoon;
      }
    });
  }

  void _applyRecommendedMaterials() {
    final recommended = <String>{
      for (final animal in _selectedAnimals) ...animal.starterMaterials,
      for (final crop in _selectedCrops) ...crop.starterMaterials,
    };
    _selectedMaterials.addAll(
      _materialPresets.where((item) => recommended.contains(item.name)),
    );
    for (final material in _selectedMaterials) {
      _materialAvailability[material] =
          _materialAvailability[material] ?? _MaterialAvailability.needSoon;
    }
  }

  Future<void> _skipMinimalSetup() async {
    await FarmSetupService().markSetupComplete(widget.userId);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _applySetup() async {
    setState(() => _saving = true);
    try {
      for (final preset in _selectedAnimals) {
        final scale = _animalScales[preset] ?? _FarmScale.small;
        final createdAnimal = await getIt<AddAnimal>().execute(
          AnimalEntity(
            name: AnimalName('${preset.defaultName} (${scale.label})'),
            type: AnimalType(preset.animalType),
            breed: preset.breedHint,
          ),
        );
        final animalId = int.tryParse(createdAnimal.id ?? '');
        if (animalId != null) {
          for (final schedule in _feedingTemplatesFor(
            animalId: animalId,
            preset: preset,
            scale: scale,
          )) {
            await getIt<AddFeedingSchedule>().execute(schedule);
          }
        }
        await getIt<AddTask>().execute(
          TaskEntity(
            title: TaskTitle('Set feeding plan for ${preset.title}'),
            description:
                'Confirm feed routine, expected output, and care schedule for ${preset.title.toLowerCase()}.',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            assignedTo: null,
            staffMemberId: null,
            sourceEventType: 'setup',
            sourceEventId: preset.title.toLowerCase().replaceAll(' ', '_'),
          ),
        );
        await getIt<AddTask>().execute(
          TaskEntity(
            title: TaskTitle(
                'Record ${scale.label.toLowerCase()} count for ${preset.title}'),
            description:
                'Capture the opening number of animals and production purpose for ${preset.title.toLowerCase()} so automation can use realistic herd or flock assumptions.',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            sourceEventType: 'setup',
            sourceEventId:
                '${preset.title.toLowerCase().replaceAll(' ', '_')}_${scale.name}',
          ),
        );
      }

      for (final preset in _selectedCrops) {
        final mode = _cropModes[preset] ?? _CropSetupMode.planned;
        final plantedAt = mode == _CropSetupMode.planted
            ? DateTime.now()
                .subtract(Duration(days: (preset.daysToHarvest * 0.35).round()))
            : DateTime.now();
        await getIt<AddCrop>().execute(
          CropEntity(
            name: CropName(preset.title),
            variety: preset.varietyHint,
            plantedAt: plantedAt,
            expectedHarvest:
                plantedAt.add(Duration(days: preset.daysToHarvest)),
            area: 1,
            status: mode == _CropSetupMode.planted ? 'Growing' : 'Planned',
            notes:
                'Seeded from onboarding farm setup template (${mode.label.toLowerCase()}).',
          ),
        );
        await getIt<AddTask>().execute(
          TaskEntity(
            title: TaskTitle(mode == _CropSetupMode.planted
                ? 'Review current ${preset.title} field'
                : 'Review ${preset.title} planting plan'),
            description: mode == _CropSetupMode.planted
                ? 'Confirm current growth stage, recent inputs, and next field action for ${preset.title.toLowerCase()}.'
                : 'Confirm acreage, inputs, and first field tasks for ${preset.title.toLowerCase()}.',
            dueDate: DateTime.now().add(const Duration(days: 3)),
            sourceEventType: 'setup',
            sourceEventId: preset.title.toLowerCase(),
          ),
        );
        for (final task in _cropChecklistFor(preset, mode)) {
          await getIt<AddTask>().execute(task);
        }
      }

      for (final material in _selectedMaterials) {
        final minStock = _recommendedMinStock(material);
        final availability =
            _materialAvailability[material] ?? _MaterialAvailability.needSoon;
        await getIt<InventoryRepository>().addItem(
          InventoryItem(
            itemName: material.name,
            category: material.category,
            quantity: availability == _MaterialAvailability.availableNow
                ? (minStock * 1.5).toDouble()
                : 0,
            unit: material.unit,
            minStock: minStock,
            supplier: null,
            unitPrice: null,
            totalValue: null,
            isSynced: false,
          ),
        );
        if (availability == _MaterialAvailability.needSoon) {
          await getIt<AddTask>().execute(
            TaskEntity(
              title: TaskTitle('Source ${material.name}'),
              description:
                  'Add or buy ${material.name.toLowerCase()} so ${material.category.toLowerCase()} workflows start without delays.',
              dueDate: DateTime.now().add(
                Duration(
                  days: material.category == 'Animal Feed' ? 2 : 5,
                ),
              ),
              sourceEventType: 'setup',
              sourceEventId:
                  'material_${material.name.toLowerCase().replaceAll(' ', '_')}',
            ),
          );
        }
      }

      await FarmSetupService().markSetupComplete(widget.userId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Farm workspace created. You can refine everything later.'),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  int _recommendedMinStock(_MaterialPreset material) {
    var score = 1;

    for (final preset in _selectedAnimals) {
      if (preset.starterMaterials.contains(material.name)) {
        score += (_animalScales[preset] ?? _FarmScale.small).weight;
      }
    }

    for (final preset in _selectedCrops) {
      if (preset.starterMaterials.contains(material.name)) {
        score += (_cropModes[preset] ?? _CropSetupMode.planned) ==
                _CropSetupMode.planted
            ? 3
            : 1;
      }
    }

    return score.clamp(1, 12);
  }

  List<FeedingScheduleEntity> _feedingTemplatesFor({
    required int animalId,
    required _AnimalPreset preset,
    required _FarmScale scale,
  }) {
    final primaryFeed = preset.starterMaterials.isNotEmpty
        ? preset.starterMaterials.first
        : 'Feed Mix';
    final secondaryFeed = preset.starterMaterials.length > 1
        ? preset.starterMaterials[1]
        : primaryFeed;
    final baseQuantity = switch (preset.animalType) {
      'cow' => 8.0,
      'goat' => 2.0,
      'chicken' => 0.12,
      'pig' => 1.8,
      _ => 1.0,
    };
    final multiplier = switch (scale) {
      _FarmScale.small => 1.0,
      _FarmScale.medium => 2.5,
      _FarmScale.large => 4.0,
    };

    return [
      FeedingScheduleEntity(
        animalId: animalId,
        feedType: primaryFeed,
        quantity: double.parse((baseQuantity * multiplier).toStringAsFixed(2)),
        unit: preset.animalType == 'chicken' ? 'kg' : 'kg',
        timeOfDay: 'Morning',
        frequency: 'Daily',
        startDate: DateTime.now(),
        notes: 'Auto-created from farm setup',
      ),
      FeedingScheduleEntity(
        animalId: animalId,
        feedType: secondaryFeed,
        quantity: double.parse(
            ((baseQuantity * multiplier) * 0.7).toStringAsFixed(2)),
        unit: 'kg',
        timeOfDay: 'Evening',
        frequency: 'Daily',
        startDate: DateTime.now(),
        notes: 'Auto-created from farm setup',
      ),
    ];
  }

  List<TaskEntity> _cropChecklistFor(
    _CropPreset preset,
    _CropSetupMode mode,
  ) {
    final cropName = preset.title;
    if (mode == _CropSetupMode.planted) {
      return [
        TaskEntity(
          title: TaskTitle('7-day $cropName field check'),
          description:
              'Review moisture, pests, and nutrient needs for current $cropName crop.',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          sourceEventType: 'setup',
          sourceEventId: '${cropName.toLowerCase()}_7d',
        ),
        TaskEntity(
          title: TaskTitle('14-day $cropName progress review'),
          description:
              'Check crop health, expected yield direction, and missing field tasks.',
          dueDate: DateTime.now().add(const Duration(days: 14)),
          sourceEventType: 'setup',
          sourceEventId: '${cropName.toLowerCase()}_14d',
        ),
        TaskEntity(
          title: TaskTitle('30-day $cropName market prep'),
          description:
              'Review likely harvest path, stock handling, and buyer readiness for $cropName.',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          sourceEventType: 'setup',
          sourceEventId: '${cropName.toLowerCase()}_30d',
        ),
      ];
    }

    return [
      TaskEntity(
        title: TaskTitle('7-day $cropName input check'),
        description:
            'Confirm seed, fertilizer, and protection inputs before starting $cropName field work.',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        sourceEventType: 'setup',
        sourceEventId: '${cropName.toLowerCase()}_7d',
      ),
      TaskEntity(
        title: TaskTitle('14-day $cropName planting readiness'),
        description: 'Confirm field, labor, and planting date for $cropName.',
        dueDate: DateTime.now().add(const Duration(days: 14)),
        sourceEventType: 'setup',
        sourceEventId: '${cropName.toLowerCase()}_14d',
      ),
      TaskEntity(
        title: TaskTitle('30-day $cropName early growth review'),
        description:
            'Plan the first monitoring cycle and expected early-stage tasks for $cropName.',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        sourceEventType: 'setup',
        sourceEventId: '${cropName.toLowerCase()}_30d',
      ),
    ];
  }
}

class _AnimalPreset {
  final String title;
  final String subtitle;
  final String animalType;
  final String defaultName;
  final String breedHint;
  final List<String> starterMaterials;

  const _AnimalPreset({
    required this.title,
    required this.subtitle,
    required this.animalType,
    required this.defaultName,
    required this.breedHint,
    required this.starterMaterials,
  });
}

class _CropPreset {
  final String title;
  final String subtitle;
  final String varietyHint;
  final int daysToHarvest;
  final List<String> starterMaterials;

  const _CropPreset({
    required this.title,
    required this.subtitle,
    required this.varietyHint,
    required this.daysToHarvest,
    required this.starterMaterials,
  });
}

class _MaterialPreset {
  final String name;
  final String category;
  final String unit;

  const _MaterialPreset({
    required this.name,
    required this.category,
    required this.unit,
  });
}

enum _FarmScale {
  small('Small'),
  medium('Medium'),
  large('Large');

  const _FarmScale(this.label);
  final String label;

  int get weight {
    switch (this) {
      case _FarmScale.small:
        return 1;
      case _FarmScale.medium:
        return 3;
      case _FarmScale.large:
        return 5;
    }
  }
}

enum _CropSetupMode {
  planned('Planned'),
  planted('Already Planted');

  const _CropSetupMode(this.label);
  final String label;
}

enum _MaterialAvailability {
  availableNow('Available Now'),
  needSoon('Need Soon');

  const _MaterialAvailability(this.label);
  final String label;
}

class _HeroSetupCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeroSetupCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.95),
            theme.colorScheme.secondary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SelectableChipCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? footer;

  const _SelectableChipCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 170,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 20,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.45),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (footer != null) ...[
              const SizedBox(height: 12),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineChoiceBar<T> extends StatelessWidget {
  final T value;
  final List<T> options;
  final String Function(T value) labelBuilder;
  final ValueChanged<T> onChanged;

  const _InlineChoiceBar({
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: options
          .map(
            (option) => ChoiceChip(
              label: Text(labelBuilder(option)),
              selected: option == value,
              onSelected: (_) => onChanged(option),
              labelStyle: theme.textTheme.bodySmall,
            ),
          )
          .toList(),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
