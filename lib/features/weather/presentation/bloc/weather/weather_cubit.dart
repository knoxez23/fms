import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../application/weather_usecases.dart';
import '../../../domain/entities/weather_entities.dart';

class WeatherState {
  final WeatherSnapshot? snapshot;
  final bool loading;
  final String? error;

  const WeatherState({
    required this.snapshot,
    required this.loading,
    this.error,
  });

  WeatherState copyWith({
    WeatherSnapshot? snapshot,
    bool? loading,
    String? error,
  }) {
    return WeatherState(
      snapshot: snapshot ?? this.snapshot,
      loading: loading ?? this.loading,
      error: error,
    );
  }

  factory WeatherState.initial() {
    return const WeatherState(snapshot: null, loading: true);
  }
}

@injectable
class WeatherCubit extends Cubit<WeatherState> {
  final GetWeather _getWeather;

  WeatherCubit(this._getWeather) : super(WeatherState.initial());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final snapshot = await _getWeather.execute();
      emit(state.copyWith(snapshot: snapshot, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: 'error_weather_load'));
    }
  }
}
