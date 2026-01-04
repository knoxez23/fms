import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pamoja_twalima/ui/marketplace/bulk_order_screen.dart';
import 'package:pamoja_twalima/ui/marketplace/export_inquiry_screen.dart';
import 'package:pamoja_twalima/ui/marketplace/import_inquiry_screen.dart';
import 'package:pamoja_twalima/ui/marketplace/product_detail_screen.dart';
import 'package:pamoja_twalima/ui/marketplace/sell_product_screen.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';
import 'package:pamoja_twalima/marketplace/application/application.dart';
import 'package:pamoja_twalima/marketplace/infrastructure/factory.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Map<String, dynamic>> _products = [];

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
      final mapped = items.map((row) => {
            'id': '${row['id']}',
            'name': row['name'] ?? row['item'] ?? 'Unknown',
            'price': row['price'] ?? 0,
            'image': row['image'],
            'category': row['category'] ?? 'Uncategorized',
            'status': row['status'] ?? 'Available',
          }).toList();
      if (!mounted) return;
      setState(() => _products = mapped);
    } catch (e) {
      // ignore errors for now
    }
  }

  String _selectedCategory = 'All';
  String _selectedSort = 'Popular';
  String _selectedView = 'Grid';
  String _searchQuery = '';
  double _priceRangeStart = 0;
  double _priceRangeEnd = 5000;
  bool _showFilters = false;
  bool _exportReadyOnly = false;
  bool _verifiedSellersOnly = false;

  final List<String> _categories = [
    'All',
    'Crops',
    'Vegetables',
    'Fruits',
    'Livestock',
    'Dairy',
    'Poultry',
    'Seeds',
    'Equipment'
  ];

  final List<String> _sortOptions = [
    'Popular',
    'Price: Low to High',
    'Price: High to Low',
    'Newest',
    'Best Rating',
    'Most Viewed'
  ];

  final List<String> _viewOptions = ['Grid', 'List'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Agricultural Marketplace',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: const Icon(LucideIcons.heart),
            onPressed: _showWishlist,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search and Filter Bar
          _buildSearchFilterBar(theme),

          // 📊 Marketplace Stats
          _buildMarketplaceStats(theme),

          // 🏷️ Category and View Controls
          _buildCategoryViewControls(theme),

          // 🎯 Advanced Filters (Expandable)
          if (_showFilters) _buildAdvancedFilters(theme),

          // 📦 Product Grid/List
          Expanded(
            child: _selectedView == 'Grid'
                ? ProductGridView(
                    products: filteredProducts,
                    theme: theme,
                    onProductTap: _navigateToProductDetail,
                    onAddToCart: _addToCart,
                    onAddToWishlist: _addToWishlist,
                  )
                : ProductListView(
                    products: filteredProducts,
                    theme: theme,
                    onProductTap: _navigateToProductDetail,
                    onAddToCart: _addToCart,
                    onAddToWishlist: _addToWishlist,
                  ),
          ),
          const SizedBox(height: 120),
        ],
      ),

      // 🛍️ Multi-action FAB
      floatingActionButton: _buildMultiActionFAB(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSearchFilterBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search products, sellers, categories...',
                    prefixIcon: Icon(LucideIcons.search,
                        color: theme.iconTheme.color?.withValues(alpha: 0.6)),
                    suffixIcon: IconButton(
                      icon: const Icon(LucideIcons.listFilter),
                      onPressed: () =>
                          setState(() => _showFilters = !_showFilters),
                    ),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceStats(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.subtleShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: '1.2K+',
            label: 'Products',
            icon: LucideIcons.package,
            theme: theme,
          ),
          _StatItem(
            value: '500+',
            label: 'Sellers',
            icon: LucideIcons.users,
            theme: theme,
          ),
          _StatItem(
            value: '98%',
            label: 'Satisfaction',
            icon: LucideIcons.star,
            theme: theme,
          ),
          _StatItem(
            value: '50+',
            label: 'Countries',
            icon: LucideIcons.globe,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryViewControls(ThemeData theme) {
    return Column(
      children: [
        const SizedBox(height: 8),
        // Categories Row (now on its own row)
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
                          : theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // Sort and View Controls Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Sort Dropdown
              PopupMenuButton<String>(
                onSelected: (value) => setState(() => _selectedSort = value),
                itemBuilder: (context) => _sortOptions.map((option) {
                  return PopupMenuItem(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedSort),
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.chevronDown, size: 16),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // View Toggle
              SegmentedButton<String>(
                segments: _viewOptions.map((view) {
                  return ButtonSegment<String>(
                    value: view,
                    icon: Icon(view == 'Grid'
                        ? LucideIcons.grid2x2
                        : LucideIcons.list),
                    label: Text(view),
                  );
                }).toList(),
                selected: <String>{_selectedView},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _selectedView = newSelection.first);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedFilters(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [AppColors.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Advanced Filters',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x),
                onPressed: () => setState(() => _showFilters = false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Price Range
          Text(
              'Price Range: KSh ${_priceRangeStart.toInt()} - KSh ${_priceRangeEnd.toInt()}'),
          RangeSlider(
            values: RangeValues(_priceRangeStart, _priceRangeEnd),
            min: 0,
            max: 10000,
            divisions: 100,
            onChanged: (RangeValues values) {
              setState(() {
                _priceRangeStart = values.start;
                _priceRangeEnd = values.end;
              });
            },
          ),
          const SizedBox(height: 16),
          // Additional Filters
          Row(
            children: [
              FilterChip(
                label: const Text('Export Ready'),
                selected: _exportReadyOnly,
                onSelected: (selected) =>
                    setState(() => _exportReadyOnly = selected),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Verified Sellers'),
                selected: _verifiedSellersOnly,
                onSelected: (selected) =>
                    setState(() => _verifiedSellersOnly = selected),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetFilters,
                  child: const Text('Reset Filters'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _showFilters = false),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiActionFAB(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Sell Item Button
          // Container(
          //   height: 50,
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(25),
          //     gradient: AppColors.primaryGradient,
          //     boxShadow: const [AppColors.cardShadow],
          //   ),
          //   child: FloatingActionButton.extended(
          //     backgroundColor: Colors.transparent,
          //     elevation: 0,
          //     onPressed: _navigateToSellWizard,
          //     icon: const Icon(LucideIcons.plus, color: Colors.white),
          //     label: const Text(
          //       "Sell Product",
          //       style: TextStyle(
          //         color: Colors.white,
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
          // const SizedBox(width: 12),
          // Quick Actions Menu
          FloatingActionButton(
            onPressed: _showQuickActions,
            backgroundColor: theme.colorScheme.secondary,
            child: const Icon(LucideIcons.plus, color: Colors.white),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredProducts() {
    List<Map<String, dynamic>> filtered = List.from(_products);

    // Category filter
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((p) => p['category'] == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final name = p['name'].toString().toLowerCase();
        final desc = p['desc'].toString().toLowerCase();
        final seller = p['seller']['name'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) ||
            desc.contains(query) ||
            seller.contains(query);
      }).toList();
    }

    // Price range filter
    filtered = filtered.where((p) {
      final price = p['price'] as double;
      return price >= _priceRangeStart && price <= _priceRangeEnd;
    }).toList();

    // Export ready filter
    if (_exportReadyOnly) {
      filtered = filtered.where((p) => p['exportReady'] == true).toList();
    }

    // Verified sellers filter
    if (_verifiedSellersOnly) {
      filtered =
          filtered.where((p) => p['seller']['verified'] == true).toList();
    }

    // Sort products
    filtered = _sortProducts(filtered);

    return filtered;
  }

  List<Map<String, dynamic>> _sortProducts(
      List<Map<String, dynamic>> products) {
    switch (_selectedSort) {
      case 'Price: Low to High':
        products.sort(
            (a, b) => (a['price'] as double).compareTo(b['price'] as double));
        break;
      case 'Price: High to Low':
        products.sort(
            (a, b) => (b['price'] as double).compareTo(a['price'] as double));
        break;
      case 'Newest':
        products.sort((a, b) =>
            (b['listedDate'] as String).compareTo(a['listedDate'] as String));
        break;
      case 'Best Rating':
        products.sort((a, b) => (b['seller']['rating'] as double)
            .compareTo(a['seller']['rating'] as double));
        break;
      case 'Most Viewed':
        products
            .sort((a, b) => (b['views'] as int).compareTo(a['views'] as int));
        break;
      // Popular (default) - combination of rating, views, and sales
      default:
        products.sort((a, b) {
          final aScore = (a['seller']['rating'] as double) *
              (a['views'] as int) *
              (a['sales'] as int);
          final bScore = (b['seller']['rating'] as double) *
              (b['views'] as int) *
              (b['sales'] as int);
          return bScore.compareTo(aScore);
        });
    }
    return products;
  }

  void _navigateToProductDetail(Map<String, dynamic> product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    // Implement add to cart logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} added to cart')),
    );
  }

  void _addToWishlist(Map<String, dynamic> product) {
    // Implement add to wishlist logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['name']} added to wishlist')),
    );
  }

  void _navigateToSellWizard() {
    // Navigate to sell product wizard
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SellProductScreen(),
      ),
    );
  }

  void _navigateToImportInquiry() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ImportInquiryScreen()),
    );
  }

  void _navigateToExportInquiry() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExportInquiryScreen()),
    );
  }

  void _navigateToBulkOrder() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BulkOrderScreen()),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickActionsMenu(
        onSellProduct: _navigateToSellWizard,
        onImportInquiry: _navigateToImportInquiry,
        onExportInquiry: _navigateToExportInquiry,
        onBulkOrder: _navigateToBulkOrder,
      ),
    );
  }

  void _showNotifications() {
    // Show notifications
  }

  void _showWishlist() {
    // Show wishlist
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'All';
      _priceRangeStart = 0;
      _priceRangeEnd = 5000;
      _exportReadyOnly = false;
      _verifiedSellersOnly = false;
      _searchQuery = '';
    });
  }
}

// 📊 Stat Item Widget
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final ThemeData theme;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// 🛒 Product Grid View
class ProductGridView extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final ThemeData theme;
  final Function(Map<String, dynamic>) onProductTap;
  final Function(Map<String, dynamic>) onAddToCart;
  final Function(Map<String, dynamic>) onAddToWishlist;

  const ProductGridView({
    super.key,
    required this.products,
    required this.theme,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onAddToWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          theme: theme,
          onTap: () => onProductTap(product),
          onAddToCart: () => onAddToCart(product),
          onAddToWishlist: () => onAddToWishlist(product),
          isGridView: true,
        );
      },
    );
  }
}

// 📋 Product List View
class ProductListView extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final ThemeData theme;
  final Function(Map<String, dynamic>) onProductTap;
  final Function(Map<String, dynamic>) onAddToCart;
  final Function(Map<String, dynamic>) onAddToWishlist;

  const ProductListView({
    super.key,
    required this.products,
    required this.theme,
    required this.onProductTap,
    required this.onAddToCart,
    required this.onAddToWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: product,
            theme: theme,
            onTap: () => onProductTap(product),
            onAddToCart: () => onAddToCart(product),
            onAddToWishlist: () => onAddToWishlist(product),
            isGridView: false,
          ),
        );
      },
    );
  }
}

// 🎴 Product Card Widget
class ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onAddToWishlist;
  final bool isGridView;

  const ProductCard({
    super.key,
    required this.product,
    required this.theme,
    required this.onTap,
    required this.onAddToCart,
    required this.onAddToWishlist,
    required this.isGridView,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridCard();
    } else {
      return _buildListCard();
    }
  }

  Widget _buildGridCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [AppColors.subtleShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product Image with Badges
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    product['image'],
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Export Badge
                if (product['exportReady'] == true)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'EXPORT',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                // Wishlist Button
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      LucideIcons.heart,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    onPressed: onAddToWishlist,
                  ),
                ),
              ],
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['desc'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Price and Seller
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'KSh ${product['price']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (product['originalPrice'] != null)
                          Text(
                            'KSh ${product['originalPrice']}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withValues(alpha: 0.4),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Seller Rating
                    Row(
                      children: [
                        Icon(LucideIcons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${product['seller']['rating']}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product['seller']['reviews']})',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard() {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [AppColors.subtleShadow],
        ),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(12)),
              child: Image.asset(
                product['image'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['desc'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'KSh ${product['price']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(LucideIcons.star,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text('${product['seller']['rating']}'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ⚡ Quick Actions Menu
class QuickActionsMenu extends StatelessWidget {
  final VoidCallback onSellProduct;
  final VoidCallback onImportInquiry;
  final VoidCallback onExportInquiry;
  final VoidCallback onBulkOrder;

  const QuickActionsMenu({
    super.key,
    required this.onSellProduct,
    required this.onImportInquiry,
    required this.onExportInquiry,
    required this.onBulkOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuickActionItem(
            icon: LucideIcons.plus,
            title: 'Sell Product',
            subtitle: 'List your farm products',
            onTap: onSellProduct,
          ),
          _QuickActionItem(
            icon: LucideIcons.download,
            title: 'Import Inquiry',
            subtitle: 'Source products internationally',
            onTap: onImportInquiry,
          ),
          _QuickActionItem(
            icon: LucideIcons.upload,
            title: 'Export Inquiry',
            subtitle: 'Export your products',
            onTap: onExportInquiry,
          ),
          _QuickActionItem(
            icon: LucideIcons.package,
            title: 'Bulk Order',
            subtitle: 'Place large quantity orders',
            onTap: onBulkOrder,
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
