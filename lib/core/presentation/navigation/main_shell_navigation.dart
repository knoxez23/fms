import 'package:flutter/material.dart';

class MainShellNavigation {
  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
  static final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>();

  static void goToTab(int index) {
    tabIndex.value = index;
  }

  static bool openDrawer() {
    final state = scaffoldKey.currentState;
    if (state == null) return false;
    state.openDrawer();
    return true;
  }
}
