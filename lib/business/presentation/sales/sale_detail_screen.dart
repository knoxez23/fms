import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/business/domain/entities/sale_entity.dart';

class SaleDetailScreen extends StatefulWidget {
  final SaleEntity sale;

  const SaleDetailScreen({super.key, required this.sale});

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.sale.paymentStatus;
    final statusLower = status.toLowerCase();
    final isPending = statusLower == 'pending';
    final isPartial = statusLower == 'partial';
    final total = widget.sale.totalAmount.value;
    final paidAmount =
        statusLower == 'paid' ? total : (isPartial ? total * 0.5 : 0.0);
    final dueAmount = (total - paidAmount).clamp(0.0, total);
    final animal = widget.sale.animal;
    final notes = widget.sale.notes;

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title: 'Sale Details',
        variant: AppBarVariant.standard,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sale Overview Card
            _AnimatedCard(
              index: 0,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _getProductColor(widget.sale.type)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getProductIcon(widget.sale.productName),
                            color: _getProductColor(widget.sale.type),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.sale.productName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.sale.quantity.value} ${widget.sale.unit}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.sale.paymentStatus)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.sale.paymentStatus,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getStatusColor(widget.sale.paymentStatus),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              Text(
                                'KSh ${widget.sale.totalAmount.value}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          if (isPending || isPartial)
                            ElevatedButton(
                              onPressed: _markAsPaid,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Mark as Paid'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Sale Details
            _AnimatedCard(
              index: 1,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sale Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Product Type',
                      value: widget.sale.type,
                      theme: theme,
                    ),
                    _DetailRow(
                      label: 'Quantity',
                      value:
                          '${widget.sale.quantity.value} ${widget.sale.unit}',
                      theme: theme,
                    ),
                    _DetailRow(
                      label: 'Unit Price',
                      value: 'KSh ${widget.sale.pricePerUnit.value}',
                      theme: theme,
                    ),
                    _DetailRow(
                      label: 'Customer',
                      value: widget.sale.customer,
                      theme: theme,
                    ),
                    if (animal != null && animal.isNotEmpty)
                      _DetailRow(
                        label: 'Source',
                        value: animal,
                        theme: theme,
                      ),
                    _DetailRow(
                      label: 'Sale Date',
                      value: _formatDisplayDate(widget.sale.date),
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Payment Information
            _AnimatedCard(
              index: 2,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _DetailRow(
                      label: 'Payment Status',
                      value: widget.sale.paymentStatus,
                      theme: theme,
                      valueColor: _getStatusColor(widget.sale.paymentStatus),
                    ),
                    _DetailRow(
                      label: 'Total Amount',
                      value: 'KSh ${widget.sale.totalAmount.value}',
                      theme: theme,
                      isHighlighted: true,
                    ),
                    if (isPartial)
                      _DetailRow(
                        label: 'Paid Amount',
                        value: 'KSh ${paidAmount.toStringAsFixed(2)}',
                        theme: theme,
                      ),
                    if (isPartial || isPending)
                      _DetailRow(
                        label: 'Due Amount',
                        value: 'KSh ${dueAmount.toStringAsFixed(2)}',
                        theme: theme,
                        valueColor: Colors.orange,
                      ),
                  ],
                ),
              ),
            ),

            // Notes Section (if available)
            if (notes != null && notes.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 16),
                  _AnimatedCard(
                    index: 3,
                    theme: theme,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notes,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Action Buttons
            _AnimatedCard(
              index: 4,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _shareSale,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share, size: 18),
                            SizedBox(width: 8),
                            Text('Share'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _deleteSale,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline, size: 18),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
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
        return Theme.of(context).colorScheme.primary;
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
      case 'sheep meat':
      case 'pork':
        return Icons.agriculture;
      case 'manure':
        return Icons.eco;
      case 'yogurt':
      case 'cheese':
      case 'butter':
        return Icons.breakfast_dining;
      default:
        return Icons.shopping_cart;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Partial':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatDisplayDate(DateTime? date) {
    if (date == null) return '—';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _markAsPaid() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: const Text('Are you sure you want to mark this sale as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update sale status logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sale marked as paid')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _shareSale() {
    // Share sale details logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing sale details...')),
    );
  }

  void _deleteSale() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text(
            'Are you sure you want to delete this sale record? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete sale logic here
              Navigator.pop(context);
              Navigator.pop(context); // Go back to sales list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sale deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;
  final bool isHighlighted;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
    this.isHighlighted = false,
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
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: valueColor ??
                  (isHighlighted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
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
