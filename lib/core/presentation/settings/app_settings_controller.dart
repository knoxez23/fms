import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const _themeModeKey = 'app_theme_mode';
  static const _languageKey = 'app_language_code';
  static const _opsRemindersEnabledKey = 'ops_reminders_enabled';
  static const _opsMorningEnabledKey = 'ops_reminders_morning_enabled';
  static const _opsEveningEnabledKey = 'ops_reminders_evening_enabled';

  static final AppSettingsController instance = AppSettingsController._();

  AppSettingsController._();

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  bool _operationalRemindersEnabled = true;
  bool _morningReminderEnabled = true;
  bool _eveningReminderEnabled = true;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get operationalRemindersEnabled => _operationalRemindersEnabled;
  bool get morningReminderEnabled => _morningReminderEnabled;
  bool get eveningReminderEnabled => _eveningReminderEnabled;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    _themeMode = _parseThemeMode(prefs.getString(_themeModeKey));
    _locale = Locale(_parseLanguage(prefs.getString(_languageKey)));
    _operationalRemindersEnabled =
        prefs.getBool(_opsRemindersEnabledKey) ?? true;
    _morningReminderEnabled = prefs.getBool(_opsMorningEnabledKey) ?? true;
    _eveningReminderEnabled = prefs.getBool(_opsEveningEnabledKey) ?? true;
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

  Future<void> setOperationalRemindersEnabled(bool value) async {
    if (_operationalRemindersEnabled == value) return;
    _operationalRemindersEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_opsRemindersEnabledKey, value);
  }

  Future<void> setMorningReminderEnabled(bool value) async {
    if (_morningReminderEnabled == value) return;
    _morningReminderEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_opsMorningEnabledKey, value);
  }

  Future<void> setEveningReminderEnabled(bool value) async {
    if (_eveningReminderEnabled == value) return;
    _eveningReminderEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_opsEveningEnabledKey, value);
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
