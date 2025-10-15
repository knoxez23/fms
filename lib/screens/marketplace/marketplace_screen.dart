import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pamoja_twalima/screens/marketplace/product_detail_screen.dart';
import 'package:pamoja_twalima/theme/app_colors.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final List<Map<String, dynamic>> _mockProducts = [
    {
      'name': 'Fresh Maize',
      'price': 1200,
      'desc': 'High-quality dry maize from local farms.',
      'image': 'assets/images/maize.jpg',
      'category': 'Crops'
    },
    {
      'name': 'Tomatoes (Crate)',
      'price': 800,
      'desc': 'Farm-fresh red tomatoes — full crate.',
      'image': 'assets/images/tomatoes_crate.jpg',
      'category': 'Vegetables'
    },
    {
      'name': 'Layer Hens',
      'price': 450,
      'desc': 'Healthy layers ready to produce eggs.',
      'image': 'assets/images/hen.jpg',
      'category': 'Livestock'
    },
    {
      'name': 'Milk (20L)',
      'price': 950,
      'desc': 'Freshly collected whole milk (20 liters).',
      'image': 'assets/images/milk.jpg',
      'category': 'Dairy'
    },
    {
      'name': 'Fresh Maize',
      'price': 1200,
      'desc': 'High-quality dry maize from local farms.',
      'image': 'assets/images/maize.jpg',
      'category': 'Crops'
    },
    {
      'name': 'Tomatoes (Crate)',
      'price': 800,
      'desc': 'Farm-fresh red tomatoes — full crate.',
      'image': 'assets/images/tomatoes_crate.jpg',
      'category': 'Vegetables'
    },
    {
      'name': 'Layer Hens',
      'price': 450,
      'desc': 'Healthy layers ready to produce eggs.',
      'image': 'assets/images/hen.jpg',
      'category': 'Livestock'
    },
    {
      'name': 'Milk (20L)',
      'price': 950,
      'desc': 'Freshly collected whole milk (20 liters).',
      'image': 'assets/images/milk.jpg',
      'category': 'Dairy'
    },
    {
      'name': 'Fresh Maize',
      'price': 1200,
      'desc': 'High-quality dry maize from local farms.',
      'image': 'assets/images/maize.jpg',
      'category': 'Crops'
    },
    {
      'name': 'Tomatoes (Crate)',
      'price': 800,
      'desc': 'Farm-fresh red tomatoes — full crate.',
      'image': 'assets/images/tomatoes_crate.jpg',
      'category': 'Vegetables'
    },
    {
      'name': 'Layer Hens',
      'price': 450,
      'desc': 'Healthy layers ready to produce eggs.',
      'image': 'assets/images/hen.jpg',
      'category': 'Livestock'
    },
    {
      'name': 'Milk (20L)',
      'price': 950,
      'desc': 'Freshly collected whole milk (20 liters).',
      'image': 'assets/images/milk.jpg',
      'category': 'Dairy'
    },
  ];

  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Crops',
    'Vegetables',
    'Livestock',
    'Dairy'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProducts = _selectedCategory == 'All'
        ? _mockProducts
        : _mockProducts
        .where((p) => p['category'] == _selectedCategory)
        .toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Marketplace',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding:
        const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 80),
        child: Column(
          children: [
            // 🔍 Search bar
            _AnimatedCard(
              index: 0,
              theme: theme,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(LucideIcons.search,
                      color: theme.iconTheme.color?.withOpacity(0.6)),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 🏷️ Category chips
            _AnimatedCard(
              index: 1,
              theme: theme,
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        checkmarkColor: theme.colorScheme.primary,
                        selectedColor:
                        theme.colorScheme.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.8),
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                        backgroundColor: theme.cardTheme.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                          side: BorderSide(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.dividerColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 🛒 Product grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];

                  return _AnimatedCard(
                    index: index + 2, // Offset by search and categories
                    theme: theme,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: Hero(
                        tag: product['name'],
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [AppColors.subtleShadow],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16)),
                                child: Image.asset(
                                  product['image'],
                                  height: 110,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      product['desc'],
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Ksh ${product['price']}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.secondary
                                                .withOpacity(0.12),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            product['category'],
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.colorScheme.secondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 🛍️ Floating action button moved here (consistent with design)
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -90),
        child: _AnimatedCard(
          index: 0,
          theme: theme,
          child: Container(
            height: 50,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: AppColors.primaryGradient,
              boxShadow: const [AppColors.cardShadow],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                // TODO: Navigate to sell-item wizard
              },
              icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
              label: const Text(
                "Sell Item",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
      duration: const Duration(milliseconds: 700),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.1 * widget.index,
          0.8,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.1 * widget.index,
          1,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
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