import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CrashReportingService {
  CrashReportingService._();

  static final CrashReportingService instance = CrashReportingService._();

  Future<void> start({
    required String dsn,
    required String environment,
    required bool enable,
    required FutureOr<void> Function() appRunner,
  }) async {
    if (!enable || dsn.trim().isEmpty) {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };
      await runZonedGuarded(() async {
        await appRunner();
      }, (error, stack) {
        debugPrint('Unhandled zone error: $error');
      });
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.environment = environment;
        options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;
        options.profilesSampleRate = 0.0;
      },
      appRunner: () async {
        await appRunner();
      },
    );
  }
}
