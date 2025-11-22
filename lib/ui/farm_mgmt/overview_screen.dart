import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';
import 'package:pamoja_twalima/ui/core/animations/animated_card.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  // Mock data - replace with actual data management
  final Map<String, dynamic> farmSummary = {
    'totalCrops': 8,
    'totalAnimals': 12,
    'balance': 2450.0,
    'pendingTasks': 3,
    'lowStockItems': 2,
  };

  final List<Map<String, dynamic>> recentTasks = [
    {"title": "Irrigate maize field", "due": "Today", "done": false},
    {"title": "Vaccinate chickens", "due": "Tomorrow", "done": false},
    {"title": "Harvest tomatoes", "due": "In 2 days", "done": false},
  ];

  final List<Map<String, dynamic>> recentExpenses = [
    {"item": "Fertilizer purchase", "amount": 1500, "date": "2 days ago"},
    {"item": "Animal feed", "amount": 800, "date": "1 week ago"},
    {"item": "Seeds", "amount": 1200, "date": "2 weeks ago"},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
// Summary Cards
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                _SummaryCard(
                  title: "Crops",
                  value: "${farmSummary['totalCrops']}",
                  icon: Icons.agriculture,
                  color: Colors.green,
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  title: "Animals",
                  value: "${farmSummary['totalAnimals']}",
                  icon: Icons.pets,
                  color: Colors.orange,
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _SummaryCard(
                  title: "Sales",
                  value: "KSh ${farmSummary['balance']}",
                  icon: Icons.attach_money,
                  color: Colors.blue,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),

// Quick Stats
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                _QuickStat(
                  value: "${farmSummary['pendingTasks']}",
                  label: "Pending Tasks",
                  theme: theme,
                ),
                const SizedBox(width: 16),
                _QuickStat(
                  value: "${farmSummary['lowStockItems']}",
                  label: "Low Stock",
                  theme: theme,
                ),
              ],
            ),
          ),
        ),

// Production Overview
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle("Production Overview", theme: theme),
                const SizedBox(height: 8),
                AnimatedCard(
                  index: 0,
                  child: Container(
                    height: 150,
                    padding: const EdgeInsets.all(16),
                    child: const Center(
                      child: Text(
                        "Production charts will be implemented here",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

// Upcoming Tasks
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle("Upcoming Tasks", theme: theme),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => AnimatedCard(
                index: index + 1,
                child: _TaskItem(
                  task: recentTasks[index],
                  theme: theme,
                  onTap: () {
                    // TODO: Navigate to detail
                  },
                ),
              ),
              childCount: recentTasks.length,
            ),
          ),
        ),

// Recent Expenses
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(
            child: _SectionTitle("Recent Expenses", theme: theme),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => AnimatedCard(
                index: index + 4,
                child: _ExpenseItem(
                  expense: recentExpenses[index],
                  theme: theme,
                ),
              ),
              childCount: recentExpenses.length,
            ),
          ),
        ),

// Bottom Padding (for visual breathing room / navbar spacing)
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [AppColors.subtleShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _QuickStat({
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Map<String, dynamic> task;
  final ThemeData theme;
  final VoidCallback onTap;

  const _TaskItem({
    required this.task,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: task['done'],
        onChanged: (value) {},
        activeColor: theme.colorScheme.primary,
      ),
      title: Text(
        task['title'],
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "Due: ${task['due']}",
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      onTap: onTap,
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final Map<String, dynamic> expense;
  final ThemeData theme;

  const _ExpenseItem({
    required this.expense,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.money_off,
          color: theme.colorScheme.primary,
          size: 20,
        ),
      ),
      title: Text(
        expense['item'],
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        expense['date'],
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Text(
        "KSh ${expense['amount']}",
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const _SectionTitle(this.title, {required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
