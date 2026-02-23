import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/di/injection.dart';
import 'core/presentation/settings/app_localizations.dart';
import 'core/services/local_notification_service.dart';
import 'core/presentation/settings/app_settings_controller.dart';
import 'features/auth/application/auth_usecases.dart';
import 'features/farm_mgmt/application/domain_event_subscribers.dart';
import 'package:pamoja_twalima/features/business/presentation/sales/sales_screen.dart';
import 'package:pamoja_twalima/features/inventory/presentation/inventory_screen.dart';
import 'data/repositories/sync_worker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';

// Screens
import 'features/home/presentation/home_screen.dart';
import 'features/farm_mgmt/presentation/farm_mgmt_screen.dart';
import 'features/farm_mgmt/presentation/animals/animals_screen.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/marketplace/presentation/sell_product_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/login_screen.dart';

// Theme
import 'core/presentation/themes/theme.dart';
import 'core/presentation/themes/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const isFlutterTest = bool.fromEnvironment('FLUTTER_TEST');

  // Load environment variables
  if (!dotenv.isInitialized) {
    await dotenv.load(fileName: '.env', isOptional: true);
  }

  // Initialize dependency injection
  await configureDependencies();
  getIt<DomainEventSubscribers>().start();
  if (!isFlutterTest) {
    await LocalNotificationService.instance.init();
  }
  await AppSettingsController.instance.load();

  runApp(const PamojaApp());
}

class PamojaApp extends StatelessWidget {
  const PamojaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appSettings = AppSettingsController.instance;
    return BlocProvider(
      create: (_) => getIt<AuthBloc>(),
      child: AnimatedBuilder(
        animation: appSettings,
        builder: (context, _) => MaterialApp(
          title: 'Pamoja Twalima',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appSettings.themeMode,
          locale: appSettings.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('sw'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
          routes: {
            '/onboarding': (_) => const OnboardingScreen(),
            '/login': (_) => const LoginScreen(),
            '/register': (_) => const RegisterScreen(),
            '/animals': (_) => const AnimalsScreen(),
            '/home': (_) => const MainShell(),
            '/profile': (_) => const ProfileScreen(),
            '/sell-item': (_) => const SellProductScreen(),
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!mounted || _didNavigate) return;
      _navigateTo('/login');
    });
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final results = await Future.wait([
        SharedPreferences.getInstance(),
        getIt<CheckAuthStatusUseCase>().execute(),
      ]).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      final prefs = results[0] as SharedPreferences;
      final isAuthenticated = results[1] as bool;
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

      String route;
      if (!seenOnboarding) {
        route = '/onboarding';
      } else if (isAuthenticated) {
        route = '/home';
      } else {
        route = '/login';
      }

      _navigateTo(route);
    } catch (e) {
      if (!mounted) return;
      _navigateTo('/login');
    }
  }

  void _navigateTo(String route) {
    if (!mounted || _didNavigate) return;
    _didNavigate = true;
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.agriculture,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Pamoja Twalima',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Initialize pages
    _pages = [
      HomeScreen(onNavigateTab: _navigateToTab),
      FarmMgmtScreen(),
      InventoryScreen(),
      SalesScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSyncWorkers();
      Future<void>.delayed(const Duration(seconds: 2), _performInitialSync);
    });
  }

  void _initializeSyncWorkers() {
    try {
      // Start the unified sync worker (handles both sales and inventory)
      SyncWorker().start(
        interval: const Duration(minutes: 2),
        runImmediately: false,
      );

      debugPrint('✅ Sync workers initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize sync workers: $e');
    }
  }

  /// Perform initial data sync from server on app startup
  Future<void> _performInitialSync() async {
    try {
      debugPrint('📥 Performing initial sync from server...');

      // Trigger sync worker to pull data from server
      await SyncWorker().syncFromServer();

      debugPrint('✅ Initial sync completed');
    } catch (e) {
      debugPrint('⚠️ Initial sync failed: $e');
      // Don't block app startup if sync fails
    }
  }

  final _icons = const [
    Icons.home,
    Icons.agriculture,
    Icons.inventory,
    Icons.paid,
  ];

  final _labels = const [
    'Home',
    'Farm',
    'Inventory',
    'Business',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        state.maybeWhen(
          unauthenticated: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomNav(theme),
      ),
    );
  }

  void _navigateToTab(int index) {
    if (!mounted) return;
    if (index < 0 || index >= _pages.length) return;
    setState(() => _currentIndex = index);
  }

  Widget _buildBottomNav(ThemeData theme) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.95),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_icons.length, (i) {
                  final isSelected = _currentIndex == i;
                  return _NavItem(
                    icon: _icons[i],
                    label: _labels[i],
                    isSelected: isSelected,
                    onTap: () => setState(() => _currentIndex = i),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : theme.iconTheme.color?.withValues(alpha: 0.7),
              size: isSelected ? 30 : 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
