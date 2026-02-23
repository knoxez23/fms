import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/animal_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/breeding_record_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/animals/animals_bloc.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/bloc/breeding/breeding_cubit.dart';

class BreedingScheduleScreen extends StatefulWidget {
  const BreedingScheduleScreen({super.key});

  @override
  State<BreedingScheduleScreen> createState() => _BreedingScheduleScreenState();
}

class _BreedingScheduleScreenState extends State<BreedingScheduleScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) =>
                getIt<AnimalsBloc>()..add(const AnimalsEvent.load())),
        BlocProvider(create: (_) => getIt<BreedingCubit>()..load()),
      ],
      child: BlocBuilder<AnimalsBloc, AnimalsState>(
        builder: (context, animalsState) {
          return BlocConsumer<BreedingCubit, BreedingState>(
            listener: (context, breedingState) {
              final error = breedingState.error;
              if (error == null || error.isEmpty) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error)),
              );
            },
            builder: (context, breedingState) {
              final animals = animalsState.maybeWhen(
                loaded: (items) => items,
                orElse: () => <AnimalEntity>[],
              );
              final records = breedingState.records;
              final nameById = {
                for (final a in animals)
                  if (a.id != null) a.id!: a.name.value,
              };
              final typeById = {
                for (final a in animals)
                  if (a.id != null) a.id!: a.type.value,
              };

              final activePregnancies = records
                  .where((r) => r.isActivePregnancy)
                  .toList()
                ..sort((a, b) =>
                    a.expectedBirthDate.compareTo(b.expectedBirthDate));

              return AppScaffold(
                backgroundColor: theme.colorScheme.surface,
                includeDrawer: false,
                appBar: const ModernAppBar(
                  title: 'Breeding Schedule',
                  variant: AppBarVariant.standard,
                ),
                body: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [AppColors.subtleShadow],
                      ),
                      child: Row(
                        children: [
                          _BreedingTab(
                            label: 'Pregnancy',
                            isSelected: _selectedTab == 0,
                            onTap: () => setState(() => _selectedTab = 0),
                            theme: theme,
                          ),
                          _BreedingTab(
                            label: 'Breeding',
                            isSelected: _selectedTab == 1,
                            onTap: () => setState(() => _selectedTab = 1),
                            theme: theme,
                          ),
                          _BreedingTab(
                            label: 'Calendar',
                            isSelected: _selectedTab == 2,
                            onTap: () => setState(() => _selectedTab = 2),
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _selectedTab,
                        children: [
                          _PregnancyTab(
                            records: activePregnancies,
                            nameById: nameById,
                            typeById: typeById,
                            theme: theme,
                          ),
                          _BreedingHistoryTab(
                            records: records,
                            nameById: nameById,
                            typeById: typeById,
                            theme: theme,
                          ),
                          _BreedingCalendarTab(
                            records: activePregnancies,
                            nameById: nameById,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                floatingActionButton: FloatingActionButton(
                  heroTag: 'addBreedingRecordFAB',
                  onPressed: () => _addRecord(context, animals),
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _addRecord(BuildContext context, List<AnimalEntity> animals) {
    if (animals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add animals first to create breeding records')),
      );
      return;
    }

    final dam = animals.firstWhere(
      (a) => a.id != null,
      orElse: () => animals.first,
    );
    if (dam.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected animal has no local id')),
      );
      return;
    }

    final matingDate = DateTime.now();
    final expectedBirthDate = matingDate.add(const Duration(days: 280));
    final record = BreedingRecordEntity(
      damAnimalId: dam.id!,
      matingDate: matingDate,
      expectedBirthDate: expectedBirthDate,
      status: 'scheduled',
      method: 'Manual Entry',
      success: null,
    );

    context.read<BreedingCubit>().add(record);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Breeding record added')),
    );
  }
}

class _BreedingTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _BreedingTab({
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

class _PregnancyTab extends StatelessWidget {
  final List<BreedingRecordEntity> records;
  final Map<String, String> nameById;
  final Map<String, String> typeById;
  final ThemeData theme;

  const _PregnancyTab({
    required this.records,
    required this.nameById,
    required this.typeById,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pregnancy Overview',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Text(
            'No active pregnancies',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          )
        else
          ...records.map((record) {
            final name = nameById[record.damAnimalId] ?? 'Unknown Animal';
            final type = typeById[record.damAnimalId] ?? 'Unknown';
            final daysToGo =
                record.expectedBirthDate.difference(DateTime.now()).inDays;

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.family_restroom,
                    color: theme.colorScheme.primary),
                title: Text(name),
                subtitle: Text(
                  '$type • Due: ${_formatDate(record.expectedBirthDate)}',
                ),
                trailing: Text(
                  '${daysToGo < 0 ? 0 : daysToGo} days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: daysToGo < 30 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _BreedingHistoryTab extends StatelessWidget {
  final List<BreedingRecordEntity> records;
  final Map<String, String> nameById;
  final Map<String, String> typeById;
  final ThemeData theme;

  const _BreedingHistoryTab({
    required this.records,
    required this.nameById,
    required this.typeById,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final total = records.length;
    final successful = records.where((r) => r.success == true).length;
    final rate = total == 0 ? 0 : ((successful / total) * 100).round();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Recent Breeding Records',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Text(
            'No breeding records',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          )
        else
          ...records.map((record) {
            final name = nameById[record.damAnimalId] ?? 'Unknown Animal';
            final type = typeById[record.damAnimalId] ?? 'Unknown';
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  record.success == false ? Icons.close : Icons.check_circle,
                  color: record.success == false ? Colors.orange : Colors.green,
                ),
                title: Text(name),
                subtitle: Text(
                  '$type • ${record.method ?? 'Unknown method'}',
                ),
                trailing: Text(
                  _formatDate(record.matingDate),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            );
          }),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(value: '$rate%', label: 'Success Rate', theme: theme),
                _Stat(value: '$total', label: 'Total Attempts', theme: theme),
                _Stat(value: '$successful', label: 'Successful', theme: theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _BreedingCalendarTab extends StatelessWidget {
  final List<BreedingRecordEntity> records;
  final Map<String, String> nameById;
  final ThemeData theme;

  const _BreedingCalendarTab({
    required this.records,
    required this.nameById,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Upcoming Due Dates',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (records.isEmpty)
          Text(
            'No upcoming due dates',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          )
        else
          ...records.map((record) {
            final name = nameById[record.damAnimalId] ?? 'Unknown Animal';
            final daysToGo =
                record.expectedBirthDate.difference(DateTime.now()).inDays;
            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading:
                    Icon(Icons.child_care, color: theme.colorScheme.primary),
                title: Text(name),
                subtitle: Text('Due: ${_formatDate(record.expectedBirthDate)}'),
                trailing: Text(
                  '${daysToGo < 0 ? 0 : daysToGo} days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: daysToGo < 30 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _Stat({required this.value, required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
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
