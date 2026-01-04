import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../themes/app_colors.dart';

enum AppBarVariant {
  standard, // Regular with back button
  home, // With drawer icon
  transparent, // Transparent overlay
  search, // With search bar
}

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final AppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final bool showNotifications;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSearchTap;
  final TextEditingController? searchController;
  final bool showSearchBar;
  final bool isSearching;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmit;
  final double elevation;
  final Widget? bottom;
  final double? bottomHeight;

  const ModernAppBar({
    super.key,
    this.title,
    this.variant = AppBarVariant.standard,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.showNotifications = true,
    this.notificationCount = 0,
    this.onNotificationTap,
    this.onSearchTap,
    this.searchController,
    this.showSearchBar = false,
    this.isSearching = false,
    this.onSearchChanged,
    this.onSearchSubmit,
    this.elevation = 0,
    this.bottom,
    this.bottomHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottomHeight ?? (bottom != null ? 48 : 0)),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine background color
    Color bgColor = backgroundColor ??
        (variant == AppBarVariant.transparent
            ? Colors.transparent
            : theme.colorScheme.surface);

    // System overlay style for status bar
    SystemUiOverlayStyle overlayStyle =
        isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return AppBar(
      systemOverlayStyle: overlayStyle,
      elevation: elevation,
      backgroundColor: bgColor,
      centerTitle: centerTitle,
      leading: _buildLeading(context),
      title: showSearchBar && isSearching
          ? _buildSearchField(context)
          : _buildTitle(context),
      actions: _buildActions(context),
      bottom: bottom != null
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight ?? 48),
              child: bottom!,
            )
          : null,
      flexibleSpace: variant == AppBarVariant.transparent
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    switch (variant) {
      case AppBarVariant.home:
        return Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return IconButton(
              icon: Icon(
                Icons.menu_rounded,
                size: 28,
                color: variant == AppBarVariant.transparent
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black87),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        );

      case AppBarVariant.transparent:
        return IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        );

      case AppBarVariant.standard:
      case AppBarVariant.search:
        // Check if we can pop
        if (ModalRoute.of(context)?.canPop ?? false) {
          return IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: variant == AppBarVariant.transparent ? Colors.white : null,
            ),
            onPressed: () => Navigator.of(context).pop(),
          );
        }
        return null;
    }
  }

  Widget? _buildTitle(BuildContext context) {
    if (title == null) return null;

    final theme = Theme.of(context);

    final textColor = variant == AppBarVariant.transparent
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.primary;

    final iconColor = textColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (variant == AppBarVariant.home) ...[
          Icon(
            Icons.agriculture,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            title!,
            style: theme.textTheme.titleLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: searchController,
        autofocus: true,
        onChanged: onSearchChanged,
        onSubmitted: (_) => onSearchSubmit?.call(),
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search...',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = variant == AppBarVariant.transparent
        ? Colors.white
        : theme.iconTheme.color;

    List<Widget> actionWidgets = [];

    // Search icon (for search variant or when search is enabled)
    if ((variant == AppBarVariant.search || showSearchBar) && !isSearching) {
      actionWidgets.add(
        IconButton(
          icon: Icon(Icons.search, color: iconColor),
          onPressed: onSearchTap,
        ),
      );
    }

    // Notifications
    if (showNotifications) {
      actionWidgets.add(
        _NotificationButton(
          count: notificationCount,
          onTap: onNotificationTap,
          iconColor: iconColor,
          isTransparent: variant == AppBarVariant.transparent,
        ),
      );
    }

    // Custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    // Add spacing at the end
    if (actionWidgets.isNotEmpty) {
      actionWidgets.add(const SizedBox(width: 8));
    }

    return actionWidgets;
  }
}

// Notification Button Widget
class _NotificationButton extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;
  final Color? iconColor;
  final bool isTransparent;

  const _NotificationButton({
    required this.count,
    this.onTap,
    this.iconColor,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          isTransparent
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              : Icon(
                  Icons.notifications_outlined,
                  color: iconColor,
                ),
          if (count > 0)
            Positioned(
              right: isTransparent ? 8 : 0,
              top: isTransparent ? 8 : 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),
                constraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Notifications coming soon!')),
            );
          },
    );
  }
}

// Pre-built AppBar variants for quick use
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int notificationCount;
  final VoidCallback? onNotificationTap;
  final List<Widget>? actions;

  const HomeAppBar({
    super.key,
    this.title = 'Pamoja Twalima',
    this.notificationCount = 0,
    this.onNotificationTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ModernAppBar(
      variant: AppBarVariant.home,
      title: title,
      notificationCount: notificationCount,
      onNotificationTap: onNotificationTap,
      actions: actions,
    );
  }
}

class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Function(String)? onSearchChanged;
  final VoidCallback? onSearchSubmit;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    required this.title,
    this.onSearchChanged,
    this.onSearchSubmit,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ModernAppBar(
      variant: AppBarVariant.search,
      title: widget.title,
      showSearchBar: true,
      isSearching: _isSearching,
      searchController: _searchController,
      onSearchTap: () => setState(() => _isSearching = !_isSearching),
      onSearchChanged: widget.onSearchChanged,
      onSearchSubmit: () {
        widget.onSearchSubmit?.call();
        setState(() => _isSearching = false);
      },
      actions: _isSearching
          ? [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _isSearching = false);
                },
              ),
            ]
          : widget.actions,
    );
  }
}

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;

  const TransparentAppBar({
    super.key,
    this.title,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ModernAppBar(
      variant: AppBarVariant.transparent,
      title: title,
      actions: actions,
      showNotifications: false,
    );
  }
}
