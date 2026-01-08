import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';

/// A reusable animated card widget that fades in and slides up
/// Perfect for list items, cards, or any content that needs animation
///
/// Usage:
/// ```dart
/// AnimatedCard(
///   index: 0,
///   child: Text('Your content here'),
/// )
/// ```
class AnimatedCard extends StatefulWidget {
  /// The child widget to display inside the card
  final Widget child;

  /// Index used to stagger animations in lists
  final int index;

  /// Optional title for cards
  final String? title;

  /// Title Styling
  final TextStyle? titleStyle;

  /// Custom padding inside the card
  final EdgeInsetsGeometry? padding;

  /// Custom margin around the card
  final EdgeInsetsGeometry? margin;

  /// Custom background color (defaults to theme card color)
  final Color? backgroundColor;

  /// Custom border radius
  final double? borderRadius;

  /// Whether to show shadow
  final bool showShadow;

  /// Animation duration in milliseconds
  final int durationMs;

  /// Delay before animation starts (per index) in milliseconds
  final int delayPerIndexMs;

  /// Custom shadow
  final List<BoxShadow>? boxShadow;

  /// Whether to animate on tap (scale effect)
  final bool animateOnTap;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.child,
    required this.index,
    this.title,
    this.titleStyle,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.showShadow = true,
    this.durationMs = 500,
    this.delayPerIndexMs = 100,
    this.boxShadow,
    this.animateOnTap = false,
    this.onTap,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;
  

  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimation();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
    );

    // Stagger effect based on index
    final start = (0.1 * widget.index).clamp(0.0, 0.6);
    final end = (0.3 + 0.1 * widget.index).clamp(0.4, 1.0);

    // Fade animation
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    // Slide animation
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    
  }

  void _startAnimation() {
    Future.delayed(
      Duration(milliseconds: widget.delayPerIndexMs * widget.index),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  void _handleTap() {
    if (widget.animateOnTap) {
      setState(() => _isTapped = true);
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _isTapped = false);
      });
    }
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 8),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.cardTheme.color,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
        boxShadow: widget.showShadow
            ? (widget.boxShadow ?? [AppColors.subtleShadow])
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title != null) ...[
            Text(
              widget.title!,
              style: widget.titleStyle ??
                  theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(
              height: 8,
            )
          ],
          widget.child
        ],
      ),
    );

    // Add tap functionality if needed
    if (widget.onTap != null || widget.animateOnTap) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
          child: content,
        ),
      );
    }

    // Apply scale animation on tap
    if (widget.animateOnTap && _isTapped) {
      content = Transform.scale(
        scale: 0.98,
        child: content,
      );
    }

    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: content,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// VARIATIONS & HELPERS
// ═══════════════════════════════════════════════════════════════

/// A simple version without container decoration
/// Useful when you want animation but custom styling
class AnimatedWidget extends StatefulWidget {
  final Widget child;
  final int index;
  final int durationMs;
  final int delayPerIndexMs;

  const AnimatedWidget({
    super.key,
    required this.child,
    required this.index,
    this.durationMs = 500,
    this.delayPerIndexMs = 100,
  });

  @override
  State<AnimatedWidget> createState() => _AnimatedWidgetState();
}

class _AnimatedWidgetState extends State<AnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.durationMs),
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

    Future.delayed(
      Duration(milliseconds: widget.delayPerIndexMs * widget.index),
      () {
        if (mounted) _controller.forward();
      },
    );
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

// ═══════════════════════════════════════════════════════════════
// USAGE EXAMPLES
// ═══════════════════════════════════════════════════════════════

/*
// ────────────────────────────────────────────────────────────────
// Example 1: Basic Usage in a ListView
// ────────────────────────────────────────────────────────────────
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedCard(
          index: index,
          child: ListTile(
            title: Text(items[index].name),
            subtitle: Text(items[index].description),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────────────────────
// Example 2: Custom Styling
// ────────────────────────────────────────────────────────────────
AnimatedCard(
  index: 0,
  backgroundColor: Colors.blue.shade50,
  borderRadius: 16,
  padding: const EdgeInsets.all(20),
  child: Column(
    children: [
      Text('Title'),
      Text('Description'),
    ],
  ),
)

// ────────────────────────────────────────────────────────────────
// Example 3: With Tap Animation
// ────────────────────────────────────────────────────────────────
AnimatedCard(
  index: 0,
  animateOnTap: true,
  onTap: () {
    Navigator.push(...);
  },
  child: YourContent(),
)

// ────────────────────────────────────────────────────────────────
// Example 4: Without Shadow
// ────────────────────────────────────────────────────────────────
AnimatedCard(
  index: 0,
  showShadow: false,
  child: YourContent(),
)

// ────────────────────────────────────────────────────────────────
// Example 5: Custom Animation Duration
// ────────────────────────────────────────────────────────────────
AnimatedCard(
  index: 0,
  durationMs: 800,
  delayPerIndexMs: 150,
  child: YourContent(),
)

// ────────────────────────────────────────────────────────────────
// Example 6: In a GridView
// ────────────────────────────────────────────────────────────────
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return AnimatedCard(
      index: index,
      margin: const EdgeInsets.all(8),
      child: YourGridItem(),
    );
  },
)

// ────────────────────────────────────────────────────────────────
// Example 7: Using AnimatedWidget for Custom Containers
// ────────────────────────────────────────────────────────────────
AnimatedWidget(
  index: 0,
  child: Container(
    // Your custom decoration here
    decoration: BoxDecoration(
      gradient: LinearGradient(...),
      border: Border.all(...),
    ),
    child: YourContent(),
  ),
)

// ────────────────────────────────────────────────────────────────
// Example 8: With Custom Shadow
// ────────────────────────────────────────────────────────────────
AnimatedCard(
  index: 0,
  boxShadow: [
    BoxShadow(
      color: Colors.blue.withOpacity(0.3),
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ],
  child: YourContent(),
)

// ────────────────────────────────────────────────────────────────
// Example 9: In SliverList (for complex scrolling)
// ────────────────────────────────────────────────────────────────
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) {
      return AnimatedCard(
        index: index,
        child: YourContent(),
      );
    },
    childCount: items.length,
  ),
)
*/

// ═══════════════════════════════════════════════════════════════
// MIGRATION GUIDE - REPLACING OLD _AnimatedCard
// ═══════════════════════════════════════════════════════════════

/*
Step 1: Create the file
  lib/ui/core/widgets/animated_card.dart

Step 2: Copy this entire code into that file

Step 3: Import in your screens
  import 'package:pamoja_twalima/core/presentation/widgets/animated_card.dart';

Step 4: Replace all instances of _AnimatedCard with AnimatedCard

Find & Replace in your project:
  FIND:    _AnimatedCard(
  REPLACE: AnimatedCard(

Remove the parameter:
  FIND:    theme: theme,
  REPLACE: (delete this line)

Step 5: Delete old _AnimatedCard class from each screen file

Step 6: Test all screens to ensure animations work
*/
