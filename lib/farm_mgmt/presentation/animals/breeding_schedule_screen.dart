import 'package:flutter/material.dart';
import 'package:pamoja_twalima/ui/core/themes/app_colors.dart';

class BreedingScheduleScreen extends StatefulWidget {
  const BreedingScheduleScreen({super.key});

  @override
  State<BreedingScheduleScreen> createState() => _BreedingScheduleScreenState();
}

class _BreedingScheduleScreenState extends State<BreedingScheduleScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _pregnantAnimals = [
    {
      'name': 'Bella',
      'type': 'Dairy Cow',
      'breedingDate': '2024-01-15',
      'dueDate': '2024-10-25',
      'daysToGo': 45,
      'status': 'Third Trimester',
    },
    {
      'name': 'Molly',
      'type': 'Goat',
      'breedingDate': '2024-02-20',
      'dueDate': '2024-07-20',
      'daysToGo': 120,
      'status': 'Second Trimester',
    },
  ];

  final List<Map<String, dynamic>> _breedingHistory = [
    {
      'name': 'Daisy',
      'type': 'Dairy Cow',
      'method': 'Artificial Insemination',
      'date': '2024-03-01',
      'success': true,
      'vet': 'Dr. Kamau',
    },
    {
      'name': 'Ruby',
      'type': 'Dairy Cow',
      'method': 'Natural Mating',
      'date': '2024-02-15',
      'success': false,
      'notes': 'Heat detection needed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Breeding Schedule',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [AppColors.subtleShadow],
            ),
            child: Row(
              children: [
                _BreedingTab(
                  label: 'Pregnancy',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                  theme: theme,
                ),
                _BreedingTab(
                  label: 'Breeding',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                  theme: theme,
                ),
                _BreedingTab(
                  label: 'Calendar',
                  isSelected: _selectedTab == 2,
                  onTap: () => setState(() => _selectedTab = 2),
                  theme: theme,
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: IndexedStack(
              index: _selectedTab,
              children: [
                _PregnancyTab(pregnantAnimals: _pregnantAnimals, theme: theme),
                _BreedingTabContent(breedingHistory: _breedingHistory, theme: theme),
                _BreedingCalendarTab(theme: theme),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'addBreedingRecordFAB',
        onPressed: () {
          // Add breeding record
        },
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _BreedingTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _BreedingTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}

class _PregnancyTab extends StatelessWidget {
  final List<Map<String, dynamic>> pregnantAnimals;
  final ThemeData theme;

  const _PregnancyTab({required this.pregnantAnimals, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 0,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pregnancy Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${pregnantAnimals.length} Animals',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...pregnantAnimals.map((animal) => _PregnancyItem(animal: animal, theme: theme)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pregnancy Timeline',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      'Pregnancy progress charts will be implemented here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PregnancyItem extends StatelessWidget {
  final Map<String, dynamic> animal;
  final ThemeData theme;

  const _PregnancyItem({required this.animal, required this.theme});

  @override
  Widget build(BuildContext context) {
    final progress = _calculateProgress(animal['daysToGo']);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.family_restroom,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${animal['type']} • Due: ${_formatDate(animal['dueDate'])}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  color: _getProgressColor(progress),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      animal['status'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${animal['daysToGo']} days to go',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getDaysColor(animal['daysToGo']),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateProgress(int daysToGo) {
    const totalDays = 280; // Average cow pregnancy
    return (totalDays - daysToGo) / totalDays;
  }

  Color _getProgressColor(double progress) {
    if (progress > 0.8) return Colors.green;
    if (progress > 0.5) return Colors.blue;
    return Colors.orange;
  }

  Color _getDaysColor(int daysToGo) {
    if (daysToGo < 30) return Colors.red;
    if (daysToGo < 60) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(String date) {
    // Simple date formatting
    return date.split('-').reversed.join('/');
  }
}

class _BreedingTabContent extends StatelessWidget {
  final List<Map<String, dynamic>> breedingHistory;
  final ThemeData theme;

  const _BreedingTabContent({required this.breedingHistory, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 0,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Breeding Records',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...breedingHistory.map((record) => _BreedingRecord(record: record, theme: theme)),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breeding Statistics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BreedingStat(
                      value: '75%',
                      label: 'Success Rate',
                      theme: theme,
                    ),
                    _BreedingStat(
                      value: '12',
                      label: 'Total Attempts',
                      theme: theme,
                    ),
                    _BreedingStat(
                      value: '8',
                      label: 'Pregnancies',
                      theme: theme,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BreedingRecord extends StatelessWidget {
  final Map<String, dynamic> record;
  final ThemeData theme;

  const _BreedingRecord({required this.record, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: record['success']
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              record['success'] ? Icons.check_circle : Icons.schedule,
              color: record['success'] ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${record['type']} • ${record['method']}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                if (record['vet'] != null)
                  Text(
                    'by ${record['vet']}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                if (record['notes'] != null)
                  Text(
                    record['notes'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            _formatDate(record['date']),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    return date.split('-').reversed.join('/');
  }
}

class _BreedingStat extends StatelessWidget {
  final String value;
  final String label;
  final ThemeData theme;

  const _BreedingStat({
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _BreedingCalendarTab extends StatelessWidget {
  final ThemeData theme;

  const _BreedingCalendarTab({required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 0,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Breeding Calendar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      'Breeding calendar with heat detection and pregnancy due dates will be implemented here',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Due Dates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _DueDateItem(
                  animal: 'Bella',
                  dueDate: '2024-10-25',
                  daysToGo: 45,
                  theme: theme,
                ),
                _DueDateItem(
                  animal: 'Molly',
                  dueDate: '2024-07-20',
                  daysToGo: 120,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DueDateItem extends StatelessWidget {
  final String animal;
  final String dueDate;
  final int daysToGo;
  final ThemeData theme;

  const _DueDateItem({
    required this.animal,
    required this.dueDate,
    required this.daysToGo,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getDueDateColor(daysToGo).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.child_care,
              color: _getDueDateColor(daysToGo),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  animal,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Due: ${_formatDate(dueDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getDueDateColor(daysToGo).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$daysToGo days',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getDueDateColor(daysToGo),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDueDateColor(int daysToGo) {
    if (daysToGo < 30) return Colors.red;
    if (daysToGo < 60) return Colors.orange;
    return Colors.green;
  }

  String _formatDate(String date) {
    return date.split('-').reversed.join('/');
  }
}

// Reuse the _AnimatedCard widget
class _AnimatedCard extends StatefulWidget {
  final Widget child;
  final ThemeData theme;
  final int index;

  const _AnimatedCard({
    required this.child,
    required this.theme,
    required this.index,
  });

  @override
  State<_AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<_AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final start = (0.1 * widget.index).clamp(0.0, 0.6);
    final end = (0.3 + 0.1 * widget.index).clamp(0.4, 1.0);

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: widget.theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [AppColors.subtleShadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}