import 'package:flutter/material.dart';
import 'package:pamoja_twalima/theme/app_colors.dart';

class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key});

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  final List<Map<String, dynamic>> _knowledgeTopics = [
    {
      'title': 'Maize Rust',
      'subtitle': 'Identify and treat common rust diseases in maize crops',
      'category': 'Crops',
      'readTime': '5 min read',
      'icon': Icons.agriculture,
    },
    {
      'title': 'Foot-and-Mouth Disease',
      'subtitle': 'Symptoms, prevention and treatment for livestock',
      'category': 'Livestock',
      'readTime': '8 min read',
      'icon': Icons.health_and_safety,
    },
    {
      'title': 'Stored Grain Pests',
      'subtitle': 'Effective prevention and control methods',
      'category': 'Storage',
      'readTime': '6 min read',
      'icon': Icons.pest_control,
    },
    {
      'title': 'Tomato Blight',
      'subtitle': 'Early detection and organic treatment options',
      'category': 'Vegetables',
      'readTime': '4 min read',
      'icon': Icons.spa,
    },
    {
      'title': 'Poultry Vaccination',
      'subtitle': 'Complete vaccination schedule for chickens',
      'category': 'Poultry',
      'readTime': '7 min read',
      'icon': Icons.medical_services,
    },
    {
      'title': 'Soil pH Management',
      'subtitle': 'Testing and adjusting soil acidity for better yields',
      'category': 'Soil Health',
      'readTime': '10 min read',
      'icon': Icons.terrain,
    },
  ];

  final List<String> _categories = [
    'All',
    'Crops',
    'Livestock',
    'Poultry',
    'Vegetables',
    'Soil Health',
    'Storage'
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredTopics = _knowledgeTopics.where((topic) {
      final matchesCategory = _selectedCategory == 'All' || topic['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          topic['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          topic['subtitle'].toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Knowledge Base',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
        child: Column(
          children: [
            // 🔍 Search Bar
            _AnimatedCard(
              index: 0,
              theme: theme,
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: 'Search diseases, crops, or treatments...',
                  prefixIcon: Icon(Icons.search, color: theme.iconTheme.color?.withOpacity(0.6)),
                  filled: true,
                  fillColor: theme.cardTheme.color,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🏷️ Category Chips
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
                        selectedColor: theme.colorScheme.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = category),
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

            const SizedBox(height: 16),

            // 📚 Results Count
            _AnimatedCard(
              index: 2,
              theme: theme,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filteredTopics.length} Articles Found',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedCategory != 'All')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedCategory,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 📖 Knowledge Topics List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filteredTopics.length,
                itemBuilder: (context, index) {
                  final topic = filteredTopics[index];

                  return _AnimatedCard(
                    index: index + 3,
                    theme: theme,
                    child: _KnowledgeCard(
                      title: topic['title'],
                      subtitle: topic['subtitle'],
                      category: topic['category'],
                      readTime: topic['readTime'],
                      icon: topic['icon'],
                      theme: theme,
                      onTap: () {
                        // TODO: Navigate to article detail
                      },
                      onBookmark: () {
                        // TODO: Implement bookmark functionality
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // 📚 Floating Action Button
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -90),
        child: _AnimatedCard(
          index: 0,
          theme: theme,
          child: Container(
            height: 50,
            width: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: AppColors.primaryGradient,
              boxShadow: const [AppColors.cardShadow],
            ),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                // TODO: Navigate to ask expert or suggest topic
              },
              icon: const Icon(Icons.lightbulb_outline, color: Colors.white),
              label: const Text(
                "Ask an Expert",
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

class _KnowledgeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final String readTime;
  final IconData icon;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _KnowledgeCard({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readTime,
    required this.icon,
    required this.theme,
    required this.onTap,
    required this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [AppColors.subtleShadow],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Bookmark
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            Icons.bookmark_border,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                            size: 20,
                          ),
                          onPressed: onBookmark,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Category and Read Time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),

                        const SizedBox(width: 4),

                        Text(
                          readTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
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