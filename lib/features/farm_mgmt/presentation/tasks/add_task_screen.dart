import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/themes.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/contact_directory_service.dart';
import 'package:pamoja_twalima/features/business/presentation/contacts/contacts_screen.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/entities/task_entity.dart';
import 'package:pamoja_twalima/features/farm_mgmt/domain/value_objects/value_objects.dart';

class AddTaskScreen extends StatefulWidget {
  final String? sourceEventType;
  final String? sourceEventId;
  final String? initialTitle;
  final String? initialDescription;

  const AddTaskScreen({
    super.key,
    this.sourceEventType,
    this.sourceEventId,
    this.initialTitle,
    this.initialDescription,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final ContactDirectoryService _contactService =
      ContactDirectoryService(ApiService());
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _estimatedTimeController =
      TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedCategory = 'Crops';
  String _selectedPriority = 'Medium';
  String _selectedAssignee = 'Self';
  bool _approvalRequired = false;
  bool _approvalTouched = false;
  DateTime? _dueDate;

  final List<String> _categories = [
    'Crops',
    'Animals',
    'Poultry',
    'Vegetables',
    'Maintenance',
    'Administrative',
    'Inventory',
    'Other'
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  final List<String> _defaultAssignees = [
    'Self',
    'Team'
  ];
  List<String> _assignees = [];
  Map<String, String> _staffIdByName = const {};
  Map<String, Map<String, dynamic>> _staffByName = const {};

  @override
  void initState() {
    super.initState();
    _assignees = List<String>.from(_defaultAssignees);
    if (widget.initialTitle != null) {
      _titleController.text = widget.initialTitle!;
    }
    if (widget.initialDescription != null) {
      _descriptionController.text = widget.initialDescription!;
    }
    _loadStaffAssignees();
  }

  Future<void> _loadStaffAssignees() async {
    try {
      final rows = await _contactService.list(ContactType.staffMember);
      if (!mounted) return;
      final entries = rows
          .map((e) => Map<String, dynamic>.from(e))
          .where(
            (entry) =>
                (entry['name'] ?? '').toString().trim().isNotEmpty &&
                (entry['id'] ?? '').toString().trim().isNotEmpty,
          )
          .toList();
      setState(() {
        _staffIdByName = {
          for (final entry in entries)
            (entry['name'] ?? '').toString().trim():
                (entry['id'] ?? '').toString().trim(),
        };
        _staffByName = {
          for (final entry in entries)
            (entry['name'] ?? '').toString().trim(): entry,
        };
        final set = {..._defaultAssignees, ..._staffIdByName.keys};
        _assignees = set.toList()..sort();
        if (!_assignees.contains(_selectedAssignee)) {
          _selectedAssignee = _assignees.first;
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppScaffold(
      backgroundColor: theme.colorScheme.surface,
      includeDrawer: false,
      appBar: ModernAppBar(
        title: widget.sourceEventType == null
            ? 'Create New Task'
            : 'Create Linked Task',
        variant: AppBarVariant.standard,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
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
                        'Basic Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Task Title *',
                          hintText:
                              'e.g., Irrigate maize field, Vaccinate chickens',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter task title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Describe what needs to be done...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter task description';
                          }
                          return null;
                        },
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
                        'Task Details',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _syncApprovalSuggestion();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedPriority,
                        items: _priorities.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Priority *',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value!;
                            _syncApprovalSuggestion();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue:
                                  _assignees.contains(_selectedAssignee)
                                      ? _selectedAssignee
                                      : (_assignees.isNotEmpty
                                          ? _assignees.first
                                          : null),
                              items: _assignees.map((assignee) {
                                return DropdownMenuItem(
                                  value: assignee,
                                  child: Text(assignee),
                                );
                              }).toList(),
                              decoration: const InputDecoration(
                                labelText: 'Assign To',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAssignee = value!;
                                  _syncApprovalSuggestion();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            tooltip: 'Manage staff',
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ContactsScreen(),
                                ),
                              );
                              await _loadStaffAssignees();
                            },
                            icon: const Icon(Icons.contacts_outlined),
                          ),
                        ],
                      ),
                      if (_selectedAssignee != 'Self' &&
                          _selectedAssignee != 'Team' &&
                          _staffByName.containsKey(_selectedAssignee)) ...[
                        const SizedBox(height: 12),
                        _StaffAssignmentHint(
                          staff: _staffByName[_selectedAssignee]!,
                          theme: theme,
                        ),
                      ] else if (_selectedAssignee == 'Team') ...[
                        const SizedBox(height: 12),
                        _AssignmentHintCard(
                          theme: theme,
                          icon: Icons.groups_2_outlined,
                          title: 'Assigned to shared team queue',
                          subtitle:
                              'Use this when any available worker can pick it up. Managers can later reassign if needed.',
                        ),
                      ] else if (_selectedAssignee == 'Self') ...[
                        const SizedBox(height: 12),
                        _AssignmentHintCard(
                          theme: theme,
                          icon: Icons.person_outline,
                          title: 'Assigned to you',
                          subtitle:
                              'Use Self for work you plan to do directly so the team queue stays clean.',
                        ),
                      ],
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
                        'Timing & Scheduling',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _dueDateController,
                        decoration: InputDecoration(
                          labelText: 'Due Date *',
                          hintText: 'Select due date',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: _selectDueDate,
                          ),
                        ),
                        readOnly: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select due date';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _estimatedTimeController,
                        decoration: const InputDecoration(
                          labelText: 'Estimated Time',
                          hintText: 'e.g., 2 hours, 30 minutes',
                          border: OutlineInputBorder(),
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
                        'Approvals',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _approvalRequired,
                        onChanged: (value) {
                          setState(() {
                            _approvalTouched = true;
                            _approvalRequired = value;
                          });
                        },
                        title: const Text('Manager approval needed'),
                        subtitle: Text(
                          _approvalRequired
                              ? 'Use this for sensitive work like spending, repairs, stock movement, or tasks that should be checked before closing.'
                              : 'Leave this off for ordinary daily work that can be completed without sign-off.',
                        ),
                      ),
                      if (_approvalRequired)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 18,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'This task will go into a waiting-for-approval state until an owner, manager, or accountant signs it off.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.72),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Additional Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes & Instructions',
                          hintText:
                              'Any special instructions, reminders, or additional information...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _AnimatedCard(
                index: 4,
                theme: theme,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Task Management Tips',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Be specific with task descriptions for clarity\n'
                        '• Set realistic due dates and time estimates\n'
                        '• Use priorities to organize your workflow\n'
                        '• Assign tasks to appropriate team members\n'
                        '• Add notes for important details or context',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      if (widget.sourceEventType != null &&
                          widget.sourceEventId != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.link, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'This task will be linked to ${widget.sourceEventType}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );

    if (picked != null) {
      setState(() {
        _dueDate = picked;
        _dueDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final title = _titleController.text.trim();
      final task = TaskEntity(
        title: TaskTitle(title),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        dueDate: _dueDate,
        isCompleted: false,
        assignedTo: _selectedAssignee,
        staffMemberId: _staffIdByName[_selectedAssignee],
        sourceEventType: widget.sourceEventType,
        sourceEventId: widget.sourceEventId,
        approvalRequired: _approvalRequired,
        approvalStatus: _approvalRequired ? 'pending' : 'not_required',
      );

      // Navigate back with result or save to database
      Navigator.pop(context, task);
    }
  }

  void _syncApprovalSuggestion() {
    if (_approvalTouched) return;
    _approvalRequired = _shouldSuggestApproval(
      category: _selectedCategory,
      priority: _selectedPriority,
      assignee: _selectedAssignee,
    );
  }

  bool _shouldSuggestApproval({
    required String category,
    required String priority,
    required String assignee,
  }) {
    final normalizedCategory = category.toLowerCase();
    final normalizedPriority = priority.toLowerCase();
    return normalizedPriority == 'high' ||
        assignee == 'Team' ||
        normalizedCategory == 'inventory' ||
        normalizedCategory == 'maintenance' ||
        normalizedCategory == 'administrative';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    _estimatedTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _StaffAssignmentHint extends StatelessWidget {
  const _StaffAssignmentHint({
    required this.staff,
    required this.theme,
  });

  final Map<String, dynamic> staff;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final role = (staff['role'] ?? 'Worker').toString();
    final status = (staff['employment_status'] ?? 'active').toString();
    final area = (staff['assignment_area'] ?? '').toString().trim();
    final canLogin = staff['can_login'] == true;

    return _AssignmentHintCard(
      theme: theme,
      icon: Icons.badge_outlined,
      title: '${staff['name'] ?? 'Team member'} • $role',
      subtitle: [
        if (area.isNotEmpty) area,
        status,
        if (canLogin) 'App access enabled',
      ].join(' • '),
    );
  }
}

class _AssignmentHintCard extends StatelessWidget {
  const _AssignmentHintCard({
    required this.theme,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final ThemeData theme;
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
