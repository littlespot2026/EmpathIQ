import 'package:flutter/material.dart';

class AppColors {
  // Deep elegant luxury dark backgrounds
  static const Color background = Color(0xFF0F1115);
  static const Color surface = Color(0xFF171A21);
  static const Color surfaceElevated = Color(0xFF202530);
  static const Color surfaceHighlight = Color(0xFF282E3D);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF282D3B);
  static const Color borderLight = Color(0xFF384052);

  // Warm Beige / Sand (Primary Accents)
  static const Color warmBeige = Color(0xFFEAD8C0);
  static const Color warmBeigeLight = Color(0xFFF6EFE6);
  static const Color warmBeigeDark = Color(0xFFC7B198);
  static const Color amberSand = Color(0xFFD4A373);
  static const Color warmGold = Color(0xFFE5B887);

  // High contrast text colors
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9DA4B0);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textWarm = Color(0xFFE5D5C5);

  // Emotional Temperature Palette (Low-saturation, premium feel)
  // 1. Cold Blue (冷淡蓝: 0°C ~ 30°C)
  static const Color coldBlue = Color(0xFF5B8DEF);
  static const Color coldBlueSubtle = Color(0xFF1E2D4A);
  static const Color coldBlueGradientStart = Color(0xFF4A7BD5);
  static const Color coldBlueGradientEnd = Color(0xFF67B0F0);

  // 2. Agitated Yellow (焦躁黄: 31°C ~ 70°C)
  static const Color agitatedYellow = Color(0xFFE5A144);
  static const Color agitatedYellowSubtle = Color(0xFF3D2F1E);
  static const Color agitatedGradientStart = Color(0xFFE5A144);
  static const Color agitatedGradientEnd = Color(0xFFF3C268);

  // 3. Flammable Red (易燃红: 71°C ~ 100°C)
  static const Color flammableRed = Color(0xFFE05252);
  static const Color flammableRedSubtle = Color(0xFF3B1C1C);
  static const Color flammableGradientStart = Color(0xFFDE4343);
  static const Color flammableGradientEnd = Color(0xFFF87171);

  // Supportive Strategy Colors
  static const Color empathyGreen = Color(0xFF52B788);
  static const Color empathyGreenSubtle = Color(0xFF193225);
  static const Color humorViolet = Color(0xFFA78BFA);
  static const Color humorVioletSubtle = Color(0xFF281F40);
  static const Color boundaryAmber = Color(0xFFE59866);
  static const Color boundaryAmberSubtle = Color(0xFF38251B);

  // Helper method to get temperature color
  static Color getTemperatureColor(int temp) {
    if (temp <= 30) return coldBlue;
    if (temp <= 70) return agitatedYellow;
    return flammableRed;
  }

  static Color getTemperatureSubtle(int temp) {
    if (temp <= 30) return coldBlueSubtle;
    if (temp <= 70) return agitatedYellowSubtle;
    return flammableRedSubtle;
  }

  static String getTemperatureLevelName(int temp) {
    if (temp <= 30) return '冷淡蓝';
    if (temp <= 70) return '焦躁黄';
    return '易燃红';
  }
}
