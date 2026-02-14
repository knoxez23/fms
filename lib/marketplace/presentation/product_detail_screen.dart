import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isInWishlist = false;
  late Map<String, dynamic> _product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = _product;
    final seller = (product['seller'] is Map<String, dynamic>)
        ? product['seller'] as Map<String, dynamic>
        : <String, dynamic>{};

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      body: CustomScrollView(
        slivers: [
          // App Bar with Back Button and Actions
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(theme, product),
            ),
            actions: [
              IconButton(
                icon:
                    Icon(_isInWishlist ? LucideIcons.heart : LucideIcons.heart),
                color: _isInWishlist ? Colors.red : Colors.white,
                onPressed: _toggleWishlist,
              ),
              IconButton(
                icon: const Icon(LucideIcons.share2),
                color: Colors.white,
                onPressed: _shareProduct,
              ),
            ],
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Header
                  _buildProductHeader(theme, product),

                  const SizedBox(height: 16),

                  // Seller Information
                  _buildSellerInfo(theme, seller),

                  const SizedBox(height: 16),

                  // Quantity Selector
                  _buildQuantitySelector(theme),

                  const SizedBox(height: 16),

                  // Product Details Tabs
                  _buildProductDetailsTabs(theme, product),
                ],
              ),
            ),
          ),
        ],
      ),

      // Fixed Purchase Bar
      bottomNavigationBar: _buildPurchaseBar(theme, product),
    );
  }

  @override
  void initState() {
    super.initState();
    _product = Map<String, dynamic>.from(widget.product);
  }

  Widget _buildImageGallery(ThemeData theme, Map<String, dynamic> product) {
    final images = [
      product['image']
    ]; // In real app, use product['images'] list

    return Stack(
      children: [
        // Main Image
        PageView.builder(
          itemCount: images.length,
          onPageChanged: (index) => setState(() => _selectedImageIndex = index),
          itemBuilder: (context, index) {
            return Image.asset(
              images[index],
              fit: BoxFit.cover,
              width: double.infinity,
            );
          },
        ),

        // Image Indicators
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedImageIndex == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              );
            }),
          ),
        ),

        // Export Badge
        if (product['exportReady'] == true)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'EXPORT READY',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductHeader(ThemeData theme, Map<String, dynamic> product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product['category'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            Icon(LucideIcons.eye,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(width: 4),
            Text(
              '${product['views']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          product['name'],
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product['desc'],
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'KSh ${product['price']}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (product['originalPrice'] != null) ...[
              const SizedBox(width: 8),
              Text(
                'KSh ${product['originalPrice']}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        if (product['originalPrice'] != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${((1 - (product['price'] as double) / (product['originalPrice'] as double)) * 100).toStringAsFixed(0)}% OFF',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSellerInfo(ThemeData theme, Map<String, dynamic> seller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            child: Icon(LucideIcons.store, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      seller['name'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (seller['verified'] == true) ...[
                      const SizedBox(width: 4),
                      Icon(LucideIcons.badgeCheck,
                          size: 16, color: Colors.blue),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  seller['location'],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${seller['rating']}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${seller['reviews']} reviews)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.messageCircle),
            onPressed: _contactSeller,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quantity',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.minus),
                      onPressed: _quantity > 1 ? _decreaseQuantity : null,
                    ),
                    Container(
                      width: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        _quantity.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.plus),
                      onPressed: _increaseQuantity,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Unit Display
              Text(
                widget.product['unit'],
                style: theme.textTheme.bodyMedium,
              ),
              const Spacer(),
              // Available Stock
              Text(
                '${widget.product['quantity']} ${widget.product['unit']} available',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          if (widget.product['minOrder'] != null) ...[
            const SizedBox(height: 8),
            Text(
              'Minimum order: ${widget.product['minOrder']} ${widget.product['unit']}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductDetailsTabs(
      ThemeData theme, Map<String, dynamic> product) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.subtleShadow],
            ),
            child: TabBar(
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.6),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              tabs: const [
                Tab(text: 'Details'),
                Tab(text: 'Specs'),
                Tab(text: 'Shipping'),
                Tab(text: 'Reviews'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: TabBarView(
              children: [
                _buildDetailsTab(theme, product),
                _buildSpecsTab(theme, product),
                _buildShippingTab(theme, product),
                _buildReviewsTab(theme, product),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(ThemeData theme, Map<String, dynamic> product) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailItem(
            label: 'Product Description',
            value: product['desc'],
            theme: theme,
          ),
          _DetailItem(
            label: 'Category',
            value: '${product['category']} > ${product['subCategory']}',
            theme: theme,
          ),
          _DetailItem(
            label: 'Quality Grade',
            value: product['qualityGrade'] ?? 'A',
            theme: theme,
          ),
          _DetailItem(
            label: 'Shelf Life',
            value: product['shelfLife'] ?? 'Not specified',
            theme: theme,
          ),
          if (product['certifications'] != null) ...[
            const SizedBox(height: 16),
            Text(
              'Certifications',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (product['certifications'] as List).map((cert) {
                return Chip(
                  label: Text(cert),
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecsTab(ThemeData theme, Map<String, dynamic> product) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _SpecItem(
            label: 'Available Quantity',
            value: '${product['quantity']} ${product['unit']}',
            theme: theme,
          ),
          _SpecItem(
            label: 'Minimum Order',
            value: '${product['minOrder'] ?? '1'} ${product['unit']}',
            theme: theme,
          ),
          _SpecItem(
            label: 'Maximum Order',
            value: '${product['maxOrder'] ?? 'No limit'} ${product['unit']}',
            theme: theme,
          ),
          _SpecItem(
            label: 'Export Ready',
            value: product['exportReady'] == true ? 'Yes' : 'No',
            theme: theme,
          ),
          _SpecItem(
            label: 'Bulk Orders',
            value: product['isBulkAvailable'] == true
                ? 'Available'
                : 'Not Available',
            theme: theme,
          ),
          if (product['variety'] != null)
            _SpecItem(
              label: 'Variety',
              value: product['variety'],
              theme: theme,
            ),
          if (product['size'] != null)
            _SpecItem(
              label: 'Size',
              value: product['size'],
              theme: theme,
            ),
        ],
      ),
    );
  }

  Widget _buildShippingTab(ThemeData theme, Map<String, dynamic> product) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _ShippingItem(
            label: 'Delivery Options',
            options: product['deliveryOptions'] ?? ['Pickup'],
            theme: theme,
          ),
          _ShippingItem(
            label: 'Payment Methods',
            options: product['paymentMethods'] ?? ['M-Pesa'],
            theme: theme,
          ),
          const SizedBox(height: 16),
          Text(
            'Shipping Information',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Delivery time varies based on location and delivery option selected. '
            'International shipping available for export-ready products.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(ThemeData theme, Map<String, dynamic> product) {
    final seller = product['seller'];
    final reviews = [
      {
        'user': 'John M.',
        'rating': 5.0,
        'comment':
            'Excellent quality maize, exactly as described. Will order again!',
        'date': '2 weeks ago'
      },
      {
        'user': 'Sarah K.',
        'rating': 4.0,
        'comment': 'Good product, fast delivery. Packaging could be better.',
        'date': '1 month ago'
      }
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          // Rating Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Text(
                      seller['rating'].toString(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(LucideIcons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${seller['rating']}'),
                      ],
                    ),
                    Text(
                      '${seller['reviews']} reviews',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _RatingBar(star: 5, percentage: 0.8, theme: theme),
                      _RatingBar(star: 4, percentage: 0.15, theme: theme),
                      _RatingBar(star: 3, percentage: 0.05, theme: theme),
                      _RatingBar(star: 2, percentage: 0.0, theme: theme),
                      _RatingBar(star: 1, percentage: 0.0, theme: theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Reviews List
          ...reviews.map((review) => _ReviewCard(review: review, theme: theme)),
        ],
      ),
    );
  }

  Widget _buildPurchaseBar(ThemeData theme, Map<String, dynamic> product) {
    final totalPrice = (product['price'] as double) * _quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [AppColors.cardShadow],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'KSh ${totalPrice.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            // Action Buttons
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _addToCart,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _buyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    setState(() {
      if (_quantity > 1) _quantity--;
    });
  }

  void _toggleWishlist() {
    setState(() {
      _isInWishlist = !_isInWishlist;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isInWishlist ? 'Added to wishlist' : 'Removed from wishlist'),
      ),
    );
  }

  void _shareProduct() {
    // Implement share functionality
  }

  void _contactSeller() {
    // Implement contact seller functionality
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added to cart')),
    );
  }

  void _buyNow() {
    // Implement buy now functionality
  }
}

// Supporting Widgets for Product Detail Screen
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailItem({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _SpecItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _SpecItem({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShippingItem extends StatelessWidget {
  final String label;
  final List<dynamic> options;
  final ThemeData theme;

  const _ShippingItem({
    required this.label,
    required this.options,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              return Chip(
                label: Text(option.toString()),
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  final int star;
  final double percentage;
  final ThemeData theme;

  const _RatingBar({
    required this.star,
    required this.percentage,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(width: 4),
          Icon(LucideIcons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: theme.colorScheme.surface,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(percentage * 100).toInt()}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final ThemeData theme;

  const _ReviewCard({
    required this.review,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  review['user'][0],
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['user'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(LucideIcons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(review['rating'].toString()),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                review['date'],
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['comment'],
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
