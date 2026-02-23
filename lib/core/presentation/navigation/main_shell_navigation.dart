import 'package:flutter/foundation.dart';

class MainShellNavigation {
  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  static void goToTab(int index) {
    tabIndex.value = index;
  }
}
