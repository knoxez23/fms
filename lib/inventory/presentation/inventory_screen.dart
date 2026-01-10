import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'add_inventory_screen.dart';
import 'inventory_history_screen.dart';

import 'package:pamoja_twalima/auth/providers/auth_provider.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';

import 'package:pamoja_twalima/inventory/application/application.dart';
import 'package:pamoja_twalima/inventory/domain/entities/inventory_item.dart';
import 'package:pamoja_twalima/inventory/infrastructure/factory.dart';
import 'package:pamoja_twalima/inventory/presentation/utils/inventory_utils.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late final GetInventory _getInventory;

  List<InventoryItem> _items = [];
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

  @override
  void initState() {
    super.initState();
    _getInventory = InventoryFactory.createGetInventory();
    _loadInventory();
  }

  // ===========================================================================
  // DATA
  // ===========================================================================

  Future<void> _loadInventory() async {
    try {
      final items = await _getInventory.execute();
      if (mounted) {
        setState(() => _items = items);
      }
    } catch (e) {
      debugPrint('Inventory load failed: $e');
    }
  }

  Future<void> _syncFromServer() async {
    if (_isSyncing) return;
    
    setState(() => _isSyncing = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text('Syncing from server...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      // Reload inventory - this will trigger sync from server
      await _loadInventory();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Synced ${_items.length} items from server'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Sync failed: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  String _statusFor(InventoryItem item) {
    if (item.quantity <= 0) return 'Critical';
    if (item.quantity <= item.minStock) return 'Low Stock';
    return 'Adequate';
  }

  List<InventoryItem> get _filteredItems {
    return _items.where((item) {
      final categoryMatch =
          _selectedCategory == 'All' || item.category == _selectedCategory;

      final statusMatch =
          _selectedStatus == 'All' || _statusFor(item) == _selectedStatus;

      return categoryMatch && statusMatch;
    }).toList();
  }

  // ===========================================================================
  // UI
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    final criticalCount =
        _items.where((i) => _statusFor(i) == 'Critical').length;
    final lowStockCount =
        _items.where((i) => _statusFor(i) == 'Low Stock').length;
    final adequateCount =
        _items.where((i) => _statusFor(i) == 'Adequate').length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: ModernAppBar(
        variant: AppBarVariant.standard,
        title: 'Inventory',
        showSyncButton: true,
        isSyncing: _isSyncing,
        onSyncTap: _syncFromServer,
        showNotifications: true,
        notificationCount: criticalCount + lowStockCount,
      ),
      body: CustomScrollView(
        slivers: [
          // -------------------------------------------------------------------
          // STATS
          // -------------------------------------------------------------------
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
          _filteredItems.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No items found',
                    subtitle: 'Try adjusting your filters or sync from server',
                    actionLabel: 'Sync Now',
                    onAction: _syncFromServer,
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = _filteredItems[index];
                        final status = _statusFor(item);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListItemCard(
                            icon: InventoryUtils.getCategoryIcon(item.category),
                            iconColor:
                                InventoryUtils.getCategoryColor(item.category),
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
                                color:
                                    InventoryUtils.getStatusColor(status),
                              ),
                            ],
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                      childCount: _filteredItems.length,
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
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddInventoryScreen(),
                  ),
                );

                if (result != null && result is Map<String, dynamic>) {
                  try {
                    final entity = _mapToEntity(result);
                    setState(() => _items.insert(0, entity));

                    final addUseCase = InventoryFactory.createAddInventoryItem();
                    await addUseCase.execute(entity);

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
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
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

  void _showItemDetails(BuildContext context, InventoryItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemDetailsSheet(item: item),
    );
  }
}

// ============================================================================
// DETAILS SHEET
// ============================================================================

class _ItemDetailsSheet extends StatelessWidget {
  final InventoryItem item;

  const _ItemDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = _statusFor(item);

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

          // Item Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: InventoryUtils.getCategoryColor(item.category)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  InventoryUtils.getCategoryIcon(item.category),
                  color: InventoryUtils.getCategoryColor(item.category),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
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
              StatusBadge(
                label: status,
                color: InventoryUtils.getStatusColor(status),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Details
          DetailRow(
            label: 'Current Stock',
            value: '${item.quantity} ${item.unit}',
            icon: Icons.inventory_2,
            valueColor: InventoryUtils.getStatusColor(status),
          ),
          DetailRow(
            label: 'Minimum Stock',
            value: '${item.minStock} ${item.unit}',
            icon: Icons.priority_high,
          ),
          if (item.supplier != null && item.supplier!.isNotEmpty)
            DetailRow(
              label: 'Supplier',
              value: item.supplier!,
              icon: Icons.business,
            ),
          if (item.lastRestock != null)
            DetailRow(
              label: 'Last Restock',
              value: _formatDate(item.lastRestock!),
              icon: Icons.calendar_today,
            ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Edit item
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Restock item
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Restock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusFor(InventoryItem item) {
    if (item.quantity <= 0) return 'Critical';
    if (item.quantity <= item.minStock) return 'Low Stock';
    return 'Adequate';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
