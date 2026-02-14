import '../entities/weather_entities.dart';

abstract class WeatherRepository {
  Future<WeatherSnapshot> getWeather();
}
