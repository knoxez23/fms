import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:pamoja_twalima/features/profile/application/profile_usecases.dart';
import 'package:pamoja_twalima/features/profile/domain/entities/audit_event_entity.dart';

class AuditEventsState {
  final bool isLoading;
  final List<AuditEventEntity> events;
  final String? error;

  const AuditEventsState({
    required this.isLoading,
    required this.events,
    this.error,
  });

  factory AuditEventsState.initial() =>
      const AuditEventsState(isLoading: false, events: []);

  AuditEventsState copyWith({
    bool? isLoading,
    List<AuditEventEntity>? events,
    String? error,
  }) {
    return AuditEventsState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      error: error,
    );
  }
}

@injectable
class AuditEventsCubit extends Cubit<AuditEventsState> {
  final GetAuditEvents _getAuditEvents;
  final Logger _logger = Logger();

  AuditEventsCubit(this._getAuditEvents) : super(AuditEventsState.initial());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final items = await _getAuditEvents.execute(limit: 200);
      emit(state.copyWith(isLoading: false, events: items));
    } catch (e) {
      _logger.e('error_audit_load', error: e);
      emit(state.copyWith(isLoading: false, error: 'error_audit_load'));
    }
  }
}
