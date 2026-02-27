import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_settings_controller.dart';
import 'package:pamoja_twalima/data/services/auth_service.dart';
import 'package:pamoja_twalima/data/repositories/sync_worker.dart';
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
                SnackBar(content: Text(context.tr(message))),
              );
            },
          );
        },
        child: AppScaffold(
          appBar: ModernAppBar(
            title: context.tr('profile_title'),
            variant: AppBarVariant.home,
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              final theme = Theme.of(context);
              final name = state.maybeWhen(
                loaded: (profile) => profile.name,
                orElse: () => context.tr('profile_default_name'),
              );
              final phone = state.maybeWhen(
                loaded: (profile) => profile.phone?.value ?? '—',
                orElse: () => '—',
              );
              final location = state.maybeWhen(
                loaded: (profile) => profile.location ?? '—',
                orElse: () => '—',
              );
              final appSettings = AppSettingsController.instance;
              final isSwahili = appSettings.locale.languageCode == 'sw';
              final currentTheme = appSettings.themeMode;

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
                          key: const Key('profile_open_edit_button'),
                          onPressed: () => _showEditProfileDialog(
                            context,
                            state: state,
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        location,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: context.tr('preferences'),
                    icon: Icons.tune,
                  ),
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
                          value: isSwahili,
                          onChanged: (value) async {
                            await appSettings.setLanguageCode(
                              value ? 'sw' : 'en',
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  value
                                      ? context.tr('language_set_swahili')
                                      : context.tr('language_set_english'),
                                ),
                              ),
                            );
                          },
                          title: Text(
                            isSwahili
                                ? context.tr('language_swahili')
                                : context.tr('language_english'),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.color_lens),
                          title: Text(context.tr('theme')),
                          subtitle: Text(_themeLabel(context, currentTheme)),
                          onTap: () => _showThemeSelector(
                            context,
                            currentTheme: currentTheme,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SectionHeader(
                    title: context.tr('data_sync'),
                    icon: Icons.sync,
                  ),
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
                          title: Text(context.tr('sync_now')),
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(context.tr('sync_running')),
                                duration: Duration(seconds: 1),
                              ),
                            );
                            try {
                              await SyncWorker().syncFromServer();
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.tr('sync_completed')),
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text(context.tr('sync_failed_short')),
                                ),
                              );
                            }
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.storage),
                          title: Text(context.tr('manage_offline')),
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title:
                                    Text(context.tr('offline_content_title')),
                                content: Text(
                                  context.tr('offline_content_desc'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(context.tr('ok')),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(context.tr('audit_trail')),
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
                  SectionHeader(
                    title: context.tr('about_section'),
                    icon: Icons.info,
                  ),
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
                          title: Text(context.tr('about_app')),
                          onTap: () {
                            showAboutDialog(
                              context: context,
                              applicationName: 'Pamoja Twalima',
                              applicationVersion: '1.0.0',
                              children: [
                                Text(context.tr('about_app_desc')),
                              ],
                            );
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: Text(context.tr('privacy_terms')),
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(context.tr('privacy_terms_title')),
                                content: Text(
                                  context.tr('privacy_terms_desc'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text(context.tr('close_button')),
                                  ),
                                ],
                              ),
                            );
                          },
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
                    label: Text(context.tr('drawer_logout')),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context, {
    required ProfileState state,
  }) async {
    final loaded = state.maybeWhen(
      loaded: (profile) => profile,
      orElse: () => null,
    );
    if (loaded == null) return;

    final nameController = TextEditingController(text: loaded.name);
    final phoneController =
        TextEditingController(text: loaded.phone?.value ?? '');
    final locationController =
        TextEditingController(text: loaded.location ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.tr('edit_profile_title')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('profile_edit_name_input'),
                controller: nameController,
                decoration:
                    InputDecoration(labelText: context.tr('name_label')),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('profile_edit_phone_input'),
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: context.tr('phone')),
              ),
              const SizedBox(height: 10),
              TextField(
                key: const Key('profile_edit_location_input'),
                controller: locationController,
                decoration:
                    InputDecoration(labelText: context.tr('location_label')),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('profile_edit_cancel_button'),
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('cancel')),
          ),
          FilledButton(
            key: const Key('profile_edit_save_button'),
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final phone = phoneController.text.trim();
              final location = locationController.text.trim();

              try {
                await getIt<AuthService>().updateCurrentUser(
                  name: name,
                  phone: phone.isEmpty ? null : phone,
                  location: location.isEmpty ? null : location,
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!context.mounted) return;
                context.read<ProfileBloc>().add(const ProfileEvent.load());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.tr('profile_updated'))),
                );
              } catch (_) {
                if (!dialogContext.mounted) return;
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(content: Text(context.tr('profile_update_failed'))),
                );
              }
            },
            child: Text(context.tr('save')),
          ),
        ],
      ),
    );
  }

  String _themeLabel(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return context.tr('theme_light');
      case ThemeMode.dark:
        return context.tr('theme_dark');
      case ThemeMode.system:
        return context.tr('theme_system_default');
    }
  }

  Future<void> _showThemeSelector(
    BuildContext context, {
    required ThemeMode currentTheme,
  }) async {
    final appSettings = AppSettingsController.instance;
    ThemeMode selected = currentTheme;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.brightness_auto),
                    title: Text(context.tr('theme_system_default')),
                    trailing: selected == ThemeMode.system
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () =>
                        setSheetState(() => selected = ThemeMode.system),
                  ),
                  ListTile(
                    leading: const Icon(Icons.light_mode_outlined),
                    title: Text(context.tr('theme_light')),
                    trailing: selected == ThemeMode.light
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () =>
                        setSheetState(() => selected = ThemeMode.light),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: Text(context.tr('theme_dark')),
                    trailing: selected == ThemeMode.dark
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => setSheetState(() => selected = ThemeMode.dark),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FilledButton(
                      onPressed: () async {
                        await appSettings.setThemeMode(selected);
                        if (!sheetContext.mounted) return;
                        Navigator.pop(sheetContext);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context
                                .tr('theme_updated_to')
                                .replaceFirst(
                                    '{theme}', _themeLabel(context, selected))),
                          ),
                        );
                      },
                      child: Text(context.tr('apply')),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
