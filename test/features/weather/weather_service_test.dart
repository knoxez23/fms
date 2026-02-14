import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/data/services/weather_service.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService api;
  late WeatherService service;

  setUp(() {
    api = MockApiService();
    service = WeatherService(api);
  });

  test('fetchWeather uses /weather and returns map payload', () async {
    when(() => api.get('/weather')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/weather'),
        data: {
          'current': {'temp': 26},
          'weekly': [],
        },
      ),
    );

    final result = await service.fetchWeather();

    expect(result['current']['temp'], 26);
    verify(() => api.get('/weather')).called(1);
  });

  test('fetchWeather unwraps nested data map contract', () async {
    when(() => api.get('/weather')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/weather'),
        data: {
          'data': {
            'current': {'temp': 23},
            'weekly': [],
          },
        },
      ),
    );

    final result = await service.fetchWeather();

    expect(result['current']['temp'], 23);
  });

  test('fetchWeather returns empty map for unsupported payload type', () async {
    when(() => api.get('/weather')).thenAnswer(
      (_) async => Response(
        requestOptions: RequestOptions(path: '/weather'),
        data: ['unexpected'],
      ),
    );

    final result = await service.fetchWeather();

    expect(result, isEmpty);
  });
}
