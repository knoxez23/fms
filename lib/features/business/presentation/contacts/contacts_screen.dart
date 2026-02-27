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

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final rows = await widget.service.list(widget.type);
      if (!mounted) return;
      setState(() {
        _rows = rows;
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
          ? Center(
              child: Text(
                '${context.tr('no_items_yet')}: ${context.tr(widget.titleKey).toLowerCase()}',
              ),
            )
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemBuilder: (_, index) {
                  final row = _rows[index];
                  final id = (row['id'] as num?)?.toInt();
                  final name = (row['name'] ?? '').toString();
                  final role = (row['role'] ?? '').toString();
                  final subtitle = [
                    if (widget.includeRole && role.isNotEmpty) role,
                    (row['phone'] ?? '').toString(),
                    (row['email'] ?? '').toString(),
                  ].where((e) => e.isNotEmpty).join(' • ');

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    title: Text(name.isEmpty ? context.tr('unnamed') : name),
                    subtitle: subtitle.isEmpty ? null : Text(subtitle),
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
                  );
                },
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemCount: _rows.length,
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
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: (widget.initial?['name'] ?? '').toString());
    _roleController =
        TextEditingController(text: (widget.initial?['role'] ?? '').toString());
    _phoneController = TextEditingController(
        text: (widget.initial?['phone'] ?? '').toString());
    _emailController = TextEditingController(
        text: (widget.initial?['email'] ?? '').toString());
    _addressController = TextEditingController(
      text: (widget.initial?['address'] ?? '').toString(),
    );
    _notesController = TextEditingController(
        text: (widget.initial?['notes'] ?? '').toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
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
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: context.tr('phone')),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: context.tr('email')),
              ),
              if (!widget.includeRole)
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: context.tr('address')),
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
              'phone': _phoneController.text.trim().isEmpty
                  ? null
                  : _phoneController.text.trim(),
              'email': _emailController.text.trim().isEmpty
                  ? null
                  : _emailController.text.trim(),
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
