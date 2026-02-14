import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import '../../../application/get_dashboard_data.dart';
import '../../../domain/entities/dashboard_data.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetDashboardData _getDashboardData;

  HomeBloc(this._getDashboardData) : super(const HomeState.initial()) {
    on<LoadHome>(_onLoad);
    on<RefreshHome>(_onRefresh);
  }

  Future<void> _onLoad(LoadHome event, Emitter<HomeState> emit) async {
    emit(const HomeState.loading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(RefreshHome event, Emitter<HomeState> emit) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      final data = await _getDashboardData.execute();
      emit(HomeState.loaded(data: data));
    } catch (e) {
      emit(const HomeState.error(message: 'Failed to load dashboard'));
    }
  }
}
