import 'package:flutter/material.dart';

class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier(super.mode);

  void update(String mode) {
    switch (mode) {
      case 'on':
      case 'dark':
        value = ThemeMode.dark;
        break;
      case 'off':
      case 'light':
        value = ThemeMode.light;
        break;
      default:
        value = ThemeMode.system;
    }
  }
}
