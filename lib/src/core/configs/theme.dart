import 'package:flutter/material.dart';

import '../../../gen/fonts.gen.dart';

class ThemeChangeNotifier extends ChangeNotifier {
  ThemeMode _currentThemeMode = ThemeMode.light;

  ThemeMode get currentThemeMode => _currentThemeMode;

  void toggleTheme() {
    _currentThemeMode =
        _currentThemeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppThemes {
  static ThemeData getTheme({ThemeMode themeMode = ThemeMode.light}) {
    final colors = _getColors(themeMode);
    final textTheme = _getTextThemeData(themeMode, colors);

    return ThemeData(
      colorScheme: ColorScheme(
        brightness:
            themeMode == ThemeMode.light ? Brightness.light : Brightness.dark,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        error: colors.error,
        onError: colors.onError,
        background: colors.background,
        onBackground: colors.onBackground,
        surface: colors.surface,
        onSurface: colors.onSurface,
      ),
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.background,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: FontFamily.axiforma,
    );
  }

  static _AppColors _getColors(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.dark:
        return _DarkColors();
      default:
        return _LightColors();
    }
  }

  static _getTextThemeData(ThemeMode themeMode, _AppColors colors) {
    final color = colors.text;
    return TextTheme(
      bodyLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }
}

abstract class _AppColors {
  final MaterialColor primary;
  final Color secondary;
  final Color background;
  final Color labelText;
  final Color text;
  final Color error;
  final Color onBackground;
  final Color onPrimary;
  final Color onError;
  final Color onSecondary;
  final Color surface;
  final Color onSurface;

  const _AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.labelText,
    required this.text,
    required this.error,
    required this.onBackground,
    required this.onPrimary,
    required this.onError,
    required this.onSecondary,
    required this.surface,
    required this.onSurface,
  });
}
//(Color(0xFF732bf0) Color(0xFF732bf0)

class _LightColors implements _AppColors {
  @override
  MaterialColor get primary => const MaterialColor(
        0xFF732bf0,
        {
          100: Color(0xFF732bf0),
          200: Color(0xFF732bf0),
          300: Color(0xFF732bf0),
          400: Color(0xFF732bf0),
          500: Color(0xFF732bf0),
          600: Color(0xFF732bf0),
          700: Color(0xFF732bf0),
          800: Color(0xFF732bf0),
        },
      );

  @override
  Color get secondary => const Color(0xFF19151f);

  @override
  Color get background => Colors.white;

  @override
  Color get labelText => const Color(0xFF524f57);

  @override
  Color get text => const Color(0xFF19151f);

  @override
  Color get error => Colors.red;

  @override
  Color get onBackground => Colors.black;

  @override
  Color get onError => Colors.black;

  @override
  Color get onPrimary => Colors.white;

  @override
  Color get onSecondary => Colors.white;

  @override
  Color get onSurface => Colors.black;

  @override
  Color get surface => Colors.orange;
}

class _DarkColors implements _AppColors {
  @override
  MaterialColor get primary => const MaterialColor(
        0xFF732bf0,
        {
          00: Color(0xFF732bf0),
          01: Color(0xFF732bf0),
        },
      );

  @override
  Color get secondary => const Color(0xFF19151f);

  @override
  Color get background => Colors.black;

  @override
  Color get labelText => const Color(0xFF524f57);

  @override
  Color get text => const Color(0xFF19151f);

  @override
  Color get error => Colors.red;

  @override
  Color get onBackground => Colors.white;

  @override
  Color get onError => Colors.white;

  @override
  Color get onPrimary => Colors.black;

  @override
  Color get onSecondary => Colors.white;

  @override
  Color get onSurface => Colors.orange;

  @override
  Color get surface => Colors.black;
}
