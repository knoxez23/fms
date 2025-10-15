import 'package:flutter/material.dart';
import 'dart:math';
import 'package:pamoja_twalima/theme/app_colors.dart';

// NOTE: Replace mock data later with your LocalData / API
class FarmMgmtScreen extends StatefulWidget {
  const FarmMgmtScreen({super.key});

  @override
  State<FarmMgmtScreen> createState() => _FarmMgmtScreenState();
}

class _FarmMgmtScreenState extends State<FarmMgmtScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Random _rand = Random();

  // Mock summaries
  int totalCrops = 8;
  int totalAnimals = 12;
  double balance = 2450;

  // Mock lists
  final List<Map<String, dynamic>> tasks = [
    {"title": "Irrigate maize field", "due": "Today", "done": false},
    {"title": "Vaccinate chickens", "due": "Tomorrow", "done": false},
  ];

  final List<Map<String, dynamic>> inventory = [
    {"name": "Fertilizer (kg)", "qty": 25},
    {"name": "Seeds (packets)", "qty": 40},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddRecordSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddRecordSheet(theme: Theme.of(context)),
    );

    if (result != null) {
      setState(() {
        if (result['type'] == 'task') {
          tasks.insert(0,
              {"title": result['title'], "due": result['due'], "done": false});
        } else if (result['type'] == 'inventory') {
          inventory.insert(0, {"name": result['title'], "qty": result['qty']});
        }
      });
    }
  }

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
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: theme.colorScheme.primary,
          tabs: const [
            Tab(text: "Overview"),
            Tab(text: "Crops"),
            Tab(text: "Animals"),
            Tab(text: "Inventory"),
            Tab(text: "Tasks"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. Overview
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // summary row
                Row(
                  children: [
                    _SmallStatCard(
                      title: "Crops",
                      value: "$totalCrops",
                      icon: Icons.agriculture,
                      theme: theme,
                    ),
                    const SizedBox(width: 12),
                    _SmallStatCard(
                      title: "Animals",
                      value: "$totalAnimals",
                      icon: Icons.pets,
                      theme: theme,
                    ),
                    const SizedBox(width: 12),
                    _SmallStatCard(
                      title: "Sales Today",
                      value: "KSh ${balance.toStringAsFixed(0)}",
                      icon: Icons.attach_money,
                      theme: theme,
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // mini chart (mock)
                _SectionTitle("Production overview", theme: theme),
                _AnimatedCard(
                  index: 0,
                  theme: theme,
                  child: SizedBox(
                    height: 120,
                    child: Row(
                      children: List.generate(6, (i) {
                        final val = 20 + _rand.nextInt(80);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: val.toDouble(),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withOpacity(0.85),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "W${i + 1}",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
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

                const SizedBox(height: 18),

                _SectionTitle("Upcoming tasks", theme: theme),
                for (var i = 0; i < tasks.length; i++)
                  _AnimatedCard(
                    index: i + 1,
                    theme: theme,
                    child: _TaskCard(
                      title: tasks[i]['title'],
                      due: tasks[i]['due'],
                      done: tasks[i]['done'],
                      theme: theme,
                    ),
                  ),

                const SizedBox(height: 18),

                _SectionTitle("Recent expenses", theme: theme),
                // mock expense list
                Column(
                  children: List.generate(3, (i) => _AnimatedCard(
                    index: i + 4,
                    theme: theme,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Fertilizer purchase",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Ksh ${1500 + i * 200}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )),
                )
              ],
            ),
          ),

          // 2. Crops tab
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle("Fields & Plots", theme: theme),
                // mock grid of plots
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (_, i) => _AnimatedCard(
                    index: i,
                    theme: theme,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Plot ${i + 1}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Maize, planted 2 wks ago",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _MiniStat(
                              icon: Icons.water_drop,
                              label: "Moisture",
                              value: "36%",
                              theme: theme,
                            ),
                            _MiniStat(
                              icon: Icons.thermostat,
                              label: "Temp",
                              value: "${20 + _rand.nextInt(8)}°C",
                              theme: theme,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionTitle("Growth calendar", theme: theme),
                _AnimatedCard(
                  index: 4,
                  theme: theme,
                  child: Column(
                    children: [
                      Text(
                        "Next: Fertilizer application",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Fri, Oct 17",
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Animals tab
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle("Livestock", theme: theme),
                // list of animals
                Column(
                  children: List.generate(4, (i) => _AnimatedCard(
                    index: i,
                    theme: theme,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                          child: Icon(
                            Icons.pets,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cow ${i + 1}",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "Age: ${1 + i} yrs",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              "Healthy",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            IconButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  )),
                ),
                const SizedBox(height: 8),
                _SectionTitle("Breeding schedule", theme: theme),
                _AnimatedCard(
                  index: 4,
                  theme: theme,
                  child: Text(
                    "Next heat detection: 3 days",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),

          // 4. Inventory tab
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle("Inventory & Inputs", theme: theme),
                Column(
                  children: inventory
                      .asMap()
                      .entries
                      .map((entry) => _AnimatedCard(
                    index: entry.key,
                    theme: theme,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.value['name'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${entry.value['qty']}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                _AnimatedCard(
                  index: inventory.length,
                  theme: theme,
                  child: ElevatedButton.icon(
                    onPressed: _openAddRecordSheet,
                    icon: const Icon(Icons.add),
                    label: const Text("Add input"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 5. Tasks tab
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle("Tasks & Routines", theme: theme),
                Column(
                  children: tasks
                      .asMap()
                      .entries
                      .map((entry) => _AnimatedCard(
                    index: entry.key,
                    theme: theme,
                    child: _TaskCard(
                      title: entry.value['title'],
                      due: entry.value['due'],
                      done: entry.value['done'],
                      theme: theme,
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                _AnimatedCard(
                  index: tasks.length,
                  theme: theme,
                  child: ElevatedButton.icon(
                    onPressed: _openAddRecordSheet,
                    icon: const Icon(Icons.add_task),
                    label: const Text("Create Task"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -90),
        child: GestureDetector(
          onTapDown: (_) => setState(() {}),
          onTapUp: (_) => setState(() {}),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 150),
            scale: 1.0,
            child: Container(
              height: 55,
              width: 55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 30),
                onPressed: _openAddRecordSheet,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

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
      duration: const Duration(milliseconds: 700),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.1 * widget.index,
          0.8,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          0.1 * widget.index,
          1,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
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
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: widget.theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ThemeData theme;

  const _SmallStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  child: Icon(icon, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final String title;
  final String due;
  final bool done;
  final ThemeData theme;

  const _TaskCard({
    required this.title,
    required this.due,
    required this.done,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: done,
          onChanged: (v) {},
          activeColor: theme.colorScheme.primary,
        ),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          due,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
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
      padding: const EdgeInsets.only(bottom: 8),
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

class _AddRecordSheet extends StatefulWidget {
  final ThemeData theme;

  const _AddRecordSheet({required this.theme});

  @override
  State<_AddRecordSheet> createState() => _AddRecordSheetState();
}

class _AddRecordSheetState extends State<_AddRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  String recordType = 'task';
  String title = '';
  String dueDate = '';
  int qty = 0;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return Container(
      padding: EdgeInsets.only(
        bottom: media.viewInsets.bottom,
        left: 16,
        right: 16,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: widget.theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Wrap(
          runSpacing: 12,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: widget.theme.colorScheme.onSurface.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              "Add New Record",
              style: widget.theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButtonFormField<String>(
              initialValue: recordType,
              items: const [
                DropdownMenuItem(value: 'task', child: Text("Task")),
                DropdownMenuItem(value: 'inventory', child: Text("Inventory")),
              ],
              decoration: const InputDecoration(
                labelText: "Record Type",
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => setState(() => recordType = val!),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Title / Description",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null || v.isEmpty ? "Enter a title" : null,
              onSaved: (v) => title = v!,
            ),
            if (recordType == 'task')
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Due Date",
                  hintText: "e.g. Tomorrow / 12 Oct",
                  border: OutlineInputBorder(),
                ),
                onSaved: (v) => dueDate = v ?? "",
              ),
            if (recordType == 'inventory')
              TextFormField(
                decoration: const InputDecoration(
                  labelText: "Quantity",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (v) => qty = int.tryParse(v ?? '0') ?? 0,
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Navigator.pop(context, {
                    "type": recordType,
                    "title": title,
                    "due": dueDate,
                    "qty": qty,
                  });
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text("Save Record"),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.theme.colorScheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}