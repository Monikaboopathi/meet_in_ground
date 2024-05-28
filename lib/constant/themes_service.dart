import 'package:flutter/material.dart';

class ThemeService {
  static bool isDayTime() {
    DateTime now = DateTime.now();
    return now.hour >= 6 && now.hour < 18;
  }

  static const Color primary = Color(0xFF6B78B7);
  static const Color secondary = Color(0xFFD9D9D9);
  static const Color third = Color(0xFFFD76DF);
  static const Color fourth = Color(0xFFF6F6F6);
  static const Color placeHolder = Color(0xFF767882);
  static const Color success = Color(0xFF28A745);
  static const Color danger = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);
  static final Color background =
      isDayTime() ? const Color(0xFFFFFFFF) : const Color(0xFF0A0030);
  static final Color textColor =
      isDayTime() ? const Color(0xFF0A0030) : const Color(0xFFFFFFFF);
  static const Color buttonBg = Color(0xFF1576FB);
  static final Color transparent = isDayTime()
      ? const Color.fromRGBO(0, 0, 0, 0.2)
      : const Color.fromRGBO(255, 255, 255, 0.2);
}
