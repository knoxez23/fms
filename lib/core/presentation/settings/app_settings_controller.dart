import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const _themeModeKey = 'app_theme_mode';
  static const _languageKey = 'app_language_code';

  static final AppSettingsController instance = AppSettingsController._();

  AppSettingsController._();

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    _themeMode = _parseThemeMode(prefs.getString(_themeModeKey));
    _locale = Locale(_parseLanguage(prefs.getString(_languageKey)));
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> setLanguageCode(String languageCode) async {
    final normalized = _parseLanguage(languageCode);
    if (_locale.languageCode == normalized) return;
    _locale = Locale(normalized);
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, normalized);
  }

  ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _parseLanguage(String? raw) {
    if (raw == 'sw') return 'sw';
    return 'en';
  }
}
