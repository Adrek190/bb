import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Secondary colors
  static const Color secondary = Color(0xFF4CAF50);
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFFC8E6C9);

  // Accent colors
  static const Color accent = Color(0xFFFF9800);
  static const Color accentDark = Color(0xFFF57C00);
  static const Color accentLight = Color(0xFFFFE0B2);

  // Notification colors
  static const Color urgent = Color(0xFFF44336);
  static const Color high = Color(0xFFFF9800);
  static const Color normal = Color(0xFF4CAF50);
  static const Color low = Color(0xFF2196F3);

  // Category colors
  static const Color billing = Color(0xFF9C27B0);
  static const Color registration = Color(0xFF009688);
  static const Color transport = Color(0xFFFFEB3B);
  static const Color system = Color(0xFF3F51B5);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);

  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);

  // Shadow colors
  static const Color shadow = Color(0x1F000000);
  static const Color lightShadow = Color(0x0F000000);

  // Disabled colors
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledText = Color(0xFF9E9E9E);

  // Notification priority gradients
  static const List<Color> urgentGradient = [
    Color(0xFFFF5722),
    Color(0xFFF44336),
  ];

  static const List<Color> highGradient = [
    Color(0xFFFF9800),
    Color(0xFFF57C00),
  ];

  static const List<Color> normalGradient = [
    Color(0xFF4CAF50),
    Color(0xFF388E3C),
  ];

  static const List<Color> lowGradient = [Color(0xFF2196F3), Color(0xFF1976D2)];
}
