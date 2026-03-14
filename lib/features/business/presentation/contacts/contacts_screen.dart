import 'package:flutter/material.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/contact_directory_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _service = ContactDirectoryService(ApiService());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      includeDrawer: false,
      appBar: ModernAppBar(
        title: context.tr('contacts'),
        variant: AppBarVariant.standard,
        showNotifications: false,
        bottomHeight: 48,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.tr('suppliers')),
            Tab(text: context.tr('customers')),
            Tab(text: context.tr('staff')),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ContactTab(
            titleKey: 'supplier',
            type: ContactType.supplier,
            service: _service,
          ),
          _ContactTab(
            titleKey: 'customer',
            type: ContactType.customer,
            service: _service,
          ),
          _ContactTab(
            titleKey: 'staff_member',
            type: ContactType.staffMember,
            service: _service,
            includeRole: true,
          ),
        ],
      ),
    );
  }
}

class _ContactTab extends StatefulWidget {
  const _ContactTab({
    required this.titleKey,
    required this.type,
    required this.service,
    this.includeRole = false,
  });

  final String titleKey;
  final ContactType type;
  final ContactDirectoryService service;
  final bool includeRole;

  @override
  State<_ContactTab> createState() => _ContactTabState();
}

class _ContactTabState extends State<_ContactTab> {
  bool _loading = true;
  List<Map<String, dynamic>> _rows = const [];
  Map<String, dynamic>? _farmContext;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final rows = await widget.service.list(widget.type);
      final farmContext = widget.type == ContactType.staffMember
          ? await widget.service.farmContext()
          : null;
      if (!mounted) return;
      setState(() {
        _rows = rows;
        _farmContext = farmContext;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${context.tr('failed_to_load')} ${context.tr(widget.titleKey).toLowerCase()}s: $e',
          ),
        ),
      );
    }
  }

  Future<void> _save(Map<String, dynamic> payload, {int? id}) async {
    try {
      if (id == null) {
        await widget.service.create(widget.type, payload);
      } else {
        await widget.service.update(widget.type, id: id, payload: payload);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('save_failed')}: $e')),
      );
    }
  }

  Future<void> _delete(int id) async {
    try {
      await widget.service.delete(widget.type, id: id);
      await _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${context.tr('delete_failed')}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: _rows.isEmpty
          ? _buildEmptyState(context)
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemBuilder: (_, index) {
                  if (widget.type == ContactType.staffMember && index == 0) {
                    return _StaffOverviewCard(contextData: _farmContext);
                  }

                  final row = _rows[widget.type == ContactType.staffMember
                      ? index - 1
                      : index];
                  final id = (row['id'] as num?)?.toInt();
                  final name = (row['name'] ?? '').toString();
                  final role = (row['role'] ?? '').toString();
                  final status = (row['employment_status'] ?? '').toString();
                  final assignmentArea =
                      (row['assignment_area'] ?? '').toString();
                  final subtitle = [
                    if (widget.includeRole && role.isNotEmpty) role,
                    if (widget.includeRole && status.isNotEmpty)
                      status.replaceAll('_', ' '),
                    if (widget.includeRole && assignmentArea.isNotEmpty)
                      assignmentArea,
                    (row['phone'] ?? '').toString(),
                    (row['email'] ?? '').toString(),
                  ].where((e) => e.isNotEmpty).join(' • ');

                  return Card(
                    margin: EdgeInsets.zero,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        child: Text(
                          (name.isEmpty ? '?' : name.characters.first)
                              .toUpperCase(),
                        ),
                      ),
                      title: Text(name.isEmpty ? context.tr('unnamed') : name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (subtitle.isNotEmpty) Text(subtitle),
                          if (widget.includeRole)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (role.isNotEmpty) _MetaChip(label: role),
                                  if (status.isNotEmpty)
                                    _MetaChip(
                                      label: status.replaceAll('_', ' '),
                                      highlighted: status == 'active',
                                    ),
                                  if ((row['can_login'] ?? false) == true)
                                    const _MetaChip(
                                      label: 'Can login',
                                      highlighted: true,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              final result =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                builder: (_) => _ContactEditorDialog(
                                  titleKey: widget.titleKey,
                                  includeRole: widget.includeRole,
                                  initial: row,
                                ),
                              );
                              if (result == null || id == null) return;
                              await _save(result, id: id);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: id == null ? null : () => _delete(id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) =>
                    const Divider(height: 12, color: Colors.transparent),
                itemCount: _rows.length +
                    (widget.type == ContactType.staffMember ? 1 : 0),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await showDialog<Map<String, dynamic>>(
              context: context,
              builder: (_) => _ContactEditorDialog(
                titleKey: widget.titleKey,
                includeRole: widget.includeRole,
              ),
            );
            if (result == null) return;
            await _save(result);
          },
          icon: const Icon(Icons.add),
          label: Text('${context.tr('add')} ${context.tr(widget.titleKey)}'),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    if (widget.type == ContactType.staffMember) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          _StaffOverviewCard(contextData: _farmContext),
          const SizedBox(height: 16),
          const Text(
            'No team members yet. Add workers, managers, or accountants so task assignment and accountability stay clear.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Center(
      child: Text(
        '${context.tr('no_items_yet')}: ${context.tr(widget.titleKey).toLowerCase()}',
      ),
    );
  }
}

class _ContactEditorDialog extends StatefulWidget {
  const _ContactEditorDialog({
    required this.titleKey,
    required this.includeRole,
    this.initial,
  });

  final String titleKey;
  final bool includeRole;
  final Map<String, dynamic>? initial;

  @override
  State<_ContactEditorDialog> createState() => _ContactEditorDialogState();
}

class _ContactEditorDialogState extends State<_ContactEditorDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _roleController;
  late final TextEditingController _assignmentAreaController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();
  late String _employmentStatus;
  late bool _canLogin;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: (widget.initial?['name'] ?? '').toString());
    _roleController =
        TextEditingController(text: (widget.initial?['role'] ?? '').toString());
    _assignmentAreaController = TextEditingController(
      text: (widget.initial?['assignment_area'] ?? '').toString(),
    );
    _phoneController = TextEditingController(
        text: (widget.initial?['phone'] ?? '').toString());
    _emailController = TextEditingController(
        text: (widget.initial?['email'] ?? '').toString());
    _addressController = TextEditingController(
      text: (widget.initial?['address'] ?? '').toString(),
    );
    _notesController = TextEditingController(
        text: (widget.initial?['notes'] ?? '').toString());
    _employmentStatus =
        (widget.initial?['employment_status'] ?? 'active').toString();
    _canLogin = widget.initial?['can_login'] == true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _assignmentAreaController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '${widget.initial == null ? context.tr('add') : context.tr('edit')} ${context.tr(widget.titleKey)}',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    InputDecoration(labelText: context.tr('name_field')),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return context.tr('name_required');
                  }
                  return null;
                },
              ),
              if (widget.includeRole)
                TextFormField(
                  controller: _roleController,
                  decoration: InputDecoration(labelText: context.tr('role')),
                ),
              if (widget.includeRole)
                DropdownButtonFormField<String>(
                  initialValue: _employmentStatus,
                  decoration:
                      const InputDecoration(labelText: 'Employment status'),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Active')),
                    DropdownMenuItem(
                        value: 'seasonal', child: Text('Seasonal')),
                    DropdownMenuItem(
                        value: 'on_leave', child: Text('On leave')),
                    DropdownMenuItem(
                        value: 'inactive', child: Text('Inactive')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _employmentStatus = value);
                    }
                  },
                ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: context.tr('phone')),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: context.tr('email')),
              ),
              if (widget.includeRole)
                TextFormField(
                  controller: _assignmentAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Work area',
                    hintText: 'Dairy unit, North field, Inventory...',
                  ),
                ),
              if (!widget.includeRole)
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: context.tr('address')),
                ),
              if (widget.includeRole)
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _canLogin,
                  title: const Text('Allow future app login'),
                  subtitle: const Text(
                    'Useful for managers or accountable staff who may need their own access later.',
                  ),
                  onChanged: (value) {
                    setState(() => _canLogin = value);
                  },
                ),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(labelText: context.tr('notes')),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, {
              'name': _nameController.text.trim(),
              if (widget.includeRole) 'role': _roleController.text.trim(),
              if (widget.includeRole) 'employment_status': _employmentStatus,
              'phone': _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              'email': _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
              if (widget.includeRole)
                'assignment_area': _assignmentAreaController.text.trim().isEmpty
                    ? null
                    : _assignmentAreaController.text.trim(),
              if (widget.includeRole) 'can_login': _canLogin,
              if (!widget.includeRole)
                'address': _addressController.text.trim().isEmpty
                    ? null
                    : _addressController.text.trim(),
              'notes': _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
            });
          },
          child: Text(context.tr('save')),
        ),
      ],
    );
  }
}

class _StaffOverviewCard extends StatelessWidget {
  const _StaffOverviewCard({required this.contextData});

  final Map<String, dynamic>? contextData;

  @override
  Widget build(BuildContext context) {
    final farm = (contextData?['farm'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final membership =
        (contextData?['membership'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final teamSummary =
        (contextData?['team_summary'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};
    final roles = (teamSummary['roles'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.14),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (farm['name'] ?? 'Farm team').toString(),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Signed in as ${(membership['role'] ?? 'owner').toString()}. Keep roles and work areas current so task assignment stays intuitive.',
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                label: '${teamSummary['staff_count'] ?? 0} team members',
                highlighted: true,
              ),
              _MetaChip(
                label: '${teamSummary['active_staff_count'] ?? 0} active',
              ),
              ...roles.entries.take(3).map(
                  (entry) => _MetaChip(label: '${entry.key}: ${entry.value}')),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.label,
    this.highlighted = false,
  });

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted
            ? scheme.primary.withValues(alpha: 0.14)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
