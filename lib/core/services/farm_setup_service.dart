import 'package:shared_preferences/shared_preferences.dart';

class FarmSetupService {
  FarmSetupService._internal();

  static final FarmSetupService _instance = FarmSetupService._internal();
  factory FarmSetupService() => _instance;

  String _setupKey(int userId) => 'farm_setup_complete_$userId';

  Future<bool> isSetupComplete(int? userId) async {
    if (userId == null) return false;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_setupKey(userId)) ?? false;
  }

  Future<void> markSetupComplete(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_setupKey(userId), true);
  }
}
