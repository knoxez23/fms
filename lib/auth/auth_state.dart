import 'package:flutter/foundation.dart';

class AuthState {
  // Simple app-wide notifier for auth status changes
  static final ValueNotifier<bool> isAuthenticated = ValueNotifier<bool>(false);
}
