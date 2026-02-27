import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'bloc/knowledge/knowledge_cubit.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<KnowledgeCubit>()..load(),
      child: const _KnowledgeView(),
    );
  }
}

class _KnowledgeView extends StatelessWidget {
  const _KnowledgeView();

  static const List<String> _categories = [
    'All',
    'Crops',
    'Livestock',
    'Poultry',
    'Vegetables',
    'Soil Health',
    'Storage',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<KnowledgeCubit, KnowledgeState>(
      builder: (context, state) {
        final filteredTopics = state.topics.where((topic) {
          final matchesCategory = state.selectedCategory == _allCategory ||
              topic.category == state.selectedCategory;
          final query = state.searchQuery.trim().toLowerCase();
          final matchesSearch = query.isEmpty ||
              topic.title.toLowerCase().contains(query) ||
              topic.subtitle.toLowerCase().contains(query);
          return matchesCategory && matchesSearch;
        }).toList();

        return AppScaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: ModernAppBar(
            title: context.tr('knowledge_base'),
            variant: AppBarVariant.home,
          ),
          body: Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80),
            child: Column(
              children: [
                _AnimatedCard(
                  index: 0,
                  theme: theme,
                  child: TextField(
                    onChanged: (value) =>
                        context.read<KnowledgeCubit>().updateSearch(value),
                    decoration: InputDecoration(
                      hintText: context.tr('search_knowledge_hint'),
                      prefixIcon: Icon(
                        Icons.search,
                        color: theme.iconTheme.color?.withValues(alpha: 0.6),
                      ),
                      filled: true,
                      fillColor: theme.cardTheme.color,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
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
                        final isSelected = category == state.selectedCategory;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_categoryLabel(context, category)),
                            selected: isSelected,
                            checkmarkColor: theme.colorScheme.primary,
                            selectedColor: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) => context
                                .read<KnowledgeCubit>()
                                .selectCategory(category),
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
                ),
                const SizedBox(height: 16),
                _AnimatedCard(
                  index: 2,
                  theme: theme,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('articles_found').replaceFirst(
                            '{count}', '${filteredTopics.length}'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (state.selectedCategory != _allCategory)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _categoryLabel(context, state.selectedCategory),
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
                          title: topic.title,
                          subtitle: topic.subtitle,
                          category: topic.category,
                          readTime: topic.readTime,
                          icon: _iconForKey(topic.iconKey),
                          theme: theme,
                          isBookmarked:
                              state.bookmarkedTopics.contains(topic.title),
                          onTap: () {
                            // NOTE: Navigate to article detail
                          },
                          onBookmark: () {
                            context
                                .read<KnowledgeCubit>()
                                .toggleBookmark(topic.title);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
                  boxShadow: [AppColors.cardShadow],
                ),
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () {
                    // NOTE: Navigate to ask expert or suggest topic
                  },
                  icon:
                      const Icon(Icons.lightbulb_outline, color: Colors.white),
                  label: Text(
                    context.tr('ask_expert'),
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  IconData _iconForKey(String key) {
    switch (key) {
      case 'agriculture':
        return Icons.agriculture;
      case 'health':
        return Icons.health_and_safety;
      case 'pest':
        return Icons.pest_control;
      case 'spa':
        return Icons.spa;
      case 'medical':
        return Icons.medical_services;
      case 'terrain':
        return Icons.terrain;
      default:
        return Icons.menu_book;
    }
  }

  String _categoryLabel(BuildContext context, String category) {
    switch (category) {
      case _allCategory:
        return context.tr('knowledge_category_all');
      case 'Crops':
        return context.tr('knowledge_category_crops');
      case 'Livestock':
        return context.tr('knowledge_category_livestock');
      case 'Poultry':
        return context.tr('knowledge_category_poultry');
      case 'Vegetables':
        return context.tr('knowledge_category_vegetables');
      case 'Soil Health':
        return context.tr('knowledge_category_soil_health');
      case 'Storage':
        return context.tr('knowledge_category_storage');
      default:
        return category;
    }
  }

  static const String _allCategory = 'All';
}

class _KnowledgeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String category;
  final String readTime;
  final IconData icon;
  final ThemeData theme;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmark;

  const _KnowledgeCard({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.readTime,
    required this.icon,
    required this.theme,
    required this.isBookmarked,
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
          boxShadow: [AppColors.subtleShadow],
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
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
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
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: isBookmarked
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface
                                    .withValues(alpha: 0.5),
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
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.7),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary
                                .withValues(alpha: 0.12),
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
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          readTime,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
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
