import 'package:injectable/injectable.dart';
import '../../../core/domain/repositories/farm_summary_repository.dart';
import '../../weather/application/weather_usecases.dart';
import '../domain/entities/dashboard_data.dart';
import '../../weather/domain/entities/weather_entities.dart';

@lazySingleton
class GetDashboardData {
  final FarmSummaryRepository _farmSummaryRepository;
  final GetWeather _getWeather;

  GetDashboardData(this._farmSummaryRepository, this._getWeather);

  Future<DashboardData> execute() async {
    final results = await Future.wait([
      _farmSummaryRepository.getFarmSummary(),
      _getWeather.execute(),
    ]);
    final summary = results[0] as Map<String, dynamic>;
    final weather = results[1] as WeatherSnapshot;
    return DashboardData(summary: summary, weatherSnapshot: weather);
  }
}
