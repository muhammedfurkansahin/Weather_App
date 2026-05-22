import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(_lightTheme);

  // Modern Light Theme - Nature inspired
  static final _lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0D9488), // Teal 600
    scaffoldBackgroundColor: const Color(0xFFF0FDFA), // Teal 50
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0D9488), // Teal 600
      secondary: Color(0xFFF59E0B), // Amber 500
      tertiary: Color(0xFF0EA5E9), // Sky 500
      surface: Color(0xFFFFFFFF),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF134E4A), // Teal 900
      outline: Color(0xFFCCDFB1),
      surfaceContainerHighest: Color(0xFFCCFBF1), // Teal 100
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white,
      shadowColor: const Color(0xFF0D9488).withValues(alpha: 0.1),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF0FDFA),
      foregroundColor: Color(0xFF134E4A),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Color(0xFF134E4A),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFF115E59),
        fontWeight: FontWeight.w700,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF115E59),
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF134E4A),
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF334155),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF475569),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0D9488),
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: const Color(0xFF0D9488).withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFCCFBF1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF99F6E4), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF99F6E4), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0D9488), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF5EEAD4),
        fontWeight: FontWeight.w400,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF0F766E),
      size: 24,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF99F6E4),
      thickness: 1,
    ),
  );

  // Modern Dark Theme - Deep & Vibrant
  static final _darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF14B8A6), // Teal 500
    scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF14B8A6), // Teal 500
      secondary: Color(0xFFFBBF24), // Amber 400
      tertiary: Color(0xFF38BDF8), // Sky 400
      surface: Color(0xFF1E293B), // Slate 800
      onPrimary: Color(0xFF0F172A),
      onSecondary: Color(0xFF0F172A),
      onSurface: Color(0xFFF1F5F9), // Slate 100
      outline: Color(0xFF334155),
      surfaceContainerHighest: Color(0xFF334155),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color(0xFF1E293B), // Slate 800
      shadowColor: const Color(0xFF14B8A6).withValues(alpha: 0.1),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F172A),
      foregroundColor: Color(0xFFF1F5F9),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: Color(0xFFF1F5F9),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Color(0xFFF0FDFA),
        fontWeight: FontWeight.w700,
        fontSize: 32,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFFCCFBF1),
        fontWeight: FontWeight.w600,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: Color(0xFFE2E8F0),
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      bodyLarge: TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF14B8A6),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        shadowColor: const Color(0xFF14B8A6).withValues(alpha: 0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF334155), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF14B8A6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w400,
      ),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF94A3B8),
      size: 24,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
    ),
  );

  void toggleTheme() {
    emit(state.brightness == Brightness.light ? _darkTheme : _lightTheme);
  }
}
