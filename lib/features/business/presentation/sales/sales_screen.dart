import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';
import 'package:pamoja_twalima/features/business/presentation/contacts/contacts_screen.dart';
import 'package:pamoja_twalima/features/business/presentation/expenses/add_expense_screen.dart';
import 'add_sale_screen.dart';
import 'sale_detail_screen.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/features/business/presentation/bloc/sales/sales_bloc.dart';
import 'package:pamoja_twalima/features/business/domain/entities/sale_entity.dart';
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
  int _financeRefreshTick = 0;

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
        final periodSales = filteredSales
            .where((sale) => _isInSelectedPeriod(sale.date, _selectedPeriod))
            .toList();

        final totalRevenue = periodSales.fold(
          0.00,
          (sum, sale) => sum + sale.totalAmount.value,
        );
        final pendingAmount = periodSales
            .where((sale) => sale.isPending)
            .fold(0.00, (sum, sale) => sum + sale.totalAmount.value);
        final paidSales = periodSales
            .where((sale) => sale.paymentStatus.toLowerCase() == 'paid')
            .length;
        final pendingSales = periodSales.where((sale) => sale.isPending).length;
        final avgOrder = periodSales.isEmpty
            ? 0.0
            : totalRevenue / periodSales.length.toDouble();

        return AppScaffold(
          backgroundColor: theme.colorScheme.surface,
          includeDrawer: false,
          appBar: ModernAppBar(
            title: context.tr('sales'),
            variant: AppBarVariant.home,
            actions: [
              _OpenContactsButton(),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: SectionHeader(
                    title: context.tr('performance'),
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
                        label: context.tr('total_revenue'),
                        color: Colors.green,
                        theme: theme,
                        icon: Icons.account_balance,
                      ),
                      _RevenueCard(
                        amount: pendingAmount,
                        label: context.tr('pending'),
                        color: Colors.orange,
                        theme: theme,
                        icon: Icons.pending_actions,
                      ),
                      _RevenueCard(
                        amount: sales.length,
                        label: context.tr('transactions'),
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
                        child: FilterDropdown(
                          value: _selectedFilter,
                          items: _filters,
                          onChanged: (value) =>
                              setState(() => _selectedFilter = value!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilterDropdown(
                          value: _selectedPeriod,
                          items: _periods,
                          onChanged: (value) =>
                              setState(() => _selectedPeriod = value!),
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
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.receipt,
                          value: periodSales.length.toString(),
                          label: context.tr('sales'),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.check_circle_outline,
                          value: paidSales.toString(),
                          label: context.tr('paid'),
                          theme: theme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickStat(
                          icon: Icons.hourglass_empty,
                          value: pendingSales.toString(),
                          label: context.tr('pending'),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [AppColors.subtleShadow],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stacked_line_chart,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('average_order_value'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        Text(
                          'KSh ${avgOrder.toStringAsFixed(0)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: SectionHeader(
                    title: 'Cashflow',
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<_BusinessFinanceData>(
                    future: _loadFinanceData(_financeRefreshTick),
                    builder: (context, snapshot) {
                      final finance =
                          snapshot.data ?? const _BusinessFinanceData.empty();
                      return _BusinessFinancePanel(
                        theme: theme,
                        finance: finance,
                        onCreateOutputDraft: _openOutputSaleDraft,
                      );
                    },
                  ),
                ),
              ),

              // Sales List
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: periodSales.isEmpty
                    ? SliverToBoxAdapter(
                        child: const _SalesEmptyState(),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final sale = periodSales[index];
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
                                      builder: (_) =>
                                          SaleDetailScreen(sale: sale),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: periodSales.length,
                        ),
                      ),
              ),

              // Add bottom padding so content isn’t hidden by FAB or bottom bar
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
          floatingActionButton: AppFabStack(
            actions: [
              AppFabAction(
                heroTag: 'addSaleFAB',
                icon: Icons.add,
                tooltip: 'Add business record',
                onPressed: _openAddActions,
                backgroundColor: theme.colorScheme.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openAddActions() async {
    final selection = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.receipt_long),
                  ),
                  title: const Text('Record Sale'),
                  subtitle:
                      const Text('Add revenue from sold produce or livestock'),
                  onTap: () => Navigator.of(sheetContext).pop('sale'),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.money_off_csred_outlined),
                  ),
                  title: const Text('Add Expense'),
                  subtitle: const Text(
                      'Track feed, labor, transport, vet, and other costs'),
                  onTap: () => Navigator.of(sheetContext).pop('expense'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || selection == null) return;
    if (selection == 'sale') {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddSaleScreen()),
      );

      if (result == null || !mounted) return;
      final sale = switch (result) {
        SaleDraftResult draft => draft.sale,
        SaleEntity saleEntity => saleEntity,
        _ => null,
      };
      if (sale == null) return;
      context.read<SalesBloc>().add(SalesEvent.addSale(sale: sale));
      setState(() => _financeRefreshTick++);
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (result == true && mounted) {
      setState(() => _financeRefreshTick++);
    }
  }

  Future<_BusinessFinanceData> _loadFinanceData(int _) async {
    final results = await Future.wait([
      LocalData.getFarmSummary(),
      LocalData.getRecentExpenses(limit: 4),
      LocalData.getRevenueByType(),
      LocalData.getExpensesByCategory(),
    ]);
    return _BusinessFinanceData(
      summary: results[0] as Map<String, dynamic>,
      expenses: results[1] as List<Map<String, dynamic>>,
      revenueByType: results[2] as List<Map<String, dynamic>>,
      expensesByCategory: results[3] as List<Map<String, dynamic>>,
    );
  }

  Future<void> _openOutputSaleDraft(_OutputSaleDraft draft) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddSaleScreen(
          initialType: draft.type,
          initialProductName: draft.productName,
          initialQuantity: draft.quantity,
          initialUnit: draft.unit,
          initialNotes:
              'Draft created from ready output currently sitting in stock.',
          automationMessage: draft.message,
        ),
      ),
    );

    if (result == null || !mounted) return;
    final sale = switch (result) {
      SaleDraftResult draftResult => draftResult.sale,
      SaleEntity saleEntity => saleEntity,
      _ => null,
    };
    if (sale == null) return;

    context.read<SalesBloc>().add(SalesEvent.addSale(sale: sale));
    setState(() => _financeRefreshTick++);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${draft.productName} sale draft saved successfully.'),
      ),
    );
  }

  bool _isInSelectedPeriod(DateTime? date, String period) {
    if (period == 'All Time') return true;
    if (date == null) return false;

    final now = DateTime.now();
    final d = DateTime(date.year, date.month, date.day);
    final n = DateTime(now.year, now.month, now.day);

    switch (period) {
      case 'Today':
        return d == n;
      case 'This Week':
        final startOfWeek = n.subtract(Duration(days: n.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return !d.isBefore(startOfWeek) && !d.isAfter(endOfWeek);
      case 'This Month':
        return d.year == n.year && d.month == n.month;
      case 'This Year':
        return d.year == n.year;
      default:
        return true;
    }
  }
}

class _BusinessFinanceData {
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> expenses;
  final List<Map<String, dynamic>> revenueByType;
  final List<Map<String, dynamic>> expensesByCategory;

  const _BusinessFinanceData({
    required this.summary,
    required this.expenses,
    required this.revenueByType,
    required this.expensesByCategory,
  });

  const _BusinessFinanceData.empty()
      : summary = const {},
        expenses = const [],
        revenueByType = const [],
        expensesByCategory = const [];
}

class _BusinessFinancePanel extends StatelessWidget {
  final ThemeData theme;
  final _BusinessFinanceData finance;
  final Future<void> Function(_OutputSaleDraft draft)? onCreateOutputDraft;

  const _BusinessFinancePanel({
    required this.theme,
    required this.finance,
    this.onCreateOutputDraft,
  });

  @override
  Widget build(BuildContext context) {
    final summary = finance.summary;
    final netFlow = ((summary['monthlyNetCashFlow'] as num?) ?? 0).toDouble();
    final expenses = finance.expenses;
    final revenueByType = finance.revenueByType.take(3).toList();
    final expensesByCategory = finance.expensesByCategory.take(3).toList();
    final milkToday = ((summary['milkToday'] as num?) ?? 0).toDouble();
    final eggsToday = ((summary['eggsToday'] as num?) ?? 0).toDouble();
    final milkSoldToday =
        ((summary['milkSoldToday'] as num?) ?? 0).toDouble();
    final eggsSoldToday =
        ((summary['eggsSoldToday'] as num?) ?? 0).toDouble();
    final milkStockOnHand =
        ((summary['milkStockOnHand'] as num?) ?? 0).toDouble();
    final eggsStockOnHand =
        ((summary['eggsStockOnHand'] as num?) ?? 0).toDouble();
    final outputStockValue =
        ((summary['outputStockValue'] as num?) ?? 0).toDouble();
    final pendingCollectionsValue =
        ((summary['pendingCollectionsValue'] as num?) ?? 0).toDouble();
    final restockCostEstimate =
        ((summary['restockCostEstimate'] as num?) ?? 0).toDouble();
    final projectedCashBuffer =
        ((summary['projectedCashBuffer'] as num?) ?? 0).toDouble();
    final freshnessRiskCount =
        ((summary['freshnessRiskCount'] as num?) ?? 0).toInt();
    final freshnessPriorityLabel =
        (summary['freshnessPriorityLabel'] ?? '').toString().trim();
    final oldestFreshOutputAgeHours =
        ((summary['oldestFreshOutputAgeHours'] as num?) ?? 0).toDouble();
    final verificationScore =
        ((summary['verificationScore'] as num?) ?? 0).toInt();
    final verificationBand =
        (summary['verificationBand'] ?? 'Needs work').toString();
    final marketplaceTrustScore =
        ((summary['marketplaceTrustScore'] as num?) ?? 0).toInt();
    final marketplaceTrustBand =
        (summary['marketplaceTrustBand'] ?? 'Needs work').toString();
    final lendingReadinessScore =
        ((summary['lendingReadinessScore'] as num?) ?? 0).toInt();
    final lendingReadinessBand =
        (summary['lendingReadinessBand'] ?? 'Needs work').toString();
    final operationsHealthScore =
        ((summary['operationsHealthScore'] as num?) ?? 0).toInt();
    final operationsHealthBand =
        (summary['operationsHealthBand'] ?? 'Needs work').toString();
    final executionPressureBand =
        (summary['executionPressureBand'] ?? 'Stable').toString();
    final enterpriseFocus = (summary['enterpriseFocus'] ?? 'Mixed farm')
        .toString()
        .trim();
    final costDisciplineBand =
        (summary['costDisciplineBand'] ?? 'Building').toString();
    final collectionsDisciplineBand =
        (summary['collectionsDisciplineBand'] ?? 'Building').toString();
    final milkTrendBand = (summary['milkTrendBand'] ?? 'No data').toString();
    final eggsTrendBand = (summary['eggsTrendBand'] ?? 'No data').toString();
    final breedingReviewsDue =
        ((summary['breedingReviewsDue'] as num?) ?? 0).toInt();
    final treatmentFollowUps =
        ((summary['treatmentFollowUps'] as num?) ?? 0).toInt();
    final cropStageReviewsDue =
        ((summary['cropStageReviewsDue'] as num?) ?? 0).toInt();
    final enterpriseAdvicePrimary =
        (summary['enterpriseAdvicePrimary'] ?? '').toString().trim();
    final enterpriseAdviceSecondary =
        (summary['enterpriseAdviceSecondary'] ?? '').toString().trim();
    final advicePrimary = (summary['advicePrimary'] ?? '').toString().trim();
    final adviceSecondary =
        (summary['adviceSecondary'] ?? '').toString().trim();
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _FinanceMetricTile(
                  theme: theme,
                  label: 'Income',
                  value:
                      'KSh ${((summary['monthlySales'] as num?) ?? 0).toStringAsFixed(0)}',
                  color: Colors.green,
                  icon: Icons.trending_up,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinanceMetricTile(
                  theme: theme,
                  label: 'Expenses',
                  value:
                      'KSh ${((summary['monthlyExpenses'] as num?) ?? 0).toStringAsFixed(0)}',
                  color: Colors.redAccent,
                  icon: Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (netFlow >= 0 ? Colors.teal : Colors.deepOrange)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  netFlow >= 0
                      ? Icons.account_balance_wallet_outlined
                      : Icons.warning_amber_rounded,
                  color: netFlow >= 0 ? Colors.teal : Colors.deepOrange,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Monthly net flow',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'KSh ${netFlow.toStringAsFixed(0)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: netFlow >= 0 ? Colors.teal : Colors.deepOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CollapsibleCardSection(
            title: 'Outlook',
            icon: Icons.insights_outlined,
            child: _FinanceOutlookCard(
              theme: theme,
              pendingCollectionsValue: pendingCollectionsValue,
              restockCostEstimate: restockCostEstimate,
              projectedCashBuffer: projectedCashBuffer,
              freshnessRiskCount: freshnessRiskCount,
              freshnessPriorityLabel: freshnessPriorityLabel,
              oldestFreshOutputAgeHours: oldestFreshOutputAgeHours,
              verificationScore: verificationScore,
              verificationBand: verificationBand,
              marketplaceTrustScore: marketplaceTrustScore,
              marketplaceTrustBand: marketplaceTrustBand,
              lendingReadinessScore: lendingReadinessScore,
              lendingReadinessBand: lendingReadinessBand,
            ),
          ),
          const SizedBox(height: 14),
          CollapsibleCardSection(
            title: 'Management signals',
            icon: Icons.tips_and_updates_outlined,
            child: _ManagementSignalsCard(
              theme: theme,
              operationsHealthScore: operationsHealthScore,
              operationsHealthBand: operationsHealthBand,
              executionPressureBand: executionPressureBand,
              advicePrimary: advicePrimary,
              adviceSecondary: adviceSecondary,
            ),
          ),
          const SizedBox(height: 14),
          CollapsibleCardSection(
            title: 'Operations review',
            icon: Icons.rule_folder_outlined,
            initiallyExpanded: false,
            child: _OperationsReviewCard(
              theme: theme,
              enterpriseFocus: enterpriseFocus,
              costDisciplineBand: costDisciplineBand,
              collectionsDisciplineBand: collectionsDisciplineBand,
              milkTrendBand: milkTrendBand,
              eggsTrendBand: eggsTrendBand,
              breedingReviewsDue: breedingReviewsDue,
              treatmentFollowUps: treatmentFollowUps,
              cropStageReviewsDue: cropStageReviewsDue,
              enterpriseAdvicePrimary: enterpriseAdvicePrimary,
              enterpriseAdviceSecondary: enterpriseAdviceSecondary,
            ),
          ),
          const SizedBox(height: 14),
          CollapsibleCardSection(
            title: 'Output pipeline',
            icon: Icons.inventory_2_outlined,
            child: _OutputPipelineCard(
              theme: theme,
              milkToday: milkToday,
              eggsToday: eggsToday,
              milkSoldToday: milkSoldToday,
              eggsSoldToday: eggsSoldToday,
              milkStockOnHand: milkStockOnHand,
              eggsStockOnHand: eggsStockOnHand,
              outputStockValue: outputStockValue,
              onCreateDraft: onCreateOutputDraft,
            ),
          ),
          const SizedBox(height: 14),
          CollapsibleCardSection(
            title: 'Unit economics',
            icon: Icons.stacked_bar_chart_outlined,
            initiallyExpanded: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _BreakdownCard(
                    theme: theme,
                    title: 'Revenue by line',
                    emptyLabel: 'No sales yet',
                    accent: Colors.green,
                    rows: revenueByType,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BreakdownCard(
                    theme: theme,
                    title: 'Costs by category',
                    emptyLabel: 'No expenses yet',
                    accent: Colors.redAccent,
                    rows: expensesByCategory,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          CollapsibleCardSection(
            title: 'Recent expenses',
            icon: Icons.money_off_csred_outlined,
            initiallyExpanded: false,
            child: expenses.isEmpty
                ? Text(
                    'No expenses recorded yet. Start with feed, vet, labor, or transport.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  )
                : Column(
                    children: expenses
                        .map(
                          (expense) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ListItemCard(
                              icon: Icons.money_off_csred_outlined,
                              iconColor: Colors.redAccent,
                              title: (expense['item_name'] ?? 'Expense')
                                  .toString(),
                              subtitle:
                                  '${expense['category'] ?? 'Other'} • ${_dateLabel(expense['expense_date']?.toString())}',
                              trailing: Text(
                                'KSh ${((expense['amount'] as num?) ?? 0).toStringAsFixed(0)}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(String? value) {
    final date = value == null ? null : DateTime.tryParse(value);
    if (date == null) return 'No date';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ManagementSignalsCard extends StatelessWidget {
  final ThemeData theme;
  final int operationsHealthScore;
  final String operationsHealthBand;
  final String executionPressureBand;
  final String advicePrimary;
  final String adviceSecondary;

  const _ManagementSignalsCard({
    required this.theme,
    required this.operationsHealthScore,
    required this.operationsHealthBand,
    required this.executionPressureBand,
    required this.advicePrimary,
    required this.adviceSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = operationsHealthScore >= 80
        ? Colors.teal
        : operationsHealthScore >= 60
            ? Colors.orange
            : Colors.redAccent;
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      color: scoreColor.withValues(alpha: 0.08),
      boxShadow: const [],
      border: Border.all(color: scoreColor.withValues(alpha: 0.18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _FinanceMetricTile(
                  theme: theme,
                  label: 'Ops health',
                  value: '$operationsHealthScore',
                  color: scoreColor,
                  icon: Icons.health_and_safety_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinanceMetricTile(
                  theme: theme,
                  label: 'Execution pressure',
                  value: executionPressureBand,
                  color: executionPressureBand == 'High'
                      ? Colors.redAccent
                      : executionPressureBand == 'Moderate'
                          ? Colors.orange
                          : Colors.teal,
                  icon: Icons.speed_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Farmly rates current operations as $operationsHealthBand. Use these advice cues to tighten execution before finance and output quality start slipping.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
            ),
          ),
          if (advicePrimary.isNotEmpty) ...[
            const SizedBox(height: 10),
            _AdviceRow(theme: theme, text: advicePrimary),
          ],
          if (adviceSecondary.isNotEmpty) ...[
            const SizedBox(height: 8),
            _AdviceRow(theme: theme, text: adviceSecondary),
          ],
        ],
      ),
    );
  }
}

class _AdviceRow extends StatelessWidget {
  final ThemeData theme;
  final String text;

  const _AdviceRow({
    required this.theme,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.tips_and_updates_outlined,
            size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _OperationsReviewCard extends StatelessWidget {
  const _OperationsReviewCard({
    required this.theme,
    required this.enterpriseFocus,
    required this.costDisciplineBand,
    required this.collectionsDisciplineBand,
    required this.milkTrendBand,
    required this.eggsTrendBand,
    required this.breedingReviewsDue,
    required this.treatmentFollowUps,
    required this.cropStageReviewsDue,
    required this.enterpriseAdvicePrimary,
    required this.enterpriseAdviceSecondary,
  });

  final ThemeData theme;
  final String enterpriseFocus;
  final String costDisciplineBand;
  final String collectionsDisciplineBand;
  final String milkTrendBand;
  final String eggsTrendBand;
  final int breedingReviewsDue;
  final int treatmentFollowUps;
  final int cropStageReviewsDue;
  final String enterpriseAdvicePrimary;
  final String enterpriseAdviceSecondary;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.secondary.withValues(alpha: 0.08),
      boxShadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TaskPill(label: 'Lead enterprise: $enterpriseFocus'),
              _TaskPill(label: 'Cost discipline: $costDisciplineBand'),
              _TaskPill(label: 'Collections: $collectionsDisciplineBand'),
              _TaskPill(label: 'Milk trend: $milkTrendBand'),
              _TaskPill(label: 'Egg trend: $eggsTrendBand'),
              if (breedingReviewsDue > 0)
                _TaskPill(label: '$breedingReviewsDue breeding due'),
              if (treatmentFollowUps > 0)
                _TaskPill(label: '$treatmentFollowUps treatment checks'),
              if (cropStageReviewsDue > 0)
                _TaskPill(label: '$cropStageReviewsDue crop timing reviews'),
            ],
          ),
          if (enterpriseAdvicePrimary.isNotEmpty) ...[
            const SizedBox(height: 10),
            _AdviceRow(theme: theme, text: enterpriseAdvicePrimary),
          ],
          if (enterpriseAdviceSecondary.isNotEmpty) ...[
            const SizedBox(height: 8),
            _AdviceRow(theme: theme, text: enterpriseAdviceSecondary),
          ],
        ],
      ),
    );
  }
}

class _TaskPill extends StatelessWidget {
  const _TaskPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ChipPill(
      label: label,
      color: Theme.of(context).colorScheme.primary,
      outlined: true,
    );
  }
}

class _FinanceOutlookCard extends StatelessWidget {
  final ThemeData theme;
  final double pendingCollectionsValue;
  final double restockCostEstimate;
  final double projectedCashBuffer;
  final int freshnessRiskCount;
  final String freshnessPriorityLabel;
  final double oldestFreshOutputAgeHours;
  final int verificationScore;
  final String verificationBand;
  final int marketplaceTrustScore;
  final String marketplaceTrustBand;
  final int lendingReadinessScore;
  final String lendingReadinessBand;

  const _FinanceOutlookCard({
    required this.theme,
    required this.pendingCollectionsValue,
    required this.restockCostEstimate,
    required this.projectedCashBuffer,
    required this.freshnessRiskCount,
    required this.freshnessPriorityLabel,
    required this.oldestFreshOutputAgeHours,
    required this.verificationScore,
    required this.verificationBand,
    required this.marketplaceTrustScore,
    required this.marketplaceTrustBand,
    required this.lendingReadinessScore,
    required this.lendingReadinessBand,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      boxShadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _FinanceMetricTile(
                  theme: theme,
                  label: 'To collect',
                  value: 'KSh ${pendingCollectionsValue.toStringAsFixed(0)}',
                  color: Colors.indigo,
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinanceMetricTile(
                  theme: theme,
                  label: 'Restock pressure',
                  value: 'KSh ${restockCostEstimate.toStringAsFixed(0)}',
                  color: Colors.deepOrange,
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: projectedCashBuffer >= 0
                  ? Colors.teal.withValues(alpha: 0.1)
                  : Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  projectedCashBuffer >= 0
                      ? Icons.account_balance_wallet_outlined
                      : Icons.warning_amber_rounded,
                  color: projectedCashBuffer >= 0
                      ? Colors.teal
                      : Colors.redAccent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    projectedCashBuffer >= 0
                        ? 'Projected operating buffer stays positive after collections and likely restocking.'
                        : 'Collections or margins need attention. Current restocking pressure would push cash negative.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'KSh ${projectedCashBuffer.toStringAsFixed(0)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: projectedCashBuffer >= 0
                        ? Colors.teal
                        : Colors.redAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (freshnessRiskCount > 0 || freshnessPriorityLabel.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.timelapse_outlined, color: Colors.amber.shade900),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      freshnessPriorityLabel.isEmpty
                          ? '$freshnessRiskCount fresh-output lot(s) need faster selling.'
                          : '$freshnessPriorityLabel. Oldest stock is about ${oldestFreshOutputAgeHours.toStringAsFixed(0)}h old.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.amber.shade900,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ScoreChip(
                theme: theme,
                label: 'Verification $verificationScore',
                detail: verificationBand,
                color: Colors.blueGrey,
              ),
              _ScoreChip(
                theme: theme,
                label: 'Market trust $marketplaceTrustScore',
                detail: marketplaceTrustBand,
                color: Colors.green,
              ),
              _ScoreChip(
                theme: theme,
                label: 'Lending readiness $lendingReadinessScore',
                detail: lendingReadinessBand,
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String detail;
  final Color color;

  const _ScoreChip({
    required this.theme,
    required this.label,
    required this.detail,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ChipPill(
      label: '$label • $detail',
      color: color,
    );
  }
}

class _OutputPipelineCard extends StatelessWidget {
  final ThemeData theme;
  final double milkToday;
  final double eggsToday;
  final double milkSoldToday;
  final double eggsSoldToday;
  final double milkStockOnHand;
  final double eggsStockOnHand;
  final double outputStockValue;
  final Future<void> Function(_OutputSaleDraft draft)? onCreateDraft;

  const _OutputPipelineCard({
    required this.theme,
    required this.milkToday,
    required this.eggsToday,
    required this.milkSoldToday,
    required this.eggsSoldToday,
    required this.milkStockOnHand,
    required this.eggsStockOnHand,
    required this.outputStockValue,
    this.onCreateDraft,
  });

  @override
  Widget build(BuildContext context) {
    final hasOutput = milkToday > 0 ||
        eggsToday > 0 ||
        milkStockOnHand > 0 ||
        eggsStockOnHand > 0;
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      color: Colors.amber.withValues(alpha: 0.09),
      boxShadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!hasOutput)
            Text(
              'No milk or egg output has moved through stock or sales yet today.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            )
          else ...[
            _OutputPipelineRow(
              theme: theme,
              label: 'Milk today',
              produced: milkToday,
              sold: milkSoldToday,
              inStock: milkStockOnHand,
              unit: 'liters',
            ),
            const SizedBox(height: 8),
            _OutputPipelineRow(
              theme: theme,
              label: 'Eggs today',
              produced: eggsToday,
              sold: eggsSoldToday,
              inStock: eggsStockOnHand,
              unit: 'pieces',
            ),
            if (outputStockValue > 0) ...[
              const SizedBox(height: 10),
              Text(
                'Estimated output value in stock: KSh ${outputStockValue.toStringAsFixed(0)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.amber.shade900,
                ),
              ),
            ],
            if (onCreateDraft != null &&
                (milkStockOnHand > 0 || eggsStockOnHand > 0)) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (milkStockOnHand > 0)
                    FilledButton.tonalIcon(
                      onPressed: () => onCreateDraft!(
                        _OutputSaleDraft(
                          productName: 'Milk',
                          type: 'Dairy',
                          quantity: milkStockOnHand,
                          unit: 'liters',
                          message:
                              'Prefilled from milk currently sitting in stock. Confirm customer and pricing, then save the sale draft.',
                        ),
                      ),
                      icon: const Icon(Icons.local_drink_outlined),
                      label: Text(
                        'Sell ${_formatQty(milkStockOnHand)} liters milk',
                      ),
                    ),
                  if (eggsStockOnHand > 0)
                    FilledButton.tonalIcon(
                      onPressed: () => onCreateDraft!(
                        _OutputSaleDraft(
                          productName: 'Eggs',
                          type: 'Poultry',
                          quantity: eggsStockOnHand,
                          unit: 'pieces',
                          message:
                              'Prefilled from eggs currently sitting in stock. Confirm customer and pricing, then save the sale draft.',
                        ),
                      ),
                      icon: const Icon(Icons.egg_alt_outlined),
                      label: Text(
                        'Sell ${_formatQty(eggsStockOnHand)} eggs',
                      ),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatQty(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _OutputSaleDraft {
  final String productName;
  final String type;
  final double quantity;
  final String unit;
  final String message;

  const _OutputSaleDraft({
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.message,
  });
}

class _OutputPipelineRow extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final double produced;
  final double sold;
  final double inStock;
  final String unit;

  const _OutputPipelineRow({
    required this.theme,
    required this.label,
    required this.produced,
    required this.sold,
    required this.inStock,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final unsold = (produced - sold) > 0 ? (produced - sold) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _PipelinePill(
              theme: theme,
              label: 'Produced ${_qty(produced)} $unit',
              color: Colors.blueGrey,
            ),
            _PipelinePill(
              theme: theme,
              label: 'Sold ${_qty(sold)} $unit',
              color: Colors.green,
            ),
            if (inStock > 0)
              _PipelinePill(
                theme: theme,
                label: 'In stock ${_qty(inStock)} $unit',
                color: Colors.orange,
              ),
            if (unsold > 0)
              _PipelinePill(
                theme: theme,
                label: 'Still to move ${_qty(unsold)} $unit',
                color: Colors.deepOrange,
              ),
          ],
        ),
      ],
    );
  }

  String _qty(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _PipelinePill extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final Color color;

  const _PipelinePill({
    required this.theme,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ChipPill(label: label, color: color);
  }
}

class _BreakdownCard extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String emptyLabel;
  final Color accent;
  final List<Map<String, dynamic>> rows;

  const _BreakdownCard({
    required this.theme,
    required this.title,
    required this.emptyLabel,
    required this.accent,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      color: accent.withValues(alpha: 0.08),
      boxShadow: const [],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            Text(
              emptyLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
              ),
            )
          else
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (row['label'] ?? 'Other').toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'KSh ${((row['total'] as num?) ?? 0).toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FinanceMetricTile extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _FinanceMetricTile({
    required this.theme,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return MetricTile(
      label: label,
      value: value,
      icon: icon,
      color: color,
      compact: true,
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
      child: MetricTile(
        label: label,
        value: 'KSh ${amount.toStringAsFixed(0)}',
        icon: icon,
        color: color,
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
    return MetricTile(
      label: label,
      value: value,
      icon: icon,
      color: theme.colorScheme.primary,
      compact: true,
    );
  }
}

class _OpenContactsButton extends StatelessWidget {
  const _OpenContactsButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Manage Contacts',
      icon: const Icon(Icons.contacts_outlined),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ContactsScreen()),
        );
      },
    );
  }
}

class _SalesEmptyState extends StatelessWidget {
  const _SalesEmptyState();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No sales in this filter',
      subtitle: 'Create a new sale or adjust your period/category filters.',
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListItemCard(
        icon: _getProductIcon(sale.productName),
        iconColor: _getProductColor(sale.type),
        title: sale.productName,
        subtitle: '${sale.quantity.value} ${sale.unit} • ${sale.customer}',
        badges: [
          ChipPill(
            label: sale.type,
            color: _getTypeColor(sale.type),
          ),
          ChipPill(
            label: sale.paymentStatus,
            color: isPending ? Colors.orange : Colors.green,
          ),
        ],
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
