import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_settings_controller.dart';
import '../../../features/auth/presentation/bloc/auth/auth_bloc.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final _storage = const FlutterSecureStorage();

  String _userName = 'User';
  String _userEmail = '';
  bool _loadingLogout = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final name = await _storage.read(key: 'user_name');
    final email = await _storage.read(key: 'user_email');

    if (mounted) {
      setState(() {
        _userName = name ?? 'User';
        _userEmail = email ?? '';
      });
    }
  }

  Future<void> _handleLogout() async {
    setState(() => _loadingLogout = true);

    try {
      context.read<AuthBloc>().add(const AuthEvent.logoutRequested());
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text('Logout failed: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingLogout = false);
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = AppSettingsController.instance;
    final effectiveDarkMode = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            theme.brightness == Brightness.dark);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (!_loadingLogout) return;

        state.maybeWhen(
          unauthenticated: () async {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: const [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Logged out successfully'),
                  ],
                ),
                backgroundColor: Colors.green.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            await Future.delayed(const Duration(milliseconds: 500));

            if (!context.mounted) return;
            setState(() => _loadingLogout = false);

            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (route) => false);
          },
          error: (message) {
            if (!mounted) return;
            setState(() => _loadingLogout = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(child: Text('Logout failed: $message')),
                  ],
                ),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
          orElse: () {},
        );
      },
      child: Drawer(
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      child: const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _userName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_userEmail.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _DrawerItem(
                      icon: Icons.person_outline,
                      title: context.tr('drawer_profile'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      title: context.tr('drawer_settings'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.help_outline,
                      title: context.tr('drawer_help'),
                      onTap: () {
                        Navigator.pop(context);
                        _showHelpDialog();
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.info_outline,
                      title: context.tr('drawer_about'),
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog();
                      },
                    ),
                    const Divider(height: 32),
                    _DrawerItem(
                      icon: Icons.dark_mode_outlined,
                      title: context.tr('drawer_dark_mode'),
                      onTap: () async {
                        await settings.setThemeMode(
                          effectiveDarkMode ? ThemeMode.light : ThemeMode.dark,
                        );
                        if (!mounted) return;
                        _showThemeHint(settings.themeMode);
                      },
                      trailing: Switch(
                        value: effectiveDarkMode,
                        onChanged: (value) async {
                          await settings.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                          if (!mounted) return;
                          _showThemeHint(settings.themeMode);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: _loadingLogout
                    ? const Center(child: CircularProgressIndicator())
                    : ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        title: Text(
                          context.tr('drawer_logout'),
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: _showLogoutDialog,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        tileColor: Colors.red.withValues(alpha: 0.1),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Version 1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color
                        ?.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: context.tr('app_name'),
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.agriculture,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: const [
        Text(
          'A comprehensive farm management application to help you manage your farm operations efficiently.',
        ),
      ],
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: support@pamoja-twalima.app'),
            SizedBox(height: 8),
            Text('Phone: +254 700 000 000'),
            SizedBox(height: 8),
            Text('Response time: within 24 hours'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showThemeHint(ThemeMode mode) {
    final label = switch (mode) {
      ThemeMode.dark => context.tr('theme_dark_enabled'),
      ThemeMode.light => context.tr('theme_light_enabled'),
      ThemeMode.system => context.tr('theme_system_enabled'),
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(label),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
