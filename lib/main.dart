import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/providers/auth_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pamoja_twalima/business/presentation/sales/sales_screen.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_drawer.dart';
import 'package:pamoja_twalima/inventory/presentation/inventory_screen.dart';
import 'data/repositories/sync_worker.dart';
import 'feature/animals/animals_list_screen.dart';
import 'auth/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'home/presentation/home_screen.dart';
import 'farm_mgmt/presentation/farm_mgmt_screen.dart';
import 'onboarding/presentation/onboarding_screen.dart';
import 'profile/presentation/profile_screen.dart';
import 'marketplace/presentation/sell_product_screen.dart';
import 'auth/presentation/register_screen.dart';
import 'auth/presentation/login_screen.dart';

// Theme
import 'core/presentation/themes/theme.dart';
import 'core/presentation/themes/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  runApp(const PamojaApp());
}

class PamojaApp extends StatelessWidget {
  const PamojaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Pamoja Twalima',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/animals': (_) => const AnimalsListScreen(),
          '/home': (_) => const MainShell(),
          '/profile': (_) => const ProfileScreen(),
          '/sell-item': (_) => const SellProductScreen(),
        },
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
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final results = await Future.wait([
        SharedPreferences.getInstance(),
        const FlutterSecureStorage().read(key: 'auth_token'),
      ]);

      if (!mounted) return;

      final prefs = results[0] as SharedPreferences;
      final token = results[1] as String?;
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

      String route;
      if (!seenOnboarding) {
        route = '/onboarding';
      } else if (token != null && token.isNotEmpty) {
        route = '/home';
      } else {
        route = '/login';
      }

      Navigator.of(context).pushReplacementNamed(route);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    }
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
  Timer? _syncTimer;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    
    // Initialize pages
    _pages = const [
      HomeScreen(),
      FarmMgmtScreen(),
      InventoryScreen(),
      SalesScreen(),
    ];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSyncWorkers();
      _setupAuthListener();
      _performInitialSync();
    });
  }

  void _initializeSyncWorkers() {
    try {
      // Start the unified sync worker (handles both sales and inventory)
      SyncWorker().start(interval: const Duration(minutes: 2));
      
      debugPrint('✅ Sync workers initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize sync workers: $e');
    }
  }

  void _setupAuthListener() {
    // Listen for auth changes and redirect to login if unauthenticated
    AuthState.isAuthenticated.addListener(() {
      if (!AuthState.isAuthenticated.value) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    });
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

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
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

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const AppDrawer(),
      
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      bottomNavigationBar: _buildBottomNav(theme),
    );
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