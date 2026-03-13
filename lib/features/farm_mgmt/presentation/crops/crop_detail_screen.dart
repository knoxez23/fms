import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/models/task.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/crop_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/presentation/tasks/add_task_screen.dart';
import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';
import 'package:pamoja_twalima/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pamoja_twalima/features/inventory/presentation/add_inventory_screen.dart';
import 'package:pamoja_twalima/features/marketplace/domain/entities/product_entity.dart';
import 'package:pamoja_twalima/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:pamoja_twalima/features/marketplace/presentation/sell_product_screen.dart';

class CropDetailScreen extends StatefulWidget {
  final CropEntity entity;

  const CropDetailScreen({
    super.key,
    required this.entity,
  });

  const CropDetailScreen.fromEntity({
    Key? key,
    required CropEntity entity,
  }) : this(key: key, entity: entity);

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final crop = _CropDetailView.fromEntity(widget.entity);
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title: crop.name,
        variant: AppBarVariant.standard,
      ),
      body: Column(
        children: [
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
                      CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.agriculture,
                          color: theme.colorScheme.primary,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              crop.type,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(crop.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          crop.status,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(crop.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _DetailItem(
                        icon: Icons.square_foot,
                        label: 'Area',
                        value: crop.area,
                        theme: theme,
                      ),
                      _DetailItem(
                        icon: Icons.calendar_today,
                        label: 'Planted',
                        value: crop.plantedDate,
                        theme: theme,
                      ),
                      _DetailItem(
                        icon: Icons.event_available,
                        label: 'Harvest',
                        value: crop.harvestDate,
                        theme: theme,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _HarvestAutomationStrip(
                    crop: crop,
                    theme: theme,
                    onCreateStockDraft: () => _openHarvestStockDraft(crop),
                    onCreateMarketplaceDraft: () => _openMarketplaceDraft(crop),
                    onCreateFollowUpTask: () =>
                        _createHarvestFollowUpTask(crop),
                  ),
                ],
              ),
            ),
          ),
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
                  label: 'Growth',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                  theme: theme,
                ),
                _DetailTab(
                  label: 'Tasks',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                  theme: theme,
                ),
                _DetailTab(
                  label: 'History',
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
                _GrowthTab(crop: crop, theme: theme),
                _TasksTab(crop: crop, theme: theme),
                _HistoryTab(crop: crop, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'harvested':
        return Colors.green;
      case 'flowering':
      case 'fruiting':
        return Colors.blue;
      case 'vegetative':
      case 'germinating':
        return Colors.orange;
      case 'planted':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  Future<void> _openHarvestStockDraft(_CropDetailView crop) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddInventoryScreen(
          initialName: crop.name,
          initialCategory: 'Crops',
          initialUnit: 'kg',
          initialMinStock: '0',
          initialNotes:
              'Harvest stock drafted from ${crop.name} crop${crop.harvestDate == 'Not set' ? '' : ' scheduled for ${crop.harvestDate}'}',
        ),
      ),
    );

    if (result is! Map<String, dynamic>) return;

    final item = InventoryItem(
      itemName: (result['itemName'] ?? '').toString(),
      category: (result['category'] ?? 'Crops').toString(),
      quantity: ((result['quantity'] as num?) ?? 0).toDouble(),
      unit: (result['unit'] ?? 'kg').toString(),
      minStock: (result['minStock'] as int?) ?? 0,
      supplier: result['supplier']?.toString(),
      supplierId: result['supplierId']?.toString(),
      unitPrice: (result['unitPrice'] as num?)?.toDouble(),
      totalValue: (result['totalValue'] as num?)?.toDouble(),
      lastRestock: result['lastRestock'] as DateTime?,
      isSynced: false,
    );

    await getIt<InventoryRepository>().addItem(item);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harvest stock added to inventory')),
    );
  }

  Future<void> _openMarketplaceDraft(_CropDetailView crop) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SellProductScreen(
          initialName: crop.name,
          initialCategory: 'Crops',
          initialSubCategory: 'Other',
          initialUnit: 'kg',
          initialDescription:
              '${crop.name} harvested from this farm and prepared for direct sale. The listing can be adjusted with grade, delivery terms, and pricing before buyers see it.',
        ),
      ),
    );

    if (result is! ProductEntity) return;
    await getIt<MarketplaceRepository>().addProduct(result);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Marketplace draft created from crop')),
    );
  }

  Future<void> _createHarvestFollowUpTask(_CropDetailView crop) async {
    await SyncData().insertTask(
      Task(
        title: 'Prepare ${crop.name} harvest for sale or storage',
        description:
            'Sort, bag, transport, or store ${crop.name} harvest and confirm final market-ready quantity.',
        dueDate: crop.expectedHarvest?.toIso8601String(),
        category: 'Crops',
        status: 'pending',
        sourceEventType: 'crop',
        sourceEventId: crop.id,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Harvest follow-up task created')),
    );
  }
}

class _HarvestAutomationStrip extends StatelessWidget {
  final _CropDetailView crop;
  final ThemeData theme;
  final VoidCallback onCreateStockDraft;
  final VoidCallback onCreateMarketplaceDraft;
  final VoidCallback onCreateFollowUpTask;

  const _HarvestAutomationStrip({
    required this.crop,
    required this.theme,
    required this.onCreateStockDraft,
    required this.onCreateMarketplaceDraft,
    required this.onCreateFollowUpTask,
  });

  @override
  Widget build(BuildContext context) {
    final isHarvestWindow = crop.expectedHarvest != null &&
        crop.expectedHarvest!.difference(DateTime.now()).inDays.abs() <= 21;
    final helperText = isHarvestWindow
        ? 'Harvest window is near. Turn this crop into stock, a listing, or a follow-up task.'
        : 'Pre-build the handoff from field to stock or market before harvest day.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Harvest Automation',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            helperText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: onCreateStockDraft,
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Harvest Stock'),
              ),
              FilledButton.tonalIcon(
                onPressed: onCreateMarketplaceDraft,
                icon: const Icon(Icons.storefront_outlined),
                label: const Text('Market Draft'),
              ),
              OutlinedButton.icon(
                onPressed: onCreateFollowUpTask,
                icon: const Icon(Icons.task_alt_outlined),
                label: const Text('Follow-up Task'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CropDetailView {
  final String id;
  final String name;
  final String type;
  final String status;
  final String area;
  final String plantedDate;
  final String harvestDate;
  final DateTime? plantedAt;
  final DateTime? expectedHarvest;
  final String? notes;

  const _CropDetailView({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.area,
    required this.plantedDate,
    required this.harvestDate,
    required this.plantedAt,
    required this.expectedHarvest,
    required this.notes,
  });

  factory _CropDetailView.fromEntity(CropEntity entity) {
    return _CropDetailView(
      id: entity.id ?? '',
      name: entity.name.value,
      type: entity.variety ?? 'General',
      status:
          entity.status ?? (entity.isReadyForHarvest ? 'Harvested' : 'Growing'),
      area: entity.area == null
          ? 'Not set'
          : '${entity.area!.toStringAsFixed(1)} ac',
      plantedDate: _formatDate(entity.plantedAt),
      harvestDate: _formatDate(entity.expectedHarvest),
      plantedAt: entity.plantedAt,
      expectedHarvest: entity.expectedHarvest,
      notes: entity.notes,
    );
  }
}

class _GrowthTab extends StatelessWidget {
  final _CropDetailView crop;
  final ThemeData theme;

  const _GrowthTab({required this.crop, required this.theme});

  @override
  Widget build(BuildContext context) {
    final progress = _growthProgress(crop.plantedAt, crop.expectedHarvest);
    final daysToHarvest = _daysToHarvest(crop.expectedHarvest);

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
                  'Growth Stage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      crop.status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${(progress * 100).round()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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
                  'Timeline',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoRow(
                    label: 'Planted Date',
                    value: crop.plantedDate,
                    theme: theme),
                _InfoRow(
                    label: 'Expected Harvest',
                    value: crop.harvestDate,
                    theme: theme),
                _InfoRow(
                  label: 'Harvest Countdown',
                  value: daysToHarvest,
                  theme: theme,
                ),
                if (crop.notes != null && crop.notes!.isNotEmpty)
                  _InfoRow(label: 'Notes', value: crop.notes!, theme: theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _growthProgress(DateTime? plantedAt, DateTime? harvestAt) {
    if (plantedAt == null || harvestAt == null) return 0;
    final totalDays = harvestAt.difference(plantedAt).inDays;
    if (totalDays <= 0) return 0;
    final elapsed = DateTime.now().difference(plantedAt).inDays;
    return (elapsed / totalDays).clamp(0.0, 1.0);
  }

  String _daysToHarvest(DateTime? harvestAt) {
    if (harvestAt == null) return 'Not scheduled';
    final diff = DateTime(harvestAt.year, harvestAt.month, harvestAt.day)
        .difference(DateTime.now());
    final days = diff.inDays;
    if (days == 0) return 'Today';
    if (days > 0) return 'In $days days';
    return '${days.abs()} days ago';
  }
}

class _TasksTab extends StatefulWidget {
  final _CropDetailView crop;
  final ThemeData theme;

  const _TasksTab({required this.crop, required this.theme});

  @override
  State<_TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<_TasksTab> {
  late Future<List<Map<String, dynamic>>> _tasksFuture;
  final SyncData _syncData = SyncData();

  @override
  void initState() {
    super.initState();
    _tasksFuture = LocalData.getUpcomingTasks(limit: 20);
  }

  void _reload() {
    setState(() {
      _tasksFuture = LocalData.getUpcomingTasks(limit: 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _tasksFuture,
      builder: (context, snapshot) {
        final allTasks = snapshot.data ?? const <Map<String, dynamic>>[];
        final cropTasks = allTasks.where((task) {
          final title = (task['title'] ?? '').toString().toLowerCase();
          final eventId = (task['source_event_id'] ?? '').toString();
          return eventId == widget.crop.id ||
              title.contains(widget.crop.name.toLowerCase());
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
                            'Crop Tasks',
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
                                  sourceEventType: 'crop',
                                  sourceEventId: widget.crop.id,
                                  initialTitle: 'Task for ${widget.crop.name}',
                                  initialDescription:
                                      'Linked task for ${widget.crop.name}',
                                ),
                              ),
                            );
                            if (result == null) return;
                            if (result is! TaskEntity) return;
                            await _syncData.insertTask(
                              Task(
                                title: result.title.value,
                                description: result.description,
                                dueDate: result.dueDate?.toIso8601String(),
                                status: result.isCompleted
                                    ? 'completed'
                                    : 'pending',
                                sourceEventType: result.sourceEventType,
                                sourceEventId: result.sourceEventId,
                              ),
                            );
                            _reload();
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (snapshot.connectionState == ConnectionState.waiting)
                      const Center(child: CircularProgressIndicator())
                    else if (cropTasks.isEmpty)
                      const ListTile(
                        leading: Icon(Icons.task_alt_outlined),
                        title: Text('No linked tasks'),
                        subtitle: Text(
                          'Tap Add to create a task linked to this crop.',
                        ),
                      )
                    else
                      ...cropTasks.take(8).map(
                            (task) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.task_alt),
                              title: Text(
                                  (task['title'] ?? 'Untitled').toString()),
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

class _HistoryTab extends StatelessWidget {
  final _CropDetailView crop;
  final ThemeData theme;

  const _HistoryTab({required this.crop, required this.theme});

  @override
  Widget build(BuildContext context) {
    final history = <_HistoryEntry>[
      if (crop.plantedAt != null)
        _HistoryEntry(
          title: 'Planted',
          details: 'Crop was planted',
          when: crop.plantedAt!,
        ),
      if (crop.expectedHarvest != null)
        _HistoryEntry(
          title: 'Harvest Scheduled',
          details: 'Expected harvest date set',
          when: crop.expectedHarvest!,
        ),
      if (crop.notes != null && crop.notes!.isNotEmpty)
        _HistoryEntry(
          title: 'Latest Notes',
          details: crop.notes!,
          when: DateTime.now(),
        ),
    ]..sort((a, b) => b.when.compareTo(a.when));

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
                  'Activity History',
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
                        'Crop events will appear here as data is captured.'),
                  )
                else
                  ...history.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.history),
                      title: Text(entry.title),
                      subtitle: Text(entry.details),
                      trailing: Text(
                        _formatDate(entry.when),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryEntry {
  final String title;
  final String details;
  final DateTime when;

  const _HistoryEntry({
    required this.title,
    required this.details,
    required this.when,
  });
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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

String _formatDate(DateTime? date) {
  if (date == null) return 'Not set';
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
