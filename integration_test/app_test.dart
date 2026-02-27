import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pamoja_twalima/core/services/local_notification_service.dart';
import 'package:pamoja_twalima/data/models/animal.dart';
import 'package:pamoja_twalima/data/repositories/sync_data.dart';
import 'package:pamoja_twalima/main.dart' as app;

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
  Duration step = const Duration(milliseconds: 200),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }
  throw TestFailure('Timed out waiting for widget: $finder');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  const secureStorage = FlutterSecureStorage();
  LocalNotificationService.suppressPermissionRequestsForTests = true;

  Future<void> resetAppState({
    required bool seenOnboarding,
    bool authenticated = false,
  }) async {
    // Ensure auth bootstrap cannot reuse previous emulator/device credentials.
    await secureStorage.deleteAll();
    if (authenticated) {
      await secureStorage.write(key: 'auth_token', value: 'integration-token');
      await secureStorage.write(key: 'user_name', value: 'Integration Farmer');
      await secureStorage.write(key: 'user_email', value: 'farmer@test.local');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('seenOnboarding', seenOnboarding);
  }

  Future<void> seedAnimalForHealthFlow() async {
    await SyncData().insertAnimal(
      Animal(
        name: 'Integration Cow',
        type: 'Cattle',
        breed: 'Friesian',
        age: 3,
        weight: 420,
        healthStatus: 'Healthy',
      ),
    );
  }

  group('app integration flows', () {
    testWidgets('onboarding skip navigates to login', (tester) async {
      await resetAppState(seenOnboarding: false, authenticated: false);

      app.main();
      await tester.pumpAndSettle();

      final skipButton = find.byKey(const Key('onboarding_skip_button'));
      await _pumpUntilFound(tester, skipButton);
      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
    });

    testWidgets('login screen can navigate to register and back',
        (tester) async {
      await resetAppState(seenOnboarding: true, authenticated: false);

      app.main();
      await tester.pumpAndSettle();
      final toRegister = find.byKey(const Key('login_to_register_button'));
      await _pumpUntilFound(tester, toRegister);
      await tester.tap(toRegister);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
      expect(find.byKey(const Key('register_to_login_button')), findsOneWidget);

      await tester.tap(find.byKey(const Key('register_to_login_button')));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('authenticated bootstrap lands on home shell', (tester) async {
      await resetAppState(seenOnboarding: true, authenticated: true);

      app.main();
      await tester.pumpAndSettle();

      await _pumpUntilFound(tester, find.byType(app.MainShell));
      expect(find.byType(app.MainShell), findsOneWidget);
    });

    testWidgets('drawer profile edit flow updates profile name',
        (tester) async {
      await resetAppState(seenOnboarding: true, authenticated: true);

      app.main();
      await tester.pumpAndSettle();

      await _pumpUntilFound(tester, find.byType(app.MainShell));

      await tester.tap(find.byKey(const Key('appbar_menu_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('drawer_profile_item')));
      await tester.pumpAndSettle();

      await _pumpUntilFound(
          tester, find.byKey(const Key('profile_open_edit_button')));
      await tester.tap(find.byKey(const Key('profile_open_edit_button')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('profile_edit_name_input')),
        'Edited Farmer',
      );
      await tester.tap(find.byKey(const Key('profile_edit_save_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Profile updated'), findsOneWidget);
    });

    testWidgets('animal health flow allows status update from animals list',
        (tester) async {
      await resetAppState(seenOnboarding: true, authenticated: true);
      await seedAnimalForHealthFlow();

      app.main();
      await tester.pumpAndSettle();

      await _pumpUntilFound(tester, find.byType(app.MainShell));
      await tester.tap(find.byKey(const Key('bottom_nav_farm')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Animals'));
      await tester.pumpAndSettle();
      await _pumpUntilFound(tester, find.textContaining('Integration Cow'));

      await tester
          .tap(find.byKey(const Key('animal_health_menu_button')).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Critical'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Updated Integration Cow health to Critical'),
        findsOneWidget,
      );
    });
  });
}
