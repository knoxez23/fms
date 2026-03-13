import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';

import 'add_inventory_screen.dart';
import 'inventory_conflict_center_screen.dart';
import 'inventory_history_screen.dart';

import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/contact_directory_service.dart';
import 'package:pamoja_twalima/features/business/presentation/contacts/contacts_screen.dart';

import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';
import 'package:pamoja_twalima/features/inventory/presentation/utils/inventory_utils.dart';
import 'package:pamoja_twalima/features/inventory/presentation/bloc/inventory/inventory_bloc.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InventoryBloc>(
      create: (_) =>
          getIt<InventoryBloc>()..add(const InventoryEvent.loadInventory()),
      child: const InventoryView(),
    );
  }
}

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool _isSyncing = false;

  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final List<String> _categories = [
    'All',
    'Fertilizers',
    'Seeds',
    'Animal Feed',
    'Chemicals',
    'Animal Health',
    'Equipment',
    'Tools',
  ];

  final List<String> _statusOptions = [
    'All',
    'Adequate',
    'Low Stock',
    'Critical',
  ];

  // ===========================================================================
  // DATA
  // ===========================================================================

  Future<void> _syncFromServer() async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(context.tr('syncing_from_server')),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      // Reload inventory - this will trigger sync from server
      context.read<InventoryBloc>().add(const InventoryEvent.loadInventory());
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text('${context.tr('sync_failed')}: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      // _isSyncing is cleared when bloc returns loaded/error state
    }
  }

  String _statusFor(InventoryItem item) {
    if (item.quantity <= 0) return 'Critical';
    if (item.quantity <= item.minStock) return 'Low Stock';
    return 'Adequate';
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    return items.where((item) {
      final categoryMatch =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      final statusMatch =
          _selectedStatus == 'All' || _statusFor(item) == _selectedStatus;

      return categoryMatch && statusMatch;
    }).toList();
  }

  void _showItemDetails(BuildContext context, InventoryItem item) async {
    final inventoryBloc = context.read<InventoryBloc>();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemDetailsSheet(
        item: item,
        inventoryBloc: inventoryBloc,
        onResolveKeepLocal: () => _resolveConflictKeepLocal(item),
        onResolveUseServer: () => _resolveConflictUseServer(item),
      ),
    );

    // If item was deleted, refresh the list
    if (result == true) {
      if (!context.mounted) return;
      context.read<InventoryBloc>().add(const InventoryEvent.loadInventory());
    }
  }

  void _resolveConflictKeepLocal(InventoryItem item) {
    if (item.id == null) return;
    context.read<InventoryBloc>().add(
          InventoryEvent.resolveConflictKeepLocal(id: int.parse(item.id!)),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('local_version_kept')),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _resolveConflictUseServer(InventoryItem item) {
    if (item.id == null) return;
    context.read<InventoryBloc>().add(
          InventoryEvent.resolveConflictUseServer(id: int.parse(item.id!)),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('server_version_applied')),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Future<void> _openAddInventory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddInventoryScreen(),
      ),
    );

    if (!mounted) return;
    _handleAddResult(result);
  }

  void _openConflictCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<InventoryBloc>(),
          child: const InventoryConflictCenterScreen(),
        ),
      ),
    );
  }

  // ===========================================================================
  // UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return BlocConsumer<InventoryBloc, InventoryState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: (items, searchQuery, filterCategory) {
            if (_isSyncing) {
              setState(() => _isSyncing = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                          '${context.tr('synced_items_from_server')}: ${items.length}'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          error: (message) {
            if (_isSyncing) {
              setState(() => _isSyncing = false);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text(message)),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.maybeWhen(
          loading: () => true,
          orElse: () => false,
        );
        final items = state.maybeWhen(
          loaded: (items, _, __) => items,
          orElse: () => <InventoryItem>[],
        );
        final filteredItems = _filterItems(items);

        final criticalCount =
            items.where((i) => _statusFor(i) == 'Critical').length;
        final lowStockCount =
            items.where((i) => _statusFor(i) == 'Low Stock').length;
        final adequateCount =
            items.where((i) => _statusFor(i) == 'Adequate').length;
        final conflictCount = items.where((i) => i.hasConflict).length;
        final totalValue = items.fold<double>(
          0,
          (sum, item) =>
              sum + (item.totalValue ?? (item.unitPrice ?? 0) * item.quantity),
        );

        return AppScaffold(
          backgroundColor: theme.colorScheme.surface,
          includeDrawer: false,
          appBar: ModernAppBar(
            variant: AppBarVariant.home,
            title: context.tr('inventory'),
            showSyncButton: true,
            isSyncing: _isSyncing,
            onSyncTap: _syncFromServer,
            showNotifications: true,
            notificationCount: criticalCount + lowStockCount,
          ),
          body: CustomScrollView(
            slivers: [
              if (conflictCount > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: InkWell(
                      onTap: _openConflictCenter,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '$conflictCount inventory item(s) need conflict resolution',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Open',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              // -------------------------------------------------------------------
              // HERO SUMMARY
              // -------------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: _InventorySummaryCard(
                    totalItems: items.length,
                    totalValue: totalValue,
                    onAddTap: _openAddInventory,
                  ),
                ),
              ),
              // -------------------------------------------------------------------
              // STATS
              // -------------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          count: criticalCount,
                          label: 'Critical',
                          color: Colors.red,
                          icon: Icons.error_outline,
                          onTap: () =>
                              setState(() => _selectedStatus = 'Critical'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          count: lowStockCount,
                          label: 'Low Stock',
                          color: Colors.orange,
                          icon: Icons.warning_amber,
                          onTap: () =>
                              setState(() => _selectedStatus = 'Low Stock'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatCard(
                          count: adequateCount,
                          label: 'Adequate',
                          color: Colors.green,
                          icon: Icons.check_circle_outline,
                          onTap: () =>
                              setState(() => _selectedStatus = 'Adequate'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // -------------------------------------------------------------------
              // FILTERS
              // -------------------------------------------------------------------
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilterDropdown(
                          value: _selectedCategory,
                          items: _categories,
                          prefixIcon: Icons.category,
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilterDropdown(
                          value: _selectedStatus,
                          items: _statusOptions,
                          prefixIcon: Icons.filter_list,
                          onChanged: (v) =>
                              setState(() => _selectedStatus = v!),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // -------------------------------------------------------------------
              // LIST
              // -------------------------------------------------------------------
              isLoading && items.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : filteredItems.isEmpty
                      ? SliverFillRemaining(
                          child: EmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'No items found',
                            subtitle:
                                'Try adjusting your filters or sync from server',
                            actionLabel: 'Sync Now',
                            onAction: _syncFromServer,
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filteredItems[index];
                                final status = _statusFor(item);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ListItemCard(
                                    icon: InventoryUtils.getCategoryIcon(
                                        item.category),
                                    iconColor: InventoryUtils.getCategoryColor(
                                        item.category),
                                    title: item.itemName,
                                    subtitle:
                                        '${item.category} • ${item.supplier ?? '-'}',
                                    badges: [
                                      StatusBadge(
                                        label: '${item.quantity} ${item.unit}',
                                        color: Colors.blue,
                                        icon: Icons.inventory_2,
                                      ),
                                      StatusBadge(
                                        label: status,
                                        color: InventoryUtils.getStatusColor(
                                            status),
                                      ),
                                    ],
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _syncBadge(item),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Min: ${item.minStock}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    onTap: () =>
                                        _showItemDetails(context, item),
                                  ),
                                );
                              },
                              childCount: filteredItems.length,
                            ),
                          ),
                        ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),

          // -----------------------------------------------------------------------
          // ACTIONS
          // -----------------------------------------------------------------------
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'history',
                  mini: true,
                  backgroundColor: theme.colorScheme.secondary,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InventoryHistoryScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.history, color: Colors.white),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: 'addInventory',
                  backgroundColor: AppColors.primary,
                  onPressed: _openAddInventory,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // HELPERS
  // ===========================================================================

  InventoryItem _mapToEntity(Map<String, dynamic> map) {
    final itemName = map['itemName']?.toString() ?? '';
    final category = map['category']?.toString() ?? '';
    final unit = map['unit']?.toString() ?? '';
    final supplier = map['supplier']?.toString() ?? '';

    if (itemName.isEmpty) {
      throw ArgumentError('Item name cannot be empty');
    }
    if (category.isEmpty) {
      throw ArgumentError('Category cannot be empty');
    }
    if (unit.isEmpty) {
      throw ArgumentError('Unit cannot be empty');
    }
    if (supplier.isEmpty) {
      throw ArgumentError('Supplier cannot be empty');
    }

    double quantity;
    try {
      quantity = (map['quantity'] as num).toDouble();
    } catch (e) {
      throw ArgumentError('Invalid quantity value: ${map['quantity']}');
    }

    DateTime? lastRestock;
    if (map['lastRestock'] != null) {
      if (map['lastRestock'] is DateTime) {
        lastRestock = map['lastRestock'] as DateTime;
      } else if (map['lastRestock'] is String) {
        try {
          lastRestock = DateTime.parse(map['lastRestock'] as String);
        } catch (e) {
          lastRestock = DateTime.now();
        }
      }
    } else {
      lastRestock = DateTime.now();
    }

    return InventoryItem(
      itemName: itemName,
      supplierId: map['supplierId']?.toString(),
      category: category,
      quantity: quantity,
      unit: unit,
      minStock: map['minStock'] ?? 0,
      supplier: supplier,
      unitPrice: map['unitPrice'] != null
          ? (map['unitPrice'] as num).toDouble()
          : null,
      totalValue: map['totalValue'] != null
          ? (map['totalValue'] as num).toDouble()
          : null,
      lastRestock: lastRestock,
      isSynced: false,
    );
  }

  void _handleAddResult(dynamic result) {
    if (result != null && result is Map<String, dynamic>) {
      try {
        final entity = _mapToEntity(result);

        context.read<InventoryBloc>().add(
              InventoryEvent.addItem(
                itemName: entity.itemName,
                category: entity.category,
                quantity: entity.quantity,
                unit: entity.unit,
                minStock: entity.minStock,
                supplier: entity.supplier,
                supplierId: entity.supplierId,
                unitPrice: entity.unitPrice,
                totalValue: entity.totalValue,
                lastRestock: entity.lastRestock,
              ),
            );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('Error mapping inventory item: $e');
        debugPrint('Stack trace: $stackTrace');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _syncBadge(InventoryItem item) {
    if (item.hasConflict) {
      return _badge('CONFLICT', Colors.red);
    }
    if (!item.isSynced) {
      return _badge('SYNCING', Colors.orange);
    }
    return _badge('SYNCED', Colors.green);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11),
      ),
    );
  }

  // void _showItemDetails(BuildContext context, InventoryItem item) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (_) => _ItemDetailsSheet(item: item),
  //   );
  // }
}

// ============================================================================
// DETAILS SHEET
// ============================================================================

// ============================================================================
// 1. Update inventory_screen.dart - Add delete functionality
// ============================================================================

// Replace your _ItemDetailsSheet widget with this enhanced version:

class _ItemDetailsSheet extends StatelessWidget {
  final InventoryItem item;
  final InventoryBloc inventoryBloc;
  final VoidCallback onResolveKeepLocal;
  final VoidCallback onResolveUseServer;

  const _ItemDetailsSheet({
    required this.item,
    required this.inventoryBloc,
    required this.onResolveKeepLocal,
    required this.onResolveUseServer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetHeader(),
          const SizedBox(height: 16),

          // Item Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: InventoryUtils.getCategoryColor(item.category)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  InventoryUtils.getCategoryIcon(item.category),
                  color: InventoryUtils.getCategoryColor(item.category),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.itemName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Item Details
          _DetailRow(
            icon: Icons.inventory_2,
            label: 'Quantity',
            value: '${item.quantity} ${item.unit}',
            theme: theme,
          ),
          const SizedBox(height: 12),
          _DetailRow(
            icon: Icons.trending_down,
            label: 'Minimum Stock',
            value: '${item.minStock} ${item.unit}',
            theme: theme,
          ),
          if (item.supplier != null && item.supplier!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.local_shipping,
              label: 'Supplier',
              value: item.supplier!,
              theme: theme,
            ),
          ],
          if (item.unitPrice != null) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.attach_money,
              label: 'Unit Price',
              value: 'KSh ${item.unitPrice!.toStringAsFixed(2)}',
              theme: theme,
            ),
          ],
          if (item.totalValue != null) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calculate,
              label: 'Total Value',
              value: 'KSh ${item.totalValue!.toStringAsFixed(2)}',
              theme: theme,
              highlight: true,
            ),
          ],
          if (item.lastRestock != null) ...[
            const SizedBox(height: 12),
            _DetailRow(
              icon: Icons.calendar_today,
              label: 'Last Restock',
              value: _formatDate(item.lastRestock!),
              theme: theme,
            ),
          ],
          if (item.hasConflict) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sync conflict detected',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose which version to keep for this item.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            onResolveUseServer();
                            Navigator.pop(context);
                          },
                          child: const Text('Use Server'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            onResolveKeepLocal();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Keep Local'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditDialog(context, item);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, item);
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditDialog(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => _EditInventoryDialog(
        item: item,
        inventoryBloc: inventoryBloc,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(
        item: item,
        inventoryBloc: inventoryBloc,
      ),
    );
  }
}

class _InventorySummaryCard extends StatelessWidget {
  final int totalItems;
  final double totalValue;
  final VoidCallback onAddTap;

  const _InventorySummaryCard({
    required this.totalItems,
    required this.totalValue,
    required this.onAddTap,
  });

  String _formatCurrency(double value) {
    return 'KSh ${value.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory Snapshot',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalItems items • ${_formatCurrency(totalValue)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onAddTap,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Detail Row Widget
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final bool highlight;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: highlight
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                  color: highlight ? theme.colorScheme.primary : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Delete Confirmation Dialog
class _DeleteConfirmationDialog extends StatefulWidget {
  final InventoryItem item;
  final InventoryBloc inventoryBloc;

  const _DeleteConfirmationDialog({
    required this.item,
    required this.inventoryBloc,
  });

  @override
  State<_DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<_DeleteConfirmationDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
          ),
          const SizedBox(width: 12),
          const Text('Delete Item'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this item?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.itemName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.item.quantity} ${widget.item.unit}',
                  style: theme.textTheme.bodyMedium,
                ),
                if (widget.item.totalValue != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Value: KSh ${widget.item.totalValue!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This action cannot be undone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _handleDelete,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _handleDelete() async {
    if (widget.item.id == null) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isDeleting = true);

    try {
      widget.inventoryBloc.add(
        InventoryEvent.deleteItem(
          id: int.parse(widget.item.id!),
        ),
      );

      if (!context.mounted) return;

      Navigator.pop(context, true); // Return true to indicate success

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('${widget.item.itemName} deleted successfully'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Failed to delete: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}

class _EditInventoryDialog extends StatefulWidget {
  final InventoryItem item;
  final InventoryBloc inventoryBloc;

  const _EditInventoryDialog({
    required this.item,
    required this.inventoryBloc,
  });

  @override
  State<_EditInventoryDialog> createState() => _EditInventoryDialogState();
}

class _EditInventoryDialogState extends State<_EditInventoryDialog> {
  final ContactDirectoryService _contactService =
      ContactDirectoryService(ApiService());
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _quantityController;
  late final TextEditingController _minStockController;
  late final TextEditingController _supplierController;
  late final TextEditingController _unitPriceController;

  bool _saving = false;
  List<String> _supplierNames = const [];
  Map<String, String> _supplierIdByName = const {};
  String? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    _quantityController =
        TextEditingController(text: widget.item.quantity.toString());
    _minStockController =
        TextEditingController(text: widget.item.minStock.toString());
    _supplierController =
        TextEditingController(text: widget.item.supplier ?? '');
    _unitPriceController = TextEditingController(
      text: widget.item.unitPrice?.toStringAsFixed(2) ?? '',
    );
    _selectedSupplierId = widget.item.supplierId;
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    try {
      final rows = await _contactService.list(ContactType.supplier);
      if (!mounted) return;
      final entries = rows
          .map((e) => (
                name: (e['name'] ?? '').toString(),
                id: (e['id'] ?? '').toString(),
              ))
          .where((entry) => entry.name.isNotEmpty && entry.id.isNotEmpty)
          .toList();
      setState(() {
        _supplierIdByName = {for (final entry in entries) entry.name: entry.id};
        _supplierNames = _supplierIdByName.keys.toList()..sort();
        if (_selectedSupplierId != null) {
          for (final entry in _supplierIdByName.entries) {
            if (entry.value == _selectedSupplierId) {
              _supplierController.text = entry.key;
              break;
            }
          }
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _minStockController.dispose();
    _supplierController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.edit, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Text('Edit Inventory Item'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g., 25',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Quantity is required';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid quantity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minStockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum Stock',
                  hintText: 'e.g., 10',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Minimum stock is required';
                  }
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed < 0) {
                    return 'Enter a valid minimum stock';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _supplierController,
                decoration: InputDecoration(
                  labelText: 'Supplier',
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
                      _selectedSupplierId = _supplierIdByName[value];
                    });
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Unit Price (optional)',
                  hintText: 'e.g., 1500',
                  prefixText: 'KSh ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _handleSave,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.item.id == null) {
      Navigator.pop(context);
      return;
    }

    final quantity = double.parse(_quantityController.text.trim());
    final minStock = int.parse(_minStockController.text.trim());
    final unitPrice = _unitPriceController.text.trim().isEmpty
        ? null
        : double.tryParse(_unitPriceController.text.trim());
    final totalValue = unitPrice != null ? quantity * unitPrice : null;

    setState(() => _saving = true);

    widget.inventoryBloc.add(
      InventoryEvent.updateItem(
        id: int.parse(widget.item.id!),
        quantity: quantity,
        minStock: minStock,
        supplier: _supplierController.text.trim(),
        supplierId: _supplierIdByName[_supplierController.text.trim()] ??
            _selectedSupplierId,
        unitPrice: unitPrice,
        totalValue: totalValue,
      ),
    );

    if (!mounted) return;
    Navigator.pop(context);
  }
}
