import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/repositories/local_data.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _notesController = TextEditingController();

  String _category = 'Feed';
  String _paymentMethod = 'Cash';
  DateTime _expenseDate = DateTime.now();
  bool _saving = false;

  final List<String> _categories = const [
    'Feed',
    'Seeds',
    'Fertilizer',
    'Veterinary',
    'Labor',
    'Transport',
    'Utilities',
    'Equipment',
    'Other',
  ];

  final List<String> _paymentMethods = const [
    'Cash',
    'M-Pesa',
    'Bank Transfer',
    'Credit',
  ];

  @override
  void dispose() {
    _itemController.dispose();
    _amountController.dispose();
    _vendorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppScaffold(
      includeDrawer: false,
      backgroundColor: theme.colorScheme.surface,
      appBar: const ModernAppBar(
        title: 'Add Expense',
        variant: AppBarVariant.standard,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _sectionCard(
                theme: theme,
                title: 'Expense Details',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      items: _categories
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _category = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemController,
                      decoration: const InputDecoration(
                        labelText: 'Item or service',
                        hintText: 'e.g. Dairy meal, transport, labor',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter the expense item';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        hintText: 'e.g. 2500',
                        border: OutlineInputBorder(),
                        prefixText: 'KSh ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final amount = double.tryParse((value ?? '').trim());
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid amount';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                theme: theme,
                title: 'Payment',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _paymentMethod,
                      items: _paymentMethods
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      decoration: const InputDecoration(
                        labelText: 'Payment method',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _paymentMethod = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vendorController,
                      decoration: const InputDecoration(
                        labelText: 'Vendor or payee',
                        hintText: 'Optional',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Expense date'),
                      subtitle: Text(_formatDate(_expenseDate)),
                      trailing: TextButton(
                        onPressed: _pickDate,
                        child: const Text('Change'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _sectionCard(
                theme: theme,
                title: 'Notes',
                child: TextFormField(
                  controller: _notesController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Why was this expense made?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: _saving ? null : _saveExpense,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(_saving ? 'Saving...' : 'Save Expense'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
            backgroundColor: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    required ThemeData theme,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _expenseDate = picked);
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await LocalData.insertExpense({
        'category': _category,
        'item_name': _itemController.text.trim(),
        'amount': double.parse(_amountController.text.trim()),
        'expense_date': _expenseDate.toIso8601String(),
        'vendor_name': _vendorController.text.trim().isEmpty
            ? null
            : _vendorController.text.trim(),
        'payment_method': _paymentMethod,
        'notes': _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      });

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
