import 'package:flutter/material.dart';

class FlutterTodosTheme {
  static ThemeData get light {
    return ThemeData(
      appBarTheme: const AppBarTheme(color: Color.fromARGB(255, 117, 208, 247)),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF13B9FF),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        color: Color.fromARGB(255, 16, 46, 59),
      ),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color(0xFF13B9FF),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static const Color white = Color(0xFFFFFFFFF);
  static const Color red = Color(0xFFE57373);
  static const Color orange = Color(0xFFFFB74D);
  static const Color purple = Color(0xFFBA68C8);
  static const Color darkGreen = Color(0xFF388E3C);
  static const Color lightGreen = Color(0xFF81C784);
  static const Color skyBlue = Color(0xFF4FC3F7);
  static const Color darkBlue = Color(0xFF1976D2);

  static const Map<String, Color> predefinedColorMap = {
    "White": white,
    "Red": red,
    "Orange": orange,
    "Purple": purple,
    "Dark Green": darkGreen,
    "Light Green": lightGreen,
    "Sky Blue": skyBlue,
    "Dark Blue": darkBlue,
  };

  static List<Color> get predefinedColors => predefinedColorMap.values.toList();
}
