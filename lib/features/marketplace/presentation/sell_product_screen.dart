import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/features/marketplace/domain/entities/product_entity.dart';
import 'package:pamoja_twalima/features/marketplace/domain/value_objects/value_objects.dart';

class SellProductScreen extends StatefulWidget {
  const SellProductScreen({super.key});

  @override
  State<SellProductScreen> createState() => _SellProductScreenState();
}

class _SellProductScreenState extends State<SellProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Product Information
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();
  final TextEditingController _maxOrderController = TextEditingController();

  // Product Details
  String _selectedCategory = 'Crops';
  String _selectedSubCategory = 'Grains';
  String _selectedUnit = 'kg';
  final List<String> _selectedCertifications = [];
  final List<String> _selectedDeliveryOptions = ['Pickup'];
  final List<String> _selectedPaymentMethods = ['M-Pesa'];

  // Export & Quality
  bool _isExportReady = false;
  bool _isBulkAvailable = true;
  String _qualityGrade = 'A';
  String _shelfLife = '';

  // Images
  final List<String> _productImages = [];

  final List<String> _categories = [
    'Crops',
    'Vegetables',
    'Fruits',
    'Livestock',
    'Dairy',
    'Poultry',
    'Seeds',
    'Equipment',
    'Other'
  ];

  final Map<String, List<String>> _subCategories = {
    'Crops': ['Grains', 'Coffee', 'Tea', 'Beans', 'Nuts', 'Other'],
    'Vegetables': ['Leafy', 'Root', 'Fruit-bearing', 'Other'],
    'Fruits': ['Tropical', 'Citrus', 'Berries', 'Other'],
    'Livestock': ['Cattle', 'Goats', 'Sheep', 'Pigs', 'Other'],
    'Dairy': ['Milk', 'Cheese', 'Yogurt', 'Butter', 'Other'],
    'Poultry': ['Layers', 'Broilers', 'Chicks', 'Eggs', 'Other'],
    'Seeds': ['Grains', 'Vegetables', 'Fruits', 'Other'],
    'Equipment': ['Tools', 'Machinery', 'Irrigation', 'Other'],
    'Other': ['Other']
  };

  final List<String> _units = [
    'kg',
    'grams',
    'liters',
    'pieces',
    'crates',
    'bags',
    'tons'
  ];
  final List<String> _certifications = [
    'Organic',
    'KEBS',
    'GlobalG.A.P.',
    'Fair Trade',
    'UTZ',
    'HACCP'
  ];
  final List<String> _deliveryOptions = [
    'Pickup',
    'Local Delivery',
    'Nationwide',
    'International Shipping',
    'Cold Chain'
  ];
  final List<String> _paymentMethods = [
    'M-Pesa',
    'Bank Transfer',
    'Cash on Delivery',
    'Escrow',
    'Letter of Credit'
  ];
  final List<String> _qualityGrades = [
    'A',
    'B',
    'C',
    'Premium',
    'Export Quality'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: ModernAppBar(
        title: 'Sell Product',
        variant: AppBarVariant.home,
        actions: [
          TextButton(
            onPressed: _saveAsDraft,
            child: const Text('Save Draft'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressIndicator(theme),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildProductInfoStep(theme),
                _buildProductDetailsStep(theme),
                _buildPricingStep(theme),
                _buildExportQualityStep(theme),
                _buildReviewStep(theme),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(theme),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [AppColors.subtleShadow],
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / 5,
            backgroundColor: theme.colorScheme.surface,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            _getStepTitle(_currentStep),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Product Information';
      case 1:
        return 'Product Details';
      case 2:
        return 'Pricing & Quantity';
      case 3:
        return 'Export & Quality';
      case 4:
        return 'Review & Publish';
      default:
        return '';
    }
  }

  Widget _buildProductInfoStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Product Images
            _AnimatedCard(
              index: 0,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Images',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildImageUploadSection(theme),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Basic Information
            _AnimatedCard(
              index: 1,
              theme: theme,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _productNameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Fresh Maize Grade A',
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
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description *',
                        border: OutlineInputBorder(),
                        hintText: 'Describe your product in detail...',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product description';
                        }
                        if (value.length < 50) {
                          return 'Description should be at least 50 characters';
                        }
                        return null;
                      },
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

  Widget _buildProductDetailsStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Category & Subcategory
          _AnimatedCard(
            index: 0,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Main Category *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                        _selectedSubCategory = _subCategories[value]!.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSubCategory,
                    items: (_subCategories[_selectedCategory] ?? ['Other'])
                        .map((subCategory) {
                      return DropdownMenuItem(
                        value: subCategory,
                        child: Text(subCategory),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Sub Category *',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedSubCategory = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Certifications
          _AnimatedCard(
            index: 1,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Certifications & Standards',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _certifications.map((certification) {
                      final isSelected =
                          _selectedCertifications.contains(certification);
                      return FilterChip(
                        label: Text(certification),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCertifications.add(certification);
                            } else {
                              _selectedCertifications.remove(certification);
                            }
                          });
                        },
                        backgroundColor: theme.cardTheme.color,
                        selectedColor:
                            theme.colorScheme.primary.withValues(alpha: 0.15),
                        checkmarkColor: theme.colorScheme.primary,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Pricing
          _AnimatedCard(
            index: 0,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pricing & Quantity',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: 'Price per Unit (KSh) *',
                      border: OutlineInputBorder(),
                      prefixText: 'KSh ',
                      hintText: 'e.g., 1200',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Available Quantity *',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 5000',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter quantity';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          items: _units.map((unit) {
                            return DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'Unit *',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedUnit = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _minOrderController,
                          decoration: const InputDecoration(
                            labelText: 'Minimum Order',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 100',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _maxOrderController,
                          decoration: const InputDecoration(
                            labelText: 'Maximum Order',
                            border: OutlineInputBorder(),
                            hintText: 'e.g., 1000',
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Delivery & Payment
          _AnimatedCard(
            index: 1,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery & Payment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMultiSelectSection(
                    'Delivery Options',
                    _deliveryOptions,
                    _selectedDeliveryOptions,
                    theme,
                  ),
                  const SizedBox(height: 16),
                  _buildMultiSelectSection(
                    'Payment Methods',
                    _paymentMethods,
                    _selectedPaymentMethods,
                    theme,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportQualityStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Export & Bulk
          _AnimatedCard(
            index: 0,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Export & Bulk Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Export Ready'),
                    subtitle: const Text(
                        'This product meets international export standards'),
                    value: _isExportReady,
                    onChanged: (value) =>
                        setState(() => _isExportReady = value),
                  ),
                  SwitchListTile(
                    title: const Text('Bulk Orders Available'),
                    subtitle: const Text('Accept large quantity orders'),
                    value: _isBulkAvailable,
                    onChanged: (value) =>
                        setState(() => _isBulkAvailable = value),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quality Information
          _AnimatedCard(
            index: 1,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quality Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _qualityGrade,
                    items: _qualityGrades.map((grade) {
                      return DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Quality Grade',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _qualityGrade = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    onChanged: (value) {
                      setState(() => _shelfLife = value.trim());
                    },
                    decoration: const InputDecoration(
                      labelText: 'Shelf Life',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 12 months, 14 days',
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

  Widget _buildReviewStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
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
                    'Product Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ReviewItem(
                    label: 'Product Name',
                    value: _productNameController.text,
                    theme: theme,
                  ),
                  _ReviewItem(
                    label: 'Category',
                    value: '$_selectedCategory > $_selectedSubCategory',
                    theme: theme,
                  ),
                  _ReviewItem(
                    label: 'Price',
                    value: 'KSh ${_priceController.text} per $_selectedUnit',
                    theme: theme,
                  ),
                  _ReviewItem(
                    label: 'Quantity',
                    value: '${_quantityController.text} $_selectedUnit',
                    theme: theme,
                  ),
                  _ReviewItem(
                    label: 'Export Ready',
                    value: _isExportReady ? 'Yes' : 'No',
                    theme: theme,
                  ),
                  _ReviewItem(
                    label: 'Certifications',
                    value: _selectedCertifications.join(', '),
                    theme: theme,
                  ),
                  if (_shelfLife.isNotEmpty)
                    _ReviewItem(
                      label: 'Shelf Life',
                      value: _shelfLife,
                      theme: theme,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Terms and Conditions
          _AnimatedCard(
            index: 1,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Terms & Conditions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'By publishing this product, you agree to our marketplace terms and conditions. '
                    'You confirm that the product information is accurate and you have the right to sell this product.',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (value) {}),
                      const Text('I agree to the terms and conditions'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(ThemeData theme) {
    return Column(
      children: [
        Container(
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _productImages.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.image,
                        size: 40,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                    const SizedBox(height: 8),
                    Text(
                      'Add Product Images',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                )
              : GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _productImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Image.asset(
                          _productImages[index],
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.close,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _addSampleImage,
          icon: const Icon(LucideIcons.upload),
          label: const Text('Upload Images'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiSelectSection(String title, List<String> options,
      List<String> selected, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selected.add(option);
                  } else {
                    selected.remove(option);
                  }
                });
              },
              backgroundColor: theme.cardTheme.color,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
              checkmarkColor: theme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        boxShadow: [AppColors.cardShadow],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(_currentStep == 4 ? 'Publish Product' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      if (_validateCurrentStep()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentStep++;
        });
      }
    } else {
      _publishProduct();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _formKey.currentState?.validate() ?? false;
      case 1:
        return _selectedCategory.isNotEmpty && _selectedSubCategory.isNotEmpty;
      case 2:
        return _priceController.text.isNotEmpty &&
            _quantityController.text.isNotEmpty;
      default:
        return true;
    }
  }

  void _addSampleImage() {
    setState(() {
      _productImages.add('assets/images/maize.jpg');
    });
  }

  void _removeImage(int index) {
    setState(() {
      _productImages.removeAt(index);
    });
  }

  void _saveAsDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product saved as draft')),
    );
  }

  Future<void> _publishProduct() async {
    if (!_validateCurrentStep()) return;

    final name = _productNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product name is required')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text) ?? 0.0;
    final quantity = double.tryParse(_quantityController.text) ?? 0.0;

    final product = ProductEntity(
      name: ProductName(name),
      category: _selectedCategory,
      price: Price(price),
      quantity: quantity,
      unit: _selectedUnit,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product published successfully!')),
    );
    Navigator.pop(context, product);
  }
}

extension on bool {
  void remove(String option) {}

  void add(String option) {}
}

class _ReviewItem extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _ReviewItem({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value.isEmpty ? 'Not set' : value,
              style: theme.textTheme.bodyMedium,
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
