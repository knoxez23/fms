import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'add_inventory_screen.dart';
import 'inventory_history_screen.dart';
import 'package:pamoja_twalima/inventory/application/application.dart';
import 'package:pamoja_twalima/inventory/infrastructure/factory.dart';
import '../../data/services/inventory_service.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

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
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final bool isAuth = auth.isAuthenticated;
                final messenger = ScaffoldMessenger.of(context);
                final fallback = InventoryFactory.createAddInventoryItem();

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
                );

                if (result != null && result is Map<String, dynamic>) {
                  // Validate and sanitize the result before using it
                  final sanitizedItem = _sanitizeInventoryItem(result);

                  // Validate required fields
                  if (!_validateInventoryItem(sanitizedItem)) {
                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Invalid item data. Please check all required fields.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Optimistic insert with sanitized data
                  setState(() => inventoryItems.insert(0, sanitizedItem));

                  if (isAuth) {
                    try {
                      // Send to API - transform for API if needed
                      final apiPayload = _transformForApi(sanitizedItem);
                      await InventoryService().create(apiPayload);

                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Item saved successfully'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content:
                              Text('Failed to save on server: ${e.toString()}'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      // Fallback to local storage
                      try {
                        await fallback.execute(sanitizedItem);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(
                              content: Text('Item saved locally instead')),
                        );
                      } catch (localError) {
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                                'Failed to save locally: ${localError.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        // Remove from UI if both save attempts failed
                        setState(() => inventoryItems.removeAt(0));
                      }
                    }
                  } else {
                    // Save locally when offline/unauthenticated
                    try {
                      await fallback.execute(sanitizedItem);
                      if (!mounted) return;
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Item saved locally')),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text('Failed to save: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      // Remove from UI if save failed
                      setState(() => inventoryItems.removeAt(0));
                    }
                  }
                }
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

  /// Sanitize inventory item to ensure no null values in required String fields
  Map<String, dynamic> _sanitizeInventoryItem(Map<String, dynamic> item) {
    final quantity = item['quantity'] is num
        ? item['quantity']
        : (num.tryParse('${item['quantity']}') ?? 0);

    final minStock = item['minStock'] ?? item['min_stock'] ?? 0;

    // Calculate status based on quantity vs minStock
    String status = 'Adequate';
    if (minStock is num && quantity is num) {
      if (quantity <= 0) {
        status = 'Critical';
      } else if (quantity <= minStock) {
        status = 'Low Stock';
      }
    }

    return {
      'id': item['id']?.toString() ?? '',
      'name': item['name']?.toString() ??
          item['item_name']?.toString() ??
          'Unknown Item',
      'category': item['category']?.toString() ?? 'Uncategorized',
      'quantity': quantity,
      'unit': item['unit']?.toString() ?? item['uom']?.toString() ?? 'units',
      'minStock': minStock,
      'status': status,
      'lastRestock': item['lastRestock']?.toString() ??
          item['last_updated']?.toString() ??
          DateTime.now().toIso8601String(),
      'supplier': item['supplier']?.toString() ?? 'Unknown',
    };
  }

  /// Validate that required fields are present and valid
  bool _validateInventoryItem(Map<String, dynamic> item) {
    // Check required string fields are not empty
    if ((item['name'] as String).trim().isEmpty) return false;
    if ((item['category'] as String).trim().isEmpty) return false;

    // Check numeric fields are valid
    if (item['quantity'] == null || item['quantity'] is! num) return false;
    if (item['minStock'] == null || item['minStock'] is! num) return false;

    return true;
  }

  /// Transform data for API (map field names if needed)
  Map<String, dynamic> _transformForApi(Map<String, dynamic> item) {
    return {
      'item_name': item['name'],
      'category': item['category'],
      'quantity': item['quantity'],
      'unit': item['unit'],
      'min_stock': item['minStock'],
      'supplier': item['supplier'],
      'unit_price': item['unit_price'],
      'total_value': item['total_value'],
      'notes': item['notes'],
      'last_updated': item['lastRestock'],
    };
  }

  Future<void> _loadInventory() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        final api = InventoryService();
        final list = await api.list();

        final mapped = list.map((row) {
          return _sanitizeInventoryItem(row);
        }).toList();

        if (mounted) {
          setState(() => inventoryItems = mapped);
        }
        return;
      }

      // Fallback to local data
      final items = await _getInventoryUseCase.execute();
      final mapped = items.map((row) {
        return _sanitizeInventoryItem(row);
      }).toList();

      if (mounted) {
        setState(() => inventoryItems = mapped);
      }
    } catch (e) {
      // Log error but keep UI stable
      debugPrint('Failed to load inventory: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load inventory: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
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
