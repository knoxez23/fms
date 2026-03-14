import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/settings/app_localizations.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
import 'package:pamoja_twalima/features/profile/domain/entities/audit_event_entity.dart';
import 'package:pamoja_twalima/features/profile/presentation/bloc/profile/audit_events_cubit.dart';

class AuditEventsScreen extends StatelessWidget {
  const AuditEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuditEventsCubit>()..load(),
      child: BlocBuilder<AuditEventsCubit, AuditEventsState>(
        builder: (context, state) {
          final theme = Theme.of(context);
          return AppScaffold(
            includeDrawer: false,
            appBar: ModernAppBar(
              title: context.tr('audit_trail'),
              variant: AppBarVariant.standard,
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text(context.tr(state.error!)))
                    : state.events.isEmpty
                        ? Center(child: Text(context.tr('no_audit_events')))
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.events.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final event = state.events[index];
                              final summary = _summaryFor(event);
                              return Card(
                                elevation: 0,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    child: Icon(
                                      _iconFor(event.eventType),
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  title: Text(_titleFor(event.eventType)),
                                  subtitle: Text(
                                    '$summary\n'
                                    '${_entityLabel(event)} • ${event.occurredAt.toLocal().toIso8601String().replaceFirst('T', ' ').split('.').first}',
                                  ),
                                  isThreeLine: true,
                                  trailing: event.metadata.isEmpty
                                      ? null
                                      : IconButton(
                                          icon: Icon(
                                            Icons.info_outline,
                                            color: theme.colorScheme.primary,
                                          ),
                                          onPressed: () =>
                                              _showMetadata(context, event),
                                        ),
                                ),
                              );
                            },
                          ),
          );
        },
      ),
    );
  }

  String _titleFor(String eventType) {
    switch (eventType) {
      case 'animal.created':
        return 'Animal Added';
      case 'animal.updated':
        return 'Animal Updated';
      case 'animal.deleted':
        return 'Animal Deleted';
      case 'crop.created':
        return 'Crop Added';
      case 'crop.updated':
        return 'Crop Updated';
      case 'crop.deleted':
        return 'Crop Deleted';
      case 'sale.created':
        return 'Sale Recorded';
      case 'sale.updated':
        return 'Sale Updated';
      case 'sale.deleted':
        return 'Sale Deleted';
      case 'staff.created':
        return 'Staff Added';
      case 'staff.updated':
        return 'Staff Updated';
      case 'staff.deleted':
        return 'Staff Deleted';
      case 'feeding_schedule.created':
        return 'Feeding Schedule Added';
      case 'feeding_schedule.updated':
        return 'Feeding Schedule Updated';
      case 'feeding_schedule.deleted':
        return 'Feeding Schedule Deleted';
      case 'feeding_log.created':
        return 'Feeding Logged';
      case 'feeding_log.updated':
        return 'Feeding Log Updated';
      case 'feeding_log.deleted':
        return 'Feeding Log Deleted';
      case 'animal_health.created':
        return 'Health Record Added';
      case 'animal_health.updated':
        return 'Health Record Updated';
      case 'animal_health.deleted':
        return 'Health Record Deleted';
      case 'animal_production.created':
        return 'Production Logged';
      case 'animal_production.updated':
        return 'Production Log Updated';
      case 'animal_production.deleted':
        return 'Production Log Deleted';
      case 'animal_weight.created':
        return 'Weight Recorded';
      case 'animal_weight.updated':
        return 'Weight Record Updated';
      case 'animal_weight.deleted':
        return 'Weight Record Deleted';
      case 'inventory.created':
        return 'Inventory Added';
      case 'inventory.updated':
      case 'inventory.upserted':
        return 'Inventory Updated';
      case 'inventory.deleted':
        return 'Inventory Deleted';
      case 'task.created':
        return 'Task Added';
      case 'task.updated':
      case 'task.upserted':
        return 'Task Updated';
      case 'task.deleted':
        return 'Task Deleted';
      case 'supplier.created':
        return 'Supplier Added';
      case 'supplier.updated':
        return 'Supplier Updated';
      case 'supplier.deleted':
        return 'Supplier Deleted';
      case 'customer.created':
        return 'Customer Added';
      case 'customer.updated':
        return 'Customer Updated';
      case 'customer.deleted':
        return 'Customer Deleted';
      default:
        return eventType.replaceAll('.', ' ').trim();
    }
  }

  String _summaryFor(AuditEventEntity event) {
    final summary = event.metadata['summary']?.toString().trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }
    return 'Recorded ${_titleFor(event.eventType).toLowerCase()}.';
  }

  String _entityLabel(AuditEventEntity event) {
    final type = event.entityType.replaceAll('_', ' ');
    if (event.entityId == null || event.entityId.toString().trim().isEmpty) {
      return type;
    }
    return '$type #${event.entityId}';
  }

  IconData _iconFor(String eventType) {
    if (eventType.startsWith('animal')) return Icons.pets_outlined;
    if (eventType.startsWith('crop')) return Icons.grass_outlined;
    if (eventType.startsWith('sale')) return Icons.receipt_long_outlined;
    if (eventType.startsWith('staff')) return Icons.badge_outlined;
    if (eventType.startsWith('feeding')) return Icons.local_dining_outlined;
    if (eventType.startsWith('inventory')) return Icons.inventory_2_outlined;
    if (eventType.startsWith('task')) return Icons.task_alt_outlined;
    if (eventType.startsWith('supplier')) return Icons.local_shipping_outlined;
    if (eventType.startsWith('customer')) return Icons.person_outline;
    return Icons.history;
  }

  void _showMetadata(BuildContext context, AuditEventEntity event) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final rows = event.metadata.entries
            .where((entry) => entry.value != null)
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleFor(event.eventType),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...rows.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            entry.key.replaceAll('_', ' '),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value.toString(),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
