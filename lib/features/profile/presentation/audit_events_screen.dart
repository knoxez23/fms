import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pamoja_twalima/core/di/injection.dart';
import 'package:pamoja_twalima/core/presentation/widgets/app_scaffold.dart';
import 'package:pamoja_twalima/core/presentation/widgets/modern_app_bar.dart';
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
            appBar: const ModernAppBar(
              title: 'Audit Trail',
              variant: AppBarVariant.standard,
            ),
            body: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? Center(child: Text(state.error!))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.events.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final event = state.events[index];
                          return Card(
                            elevation: 0,
                            child: ListTile(
                              title: Text(event.eventType),
                              subtitle: Text(
                                '${event.entityType}${event.entityId != null ? ' #${event.entityId}' : ''}\n'
                                '${event.occurredAt.toLocal().toIso8601String().replaceFirst('T', ' ').split('.').first}',
                              ),
                              isThreeLine: true,
                              trailing: event.metadata.isEmpty
                                  ? null
                                  : Icon(
                                      Icons.info_outline,
                                      color: theme.colorScheme.primary,
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
}
