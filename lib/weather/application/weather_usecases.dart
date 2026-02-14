import 'package:injectable/injectable.dart';
import '../domain/entities/weather_entities.dart';
import '../domain/repositories/weather_repository.dart';

@lazySingleton
class GetWeather {
  final WeatherRepository repository;
  GetWeather(this.repository);

  Future<WeatherSnapshot> execute() async {
    return await repository.getWeather();
  }
}
