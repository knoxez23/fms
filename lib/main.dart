import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pamoja_twalima/screens/business/sales/sales_screen.dart';
import 'package:pamoja_twalima/screens/inventory/inventory_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'screens/home/home_screen.dart';
import 'screens/marketplace/marketplace_screen.dart';
import 'screens/farm_mgmt/farm_mgmt_screen.dart';
import 'screens/weather/weather_screen.dart';
import 'screens/knowledge/knowledge_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/marketplace/sell_product_screen.dart';

// Theme
import 'theme/theme.dart';
import 'theme/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

  runApp(PamojaApp(startRoute: seenOnboarding ? '/home' : '/onboarding'));
}

class PamojaApp extends StatelessWidget {
  final String startRoute;
  const PamojaApp({super.key, required this.startRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pamoja Twalima',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: startRoute,
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const MainShell(),
        '/profile': (_) => const ProfileScreen(),
        '/sell-item': (_) => const SellProductScreen(),
      },
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

  final _pages = const [
    HomeScreen(),
    // MarketplaceScreen(),
    FarmMgmtScreen(),
    InventoryScreen(),
    SalesScreen(),
  ];

  final _icons = [
    Icons.home,
    // Icons.storefront,
    Icons.agriculture,
    Icons.inventory,
    Icons.paid,
  ];

  final _labels = [
    'Home',
    // 'Market',
    'Farm',
    'Inventory',
    'Business',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _pages[_currentIndex],

      // 🌿 Modern curved translucent bottom nav
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 17, right: 17, bottom: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_icons.length, (i) {
                  final isSelected = _currentIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _currentIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _icons[i],
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).iconTheme.color?.withValues(alpha: 0.7),
                            size: isSelected ? 30 : 26,
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                _labels[i],
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
