import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnvironment {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api';

  static String get sentryDsn => dotenv.env['SENTRY_DSN'] ?? '';

  static String get appEnv =>
      dotenv.env['APP_ENV'] ?? (kReleaseMode ? 'production' : 'development');

  static bool get enableLogging {
    final raw = (dotenv.env['ENABLE_LOGGING'] ?? 'true').toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }
}
