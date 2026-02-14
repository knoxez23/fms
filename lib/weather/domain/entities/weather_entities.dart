class CurrentWeather {
  final int temperatureC;
  final String condition;
  final String iconKey;
  final int humidity;
  final int windKph;
  final int rainChance;
  final String advice;

  const CurrentWeather({
    required this.temperatureC,
    required this.condition,
    required this.iconKey,
    required this.humidity,
    required this.windKph,
    required this.rainChance,
    required this.advice,
  });
}

class DailyForecast {
  final String day;
  final int temperatureC;
  final String condition;
  final String iconKey;
  final int rainChance;

  const DailyForecast({
    required this.day,
    required this.temperatureC,
    required this.condition,
    required this.iconKey,
    required this.rainChance,
  });
}

class WeatherSnapshot {
  final CurrentWeather current;
  final List<DailyForecast> weekly;

  const WeatherSnapshot({
    required this.current,
    required this.weekly,
  });
}
