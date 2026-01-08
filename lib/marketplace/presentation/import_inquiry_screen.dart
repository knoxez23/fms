import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/marketplace/application/application.dart';
import 'package:pamoja_twalima/marketplace/infrastructure/factory.dart';

class ImportInquiryScreen extends StatefulWidget {
  const ImportInquiryScreen({super.key});

  @override
  State<ImportInquiryScreen> createState() => _ImportInquiryScreenState();
}

class _ImportInquiryScreenState extends State<ImportInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _specificationsController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();

  String _selectedCategory = 'Crops';
  String _selectedOrigin = 'Any';
  String _selectedQuality = 'Standard';

  List<Map<String, dynamic>> _products = [];
  List<String> _productNames = [];
  late final GetProducts _getProductsUseCase;

  @override
  void initState() {
    super.initState();
    _getProductsUseCase = MarketplaceFactory.createGetProducts();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final items = await _getProductsUseCase.execute();
      if (!mounted) return;
      setState(() {
        _products = items;
        _productNames = items
            .map((e) => (e['name'] ?? e['item'] ?? '').toString())
            .where((s) => s.isNotEmpty)
            .toSet()
            .toList();
      });
    } catch (_) {
      // ignore errors for now
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Import Product Inquiry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
                        'Product Requirements',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _productController,
                        decoration: InputDecoration(
                          labelText: 'Product Name *',
                          border: const OutlineInputBorder(),
                          hintText: 'e.g., Soybean Meal, Wheat Bran',
                          suffixIcon: _productNames.isEmpty
                              ? null
                              : PopupMenuButton<String>(
                                  icon: const Icon(Icons.arrow_drop_down),
                                  onSelected: (value) {
                                    setState(() => _productController.text = value);
                                  },
                                  itemBuilder: (context) => _productNames
                                      .map((p) => PopupMenuItem(value: p, child: Text(p)))
                                      .toList(),
                                ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: const [
                          'Crops',
                          'Animal Feed',
                          'Seeds',
                          'Equipment',
                          'Fertilizers',
                          'Other'
                        ].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Product Category *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
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
                        'Quantity & Specifications',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Required Quantity *',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 5000 kg',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _specificationsController,
                        decoration: const InputDecoration(
                          labelText: 'Specifications & Standards',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., Protein content >45%, GMO-free',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _AnimatedCard(
                index: 2,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logistics & Budget',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedOrigin,
                              items: const [
                                'Any',
                                'Brazil',
                                'USA',
                                'China',
                                'India',
                                'Thailand',
                                'Other'
                              ].map((origin) {
                                return DropdownMenuItem(
                                  value: origin,
                                  child: Text(origin),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: 'Preferred Origin',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedOrigin = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedQuality,
                              items: const [
                                'Standard',
                                'Premium',
                                'Export Quality',
                                'Organic'
                              ].map((quality) {
                                return DropdownMenuItem(
                                  value: quality,
                                  child: Text(quality),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: 'Quality Grade',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedQuality = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _budgetController,
                        decoration: const InputDecoration(
                          labelText: 'Budget Range (USD)',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 10000-15000',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _timelineController,
                        decoration: const InputDecoration(
                          labelText: 'Required Timeline',
                          border: OutlineInputBorder(),
                          hintText: 'e.g., 30-45 days',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitInquiry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit Import Inquiry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitInquiry() {
    if (_formKey.currentState!.validate()) {
      final inquiry = {
        'product': _productController.text,
        'category': _selectedCategory,
        'quantity': _quantityController.text,
        'specifications': _specificationsController.text,
        'origin': _selectedOrigin,
        'quality': _selectedQuality,
        'budget': _budgetController.text,
        'timeline': _timelineController.text,
        'type': 'import',
        'submittedAt': DateTime.now(),
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import inquiry submitted successfully!')),
      );

      Navigator.pop(context);
    }
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