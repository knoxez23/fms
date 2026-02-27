import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';

import 'package:pamoja_twalima/features/inventory/domain/entities/inventory_item.dart';
import 'package:pamoja_twalima/features/inventory/presentation/bloc/inventory/inventory_bloc.dart';

class InventoryConflictCenterScreen extends StatelessWidget {
  const InventoryConflictCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('conflict_center')),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _resolveAll(context, value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'server',
                child: Text(context.tr('resolve_all_use_server')),
              ),
              PopupMenuItem(
                value: 'local',
                child: Text(context.tr('resolve_all_keep_local')),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          final items = state.maybeWhen(
            loaded: (items, _, __) => items,
            orElse: () => <InventoryItem>[],
          );
          final conflicts = items.where((item) => item.hasConflict).toList();

          if (conflicts.isEmpty) {
            return Center(
              child: Text(context.tr('no_sync_conflicts')),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: conflicts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = conflicts[index];
              return _ConflictCard(item: item);
            },
          );
        },
      ),
    );
  }

  void _resolveAll(BuildContext context, String mode) {
    final state = context.read<InventoryBloc>().state;
    final items = state.maybeWhen(
      loaded: (items, _, __) => items,
      orElse: () => <InventoryItem>[],
    );
    final conflicts = items.where((item) => item.hasConflict).toList();
    for (final item in conflicts) {
      if (item.id == null) continue;
      final id = int.parse(item.id!);
      context.read<InventoryBloc>().add(
            mode == 'server'
                ? InventoryEvent.resolveConflictUseServer(id: id)
                : InventoryEvent.resolveConflictKeepLocal(id: id),
          );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mode == 'server'
              ? '${context.tr('resolve_all_use_server')} (${conflicts.length})'
              : '${context.tr('resolve_all_keep_local')} (${conflicts.length})',
        ),
      ),
    );
  }
}

class _ConflictCard extends StatelessWidget {
  final InventoryItem item;

  const _ConflictCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        color: Colors.red.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.itemName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.category} • ${item.quantity} ${item.unit}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _resolveUseServer(context, item),
                  child: Text(context.tr('use_server')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _resolveKeepLocal(context, item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(context.tr('keep_local')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _resolveUseServer(BuildContext context, InventoryItem item) {
    if (item.id == null) return;
    context.read<InventoryBloc>().add(
          InventoryEvent.resolveConflictUseServer(id: int.parse(item.id!)),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              '${item.itemName}: ${context.tr('applied_server_version')}')),
    );
  }

  void _resolveKeepLocal(BuildContext context, InventoryItem item) {
    if (item.id == null) return;
    context.read<InventoryBloc>().add(
          InventoryEvent.resolveConflictKeepLocal(id: int.parse(item.id!)),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text('${item.itemName}: ${context.tr('local_version_queued')}')),
    );
  }
}
