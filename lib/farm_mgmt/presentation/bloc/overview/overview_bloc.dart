import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../application/get_overview.dart';
import '../../../domain/entities/overview_summary_entity.dart';

part 'overview_event.dart';
part 'overview_state.dart';
part 'overview_bloc.freezed.dart';

@injectable
class OverviewBloc extends Bloc<OverviewEvent, OverviewState> {
  final GetOverview _getOverview;
  final Logger _logger = Logger();

  OverviewBloc(this._getOverview) : super(const OverviewState.initial()) {
    on<LoadOverview>(_onLoad);
  }

  Future<void> _onLoad(
    LoadOverview event,
    Emitter<OverviewState> emit,
  ) async {
    emit(const OverviewState.loading());
    try {
      final summary = await _getOverview.execute();
      emit(OverviewState.loaded(summary: summary));
    } catch (e) {
      _logger.e('Failed to load overview', error: e);
      emit(const OverviewState.error(message: 'Failed to load overview'));
    }
  }
}
