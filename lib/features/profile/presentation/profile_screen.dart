import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/features/profile/presentation/bloc/profile/profile_bloc.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/reusable_widgets.dart';
import 'package:pamoja_twalima/features/profile/presentation/audit_events_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileEvent.load()),
      child: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          state.when(
            initial: () {},
            loading: () {},
            loaded: (_) {},
            loggedOut: () {
              if (Navigator.canPop(context)) {
                Navigator.of(context).pushReplacementNamed('/login');
              } else {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (r) => false);
              }
            },
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          );
        },
        child: AppScaffold(
          appBar: const ModernAppBar(
            title: 'Profile & Settings',
            variant: AppBarVariant.home,
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final theme = Theme.of(context);
              final name = state.maybeWhen(
                loaded: (profile) => profile.name,
                orElse: () => 'Farmer',
              );
              final phone = state.maybeWhen(
                loaded: (profile) => profile.phone?.value ?? '—',
                orElse: () => '—',
              );

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [AppColors.cardShadow],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 26,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                phone,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.9),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Preferences', icon: Icons.tune),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: true,
                          onChanged: (_) {},
                          title: const Text('Language: English'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.color_lens),
                          title: const Text('Theme'),
                          subtitle: const Text('System default'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'Data & Sync', icon: Icons.sync),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.sync),
                          title: const Text('Sync Now'),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.storage),
                          title: const Text('Manage Offline Content'),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: const Text('Audit Trail'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AuditEventsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(title: 'About', icon: Icons.info),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('About Pamoja Twalima'),
                          onTap: () {},
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: const Text('Privacy & Terms'),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      context
                          .read<ProfileBloc>()
                          .add(const ProfileEvent.logout());
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
