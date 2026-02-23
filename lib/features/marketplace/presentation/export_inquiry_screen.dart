import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/features/marketplace/application/marketplace_usecases.dart';
import 'package:pamoja_twalima/features/marketplace/domain/entities/inquiry_entity.dart';
import 'package:pamoja_twalima/features/marketplace/domain/repositories/repositories.dart';
import 'package:pamoja_twalima/features/marketplace/presentation/bloc/marketplace/marketplace_bloc.dart';

class ExportInquiryScreen extends StatefulWidget {
  const ExportInquiryScreen({super.key});

  @override
  State<ExportInquiryScreen> createState() => _ExportInquiryScreenState();
}

class _ExportInquiryScreenState extends State<ExportInquiryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _specificationsController =
      TextEditingController();

  String _selectedDestination = 'Europe';
  String _selectedCertification = 'GlobalG.A.P.';

  List<String> _productNames = [];
  late final SubmitMarketplaceInquiry _submitMarketplaceInquiry;

  @override
  void initState() {
    super.initState();
    _submitMarketplaceInquiry =
        SubmitMarketplaceInquiry(getIt<MarketplaceRepository>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MarketplaceBloc>().add(const MarketplaceEvent.load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<MarketplaceBloc, MarketplaceState>(
      listener: (context, state) {
        state.when(
          initial: () {},
          loading: () {},
          loaded: (products) {
            setState(() {
              _productNames = products
                  .map((e) => e.name.value)
                  .where((s) => s.isNotEmpty)
                  .toSet()
                  .toList();
            });
          },
          error: (_) {},
        );
      },
      child: AppScaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: const ModernAppBar(
          title: 'Export Product Inquiry',
          variant: AppBarVariant.home,
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
                          'Export Product Details',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _productController,
                          decoration: InputDecoration(
                            labelText: 'Product for Export *',
                            border: const OutlineInputBorder(),
                            hintText: 'e.g., Coffee Beans, Avocados',
                            suffixIcon: _productNames.isEmpty
                                ? null
                                : PopupMenuButton<String>(
                                    icon: const Icon(Icons.arrow_drop_down),
                                    onSelected: (value) {
                                      setState(() =>
                                          _productController.text = value);
                                    },
                                    itemBuilder: (context) => _productNames
                                        .map((p) => PopupMenuItem(
                                            value: p, child: Text(p)))
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
                        TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Available Quantity *',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 10000 kg',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            return null;
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
                          'Export Destination & Requirements',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedDestination,
                          items: const [
                            'Europe',
                            'USA',
                            'Middle East',
                            'Asia',
                            'Other'
                          ].map((destination) {
                            return DropdownMenuItem(
                              value: destination,
                              child: Text(destination),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Target Market *',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedDestination = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCertification,
                          items: const [
                            'GlobalG.A.P.',
                            'Organic',
                            'Fair Trade',
                            'UTZ',
                            'HACCP',
                            'Other'
                          ].map((certification) {
                            return DropdownMenuItem(
                              value: certification,
                              child: Text(certification),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Required Certification',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedCertification = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _specificationsController,
                          decoration: const InputDecoration(
                            labelText: 'Special Requirements',
                            border: OutlineInputBorder(),
                            hintText:
                                'e.g., Specific packaging, phytosanitary requirements',
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
                          'Export Readiness',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const ListTile(
                          leading: Icon(LucideIcons.circleCheck,
                              color: Colors.green),
                          title: Text('Product meets export standards'),
                          subtitle: Text(
                              'Ensure your product complies with international requirements'),
                        ),
                        const ListTile(
                          leading:
                              Icon(LucideIcons.package, color: Colors.blue),
                          title: Text('Proper packaging available'),
                          subtitle: Text('Export-grade packaging materials'),
                        ),
                        const ListTile(
                          leading:
                              Icon(LucideIcons.truck, color: Colors.orange),
                          title: Text('Logistics arranged'),
                          subtitle: Text('Shipping and customs clearance'),
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
                    child: const Text('Submit Export Inquiry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitInquiry() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _submitMarketplaceInquiry.execute(
          InquiryEntity(
            inquiryType: 'export',
            productName: _productController.text.trim(),
            category: 'Export',
            quantity: _quantityController.text.trim(),
            details: [
              'destination=$_selectedDestination',
              'certification=$_selectedCertification',
              if (_specificationsController.text.trim().isNotEmpty)
                'requirements=${_specificationsController.text.trim()}',
            ].join('; '),
            createdAt: DateTime.now(),
          ),
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Export inquiry submitted successfully!')),
        );
        Navigator.pop(context);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit export inquiry')),
        );
      }
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
