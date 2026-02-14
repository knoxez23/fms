import 'package:injectable/injectable.dart';
import '../domain/entities/weather_entities.dart';
import '../domain/repositories/weather_repository.dart';
import '../../data/services/weather_service.dart';

@LazySingleton(as: WeatherRepository)
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherService _service;

  WeatherRepositoryImpl(this._service);

  @override
  Future<WeatherSnapshot> getWeather() async {
    final data = await _service.fetchWeather();
    final current = _mapCurrent(data['current'] as Map<String, dynamic>? ?? data);
    final weeklyRaw = (data['weekly'] ?? data['forecast'] ?? []) as List;
    final weekly = weeklyRaw
        .whereType<Map>()
        .map((e) => _mapDaily(e.cast<String, dynamic>()))
        .toList();
    return WeatherSnapshot(current: current, weekly: weekly);
  }

  CurrentWeather _mapCurrent(Map<String, dynamic> map) {
    return CurrentWeather(
      temperatureC: _toInt(map['temp'] ?? map['temperature'] ?? 0),
      condition: (map['condition'] ?? map['summary'] ?? '').toString(),
      iconKey: (map['icon'] ?? map['icon_key'] ?? 'wb_sunny').toString(),
      humidity: _toInt(map['humidity'] ?? 0),
      windKph: _toInt(map['wind'] ?? map['wind_kph'] ?? 0),
      rainChance: _toInt(map['rain_chance'] ?? map['rainChance'] ?? 0),
      advice: (map['advice'] ?? '').toString(),
    );
  }

  DailyForecast _mapDaily(Map<String, dynamic> map) {
    return DailyForecast(
      day: (map['day'] ?? map['date'] ?? '').toString(),
      temperatureC: _toInt(map['temp'] ?? map['temperature'] ?? 0),
      condition: (map['condition'] ?? map['summary'] ?? '').toString(),
      iconKey: (map['icon'] ?? map['icon_key'] ?? 'wb_sunny').toString(),
      rainChance: _toInt(map['rain_chance'] ?? map['rainChance'] ?? 0),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    return int.tryParse(value.toString()) ?? 0;
  }
}
