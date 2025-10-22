
import 'package:flutter/material.dart';

class NavigatorHelper {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static void navigateToNewRoute(rountName) {
    navigatorKey.currentState?.pushReplacementNamed(rountName);
  }
}