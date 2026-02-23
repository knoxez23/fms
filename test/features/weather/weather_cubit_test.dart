import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pamoja_twalima/features/weather/application/weather_usecases.dart';
import 'package:pamoja_twalima/features/weather/domain/entities/weather_entities.dart';
import 'package:pamoja_twalima/features/weather/presentation/bloc/weather/weather_cubit.dart';

class MockGetWeather extends Mock implements GetWeather {}

void main() {
  late MockGetWeather getWeather;
  late WeatherSnapshot snapshot;

  setUp(() {
    getWeather = MockGetWeather();
    snapshot = const WeatherSnapshot(
      current: CurrentWeather(
        temperatureC: 25,
        condition: 'Clear',
        iconKey: 'wb_sunny',
        humidity: 58,
        windKph: 10,
        rainChance: 8,
        advice: 'Proceed with field work.',
      ),
      weekly: [
        DailyForecast(
          day: '2026-02-14',
          temperatureC: 26,
          condition: 'Clear',
          iconKey: 'wb_sunny',
          rainChance: 10,
        ),
      ],
    );
  });

  blocTest<WeatherCubit, WeatherState>(
    'emits loading then loaded state when use case succeeds',
    build: () {
      when(() => getWeather.execute()).thenAnswer((_) async => snapshot);
      return WeatherCubit(getWeather);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<WeatherState>().having((s) => s.loading, 'loading', true),
      isA<WeatherState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.snapshot, 'snapshot', snapshot)
          .having((s) => s.error, 'error', null),
    ],
    verify: (_) {
      verify(() => getWeather.execute()).called(1);
    },
  );

  blocTest<WeatherCubit, WeatherState>(
    'emits loading then error state when use case fails',
    build: () {
      when(() => getWeather.execute()).thenThrow(Exception('network'));
      return WeatherCubit(getWeather);
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      isA<WeatherState>().having((s) => s.loading, 'loading', true),
      isA<WeatherState>()
          .having((s) => s.loading, 'loading', false)
          .having((s) => s.error, 'error', 'Failed to load weather'),
    ],
  );
}
