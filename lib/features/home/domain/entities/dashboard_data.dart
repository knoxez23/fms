import '../../../weather/domain/entities/weather_entities.dart';

class DashboardData {
  final Map<String, dynamic> summary;
  final WeatherSnapshot? weatherSnapshot;

  const DashboardData({
    required this.summary,
    required this.weatherSnapshot,
  });
}
