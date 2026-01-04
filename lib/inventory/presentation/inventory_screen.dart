import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';
import 'add_inventory_screen.dart';
import 'inventory_history_screen.dart';
import 'package:pamoja_twalima/inventory/application/application.dart';
import 'package:pamoja_twalima/inventory/infrastructure/factory.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<Map<String, dynamic>> inventoryItems = [];

  late final GetInventory _getInventoryUseCase;

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
    'Tools'
  ];

  final List<String> _statusOptions = [
    'All',
    'Adequate',
    'Low Stock',
    'Critical'
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    final filteredItems = inventoryItems.where((item) {
      final categoryMatch =
          _selectedCategory == 'All' || item['category'] == _selectedCategory;
      final statusMatch =
          _selectedStatus == 'All' || item['status'] == _selectedStatus;
      return categoryMatch && statusMatch;
    }).toList();

    final lowStockCount =
        inventoryItems.where((item) => item['status'] == 'Low Stock').length;
    final criticalCount =
        inventoryItems.where((item) => item['status'] == 'Critical').length;
    final adequateCount =
        inventoryItems.where((item) => item['status'] == 'Adequate').length;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Inventory",
          style: theme.textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.cardColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Stats Row
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
                      onTap: () {
                        setState(() => _selectedStatus = 'Critical');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      count: lowStockCount,
                      label: 'Low Stock',
                      color: Colors.orange,
                      icon: Icons.warning_amber,
                      onTap: () {
                        setState(() => _selectedStatus = 'Low Stock');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      count: adequateCount,
                      label: 'Adequate',
                      color: Colors.green,
                      icon: Icons.check_circle_outline,
                      onTap: () {
                        setState(() => _selectedStatus = 'Adequate');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filter Row
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
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilterDropdown(
                      value: _selectedStatus,
                      items: _statusOptions,
                      prefixIcon: Icons.filter_list,
                      onChanged: (value) =>
                          setState(() => _selectedStatus = value!),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Inventory List
          filteredItems.isEmpty
              ? SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: 'No items found',
                    subtitle: 'Try adjusting your filters',
                    actionLabel: 'Clear Filters',
                    onAction: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _selectedStatus = 'All';
                      });
                    },
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = filteredItems[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListItemCard(
                            icon: InventoryUtils.getCategoryIcon(
                                item['category']),
                            iconColor: InventoryUtils.getCategoryColor(
                                item['category']),
                            title: item['name'],
                            subtitle:
                                '${item['category']} • ${item['supplier']}',
                            badges: [
                              StatusBadge(
                                label: '${item['quantity']} ${item['unit']}',
                                color: Colors.blue,
                                icon: Icons.inventory_2,
                              ),
                              StatusBadge(
                                label: item['status'],
                                color: InventoryUtils.getStatusColor(
                                    item['status']),
                              ),
                            ],
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (item['quantity'] <= item['minStock'])
                                  const Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                Text(
                                  'Min: ${item['minStock']}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _showItemDetails(context, item),
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

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: 'history',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InventoryHistoryScreen()),
                );
              },
              backgroundColor: theme.colorScheme.secondary,
              mini: true,
              child: const Icon(Icons.history, color: Colors.white),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              heroTag: 'addInventoryFAB',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddInventoryScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getInventoryUseCase = InventoryFactory.createGetInventory();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    try {
      final items = await _getInventoryUseCase.execute();
      final mapped = items.map((row) {
        final quantity = (row['quantity'] is num) ? row['quantity'] : (num.tryParse('${row['quantity']}') ?? 0);
        final minStock = row['minStock'] ?? 0;
        final status = (minStock is num && quantity is num)
            ? (quantity <= minStock ? 'Low Stock' : 'Adequate')
            : 'Adequate';

        return <String, dynamic>{
          'id': '${row['id']}',
          'name': row['item_name'] ?? row['name'] ?? 'Unknown',
          'category': row['category'] ?? 'Uncategorized',
          'quantity': quantity,
          'unit': row['unit'] ?? '',
          'minStock': minStock,
          'status': status,
          'lastRestock': row['last_updated'] ?? '',
          'supplier': row['supplier'] ?? '',
        };
      }).toList();

      setState(() => inventoryItems = mapped);
    } catch (e) {
      // keep existing UI stable on errors
    }
  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ItemDetailsSheet(item: item),
    );
  }
}

// ============================================================================
// ITEM DETAILS BOTTOM SHEET
// ============================================================================

class ItemDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemDetailsSheet({super.key, required this.item});

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
          
          // Item Header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: InventoryUtils.getCategoryColor(item['category'])
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  InventoryUtils.getCategoryIcon(item['category']),
                  color: InventoryUtils.getCategoryColor(item['category']),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['category'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: item['status'],
                color: InventoryUtils.getStatusColor(item['status']),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Details
          DetailRow(
            label: 'Current Stock',
            value: '${item['quantity']} ${item['unit']}',
            icon: Icons.inventory_2,
            valueColor: InventoryUtils.getStatusColor(item['status']),
          ),
          DetailRow(
            label: 'Minimum Stock',
            value: '${item['minStock']} ${item['unit']}',
            icon: Icons.priority_high,
          ),
          DetailRow(
            label: 'Supplier',
            value: item['supplier'],
            icon: Icons.business,
          ),
          DetailRow(
            label: 'Last Restock',
            value: _formatDate(item['lastRestock']),
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

  String _formatDate(String date) {
    final parts = date.split('-');
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}

// ============================================================================
// INVENTORY UTILITIES
// ============================================================================

class InventoryUtils {
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Fertilizers':
        return Colors.green;
      case 'Seeds':
        return Colors.blue;
      case 'Animal Feed':
        return Colors.orange;
      case 'Chemicals':
        return Colors.red;
      case 'Animal Health':
        return Colors.purple;
      case 'Equipment':
        return Colors.brown;
      case 'Tools':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Fertilizers':
        return Icons.eco;
      case 'Seeds':
        return Icons.spa;
      case 'Animal Feed':
        return Icons.grain;
      case 'Chemicals':
        return Icons.science;
      case 'Animal Health':
        return Icons.medical_services;
      case 'Equipment':
        return Icons.build;
      case 'Tools':
        return Icons.construction;
      default:
        return Icons.inventory;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Adequate':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}