import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  static const String _rationLabelPrefix = 'measure_label:';
  final ImagePicker _imagePicker = ImagePicker();
  final Set<_AnimalPreset> _selectedAnimals = {};
  final Set<_CropPreset> _selectedCrops = {};
  final Set<_MaterialPreset> _selectedMaterials = {};
  final Map<_AnimalPreset, _AnimalSetupDraft> _animalDrafts = {};
  final Map<_CropPreset, _CropSetupDraft> _cropDrafts = {};
  final Map<_MaterialPreset, _MaterialSetupDraft> _materialDrafts = {};
  final List<_AnimalSetupDraft> _customAnimalDrafts = [];
  final List<_CropSetupDraft> _customCropDrafts = [];
  final List<_MaterialSetupDraft> _customMaterialDrafts = [];
  _FeedMeasurementStyle _feedMeasurementStyle = _FeedMeasurementStyle.household;
  bool _saving = false;

  static const List<_AnimalPreset> _animalPresets = [
    _AnimalPreset(
      title: 'Dairy Cows',
      subtitle: 'Milk production, feed planning, breeding, vet care',
      animalType: 'cow',
      defaultName: 'Dairy Cow Group',
      breedHint: 'Friesian / Ayrshire',
      starterMaterials: ['Napier Grass', 'Hay', 'Dairy Meal'],
      supportsIndividualTracking: true,
    ),
    _AnimalPreset(
      title: 'Beef Cattle',
      subtitle: 'Meat growth tracking, feed cost, sale readiness',
      animalType: 'cow',
      defaultName: 'Beef Cattle Group',
      breedHint: 'Boran / Sahiwal',
      starterMaterials: ['Hay', 'Silage', 'Mineral Lick'],
      supportsIndividualTracking: true,
    ),
    _AnimalPreset(
      title: 'Dairy Goats',
      subtitle: 'Milk yield, kidding reminders, low-input dairy',
      animalType: 'goat',
      defaultName: 'Dairy Goat Group',
      breedHint: 'Toggenburg / Alpine',
      starterMaterials: ['Napier Grass', 'Hay', 'Goat Dairy Mix'],
      supportsIndividualTracking: true,
    ),
    _AnimalPreset(
      title: 'Meat Goats',
      subtitle: 'Weight gain, herd records, sale timing',
      animalType: 'goat',
      defaultName: 'Meat Goat Group',
      breedHint: 'Boer Cross',
      starterMaterials: ['Hay', 'Browse Feed', 'Mineral Lick'],
      supportsIndividualTracking: true,
    ),
    _AnimalPreset(
      title: 'Layers',
      subtitle: 'Egg output, feed conversion, laying alerts',
      animalType: 'chicken',
      defaultName: 'Layer Flock',
      breedHint: 'Kienyeji / Isa Brown',
      starterMaterials: ['Layer Mash', 'Chick Starter', 'Clean Water'],
      supportsIndividualTracking: false,
    ),
    _AnimalPreset(
      title: 'Broilers',
      subtitle: 'Growth cycles, feed usage, market readiness',
      animalType: 'chicken',
      defaultName: 'Broiler Flock',
      breedHint: 'Cobb / Ross',
      starterMaterials: ['Broiler Starter', 'Broiler Finisher', 'Clean Water'],
      supportsIndividualTracking: false,
    ),
    _AnimalPreset(
      title: 'Pigs',
      subtitle: 'Feed cost, weight gain, health and sale prep',
      animalType: 'pig',
      defaultName: 'Pig Unit',
      breedHint: 'Large White / Landrace',
      starterMaterials: ['Pig Grower Feed', 'Maize Bran', 'Clean Water'],
      supportsIndividualTracking: true,
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
    _MaterialPreset(
      name: 'Goat Dairy Mix',
      category: 'Animal Feed',
      unit: 'kg',
    ),
    _MaterialPreset(name: 'Layer Mash', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(name: 'Chick Starter', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(
      name: 'Broiler Starter',
      category: 'Animal Feed',
      unit: 'kg',
    ),
    _MaterialPreset(
      name: 'Broiler Finisher',
      category: 'Animal Feed',
      unit: 'kg',
    ),
    _MaterialPreset(
      name: 'Pig Grower Feed',
      category: 'Animal Feed',
      unit: 'kg',
    ),
    _MaterialPreset(name: 'Maize Bran', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(name: 'Browse Feed', category: 'Animal Feed', unit: 'kg'),
    _MaterialPreset(
      name: 'Clean Water',
      category: 'Animal Feed',
      unit: 'liters',
    ),
    _MaterialPreset(
      name: 'Mineral Lick',
      category: 'Animal Health',
      unit: 'pieces',
    ),
    _MaterialPreset(name: 'Maize Seed', category: 'Seeds', unit: 'kg'),
    _MaterialPreset(name: 'Bean Seed', category: 'Seeds', unit: 'kg'),
    _MaterialPreset(name: 'Potato Seed', category: 'Seeds', unit: 'bags'),
    _MaterialPreset(name: 'Onion Seed', category: 'Seeds', unit: 'packets'),
    _MaterialPreset(
      name: 'Tomato Seedlings',
      category: 'Seeds',
      unit: 'pieces',
    ),
    _MaterialPreset(
      name: 'Cabbage Seedlings',
      category: 'Seeds',
      unit: 'pieces',
    ),
    _MaterialPreset(name: 'Kale Seedlings', category: 'Seeds', unit: 'pieces'),
    _MaterialPreset(
      name: 'Spinach Seed',
      category: 'Seeds',
      unit: 'packets',
    ),
    _MaterialPreset(
        name: 'DAP Fertilizer', category: 'Fertilizers', unit: 'kg'),
    _MaterialPreset(
      name: 'Top Dress Fertilizer',
      category: 'Fertilizers',
      unit: 'kg',
    ),
    _MaterialPreset(name: 'Fertilizer', category: 'Fertilizers', unit: 'kg'),
    _MaterialPreset(
      name: 'CAN Fertilizer',
      category: 'Fertilizers',
      unit: 'kg',
    ),
    _MaterialPreset(name: 'Manure', category: 'Fertilizers', unit: 'bags'),
    _MaterialPreset(name: 'Fungicide', category: 'Chemicals', unit: 'liters'),
  ];

  List<_AnimalSetupDraft> get _allAnimalDrafts => [
        ..._animalDrafts.values,
        ..._customAnimalDrafts,
      ];

  List<_CropSetupDraft> get _allCropDrafts => [
        ..._cropDrafts.values,
        ..._customCropDrafts,
      ];

  List<_MaterialSetupDraft> get _allMaterialDrafts => [
        ..._materialDrafts.values,
        ..._customMaterialDrafts,
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
        title: const Text('Build Your Farm Workspace'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _HeroSetupCard(
              title: 'Set up $farmerLabel like a working operation',
              subtitle:
                  'Choose your livestock and crops, enter the real counts, add the feeds or materials you actually use, and decide whether to track animals individually or as groups. The app will seed tasks, stock, schedules, and commercial follow-up around that setup.',
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'How This Setup Works',
              subtitle:
                  'Pick from common presets, then edit the details to match the real farm instead of forcing the farmer into fixed templates.',
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const [
                  _StepPill(
                    icon: Icons.pets,
                    title: 'Livestock',
                    subtitle: 'counts, tracking mode, names, photos',
                  ),
                  _StepPill(
                    icon: Icons.grass,
                    title: 'Crops',
                    subtitle: 'area, status, harvest timelines',
                  ),
                  _StepPill(
                    icon: Icons.inventory_2,
                    title: 'Inputs',
                    subtitle: 'available now vs need soon',
                  ),
                  _StepPill(
                    icon: Icons.auto_graph,
                    title: 'Automation',
                    subtitle: 'tasks, stock, feeding, sales signals',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Animals You Rear',
              subtitle:
                  'Start with common farm systems, then customize counts, names, photos, and whether they should be tracked individually.',
              action: OutlinedButton.icon(
                onPressed: _addCustomAnimal,
                icon: const Icon(Icons.add),
                label: const Text('Add Custom Animal'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _animalPresets
                        .map(
                          (preset) => _SelectableChipCard(
                            title: preset.title,
                            subtitle: preset.subtitle,
                            selected: _selectedAnimals.contains(preset),
                            onTap: () => _toggleAnimal(preset),
                          ),
                        )
                        .toList(),
                  ),
                  if (_allAnimalDrafts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ..._allAnimalDrafts.map(
                      (draft) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SetupDraftCard(
                          icon: Icons.pets,
                          title: draft.title,
                          subtitle:
                              '${draft.count} head/birds • ${draft.trackingMode.label} • ${draft.scale.label}',
                          badges: [
                            if (draft.breedHint.trim().isNotEmpty)
                              draft.breedHint.trim(),
                            if (draft.imagePath != null) 'Photo added',
                            draft.supportsIndividualTracking
                                ? 'Named tracking available'
                                : 'Best for flock/group tracking',
                          ],
                          details: [
                            'Record name: ${draft.groupName}',
                            'Type: ${draft.animalType}',
                            if (draft.trackingMode ==
                                _AnimalTrackingMode.individual)
                              'Animals to create: ${_resolvedAnimalNames(draft).length}',
                            if (draft.trackingMode ==
                                    _AnimalTrackingMode.individual &&
                                _resolvedAnimalNames(draft).isNotEmpty)
                              'Names: ${_resolvedAnimalNames(draft).take(4).join(', ')}${_resolvedAnimalNames(draft).length > 4 ? '…' : ''}',
                            'Feeds: ${draft.starterMaterials.join(', ')}',
                          ],
                          onEdit: () => _editAnimal(draft),
                          onRemove: () => _removeAnimalDraft(draft),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Crops You Grow',
              subtitle:
                  'Use the presets for speed, then set whether a crop is planned or already planted and capture real acreage.',
              action: OutlinedButton.icon(
                onPressed: _addCustomCrop,
                icon: const Icon(Icons.add),
                label: const Text('Add Custom Crop'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _cropPresets
                        .map(
                          (preset) => _SelectableChipCard(
                            title: preset.title,
                            subtitle: preset.subtitle,
                            selected: _selectedCrops.contains(preset),
                            onTap: () => _toggleCrop(preset),
                          ),
                        )
                        .toList(),
                  ),
                  if (_allCropDrafts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ..._allCropDrafts.map(
                      (draft) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SetupDraftCard(
                          icon: Icons.agriculture,
                          title: draft.title,
                          subtitle:
                              '${draft.mode.label} • ${draft.area.toStringAsFixed(draft.area == draft.area.roundToDouble() ? 0 : 1)} acres • ${draft.daysToHarvest} day cycle',
                          badges: [
                            if (draft.varietyHint.trim().isNotEmpty)
                              draft.varietyHint.trim(),
                            if (draft.imagePath != null) 'Photo added',
                          ],
                          details: [
                            'Workflow status: ${draft.mode.label}',
                            'Expected harvest window: ${draft.daysToHarvest} days',
                            'Inputs: ${draft.starterMaterials.join(', ')}',
                          ],
                          onEdit: () => _editCrop(draft),
                          onRemove: () => _removeCropDraft(draft),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_allAnimalDrafts.isNotEmpty)
              _SectionCard(
                title: 'How This Farm Measures Feed',
                subtitle:
                    'Use standard units if the farmer measures by kg/liters. Use everyday items if they measure by buckets, sufurias, scoops, cups, or similar farm language.',
                child: _InlineChoiceBar<_FeedMeasurementStyle>(
                  value: _feedMeasurementStyle,
                  options: _FeedMeasurementStyle.values,
                  labelBuilder: (value) => value.label,
                  onChanged: (value) {
                    setState(() {
                      _feedMeasurementStyle = value;
                      _refreshMaterialUnitsForFeedStyle();
                      _syncRecommendedMaterials();
                    });
                  },
                ),
              ),
            if (_allAnimalDrafts.isNotEmpty) const SizedBox(height: 16),
            _SectionCard(
              title: 'Feed, Inputs, and Materials',
              subtitle:
                  'The system suggests likely materials, but you can edit units, quantities, and availability or add your own items.',
              action: OutlinedButton.icon(
                onPressed: _addCustomMaterial,
                icon: const Icon(Icons.add),
                label: const Text('Add Custom Material'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _materialPresets
                        .map(
                          (material) => _SelectableChipCard(
                            title: material.name,
                            subtitle:
                                '${material.category} • ${_seedUnitForMaterial(material)}',
                            selected: _selectedMaterials.contains(material),
                            onTap: () => _toggleMaterial(material),
                          ),
                        )
                        .toList(),
                  ),
                  if (_allMaterialDrafts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ..._allMaterialDrafts.map(
                      (draft) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SetupDraftCard(
                          icon: Icons.inventory,
                          title: draft.name,
                          subtitle:
                              '${draft.category} • ${draft.unit} • ${draft.availability.label}',
                          badges: [
                            if (draft.quantity > 0)
                              'Qty ${_formatQuantity(draft.quantity)} ${draft.unit}',
                            'Min stock ${_formatQuantity(draft.minStock.toDouble())}',
                          ],
                          details: [
                            if (draft.availability ==
                                _MaterialAvailability.availableNow)
                              'Available now: ${_formatQuantity(draft.quantity)} ${draft.unit}',
                            if (draft.availability ==
                                _MaterialAvailability.needSoon)
                              'Will seed as sourcing task',
                          ],
                          onEdit: () => _editMaterial(draft),
                          onRemove: () => _removeMaterialDraft(draft),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'What This Setup Will Create',
              subtitle:
                  'The app uses this profile to seed a usable farm workspace, not a blank database.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryLine(
                    label: 'Animal records to create',
                    value: '${_animalRecordCount()}',
                  ),
                  _SummaryLine(
                    label: 'Individually tracked animals',
                    value:
                        '${_allAnimalDrafts.where((draft) => draft.trackingMode == _AnimalTrackingMode.individual).fold<int>(0, (sum, draft) => sum + _resolvedAnimalNames(draft).length)}',
                  ),
                  _SummaryLine(
                    label: 'Crop records',
                    value: '${_allCropDrafts.length}',
                  ),
                  _SummaryLine(
                    label: 'Total crop area',
                    value:
                        '${_formatQuantity(_allCropDrafts.fold<double>(0, (sum, item) => sum + item.area))} acres',
                  ),
                  _SummaryLine(
                    label: 'Inventory items',
                    value: '${_allMaterialDrafts.length}',
                  ),
                  _SummaryLine(
                    label: 'Available on hand now',
                    value:
                        '${_allMaterialDrafts.where((item) => item.availability == _MaterialAvailability.availableNow).length}',
                  ),
                  _SummaryLine(
                    label: 'Source soon tasks',
                    value:
                        '${_allMaterialDrafts.where((item) => item.availability == _MaterialAvailability.needSoon).length}',
                  ),
                  _SummaryLine(
                    label: 'Feed measurement style',
                    value: _feedMeasurementStyle.label,
                  ),
                  _SummaryLine(
                    label: 'Starter operational tasks',
                    value: '${_estimatedTaskCount()}',
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
        _animalDrafts.remove(preset);
      } else {
        _selectedAnimals.add(preset);
        _animalDrafts[preset] =
            _animalDrafts[preset] ?? _AnimalSetupDraft.fromPreset(preset);
      }
      _syncRecommendedMaterials();
    });
  }

  void _toggleCrop(_CropPreset preset) {
    setState(() {
      if (_selectedCrops.remove(preset)) {
        _cropDrafts.remove(preset);
      } else {
        _selectedCrops.add(preset);
        _cropDrafts[preset] =
            _cropDrafts[preset] ?? _CropSetupDraft.fromPreset(preset);
      }
      _syncRecommendedMaterials();
    });
  }

  void _toggleMaterial(_MaterialPreset material) {
    setState(() {
      if (_selectedMaterials.remove(material)) {
        _materialDrafts.remove(material);
      } else {
        _selectedMaterials.add(material);
        _materialDrafts[material] = _materialDrafts[material] ??
            _MaterialSetupDraft.fromPreset(
              material,
              defaultUnit: _seedUnitForMaterial(material),
            );
      }
    });
  }

  void _syncRecommendedMaterials() {
    final recommended = <String>{
      for (final animal in _allAnimalDrafts) ...animal.starterMaterials,
      for (final crop in _allCropDrafts) ...crop.starterMaterials,
    };
    for (final material in _materialPresets) {
      if (!recommended.contains(material.name) ||
          _selectedMaterials.contains(material)) {
        continue;
      }
      _selectedMaterials.add(material);
      _materialDrafts[material] = _MaterialSetupDraft.fromPreset(
        material,
        defaultUnit: _seedUnitForMaterial(material),
      );
    }
  }

  void _refreshMaterialUnitsForFeedStyle() {
    for (final entry in _materialDrafts.entries.toList()) {
      final draft = entry.value;
      if (draft.category != 'Animal Feed') continue;
      _materialDrafts[entry.key] = draft.copyWith(
        unit: _seedUnitForMaterial(entry.key),
      );
    }
    for (var i = 0; i < _customMaterialDrafts.length; i++) {
      final draft = _customMaterialDrafts[i];
      if (draft.category != 'Animal Feed' || !draft.useSuggestedUnit) continue;
      _customMaterialDrafts[i] = draft.copyWith(
        unit: _seedUnitForCustomMaterialName(draft.name),
      );
    }
  }

  Future<void> _addCustomAnimal() async {
    final created = await _showAnimalEditor(
      _AnimalSetupDraft.custom(),
      isNew: true,
    );
    if (created == null) return;
    setState(() {
      _customAnimalDrafts.add(created);
      _syncRecommendedMaterials();
    });
  }

  Future<void> _editAnimal(_AnimalSetupDraft draft) async {
    final updated = await _showAnimalEditor(draft);
    if (updated == null) return;
    setState(() {
      if (draft.isCustom) {
        final index = _customAnimalDrafts.indexOf(draft);
        if (index >= 0) _customAnimalDrafts[index] = updated;
      } else {
        final preset =
            _animalPresets.firstWhere((item) => item.title == draft.title);
        _animalDrafts[preset] = updated;
      }
      _syncRecommendedMaterials();
    });
  }

  void _removeAnimalDraft(_AnimalSetupDraft draft) {
    setState(() {
      if (draft.isCustom) {
        _customAnimalDrafts.remove(draft);
      } else {
        final preset =
            _animalPresets.firstWhere((item) => item.title == draft.title);
        _selectedAnimals.remove(preset);
        _animalDrafts.remove(preset);
      }
    });
  }

  Future<void> _addCustomCrop() async {
    final created =
        await _showCropEditor(_CropSetupDraft.custom(), isNew: true);
    if (created == null) return;
    setState(() {
      _customCropDrafts.add(created);
      _syncRecommendedMaterials();
    });
  }

  Future<void> _editCrop(_CropSetupDraft draft) async {
    final updated = await _showCropEditor(draft);
    if (updated == null) return;
    setState(() {
      if (draft.isCustom) {
        final index = _customCropDrafts.indexOf(draft);
        if (index >= 0) _customCropDrafts[index] = updated;
      } else {
        final preset =
            _cropPresets.firstWhere((item) => item.title == draft.title);
        _cropDrafts[preset] = updated;
      }
      _syncRecommendedMaterials();
    });
  }

  void _removeCropDraft(_CropSetupDraft draft) {
    setState(() {
      if (draft.isCustom) {
        _customCropDrafts.remove(draft);
      } else {
        final preset =
            _cropPresets.firstWhere((item) => item.title == draft.title);
        _selectedCrops.remove(preset);
        _cropDrafts.remove(preset);
      }
    });
  }

  Future<void> _addCustomMaterial() async {
    final created = await _showMaterialEditor(
      _MaterialSetupDraft.custom(
        defaultUnit: _seedUnitForCustomMaterialName('Custom Feed'),
      ),
      isNew: true,
    );
    if (created == null) return;
    setState(() {
      _customMaterialDrafts.add(created);
    });
  }

  Future<void> _editMaterial(_MaterialSetupDraft draft) async {
    final updated = await _showMaterialEditor(draft);
    if (updated == null) return;
    setState(() {
      if (draft.isCustom) {
        final index = _customMaterialDrafts.indexOf(draft);
        if (index >= 0) _customMaterialDrafts[index] = updated;
      } else {
        final preset =
            _materialPresets.firstWhere((item) => item.name == draft.name);
        _materialDrafts[preset] = updated;
      }
    });
  }

  void _removeMaterialDraft(_MaterialSetupDraft draft) {
    setState(() {
      if (draft.isCustom) {
        _customMaterialDrafts.remove(draft);
      } else {
        final preset =
            _materialPresets.firstWhere((item) => item.name == draft.name);
        _selectedMaterials.remove(preset);
        _materialDrafts.remove(preset);
      }
    });
  }

  Future<_AnimalSetupDraft?> _showAnimalEditor(
    _AnimalSetupDraft source, {
    bool isNew = false,
  }) async {
    final titleController = TextEditingController(text: source.title);
    final typeController = TextEditingController(text: source.animalType);
    final breedController = TextEditingController(text: source.breedHint);
    final groupNameController = TextEditingController(text: source.groupName);
    final countController =
        TextEditingController(text: source.count.toString());
    final namesController =
        TextEditingController(text: source.individualNames.join(', '));
    var scale = source.scale;
    var trackingMode = source.trackingMode;
    var autoGenerateNames = source.autoGenerateNames;
    var imagePath = source.imagePath;

    final result = await showModalBottomSheet<_AnimalSetupDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final canTrackIndividually = source.supportsIndividualTracking ||
                !_isFlockType(typeController.text);
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isNew ? 'Add Animal Setup' : 'Edit Animal Setup',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Display title',
                          hintText: 'Dairy Cows, Sheep, Rabbits...',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: typeController,
                              decoration: const InputDecoration(
                                labelText: 'Animal type',
                                hintText: 'cow, goat, chicken, pig...',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: countController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Count',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: breedController,
                        decoration: const InputDecoration(
                          labelText: 'Breed or strain',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: groupNameController,
                        decoration: const InputDecoration(
                          labelText: 'Group name or default animal name',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Farm scale',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _InlineChoiceBar<_FarmScale>(
                        value: scale,
                        options: _FarmScale.values,
                        labelBuilder: (value) => value.label,
                        onChanged: (value) {
                          setModalState(() => scale = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tracking mode',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _InlineChoiceBar<_AnimalTrackingMode>(
                        value: trackingMode,
                        options: canTrackIndividually
                            ? _AnimalTrackingMode.values
                            : const [_AnimalTrackingMode.group],
                        labelBuilder: (value) => value.label,
                        onChanged: (value) {
                          setModalState(() => trackingMode = value);
                        },
                      ),
                      if (trackingMode == _AnimalTrackingMode.individual) ...[
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          value: autoGenerateNames,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Auto-name missing animals'),
                          subtitle: const Text(
                            'If you do not type every name, the app will generate the remaining names.',
                          ),
                          onChanged: (value) {
                            setModalState(() => autoGenerateNames = value);
                          },
                        ),
                        TextField(
                          controller: namesController,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Animal names',
                            hintText:
                                'Type names separated by commas or new lines.',
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final selected = await _pickSetupImage();
                                if (selected == null) return;
                                setModalState(() => imagePath = selected);
                              },
                              icon:
                                  const Icon(Icons.photo_camera_back_outlined),
                              label: Text(
                                imagePath == null
                                    ? 'Add Photo'
                                    : 'Change Photo',
                              ),
                            ),
                          ),
                          if (imagePath != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setModalState(() => imagePath = null);
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ],
                      ),
                      if (imagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            imagePath!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                final count =
                                    int.tryParse(countController.text.trim()) ??
                                        source.count;
                                final animalType =
                                    _normalizeAnimalType(typeController.text);
                                Navigator.of(context).pop(
                                  source.copyWith(
                                    title: titleController.text.trim().isEmpty
                                        ? source.title
                                        : titleController.text.trim(),
                                    animalType: animalType,
                                    breedHint: breedController.text.trim(),
                                    groupName: groupNameController.text
                                            .trim()
                                            .isEmpty
                                        ? titleController.text.trim().isEmpty
                                            ? source.groupName
                                            : titleController.text.trim()
                                        : groupNameController.text.trim(),
                                    count: count <= 0 ? 1 : count,
                                    scale: scale,
                                    trackingMode: canTrackIndividually
                                        ? trackingMode
                                        : _AnimalTrackingMode.group,
                                    autoGenerateNames: autoGenerateNames,
                                    individualNames: _splitNames(
                                      namesController.text,
                                    ),
                                    imagePath: imagePath,
                                    clearImagePath: imagePath == null,
                                    supportsIndividualTracking:
                                        canTrackIndividually,
                                  ),
                                );
                              },
                              child: const Text('Save Animal Setup'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    typeController.dispose();
    breedController.dispose();
    groupNameController.dispose();
    countController.dispose();
    namesController.dispose();
    return result;
  }

  Future<_CropSetupDraft?> _showCropEditor(
    _CropSetupDraft source, {
    bool isNew = false,
  }) async {
    final titleController = TextEditingController(text: source.title);
    final varietyController = TextEditingController(text: source.varietyHint);
    final areaController =
        TextEditingController(text: _formatQuantity(source.area));
    final harvestDaysController =
        TextEditingController(text: source.daysToHarvest.toString());
    var mode = source.mode;
    var imagePath = source.imagePath;

    final result = await showModalBottomSheet<_CropSetupDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isNew ? 'Add Crop Setup' : 'Edit Crop Setup',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: titleController,
                        decoration:
                            const InputDecoration(labelText: 'Crop name'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: varietyController,
                              decoration: const InputDecoration(
                                labelText: 'Variety or type',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: areaController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Area (acres)',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: harvestDaysController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Days to harvest',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Crop status',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      _InlineChoiceBar<_CropSetupMode>(
                        value: mode,
                        options: _CropSetupMode.values,
                        labelBuilder: (value) => value.label,
                        onChanged: (value) {
                          setModalState(() => mode = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final selected = await _pickSetupImage();
                                if (selected == null) return;
                                setModalState(() => imagePath = selected);
                              },
                              icon: const Icon(Icons.photo_library_outlined),
                              label: Text(
                                imagePath == null
                                    ? 'Add Photo'
                                    : 'Change Photo',
                              ),
                            ),
                          ),
                          if (imagePath != null) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () {
                                setModalState(() => imagePath = null);
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(
                                  source.copyWith(
                                    title: titleController.text.trim().isEmpty
                                        ? source.title
                                        : titleController.text.trim(),
                                    varietyHint: varietyController.text.trim(),
                                    area: (double.tryParse(
                                                areaController.text.trim()) ??
                                            source.area)
                                        .clamp(0.1, 1000000),
                                    daysToHarvest: (int.tryParse(
                                                harvestDaysController.text
                                                    .trim()) ??
                                            source.daysToHarvest)
                                        .clamp(1, 1000),
                                    mode: mode,
                                    imagePath: imagePath,
                                    clearImagePath: imagePath == null,
                                  ),
                                );
                              },
                              child: const Text('Save Crop Setup'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    varietyController.dispose();
    areaController.dispose();
    harvestDaysController.dispose();
    return result;
  }

  Future<_MaterialSetupDraft?> _showMaterialEditor(
    _MaterialSetupDraft source, {
    bool isNew = false,
  }) async {
    final nameController = TextEditingController(text: source.name);
    final categoryController = TextEditingController(text: source.category);
    final unitController = TextEditingController(text: source.unit);
    final quantityController =
        TextEditingController(text: _formatQuantity(source.quantity));
    final minStockController = TextEditingController(
        text: _formatQuantity(source.minStock.toDouble()));
    var availability = source.availability;
    var useSuggestedUnit = source.useSuggestedUnit;

    final result = await showModalBottomSheet<_MaterialSetupDraft>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isNew ? 'Add Material' : 'Edit Material',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration:
                            const InputDecoration(labelText: 'Material name'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: categoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: unitController,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _InlineChoiceBar<_MaterialAvailability>(
                        value: availability,
                        options: _MaterialAvailability.values,
                        labelBuilder: (value) => value.label,
                        onChanged: (value) {
                          setModalState(() => availability = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        value: useSuggestedUnit,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Let the app suggest the unit'),
                        subtitle: const Text(
                          'Helpful when using the same feed measurement style across the farm.',
                        ),
                        onChanged: (value) {
                          setModalState(() {
                            useSuggestedUnit = value;
                            if (value &&
                                categoryController.text.trim() ==
                                    'Animal Feed') {
                              unitController.text =
                                  _seedUnitForCustomMaterialName(
                                nameController.text.trim(),
                              );
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: quantityController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Quantity on hand',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: minStockController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Minimum stock',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                final category =
                                    categoryController.text.trim().isEmpty
                                        ? source.category
                                        : categoryController.text.trim();
                                final name = nameController.text.trim().isEmpty
                                    ? source.name
                                    : nameController.text.trim();
                                final unit = useSuggestedUnit &&
                                        category == 'Animal Feed'
                                    ? _seedUnitForCustomMaterialName(name)
                                    : (unitController.text.trim().isEmpty
                                        ? source.unit
                                        : unitController.text.trim());
                                Navigator.of(context).pop(
                                  source.copyWith(
                                    name: name,
                                    category: category,
                                    unit: unit,
                                    availability: availability,
                                    quantity: (double.tryParse(
                                                quantityController.text
                                                    .trim()) ??
                                            source.quantity)
                                        .clamp(0, 1000000),
                                    minStock: (double.tryParse(
                                                minStockController.text
                                                    .trim()) ??
                                            source.minStock.toDouble())
                                        .clamp(0, 1000000)
                                        .round(),
                                    useSuggestedUnit: useSuggestedUnit,
                                  ),
                                );
                              },
                              child: const Text('Save Material'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    categoryController.dispose();
    unitController.dispose();
    quantityController.dispose();
    minStockController.dispose();
    return result;
  }

  Future<String?> _pickSetupImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    return picked?.path;
  }

  Future<void> _skipMinimalSetup() async {
    await FarmSetupService().markSetupComplete(widget.userId);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  Future<void> _applySetup() async {
    setState(() => _saving = true);
    try {
      for (final draft in _allAnimalDrafts) {
        final createdAnimalIds = <int>[];
        final resolvedNames = _resolvedAnimalNames(draft);
        final shouldCreateIndividualRecords =
            draft.trackingMode == _AnimalTrackingMode.individual &&
                resolvedNames.isNotEmpty;

        if (shouldCreateIndividualRecords) {
          for (var i = 0; i < resolvedNames.length; i++) {
            final createdAnimal = await getIt<AddAnimal>().execute(
              AnimalEntity(
                name: AnimalName(resolvedNames[i]),
                type: AnimalType(draft.animalType),
                breed: draft.breedHint.trim().isEmpty ? null : draft.breedHint,
                notes: _composeAnimalSetupNotes(
                  draft,
                  isIndividual: true,
                  animalIndex: i + 1,
                  animalName: resolvedNames[i],
                ),
              ),
            );
            final animalId = int.tryParse(createdAnimal.id ?? '');
            if (animalId != null) {
              createdAnimalIds.add(animalId);
            }
          }
        } else {
          final createdAnimal = await getIt<AddAnimal>().execute(
            AnimalEntity(
              name: AnimalName(draft.groupName),
              type: AnimalType(draft.animalType),
              breed: draft.breedHint.trim().isEmpty ? null : draft.breedHint,
              notes: _composeAnimalSetupNotes(draft, isIndividual: false),
            ),
          );
          final animalId = int.tryParse(createdAnimal.id ?? '');
          if (animalId != null) {
            createdAnimalIds.add(animalId);
          }
        }

        final sourceId = createdAnimalIds.isNotEmpty
            ? createdAnimalIds.first.toString()
            : _slugify(draft.title);

        for (final animalId in createdAnimalIds) {
          for (final schedule in _feedingTemplatesFor(
            animalId: animalId,
            draft: draft,
          )) {
            await getIt<AddFeedingSchedule>().execute(schedule);
          }
        }

        await getIt<AddTask>().execute(
          TaskEntity(
            title: TaskTitle('Set feeding plan for ${draft.title}'),
            description:
                'Confirm feed routine, expected output, and care schedule for ${draft.title.toLowerCase()}.',
            dueDate: DateTime.now().add(const Duration(days: 2)),
            sourceEventType: 'setup',
            sourceEventId: sourceId,
          ),
        );
        await getIt<AddTask>().execute(
          TaskEntity(
            title: TaskTitle('Validate opening count for ${draft.title}'),
            description:
                'Confirm the opening count, tracking mode, and operational purpose for ${draft.title.toLowerCase()} so automations use the right assumptions.',
            dueDate: DateTime.now().add(const Duration(days: 1)),
            sourceEventType: 'setup',
            sourceEventId: sourceId,
          ),
        );
        for (final task in _productionChecklistFor(draft, sourceId: sourceId)) {
          await getIt<AddTask>().execute(task);
        }
      }

      for (final draft in _allCropDrafts) {
        final plantedAt = draft.mode == _CropSetupMode.planted
            ? DateTime.now().subtract(
                Duration(days: (draft.daysToHarvest * 0.35).round()),
              )
            : DateTime.now();
        final createdCrop = await getIt<AddCrop>().execute(
          CropEntity(
            name: CropName(draft.title),
            variety:
                draft.varietyHint.trim().isEmpty ? null : draft.varietyHint,
            plantedAt: plantedAt,
            expectedHarvest: plantedAt.add(Duration(days: draft.daysToHarvest)),
            area: draft.area,
            status:
                draft.mode == _CropSetupMode.planted ? 'Growing' : 'Planned',
            notes: _composeCropSetupNotes(draft),
          ),
        );
        final sourceId = createdCrop.id ?? _slugify(draft.title);

        await getIt<AddTask>().execute(
          TaskEntity(
            title: TaskTitle(draft.mode == _CropSetupMode.planted
                ? 'Review current ${draft.title} field'
                : 'Review ${draft.title} planting plan'),
            description: draft.mode == _CropSetupMode.planted
                ? 'Confirm current growth stage, recent inputs, and next field action for ${draft.title.toLowerCase()}.'
                : 'Confirm acreage, inputs, and first field tasks for ${draft.title.toLowerCase()}.',
            dueDate: DateTime.now().add(const Duration(days: 3)),
            sourceEventType: 'setup',
            sourceEventId: sourceId,
          ),
        );
        for (final task in _cropChecklistFor(draft, sourceId: sourceId)) {
          await getIt<AddTask>().execute(task);
        }
      }

      for (final draft in _allMaterialDrafts) {
        final minStock = _recommendedMinStockForDraft(draft);
        final onHandQuantity =
            draft.availability == _MaterialAvailability.availableNow
                ? (draft.quantity > 0 ? draft.quantity : minStock * 1.5)
                : 0.0;
        await getIt<InventoryRepository>().addItem(
          InventoryItem(
            itemName: draft.name,
            category: draft.category,
            quantity: onHandQuantity,
            unit: draft.unit,
            minStock: minStock,
            supplier: null,
            unitPrice: null,
            totalValue: null,
            isSynced: false,
          ),
        );
        if (draft.availability == _MaterialAvailability.needSoon) {
          await getIt<AddTask>().execute(
            TaskEntity(
              title: TaskTitle('Source ${draft.name}'),
              description:
                  'Add or buy ${draft.name.toLowerCase()} so ${draft.category.toLowerCase()} workflows start without delays.',
              dueDate: DateTime.now().add(
                Duration(days: draft.category == 'Animal Feed' ? 2 : 5),
              ),
              sourceEventType: 'setup',
              sourceEventId: 'material_${_slugify(draft.name)}',
            ),
          );
        }
      }

      await FarmSetupService().markSetupComplete(widget.userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Farm workspace created. You can refine records, photos, and operations later.',
          ),
        ),
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  int _animalRecordCount() {
    return _allAnimalDrafts.fold<int>(
      0,
      (sum, draft) =>
          sum +
          (draft.trackingMode == _AnimalTrackingMode.individual
              ? _resolvedAnimalNames(draft).length
              : 1),
    );
  }

  int _recommendedMinStockForDraft(_MaterialSetupDraft material) {
    var score = material.minStock > 0 ? material.minStock : 1;

    for (final draft in _allAnimalDrafts) {
      if (draft.starterMaterials.contains(material.name)) {
        score += draft.scale.weight + _countWeight(draft.count);
      }
    }

    for (final draft in _allCropDrafts) {
      if (draft.starterMaterials.contains(material.name)) {
        score += draft.mode == _CropSetupMode.planted ? 3 : 1;
      }
    }

    return score.clamp(1, 9999);
  }

  int _estimatedTaskCount() {
    final materialTasks = _allMaterialDrafts
        .where((item) => item.availability == _MaterialAvailability.needSoon)
        .length;
    final cropTasks = _allCropDrafts.fold<int>(
      0,
      (count, draft) =>
          count +
          1 +
          _cropChecklistFor(draft, sourceId: 'preview_${_slugify(draft.title)}')
              .length,
    );
    final animalTasks = _allAnimalDrafts.fold<int>(
      0,
      (count, draft) =>
          count +
          2 +
          _productionChecklistFor(draft,
                  sourceId: 'preview_${_slugify(draft.title)}')
              .length,
    );
    return materialTasks + cropTasks + animalTasks;
  }

  List<FeedingScheduleEntity> _feedingTemplatesFor({
    required int animalId,
    required _AnimalSetupDraft draft,
  }) {
    final primaryFeed = draft.starterMaterials.isNotEmpty
        ? draft.starterMaterials.first
        : 'Feed Mix';
    final secondaryFeed = draft.starterMaterials.length > 1
        ? draft.starterMaterials[1]
        : primaryFeed;
    final primaryUnit = _seedUnitForFeedName(primaryFeed);
    final secondaryUnit = _seedUnitForFeedName(secondaryFeed);
    final morningQuantity = _feedingQuantityForUnit(
      animalType: draft.animalType,
      scale: draft.scale,
      unit: primaryUnit,
      count: draft.count,
      isPrimary: true,
    );
    final eveningQuantity = _feedingQuantityForUnit(
      animalType: draft.animalType,
      scale: draft.scale,
      unit: secondaryUnit,
      count: draft.count,
      isPrimary: false,
    );

    return [
      FeedingScheduleEntity(
        animalId: animalId,
        feedType: primaryFeed,
        quantity: morningQuantity,
        unit: primaryUnit,
        timeOfDay: 'Morning',
        frequency: 'Daily',
        startDate: DateTime.now(),
        notes: _composeSetupFeedingNotes(
          rationLabel: _defaultRationLabel(
            quantity: morningQuantity,
            unit: primaryUnit,
            timeOfDay: 'Morning',
          ),
        ),
      ),
      FeedingScheduleEntity(
        animalId: animalId,
        feedType: secondaryFeed,
        quantity: eveningQuantity,
        unit: secondaryUnit,
        timeOfDay: 'Evening',
        frequency: 'Daily',
        startDate: DateTime.now(),
        notes: _composeSetupFeedingNotes(
          rationLabel: _defaultRationLabel(
            quantity: eveningQuantity,
            unit: secondaryUnit,
            timeOfDay: 'Evening',
          ),
        ),
      ),
    ];
  }

  String _composeSetupFeedingNotes({required String rationLabel}) {
    return '$_rationLabelPrefix$rationLabel\n'
        'Auto-created from farm setup (${_feedMeasurementStyle.label.toLowerCase()}).';
  }

  String _composeAnimalSetupNotes(
    _AnimalSetupDraft draft, {
    required bool isIndividual,
    int? animalIndex,
    String? animalName,
  }) {
    return 'Seeded from onboarding setup.\n'
        'setup_meta:${jsonEncode({
          'profile_title': draft.title,
          'group_name': draft.groupName,
          'animal_type': draft.animalType,
          'breed': draft.breedHint,
          'count': draft.count,
          'scale': draft.scale.label,
          'tracking_mode': draft.trackingMode.name,
          'feed_measurement_style': _feedMeasurementStyle.label,
          'starter_materials': draft.starterMaterials,
          if (draft.imagePath != null) 'image_path': draft.imagePath,
          if (isIndividual) 'individual_name': animalName,
          if (isIndividual) 'animal_index': animalIndex,
        })}';
  }

  String _composeCropSetupNotes(_CropSetupDraft draft) {
    return 'Seeded from onboarding setup.\n'
        'setup_meta:${jsonEncode({
          'crop': draft.title,
          'variety': draft.varietyHint,
          'area_acres': draft.area,
          'mode': draft.mode.label,
          'days_to_harvest': draft.daysToHarvest,
          'starter_materials': draft.starterMaterials,
          if (draft.imagePath != null) 'image_path': draft.imagePath,
        })}';
  }

  String _defaultRationLabel({
    required double quantity,
    required String unit,
    required String timeOfDay,
  }) {
    final quantityText = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '$quantityText $timeOfDay ${_singularizeUnit(unit)}';
  }

  String _singularizeUnit(String unit) {
    switch (unit.toLowerCase()) {
      case 'buckets':
        return 'bucket';
      case 'sufurias':
        return 'sufuria';
      case 'plates':
        return 'plate';
      case 'cups':
        return 'cup';
      case 'tins':
        return 'tin';
      case 'scoops':
        return 'scoop';
      case 'bundles':
        return 'bundle';
      default:
        return unit;
    }
  }

  String _seedUnitForMaterial(_MaterialPreset material) {
    if (material.category != 'Animal Feed') return material.unit;
    return _seedUnitForFeedName(material.name);
  }

  String _seedUnitForCustomMaterialName(String materialName) {
    return _seedUnitForFeedName(materialName);
  }

  String _seedUnitForFeedName(String materialName) {
    if (_feedMeasurementStyle == _FeedMeasurementStyle.standard) {
      final preset = _materialPresets
          .where((item) => item.name == materialName)
          .cast<_MaterialPreset?>()
          .firstWhere((item) => item != null, orElse: () => null);
      return preset?.unit ?? 'kg';
    }

    final lower = materialName.toLowerCase();
    if (lower.contains('water')) return 'buckets';
    if (lower.contains('napier') ||
        lower.contains('hay') ||
        lower.contains('silage') ||
        lower.contains('browse')) {
      return 'buckets';
    }
    if (lower.contains('lick')) return 'pieces';
    if (lower.contains('meal') ||
        lower.contains('mash') ||
        lower.contains('starter') ||
        lower.contains('finisher') ||
        lower.contains('bran') ||
        lower.contains('grower') ||
        lower.contains('mix')) {
      return 'scoops';
    }
    return 'buckets';
  }

  double _feedingQuantityForUnit({
    required String animalType,
    required _FarmScale scale,
    required String unit,
    required int count,
    required bool isPrimary,
  }) {
    final standardBase = switch (animalType) {
      'cow' => 8.0,
      'goat' => 2.0,
      'chicken' => 0.12,
      'pig' => 1.8,
      _ => 1.0,
    };
    final standardMultiplier = switch (scale) {
      _FarmScale.small => 1.0,
      _FarmScale.medium => 2.5,
      _FarmScale.large => 4.0,
    };
    final countMultiplier = 1 + (_countWeight(count) * 0.45);
    if (_feedMeasurementStyle == _FeedMeasurementStyle.standard) {
      final value = standardBase *
          standardMultiplier *
          countMultiplier *
          (isPrimary ? 1.0 : 0.7);
      return double.parse(value.toStringAsFixed(2));
    }

    final householdBase = switch (animalType) {
      'cow' => unit == 'scoops' ? 3.0 : 2.0,
      'goat' => unit == 'scoops' ? 2.0 : 1.0,
      'chicken' => unit == 'scoops' ? 2.0 : 1.0,
      'pig' => unit == 'scoops' ? 3.0 : 1.5,
      _ => 1.0,
    };
    final householdMultiplier = switch (scale) {
      _FarmScale.small => 1.0,
      _FarmScale.medium => 1.8,
      _FarmScale.large => 2.8,
    };
    final value = householdBase *
        householdMultiplier *
        countMultiplier *
        (isPrimary ? 1.0 : 0.7);
    return double.parse(value.toStringAsFixed(1));
  }

  List<String> _resolvedAnimalNames(_AnimalSetupDraft draft) {
    final count = draft.count <= 0 ? 1 : draft.count;
    if (draft.trackingMode != _AnimalTrackingMode.individual) {
      return const [];
    }
    final names = [...draft.individualNames];
    if (names.length < count) {
      final shouldGenerate = draft.autoGenerateNames || names.isEmpty;
      if (shouldGenerate) {
        final base =
            draft.groupName.trim().isEmpty ? draft.title : draft.groupName;
        for (var i = names.length; i < count; i++) {
          names.add('${_singularNameBase(base)} ${i + 1}');
        }
      }
    }
    return names.take(count).toList();
  }

  List<String> _splitNames(String raw) {
    return raw
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _singularNameBase(String value) {
    final trimmed = value.trim();
    if (trimmed.endsWith(' Group')) {
      return trimmed.replaceFirst(RegExp(r' Group$'), '');
    }
    if (trimmed.endsWith(' Flock')) {
      return trimmed.replaceFirst(RegExp(r' Flock$'), '');
    }
    if (trimmed.endsWith(' Unit')) {
      return trimmed.replaceFirst(RegExp(r' Unit$'), '');
    }
    return trimmed;
  }

  String _normalizeAnimalType(String input) {
    final value = input.trim().toLowerCase();
    if (value.contains('cow') ||
        value.contains('cattle') ||
        value.contains('dairy')) {
      return 'cow';
    }
    if (value.contains('chicken') ||
        value.contains('poultry') ||
        value.contains('layer') ||
        value.contains('broiler')) {
      return 'chicken';
    }
    if (value.contains('goat')) return 'goat';
    if (value.contains('pig')) return 'pig';
    return value.isEmpty ? 'other' : value;
  }

  bool _isFlockType(String input) {
    final normalized = _normalizeAnimalType(input);
    return normalized == 'chicken';
  }

  int _countWeight(int count) {
    if (count <= 3) return 1;
    if (count <= 10) return 2;
    if (count <= 25) return 3;
    if (count <= 60) return 4;
    return 5;
  }

  String _formatQuantity(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }

  String _slugify(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  List<TaskEntity> _cropChecklistFor(
    _CropSetupDraft draft, {
    required String sourceId,
  }) {
    final cropName = draft.title;
    if (draft.mode == _CropSetupMode.planted) {
      return [
        TaskEntity(
          title: TaskTitle('7-day $cropName field check'),
          description:
              'Review moisture, pests, and nutrient needs for current $cropName crop.',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          sourceEventType: 'setup',
          sourceEventId: sourceId,
        ),
        TaskEntity(
          title: TaskTitle('14-day $cropName progress review'),
          description:
              'Check crop health, expected yield direction, and missing field tasks.',
          dueDate: DateTime.now().add(const Duration(days: 14)),
          sourceEventType: 'setup',
          sourceEventId: sourceId,
        ),
        TaskEntity(
          title: TaskTitle('30-day $cropName market prep'),
          description:
              'Review likely harvest path, stock handling, and buyer readiness for $cropName.',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          sourceEventType: 'setup',
          sourceEventId: sourceId,
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
        sourceEventId: sourceId,
      ),
      TaskEntity(
        title: TaskTitle('14-day $cropName planting readiness'),
        description: 'Confirm field, labor, and planting date for $cropName.',
        dueDate: DateTime.now().add(const Duration(days: 14)),
        sourceEventType: 'setup',
        sourceEventId: sourceId,
      ),
      TaskEntity(
        title: TaskTitle('30-day $cropName early growth review'),
        description:
            'Plan the first monitoring cycle and expected early-stage tasks for $cropName.',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        sourceEventType: 'setup',
        sourceEventId: sourceId,
      ),
    ];
  }

  List<TaskEntity> _productionChecklistFor(
    _AnimalSetupDraft draft, {
    required String sourceId,
  }) {
    final lowerTitle = draft.title.toLowerCase();

    if (lowerTitle.contains('dairy') || lowerTitle.contains('layer')) {
      return [
        TaskEntity(
          title: TaskTitle('7-day ${draft.title} production review'),
          description:
              'Check output trend, feed usage, and recording consistency for ${draft.title.toLowerCase()}.',
          dueDate: DateTime.now().add(const Duration(days: 7)),
          sourceEventType: 'setup',
          sourceEventId: sourceId,
        ),
        TaskEntity(
          title: TaskTitle('14-day ${draft.title} feed efficiency check'),
          description:
              'Review whether ${draft.title.toLowerCase()} output matches feed cost and current ration plan.',
          dueDate: DateTime.now().add(const Duration(days: 14)),
          sourceEventType: 'setup',
          sourceEventId: sourceId,
        ),
        TaskEntity(
          title: TaskTitle('30-day ${draft.title} sales readiness review'),
          description:
              'Decide whether current ${draft.title.toLowerCase()} output should move into sales, stock, or buyer outreach.',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          sourceEventType: 'setup',
          sourceEventId: sourceId,
        ),
      ];
    }

    return [
      TaskEntity(
        title: TaskTitle('7-day ${draft.title} growth review'),
        description:
            'Check growth, health, and stocking assumptions for ${draft.title.toLowerCase()}.',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        sourceEventType: 'setup',
        sourceEventId: sourceId,
      ),
      TaskEntity(
        title: TaskTitle('14-day ${draft.title} cost check'),
        description:
            'Review feed use, medication, and labor drivers for ${draft.title.toLowerCase()}.',
        dueDate: DateTime.now().add(const Duration(days: 14)),
        sourceEventType: 'setup',
        sourceEventId: sourceId,
      ),
      TaskEntity(
        title: TaskTitle('30-day ${draft.title} market timing review'),
        description:
            'Review sale timing and expected margin for ${draft.title.toLowerCase()}.',
        dueDate: DateTime.now().add(const Duration(days: 30)),
        sourceEventType: 'setup',
        sourceEventId: sourceId,
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
  final bool supportsIndividualTracking;

  const _AnimalPreset({
    required this.title,
    required this.subtitle,
    required this.animalType,
    required this.defaultName,
    required this.breedHint,
    required this.starterMaterials,
    required this.supportsIndividualTracking,
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

class _AnimalSetupDraft {
  final String title;
  final String animalType;
  final String groupName;
  final String breedHint;
  final int count;
  final _FarmScale scale;
  final _AnimalTrackingMode trackingMode;
  final bool autoGenerateNames;
  final List<String> individualNames;
  final String? imagePath;
  final List<String> starterMaterials;
  final bool supportsIndividualTracking;
  final bool isCustom;

  const _AnimalSetupDraft({
    required this.title,
    required this.animalType,
    required this.groupName,
    required this.breedHint,
    required this.count,
    required this.scale,
    required this.trackingMode,
    required this.autoGenerateNames,
    required this.individualNames,
    required this.imagePath,
    required this.starterMaterials,
    required this.supportsIndividualTracking,
    required this.isCustom,
  });

  factory _AnimalSetupDraft.fromPreset(_AnimalPreset preset) {
    return _AnimalSetupDraft(
      title: preset.title,
      animalType: preset.animalType,
      groupName: preset.defaultName,
      breedHint: preset.breedHint,
      count: preset.supportsIndividualTracking ? 3 : 25,
      scale: _FarmScale.small,
      trackingMode: preset.supportsIndividualTracking
          ? _AnimalTrackingMode.individual
          : _AnimalTrackingMode.group,
      autoGenerateNames: true,
      individualNames: const [],
      imagePath: null,
      starterMaterials: preset.starterMaterials,
      supportsIndividualTracking: preset.supportsIndividualTracking,
      isCustom: false,
    );
  }

  factory _AnimalSetupDraft.custom() {
    return const _AnimalSetupDraft(
      title: 'Custom Animal',
      animalType: 'cow',
      groupName: 'Custom Animal Group',
      breedHint: '',
      count: 1,
      scale: _FarmScale.small,
      trackingMode: _AnimalTrackingMode.group,
      autoGenerateNames: true,
      individualNames: [],
      imagePath: null,
      starterMaterials: ['Hay'],
      supportsIndividualTracking: true,
      isCustom: true,
    );
  }

  _AnimalSetupDraft copyWith({
    String? title,
    String? animalType,
    String? groupName,
    String? breedHint,
    int? count,
    _FarmScale? scale,
    _AnimalTrackingMode? trackingMode,
    bool? autoGenerateNames,
    List<String>? individualNames,
    String? imagePath,
    bool clearImagePath = false,
    List<String>? starterMaterials,
    bool? supportsIndividualTracking,
  }) {
    return _AnimalSetupDraft(
      title: title ?? this.title,
      animalType: animalType ?? this.animalType,
      groupName: groupName ?? this.groupName,
      breedHint: breedHint ?? this.breedHint,
      count: count ?? this.count,
      scale: scale ?? this.scale,
      trackingMode: trackingMode ?? this.trackingMode,
      autoGenerateNames: autoGenerateNames ?? this.autoGenerateNames,
      individualNames: individualNames ?? this.individualNames,
      imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
      starterMaterials: starterMaterials ?? this.starterMaterials,
      supportsIndividualTracking:
          supportsIndividualTracking ?? this.supportsIndividualTracking,
      isCustom: isCustom,
    );
  }
}

class _CropSetupDraft {
  final String title;
  final String varietyHint;
  final int daysToHarvest;
  final double area;
  final _CropSetupMode mode;
  final List<String> starterMaterials;
  final String? imagePath;
  final bool isCustom;

  const _CropSetupDraft({
    required this.title,
    required this.varietyHint,
    required this.daysToHarvest,
    required this.area,
    required this.mode,
    required this.starterMaterials,
    required this.imagePath,
    required this.isCustom,
  });

  factory _CropSetupDraft.fromPreset(_CropPreset preset) {
    return _CropSetupDraft(
      title: preset.title,
      varietyHint: preset.varietyHint,
      daysToHarvest: preset.daysToHarvest,
      area: 1,
      mode: _CropSetupMode.planned,
      starterMaterials: preset.starterMaterials,
      imagePath: null,
      isCustom: false,
    );
  }

  factory _CropSetupDraft.custom() {
    return const _CropSetupDraft(
      title: 'Custom Crop',
      varietyHint: '',
      daysToHarvest: 90,
      area: 1,
      mode: _CropSetupMode.planned,
      starterMaterials: ['Fertilizer'],
      imagePath: null,
      isCustom: true,
    );
  }

  _CropSetupDraft copyWith({
    String? title,
    String? varietyHint,
    int? daysToHarvest,
    double? area,
    _CropSetupMode? mode,
    List<String>? starterMaterials,
    String? imagePath,
    bool clearImagePath = false,
  }) {
    return _CropSetupDraft(
      title: title ?? this.title,
      varietyHint: varietyHint ?? this.varietyHint,
      daysToHarvest: daysToHarvest ?? this.daysToHarvest,
      area: area ?? this.area,
      mode: mode ?? this.mode,
      starterMaterials: starterMaterials ?? this.starterMaterials,
      imagePath: clearImagePath ? null : imagePath ?? this.imagePath,
      isCustom: isCustom,
    );
  }
}

class _MaterialSetupDraft {
  final String name;
  final String category;
  final String unit;
  final _MaterialAvailability availability;
  final double quantity;
  final int minStock;
  final bool useSuggestedUnit;
  final bool isCustom;

  const _MaterialSetupDraft({
    required this.name,
    required this.category,
    required this.unit,
    required this.availability,
    required this.quantity,
    required this.minStock,
    required this.useSuggestedUnit,
    required this.isCustom,
  });

  factory _MaterialSetupDraft.fromPreset(
    _MaterialPreset preset, {
    required String defaultUnit,
  }) {
    return _MaterialSetupDraft(
      name: preset.name,
      category: preset.category,
      unit: defaultUnit,
      availability: _MaterialAvailability.needSoon,
      quantity: 0,
      minStock: 1,
      useSuggestedUnit: preset.category == 'Animal Feed',
      isCustom: false,
    );
  }

  factory _MaterialSetupDraft.custom({required String defaultUnit}) {
    return _MaterialSetupDraft(
      name: 'Custom Material',
      category: 'Animal Feed',
      unit: defaultUnit,
      availability: _MaterialAvailability.needSoon,
      quantity: 0,
      minStock: 1,
      useSuggestedUnit: true,
      isCustom: true,
    );
  }

  _MaterialSetupDraft copyWith({
    String? name,
    String? category,
    String? unit,
    _MaterialAvailability? availability,
    double? quantity,
    int? minStock,
    bool? useSuggestedUnit,
  }) {
    return _MaterialSetupDraft(
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      availability: availability ?? this.availability,
      quantity: quantity ?? this.quantity,
      minStock: minStock ?? this.minStock,
      useSuggestedUnit: useSuggestedUnit ?? this.useSuggestedUnit,
      isCustom: isCustom,
    );
  }
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

enum _FeedMeasurementStyle {
  household('Everyday items'),
  standard('Standard units');

  const _FeedMeasurementStyle(this.label);
  final String label;
}

enum _AnimalTrackingMode {
  group('Group tracking'),
  individual('Individual tracking');

  const _AnimalTrackingMode(this.label);
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
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.domain_add, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
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
              height: 1.35,
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
  final Widget? action;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (action != null) ...[
                const SizedBox(width: 12),
                action!,
              ],
            ],
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

  const _SelectableChipCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 176,
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
                  selected ? Icons.check_circle : Icons.add_circle_outline,
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
          ],
        ),
      ),
    );
  }
}

class _SetupDraftCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> badges;
  final List<String> details;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _SetupDraftCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.details,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.72),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: badges
                  .map(
                    (badge) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (details.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(Icons.circle, size: 6),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(detail)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.tune),
              label: const Text('Customize'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _StepPill({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
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
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: options
          .map(
            (option) => ChoiceChip(
              label: Text(labelBuilder(option)),
              selected: option == value,
              onSelected: (_) => onChanged(option),
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
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
