import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/farm_mgmt/overview_screen.dart';
import 'package:pamoja_twalima/ui/farm_mgmt/crops/crops_screen.dart';
import 'package:pamoja_twalima/ui/farm_mgmt/animals/animals_screen.dart';
import 'package:pamoja_twalima/ui/farm_mgmt/tasks/tasks_screen.dart';

class FarmMgmtScreen extends StatefulWidget {
  const FarmMgmtScreen({super.key});

  @override
  State<FarmMgmtScreen> createState() => _FarmMgmtScreenState();
}

class _FarmMgmtScreenState extends State<FarmMgmtScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    OverviewScreen(),
    CropsScreen(),
    AnimalsScreen(),
    TasksScreen(),
  ];

  final List<String> _categories = [
    "Overview",
    "Crops",
    "Animals",
    "Tasks",
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.agriculture,
    Icons.pets,
    Icons.task,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Farm Management",
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.cardTheme.color,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🏷️ Chip-style navigation (like MarketplaceScreen)
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_categories.length, (index) {
                  final isSelected = index == _selectedIndex;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _icons[index],
                            size: 16,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 6),
                          Text(_categories[index]),
                        ],
                      ),
                      selected: isSelected,
                      checkmarkColor: theme.colorScheme.primary,
                      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedIndex = index),
                      backgroundColor: theme.cardTheme.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.dividerColor.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Optional: Add a subtle divider
          Divider(
            height: 1,
            thickness: 1,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),

          // Content Area
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}