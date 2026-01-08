import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'add_crop_screen.dart';
import 'crop_detail_screen.dart';
import 'package:pamoja_twalima/core/presentation/animations/animated_card.dart';

class CropsScreen extends StatefulWidget {
  const CropsScreen({super.key});

  @override
  State<CropsScreen> createState() => _CropsScreenState();
}

class _CropsScreenState extends State<CropsScreen> {
  final List<Map<String, dynamic>> crops = [
    {
      'id': '1',
      'name': 'Maize Field A',
      'type': 'Maize',
      'area': '2 acres',
      'plantedDate': '2024-01-15',
      'status': 'Growing',
      'health': 'Good',
      'yieldEstimate': '3.2 tons',
    },
    {
      'id': '2',
      'name': 'Tomato Greenhouse',
      'type': 'Tomatoes',
      'area': '0.5 acres',
      'plantedDate': '2024-02-01',
      'status': 'Flowering',
      'health': 'Excellent',
      'yieldEstimate': '800 kg',
    },
    {
      'id': '1',
      'name': 'Maize Field A',
      'type': 'Maize',
      'area': '2 acres',
      'plantedDate': '2024-01-15',
      'status': 'Growing',
      'health': 'Good',
      'yieldEstimate': '3.2 tons',
    },
    {
      'id': '2',
      'name': 'Tomato Greenhouse',
      'type': 'Tomatoes',
      'area': '0.5 acres',
      'plantedDate': '2024-02-01',
      'status': 'Flowering',
      'health': 'Excellent',
      'yieldEstimate': '800 kg',
    },
    {
      'id': '1',
      'name': 'Maize Field A',
      'type': 'Maize',
      'area': '2 acres',
      'plantedDate': '2024-01-15',
      'status': 'Growing',
      'health': 'Good',
      'yieldEstimate': '3.2 tons',
    },
    {
      'id': '2',
      'name': 'Tomato Greenhouse',
      'type': 'Tomatoes',
      'area': '0.5 acres',
      'plantedDate': '2024-02-01',
      'status': 'Flowering',
      'health': 'Excellent',
      'yieldEstimate': '800 kg',
    },
    {
      'id': '1',
      'name': 'Maize Field A',
      'type': 'Maize',
      'area': '2 acres',
      'plantedDate': '2024-01-15',
      'status': 'Growing',
      'health': 'Good',
      'yieldEstimate': '3.2 tons',
    },
    {
      'id': '2',
      'name': 'Tomato Greenhouse',
      'type': 'Tomatoes',
      'area': '0.5 acres',
      'plantedDate': '2024-02-01',
      'status': 'Flowering',
      'health': 'Excellent',
      'yieldEstimate': '800 kg',
    },
    {
      'id': '1',
      'name': 'Maize Field A',
      'type': 'Maize',
      'area': '2 acres',
      'plantedDate': '2024-01-15',
      'status': 'Growing',
      'health': 'Good',
      'yieldEstimate': '3.2 tons',
    },
    {
      'id': '2',
      'name': 'Tomato Greenhouse',
      'type': 'Tomatoes',
      'area': '0.5 acres',
      'plantedDate': '2024-02-01',
      'status': 'Flowering',
      'health': 'Excellent',
      'yieldEstimate': '800 kg',
    },
    {
      'id': '1',
      'name': 'Maize Field A',
      'type': 'Maize',
      'area': '2 acres',
      'plantedDate': '2024-01-15',
      'status': 'Growing',
      'health': 'Good',
      'yieldEstimate': '3.2 tons',
    },
    {
      'id': '2',
      'name': 'Tomato Greenhouse',
      'type': 'Tomatoes',
      'area': '0.5 acres',
      'plantedDate': '2024-02-01',
      'status': 'Flowering',
      'health': 'Excellent',
      'yieldEstimate': '800 kg',
    },
    // Add more crops...
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
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
                            builder: (_) => CropDetailScreen(crop: crop),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCropScreen()),
            );
          },
          backgroundColor: theme.colorScheme.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
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
  final Map<String, dynamic> crop;
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
          crop['name'],
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${crop['type']} • Area: ${crop['area']}'),
            Text(
              'Status: ${crop['status']} • Health: ${crop['health']}',
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