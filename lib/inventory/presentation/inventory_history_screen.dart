import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/inventory/application/application.dart';
import 'package:pamoja_twalima/inventory/infrastructure/factory.dart';

class InventoryHistoryScreen extends StatefulWidget {
  const InventoryHistoryScreen({super.key});

  @override
  State<InventoryHistoryScreen> createState() => _InventoryHistoryScreenState();
}

class _InventoryHistoryScreenState extends State<InventoryHistoryScreen> {
  int _selectedTab = 0;

  List<Map<String, dynamic>> _restockHistory = [];
  List<Map<String, dynamic>> _usageHistory = [];
  List<Map<String, dynamic>> _lowStockAlerts = [];

  late final GetInventory _getInventoryUseCase;
  List<Map<String, dynamic>> _allItems = [];

  @override
  void initState() {
    super.initState();
    _getInventoryUseCase = InventoryFactory.createGetInventory();
    _loadInventoryHistory();
  }

  Future<void> _loadInventoryHistory() async {
    try {
      final items = await _getInventoryUseCase.execute();
      _allItems = items.map((row) {
        final qty = (row['quantity'] is num)
            ? row['quantity']
            : (num.tryParse('${row['quantity']}') ?? 0);
        final minStock = row['minStock'] is num ? row['minStock'] : (row['minStock'] != null ? int.tryParse('${row['minStock']}') ?? 0 : 0);

        return {
          'id': '${row['id']}',
          'name': row['item_name'] ?? row['name'] ?? 'Unknown',
          'quantity': qty,
          'unit': row['unit'] ?? '',
          'minStock': minStock,
          'lastRestock': row['lastRestock'] ?? row['last_updated'] ?? '',
          'supplier': row['supplier'] ?? '',
          'unit_price': row['unit_price'],
          'total_value': row['total_value'],
        };
      }).toList();

      // Build low stock alerts
      _lowStockAlerts = _allItems.where((i) {
        final q = i['quantity'] as num? ?? 0;
        final m = i['minStock'] as num? ?? 0;
        return m > 0 && q <= m;
      }).map((i) {
        final q = i['quantity'] as num? ?? 0;
        final m = i['minStock'] as num? ?? 0;
        final deficit = m - q;
        final priority = deficit >= (m * 0.5) ? 'High' : 'Medium';
        return {
          'item': i['name'],
          'currentStock': q,
          'minStock': m,
          'unit': i['unit'],
          'alertDate': i['lastRestock'] ?? '',
          'priority': priority,
        };
      }).toList();

      // Restock summary from available total_value or unit_price*quantity
      _restockHistory = _allItems.map((i) {
        final total = i['total_value'] ?? ((i['unit_price'] is num && i['quantity'] is num) ? (i['unit_price'] * i['quantity']) : 0);
        return {
          'item': i['name'],
          'quantity': i['quantity'],
          'unit': i['unit'],
          'date': i['lastRestock'] ?? '',
          'supplier': i['supplier'] ?? '',
          'cost': total,
          'type': 'restock',
        };
      }).toList();

      // Usage history is not tracked separately; leave empty for now
      _usageHistory = [];

      setState(() {});
    } catch (e) {
      // ignore errors for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Inventory History',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Summary Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _HistoryStat(
                  value: 'KSh 24,000',
                  label: 'Total Restock Cost',
                  icon: Icons.attach_money,
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _HistoryStat(
                  value: '3',
                  label: 'Low Stock Alerts',
                  icon: Icons.warning,
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _HistoryStat(
                  value: '8',
                  label: 'Monthly Usage',
                  icon: Icons.trending_up,
                  theme: theme,
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.subtleShadow],
            ),
            child: Row(
              children: [
                _HistoryTab(
                  label: 'Restocks',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                  theme: theme,
                ),
                _HistoryTab(
                  label: 'Usage',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                  theme: theme,
                ),
                _HistoryTab(
                  label: 'Alerts',
                  isSelected: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                  theme: theme,
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _RestockTab(restockHistory: _restockHistory, theme: theme),
                _UsageTab(usageHistory: _usageHistory, theme: theme),
                _AlertsTab(lowStockAlerts: _lowStockAlerts, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final ThemeData theme;

  const _HistoryStat({
    required this.value,
    required this.label,
    required this.icon,
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
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
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

class _HistoryTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _HistoryTab({
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
              color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _RestockTab extends StatelessWidget {
  final List<Map<String, dynamic>> restockHistory;
  final ThemeData theme;

  const _RestockTab({required this.restockHistory, required this.theme});

  @override
  Widget build(BuildContext context) {
    final totalCost = restockHistory.fold(0.00, (sum, item) => sum + (item['cost'] ?? 0));

    return ListView(
      padding: const EdgeInsets.all(16),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Restock Summary',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'KSh ${totalCost.toStringAsFixed(0)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...restockHistory.map((record) => _RestockItem(record: record, theme: theme)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RestockItem extends StatelessWidget {
  final Map<String, dynamic> record;
  final ThemeData theme;

  const _RestockItem({required this.record, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2,
              color: Colors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['item'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${record['quantity']} ${record['unit']} • ${record['supplier']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KSh ${record['cost']?.toStringAsFixed(0) ?? '0'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                _formatDate(record['date']),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    return date.split('-').reversed.join('/');
  }
}

class _UsageTab extends StatelessWidget {
  final List<Map<String, dynamic>> usageHistory;
  final ThemeData theme;

  const _UsageTab({required this.usageHistory, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 0,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Usage History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...usageHistory.map((record) => _UsageItem(record: record, theme: theme)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monthly Usage Chart',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      'Usage trends and charts will be implemented here',
                      style: TextStyle(color: Colors.grey),
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

class _UsageItem extends StatelessWidget {
  final Map<String, dynamic> record;
  final ThemeData theme;

  const _UsageItem({required this.record, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.trending_down,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['item'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  record['purpose'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${record['quantity']} ${record['unit']}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
              Text(
                _formatDate(record['date']),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    return date.split('-').reversed.join('/');
  }
}

class _AlertsTab extends StatelessWidget {
  final List<Map<String, dynamic>> lowStockAlerts;
  final ThemeData theme;

  const _AlertsTab({required this.lowStockAlerts, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Low Stock Alerts',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${lowStockAlerts.length} Active',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...lowStockAlerts.map((alert) => _AlertItem(alert: alert, theme: theme)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Generate order list
                        },
                        icon: const Icon(Icons.shopping_cart, size: 16),
                        label: const Text('Generate Order List'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Contact suppliers
                        },
                        icon: const Icon(Icons.contact_phone, size: 16),
                        label: const Text('Contact Suppliers'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertItem extends StatelessWidget {
  final Map<String, dynamic> alert;
  final ThemeData theme;

  const _AlertItem({required this.alert, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getPriorityColor(alert['priority']).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning,
              color: _getPriorityColor(alert['priority']),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['item'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Current: ${alert['currentStock']} ${alert['unit']} • Min: ${alert['minStock']} ${alert['unit']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(alert['priority']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert['priority'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getPriorityColor(alert['priority']),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _formatDate(alert['alertDate']),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String date) {
    return date.split('-').reversed.join('/');
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