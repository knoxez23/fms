import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                      title: 'Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Settings coming soon!')),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Help coming soon!')),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.info_outline,
                      title: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        _showAboutDialog();
                      },
                    ),
                    const Divider(height: 32),
                    _DrawerItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Theme switching coming soon!'),
                          ),
                        );
                      },
                      trailing: Switch(
                        value: theme.brightness == Brightness.dark,
                        onChanged: (value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Theme switching coming soon!'),
                            ),
                          );
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
                        title: const Text(
                          'Logout',
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
      applicationName: 'Pamoja Twalima',
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
