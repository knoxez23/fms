import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pamoja_twalima/data/services/weather_service.dart';
import 'package:pamoja_twalima/weather/infrastructure/weather_repository_impl.dart';

class MockWeatherService extends Mock implements WeatherService {}

void main() {
  late MockWeatherService service;
  late WeatherRepositoryImpl repository;

  setUp(() {
    service = MockWeatherService();
    repository = WeatherRepositoryImpl(service);
  });

  test('maps current and weekly payload into WeatherSnapshot', () async {
    when(() => service.fetchWeather()).thenAnswer(
      (_) async => {
        'current': {
          'temp': 27,
          'condition': 'Sunny',
          'icon': 'wb_sunny',
          'humidity': 60,
          'wind': 14,
          'rain_chance': 10,
          'advice': 'Good day for spraying.',
        },
        'weekly': [
          {
            'day': '2026-02-14',
            'temp': 28,
            'condition': 'Sunny',
            'icon': 'wb_sunny',
            'rain_chance': 12,
          }
        ],
      },
    );

    final snapshot = await repository.getWeather();

    expect(snapshot.current.temperatureC, 27);
    expect(snapshot.current.condition, 'Sunny');
    expect(snapshot.weekly, hasLength(1));
    expect(snapshot.weekly.first.rainChance, 12);
  });

  test('falls back to top-level map when current key is absent', () async {
    when(() => service.fetchWeather()).thenAnswer(
      (_) async => {
        'temp': 21,
        'condition': 'Cloudy',
        'icon_key': 'cloud',
        'humidity': 70,
        'wind_kph': 9,
        'rainChance': 35,
        'advice': 'Plan around showers.',
        'forecast': [
          {
            'date': '2026-02-15',
            'temperature': 22,
            'summary': 'Cloudy',
            'icon_key': 'cloud',
            'rainChance': 30,
          }
        ],
      },
    );

    final snapshot = await repository.getWeather();

    expect(snapshot.current.temperatureC, 21);
    expect(snapshot.current.rainChance, 35);
    expect(snapshot.weekly.first.day, '2026-02-15');
  });
}
