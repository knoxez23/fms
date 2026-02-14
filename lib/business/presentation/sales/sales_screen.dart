import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'add_sale_screen.dart';
import 'sale_detail_screen.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/business/presentation/bloc/sales/sales_bloc.dart';
import 'package:pamoja_twalima/business/domain/entities/sale_entity.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SalesBloc>(
      create: (_) => getIt<SalesBloc>()..add(const SalesEvent.loadSales()),
      child: const SalesView(),
    );
  }
}

class SalesView extends StatefulWidget {
  const SalesView({super.key});

  @override
  State<SalesView> createState() => _SalesViewState();
}

class _SalesViewState extends State<SalesView> {
  String _selectedFilter = 'All';
  String _selectedPeriod = 'This Month';

  final List<String> _filters = [
    'All',
    'Dairy',
    'Poultry',
    'Livestock',
    'Other'
  ];

  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Year',
    'All Time'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<SalesBloc, SalesState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      },
      builder: (context, state) {
        final sales = state.maybeWhen(
          loaded: (items) => items,
          orElse: () => <SaleEntity>[],
        );

        final filteredSales = _selectedFilter == 'All'
            ? sales
            : sales.where((sale) => sale.type == _selectedFilter).toList();

        final totalRevenue =
            sales.fold(0.00, (sum, sale) => sum + sale.totalAmount.value);
        final pendingAmount = sales
            .where((sale) => sale.isPending)
            .fold(0.00, (sum, sale) => sum + sale.totalAmount.value);

        return AppScaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: const ModernAppBar(
            title: 'Sales',
            variant: AppBarVariant.home,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SectionHeader(
                    title: 'Performance',
                    icon: Icons.analytics,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _RevenueCard(
                        amount: totalRevenue,
                        label: 'Total Revenue',
                        color: Colors.green,
                        theme: theme,
                        icon: Icons.account_balance,
                      ),
                      _RevenueCard(
                        amount: pendingAmount,
                        label: 'Pending',
                        color: Colors.orange,
                        theme: theme,
                        icon: Icons.pending_actions,
                      ),
                      _RevenueCard(
                        amount: sales.length,
                        label: 'Transactions',
                        color: theme.colorScheme.primary,
                        theme: theme,
                        icon: Icons.receipt_long,
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Row
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      Expanded(
                        child: _SalesFilterDropdown(
                          value: _selectedFilter,
                          items: _filters,
                          onChanged: (value) =>
                              setState(() => _selectedFilter = value!),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SalesFilterDropdown(
                          value: _selectedPeriod,
                          items: _periods,
                          onChanged: (value) =>
                              setState(() => _selectedPeriod = value!),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Stats
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    children: [
                      _QuickStat(
                        icon: Icons.local_drink,
                        value: '18.5L',
                        label: 'Milk Today',
                        theme: theme,
                      ),
                      const SizedBox(width: 12),
                      _QuickStat(
                        icon: Icons.egg,
                        value: '120',
                        label: 'Eggs Today',
                        theme: theme,
                      ),
                      const SizedBox(width: 12),
                      _QuickStat(
                        icon: Icons.trending_up,
                        value: '+12%',
                        label: 'Growth',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),

              // Sales List
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final sale = filteredSales[index];
                      return _AnimatedCard(
                        index: index,
                        theme: theme,
                        child: _SaleItem(
                          sale: sale,
                          theme: theme,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SaleDetailScreen(sale: sale),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: filteredSales.length,
                  ),
                ),
              ),

              // Add bottom padding so content isn’t hidden by FAB or bottom bar
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: FloatingActionButton(
              heroTag: 'addSaleFAB',
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddSaleScreen()),
                );

                if (result == null || result is! SaleEntity) return;
                if (!context.mounted) return;

                context.read<SalesBloc>().add(SalesEvent.addSale(sale: result));
              },
              backgroundColor: theme.colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final dynamic amount;
  final String label;
  final Color color;
  final ThemeData theme;
  final IconData icon;

  const _RevenueCard({
    required this.amount,
    required this.label,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [AppColors.subtleShadow],
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'KSh ${amount.toStringAsFixed(0)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
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

class _SalesFilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final Function(String?) onChanged;
  final ThemeData theme;

  const _SalesFilterDropdown({
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

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SaleItem extends StatelessWidget {
  final SaleEntity sale;
  final ThemeData theme;
  final VoidCallback onTap;

  const _SaleItem({
    required this.sale,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = sale.isPending;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getProductColor(sale.type).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getProductIcon(sale.productName),
            color: _getProductColor(sale.type),
            size: 24,
          ),
        ),
        title: Text(
          sale.productName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${sale.quantity.value} ${sale.unit} • ${sale.customer}'),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTypeColor(sale.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sale.type,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getTypeColor(sale.type),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    sale.paymentStatus,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPending ? Colors.orange : Colors.green,
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'KSh ${sale.totalAmount.value}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              _formatDate(sale.date),
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

  Color _getProductColor(String type) {
    switch (type) {
      case 'Dairy':
        return Colors.blue;
      case 'Poultry':
        return Colors.orange;
      case 'Livestock':
        return Colors.brown;
      case 'Other':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getProductIcon(String product) {
    switch (product.toLowerCase()) {
      case 'milk':
        return Icons.local_drink;
      case 'eggs':
        return Icons.egg;
      case 'beef cattle':
      case 'goat meat':
        return Icons.agriculture;
      case 'manure':
        return Icons.eco;
      default:
        return Icons.shopping_cart;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Dairy':
        return Colors.blue;
      case 'Poultry':
        return Colors.orange;
      case 'Livestock':
        return Colors.brown;
      case 'Other':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
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
