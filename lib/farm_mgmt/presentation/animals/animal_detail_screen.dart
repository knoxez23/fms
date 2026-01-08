import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Map<String, dynamic> animal;

  const AnimalDetailScreen({super.key, required this.animal});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGroup = widget.animal['groupType'] == 'Group';
    final quantity = widget.animal['quantity'] ?? 1;
    final purchasePrice = widget.animal['purchasePrice'] ?? 0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.animal['name'],
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Animal Overview Card
          _AnimatedCard(
            index: 0,
            theme: theme,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: _getAnimalColor(widget.animal['type']).withValues(alpha: 0.1),
                            child: Icon(
                              _getAnimalIcon(widget.animal['type']),
                              color: _getAnimalColor(widget.animal['type']),
                              size: 30,
                            ),
                          ),
                          if (isGroup && quantity > 1)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.animal['name'],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${widget.animal['type']} • ${widget.animal['breed']}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(widget.animal['status']).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.animal['status'],
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: _getStatusColor(widget.animal['status']),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (isGroup)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Group',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  // Enhanced detail items with purchase info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _DetailItem(
                        icon: Icons.cake,
                        label: isGroup ? 'Avg Age' : 'Age',
                        value: widget.animal['age'] ?? 'Not set',
                        theme: theme,
                      ),
                      _DetailItem(
                        icon: Icons.monitor_heart,
                        label: 'Health',
                        value: '${widget.animal['healthScore']}%',
                        theme: theme,
                      ),
                      if (purchasePrice > 0)
                        _DetailItem(
                          icon: Icons.attach_money,
                          label: isGroup ? 'Total Cost' : 'Price',
                          value: 'KSh ${purchasePrice.toStringAsFixed(0)}',
                          theme: theme,
                        ),
                      if (isGroup && quantity > 1)
                        _DetailItem(
                          icon: Icons.group,
                          label: 'Quantity',
                          value: quantity.toString(),
                          theme: theme,
                        ),
                    ],
                  ),
                  if (widget.animal['shed'] != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Location: ${widget.animal['shed']}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Tab Bar
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppColors.subtleShadow],
            ),
            child: Row(
              children: [
                _DetailTab(
                  label: 'Health',
                  isSelected: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                  theme: theme,
                ),
                _DetailTab(
                  label: 'Production',
                  isSelected: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                  theme: theme,
                ),
                _DetailTab(
                  label: 'History',
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
                _HealthTab(animal: widget.animal, theme: theme),
                _ProductionTab(animal: widget.animal, theme: theme),
                _HistoryTab(animal: widget.animal, theme: theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getAnimalColor(String type) {
    final theme = Theme.of(context);
    switch (type.toLowerCase()) {
      case 'dairy cow':
        return Colors.blue;
      case 'beef cattle':
        return Colors.brown;
      case 'layers':
        return Colors.orange;
      case 'goat':
        return Colors.green;
      default:
        return theme.colorScheme.primary;
    }
  }

  IconData _getAnimalIcon(String type) {
    switch (type.toLowerCase()) {
      case 'dairy cow':
      case 'beef cattle':
        return Icons.agriculture;
      case 'layers':
        return Icons.egg;
      case 'goat':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
      case 'laying':
        return Colors.green;
      case 'pregnant':
        return Colors.purple;
      case 'growing':
        return Colors.blue;
      case 'sick':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
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

class _DetailTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _DetailTab({
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

class _HealthTab extends StatelessWidget {
  final Map<String, dynamic> animal;
  final ThemeData theme;

  const _HealthTab({required this.animal, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: animal['healthScore'] / 100,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  color: _getHealthColor(animal['healthScore']),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Health Score',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      '${animal['healthScore']}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getHealthColor(animal['healthScore']),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 2,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vaccination Records',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _VaccineItem(
                  vaccine: 'Foot & Mouth',
                  date: '2 months ago',
                  nextDue: 'In 10 months',
                  theme: theme,
                ),
                _VaccineItem(
                  vaccine: 'Brucellosis',
                  date: '6 months ago',
                  nextDue: 'In 6 months',
                  theme: theme,
                ),
                _VaccineItem(
                  vaccine: 'Anthrax',
                  date: '1 year ago',
                  nextDue: 'Due now',
                  theme: theme,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 3,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Health Checks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _HealthCheckItem(
                  date: '1 week ago',
                  findings: 'Normal temperature and appetite',
                  vet: 'Dr. Kamau',
                  theme: theme,
                ),
                _HealthCheckItem(
                  date: '1 month ago',
                  findings: 'Minor hoof issue treated',
                  vet: 'Dr. Wanjiku',
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getHealthColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    return Colors.red;
  }
}

class _VaccineItem extends StatelessWidget {
  final String vaccine;
  final String date;
  final String nextDue;
  final ThemeData theme;

  const _VaccineItem({
    required this.vaccine,
    required this.date,
    required this.nextDue,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isDue = nextDue.toLowerCase().contains('due now');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDue ? Colors.red.withValues(alpha: 0.1) : theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.medical_services,
              color: isDue ? Colors.red : theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Last: $date • Next: $nextDue',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (isDue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Due',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HealthCheckItem extends StatelessWidget {
  final String date;
  final String findings;
  final String vet;
  final ThemeData theme;

  const _HealthCheckItem({
    required this.date,
    required this.findings,
    required this.vet,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  findings,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'by $vet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
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
}

class _ProductionTab extends StatelessWidget {
  final Map<String, dynamic> animal;
  final ThemeData theme;

  const _ProductionTab({required this.animal, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Production Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (animal['production'] != null)
                  _ProductionMetric(
                    label: 'Daily Production',
                    value: animal['production'],
                    trend: '+2%',
                    theme: theme,
                  ),
                if (animal['weight'] != null)
                  _ProductionMetric(
                    label: 'Current Weight',
                    value: animal['weight'],
                    trend: '+5kg',
                    theme: theme,
                  ),
                _ProductionMetric(
                  label: 'Feed Efficiency',
                  value: '3.2:1',
                  trend: 'Good',
                  theme: theme,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 2,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Production',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 150,
                  padding: const EdgeInsets.all(16),
                  child: const Center(
                    child: Text(
                      'Production charts will be implemented here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        _AnimatedCard(
          index: 3,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Milking Records',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _MilkingRecord(
                  time: 'Today, 06:00',
                  amount: '8.5L',
                  quality: 'Good',
                  theme: theme,
                ),
                _MilkingRecord(
                  time: 'Yesterday, 18:00',
                  amount: '7.8L',
                  quality: 'Good',
                  theme: theme,
                ),
                _MilkingRecord(
                  time: 'Yesterday, 06:00',
                  amount: '8.2L',
                  quality: 'Excellent',
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

class _ProductionMetric extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final ThemeData theme;

  const _ProductionMetric({
    required this.label,
    required this.value,
    required this.trend,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTrendColor(trend).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              trend,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getTrendColor(trend),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    if (trend.startsWith('+') || trend.toLowerCase() == 'good') {
      return Colors.green;
    }
    if (trend.startsWith('-')) {
      return Colors.red;
    }
    return Colors.orange;
  }
}

class _MilkingRecord extends StatelessWidget {
  final String time;
  final String amount;
  final String quality;
  final ThemeData theme;

  const _MilkingRecord({
    required this.time,
    required this.amount,
    required this.quality,
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
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.local_drink,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  amount,
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
              color: _getQualityColor(quality).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              quality,
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getQualityColor(quality),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.blue;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _HistoryTab extends StatelessWidget {
  final Map<String, dynamic> animal;
  final ThemeData theme;

  const _HistoryTab({required this.animal, required this.theme});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> history = [
      {
        'date': '2024-02-20',
        'event': 'Health Check',
        'details': 'Routine checkup - all normal',
        'vet': 'Dr. Kamau',
      },
      {
        'date': '2024-02-15',
        'event': 'Vaccination',
        'details': 'Foot and Mouth vaccine administered',
        'vet': 'Dr. Wanjiku',
      },
      {
        'date': '2024-01-30',
        'event': 'Breeding',
        'details': 'Artificial insemination performed',
        'vet': 'Dr. Otieno',
      },
      {
        'date': '2024-01-15',
        'event': 'Purchase',
        'details': 'Animal purchased and added to farm',
        'source': 'Local breeder',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _AnimatedCard(
          index: 1,
          theme: theme,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Animal History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...history.map((entry) => _HistoryItem(entry: entry, theme: theme)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final Map<String, dynamic> entry;
  final ThemeData theme;

  const _HistoryItem({required this.entry, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getEventIcon(entry['event']),
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['event'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  entry['details'],
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      entry['date'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (entry['vet'] != null)
                      Text(
                        'by ${entry['vet']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    if (entry['source'] != null)
                      Text(
                        'from ${entry['source']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
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

  IconData _getEventIcon(String event) {
    switch (event.toLowerCase()) {
      case 'health check':
        return Icons.medical_services;
      case 'vaccination':
        return Icons.medication;
      case 'breeding':
        return Icons.family_restroom;
      case 'purchase':
        return Icons.shopping_cart;
      default:
        return Icons.history;
    }
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
            boxShadow: [AppColors.subtleShadow],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}