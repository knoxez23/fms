import 'package:injectable/injectable.dart';
import '../network/api_service.dart';

@LazySingleton()
class WeatherService {
  final ApiService _api;

  WeatherService(this._api);

  Future<Map<String, dynamic>> fetchWeather() async {
    final response = await _api.get('/weather');
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map) {
        return nested.map((key, value) => MapEntry(key.toString(), value));
      }
      return data;
    }
    if (data is Map && data['data'] is Map) {
      final nested = data['data'] as Map;
      return nested.map((key, value) => MapEntry(key.toString(), value));
    }
    return {};
  }
}
