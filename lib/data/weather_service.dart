import 'dart:math';

class WeatherData {
  final String condition;
  final int temperature;
  final int rainChance;

  WeatherData({
    required this.condition,
    required this.temperature,
    required this.rainChance,
  });
}

class WeatherService {
  static final _conditions = ["Sunny", "Cloudy", "Rainy", "Windy"];

  static WeatherData getCurrentWeather() {
    final random = Random();
    final condition = _conditions[random.nextInt(_conditions.length)];
    return WeatherData(
      condition: condition,
      temperature: 25 + random.nextInt(5),
      rainChance: 10 + random.nextInt(60),
    );
  }
}
