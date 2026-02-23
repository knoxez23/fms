import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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

  Future<void> resetAppState({required bool seenOnboarding}) async {
    // Ensure auth bootstrap cannot reuse previous emulator/device credentials.
    await secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setBool('seenOnboarding', seenOnboarding);
  }

  group('app integration flows', () {
    testWidgets('onboarding skip navigates to login', (tester) async {
      await resetAppState(seenOnboarding: false);

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
      await resetAppState(seenOnboarding: true);

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
  });
}
