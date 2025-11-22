import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';
import 'add_inventory_screen.dart';
import 'inventory_history_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final List<Map<String, dynamic>> inventoryItems = [
    {
      'id': '1',
      'name': 'NPK Fertilizer',
      'category': 'Fertilizers',
      'quantity': 25,
      'unit': 'kg',
      'minStock': 10,
      'status': 'Adequate',
      'lastRestock': '2024-02-15',
      'supplier': 'AgroSupplies Ltd',
    },
    {
      'id': '2',
      'name': 'Maize Seeds',
      'category': 'Seeds',
      'quantity': 40,
      'unit': 'packets',
      'minStock': 20,
      'status': 'Adequate',
      'lastRestock': '2024-02-10',
      'supplier': 'SeedCo Kenya',
    },
    {
      'id': '3',
      'name': 'Animal Feed',
      'category': 'Animal Feed',
      'quantity': 8,
      'unit': 'bags',
      'minStock': 15,
      'status': 'Low Stock',
      'lastRestock': '2024-01-20',
      'supplier': 'Unga Farm Care',
    },
    {
      'id': '4',
      'name': 'Pesticide',
      'category': 'Chemicals',
      'quantity': 5,
      'unit': 'liters',
      'minStock': 8,
      'status': 'Low Stock',
      'lastRestock': '2024-02-05',
      'supplier': 'Syngenta',
    },
    {
      'id': '5',
      'name': 'Vaccines',
      'category': 'Animal Health',
      'quantity': 12,
      'unit': 'doses',
      'minStock': 20,
      'status': 'Critical',
      'lastRestock': '2024-01-15',
      'supplier': 'Kenya Vet Board',
    },
    {
      'id': '6',
      'name': 'Irrigation Pipes',
      'category': 'Equipment',
      'quantity': 15,
      'unit': 'meters',
      'minStock': 5,
      'status': 'Adequate',
      'lastRestock': '2024-02-01',
      'supplier': 'FarmTech Ltd',
    },
  ];

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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Inventory",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.cardTheme.color,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          // Collapsible header section (alerts + filters)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alerts Row
                  Row(
                    children: [
                      _InventoryAlert(
                        count: criticalCount,
                        label: 'Critical',
                        color: Colors.red,
                        theme: theme,
                      ),
                      const SizedBox(width: 12),
                      _InventoryAlert(
                        count: lowStockCount,
                        label: 'Low Stock',
                        color: Colors.orange,
                        theme: theme,
                      ),
                      const SizedBox(width: 12),
                      _InventoryAlert(
                        count: inventoryItems.length,
                        label: 'Total Items',
                        color: theme.colorScheme.primary,
                        theme: theme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedCategory,
                          items: _categories,
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value!),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedStatus,
                          items: _statusOptions,
                          onChanged: (value) =>
                              setState(() => _selectedStatus = value!),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // Inventory List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final item = filteredItems[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AnimatedCard(
                      index: index,
                      theme: theme,
                      child: _InventoryItem(
                        item: item,
                        theme: theme,
                        onTap: () => _showItemDetails(context, item),
                      ),
                    ),
                  );
                },
                childCount: filteredItems.length,
              ),
            ),
          ),

          // Extra padding at bottom to prevent overlap with FABs
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),

      // Floating Action Buttons
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddInventoryScreen()),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ),
    );

  }

  void _showItemDetails(BuildContext context, Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemDetailsSheet(item: item),
    );
  }
}

class _InventoryAlert extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final ThemeData theme;

  const _InventoryAlert({
    required this.count,
    required this.label,
    required this.color,
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
          boxShadow: const [AppColors.subtleShadow],
        ),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final ThemeData theme;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: theme.textTheme.bodyMedium,
              ),
            );
          }).toList(),
          onChanged: onChanged,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _InventoryItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final ThemeData theme;
  final VoidCallback onTap;

  const _InventoryItem({
    required this.item,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getCategoryColor(item['category']).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(item['category']),
            color: _getCategoryColor(item['category']),
            size: 24,
          ),
        ),
        title: Text(
          item['name'],
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${item['category']} • ${item['supplier']}'),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  'Stock: ${item['quantity']} ${item['unit']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(item['status']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item['status'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(item['status']),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item['quantity'] <= item['minStock'])
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: 20,
              ),
            const SizedBox(height: 2),
            Text(
              'Min: ${item['minStock']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Color _getCategoryColor(String category) {
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
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getCategoryIcon(String category) {
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
      default:
        return Icons.inventory;
    }
  }

  Color _getStatusColor(String status) {
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

class _ItemDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getCategoryColor(item['category']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(item['category']),
                  color: _getCategoryColor(item['category']),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item['category'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(item['status']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item['status'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(item['status']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Current Stock',
            value: '${item['quantity']} ${item['unit']}',
            theme: theme,
          ),
          _DetailRow(
            label: 'Minimum Stock',
            value: '${item['minStock']} ${item['unit']}',
            theme: theme,
          ),
          _DetailRow(
            label: 'Supplier',
            value: item['supplier'],
            theme: theme,
          ),
          _DetailRow(
            label: 'Last Restock',
            value: _formatDate(item['lastRestock']),
            theme: theme,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Restock action
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Restock'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
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
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
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
      default:
        return Icons.inventory;
    }
  }

  Color _getStatusColor(String status) {
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

  String _formatDate(String date) {
    return date.split('-').reversed.join('/');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Reuse the _AnimatedCard widget
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
        child: widget.child,
      ),
    );
  }
}
