import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF0E141D);
  static const Color backgroundSecondary = Color(0xFF101722);
  static const Color backgroundTertiary = Color(0xFF131A24);

  static const Color card = Color(0xFF131C27);
  static const Color cardSoft = Color(0xFF16202B);
  static const Color border = Color(0xFF2B3644);

  static const Color primary = Color(0xFF35D6C8);
  static const Color primarySoft = Color(0xFF8FE9DD);
  static const Color cyan = Color(0xFF3CBFFF);
  static const Color blue = Color(0xFF4D8DFF);
  static const Color purple = Color(0xFFB46CFF);
  static const Color pink = Color(0xFFF261B4);
  static const Color yellow = Color(0xFFF2C94C);
  static const Color orange = Color(0xFFF5A623);

  static const Color white = Colors.white;
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFA8B4C4);
  static const Color textMuted = Color(0xFF7E8A9A);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF131A24),
      Color(0xFF101722),
      Color(0xFF0E141D),
    ],
  );
}