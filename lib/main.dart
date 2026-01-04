import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pamoja_twalima/ui/business/sales/sales_screen.dart';
import 'package:pamoja_twalima/ui/core/widgets/app_drawer.dart';
import 'package:pamoja_twalima/ui/inventory/inventory_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'ui/home/home_screen.dart';
import 'ui/farm_mgmt/farm_mgmt_screen.dart';
import 'ui/onboarding/onboarding_screen.dart';
import 'ui/profile/profile_screen.dart';
import 'ui/marketplace/sell_product_screen.dart';
import 'ui/auth/register_screen.dart';
import 'ui/auth/login_screen.dart';

// Theme
import 'ui/core/themes/theme.dart';
import 'ui/core/themes/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (non-blocking)
  dotenv.load();

  runApp(const PamojaApp());
}

class PamojaApp extends StatelessWidget {
  const PamojaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        '/home': (_) => const MainShell(),
        '/profile': (_) => const ProfileScreen(),
        '/sell-item': (_) => const SellProductScreen(),
      },
    );
  }
}

// Optimized splash screen - minimal UI, fast checks
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
      // Parallel execution for faster startup - removed artificial delay
      final results = await Future.wait([
        SharedPreferences.getInstance(),
        const FlutterSecureStorage().read(key: 'auth_token'),
      ]);

      if (!mounted) return;

      final prefs = results[0] as SharedPreferences;
      final token = results[1] as String?;
      final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

      // Determine route
      String route;
      if (!seenOnboarding) {
        route = '/onboarding';
      } else if (token != null && token.isNotEmpty) {
        route = '/home';
      } else {
        route = '/login';
      }

      // Navigate
      Navigator.of(context).pushReplacementNamed(route);
    } catch (e) {
      // On error, default to login
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

  // Lazy-loaded pages for better performance
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize pages once
    _pages = const [
      HomeScreen(),
      FarmMgmtScreen(),
      InventoryScreen(),
      SalesScreen(),
    ];
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

// Extracted widget for better performance
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