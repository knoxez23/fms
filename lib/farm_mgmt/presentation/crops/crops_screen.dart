import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'add_crop_screen.dart';
import 'crop_detail_screen.dart';
import 'package:pamoja_twalima/core/presentation/animations/animated_card.dart';
import 'package:pamoja_twalima/farm_mgmt/presentation/bloc/crops/crops_bloc.dart';
import 'package:pamoja_twalima/farm_mgmt/domain/entities/crop_entity.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => getIt<CropsBloc>()..add(const CropsEvent.load()),
      child: BlocConsumer<CropsBloc, CropsState>(
        listener: (context, state) {
          state.whenOrNull(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        builder: (context, state) {
          final crops = state.maybeWhen<List<CropEntity>>(
            loaded: (items) => items,
            orElse: () => <CropEntity>[],
          );

          return AppScaffold(
            backgroundColor: theme.colorScheme.surface,
            body: CustomScrollView(
              slivers: [
                // Header with Stats
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        _CropStat(
                          value: '${crops.length}',
                          label: 'Active Crops',
                          theme: theme,
                        ),
                        const SizedBox(width: 16),
                        _CropStat(
                          value: '4.2',
                          label: 'Avg Yield (tons)',
                          theme: theme,
                        ),
                        const SizedBox(width: 16),
                        _CropStat(
                          value: '75%',
                          label: 'Health Score',
                          theme: theme,
                        ),
                      ],
                    ),
                  ),
                ),

                // Crops List
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final crop = crops[index];
                        return AnimatedCard(
                          index: index,
                          child: _CropCard(
                            crop: crop,
                            theme: theme,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CropDetailScreen.fromEntity(entity: crop),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      childCount: crops.length,
                    ),
                  ),
                ),

                // Spacer so last card isn’t hidden by FAB
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton(
                heroTag: 'addCropFAB',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddCropScreen()),
                  );
                  if (result is! CropEntity) return;
                  if (!context.mounted) return;
                  context.read<CropsBloc>().add(CropsEvent.add(crop: result));
                },
                backgroundColor: theme.colorScheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CropStat extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _CropStat({
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.subtleShadow],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CropCard extends StatelessWidget {
  final CropEntity crop;
  final ThemeData theme;
  final VoidCallback onTap;

  const _CropCard({
    required this.crop,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.agriculture,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(
          crop.name.value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${crop.variety ?? crop.name.value} • Area: —'),
            Text(
              'Status: ${crop.isReadyForHarvest ? 'Ready' : 'Growing'} • Health: Good',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        onTap: onTap,
      ),
    );
  }
}
