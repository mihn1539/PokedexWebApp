import 'package:flutter/material.dart';

/// Tema oscuro personalizado para la Pokédex
ThemeData buildDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Colores principales
    colorScheme: ColorScheme.dark(
      primary: Colors.red.shade400,
      secondary: Colors.blue.shade400,
      surface: const Color(0xFF1E1E1E),
      surfaceContainer: const Color(0xFF2D2D2D),
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.white70,
      error: Colors.red.shade300,
    ),

    // Tema de AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.red.shade400,
      foregroundColor: Colors.black,
      iconTheme: const IconThemeData(color: Colors.black),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      elevation: 0,
      centerTitle: false,
    ),

    // Tema de Cards
    cardTheme: const CardThemeData(
      color: Color(0xFF2D2D2D),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),

    // Tema de botones
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Tema de iconos
    iconTheme: IconThemeData(
      color: Colors.red.shade400,
    ),

    // Tema de texto
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
    ),

    // Tema de Drawer
    drawerTheme: const DrawerThemeData(
      backgroundColor: Color(0xFF2D2D2D),
      surfaceTintColor: Color(0xFF1E1E1E),
    ),

    // Tema de Input
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF3D3D3D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red.shade400, width: 2),
      ),
    ),
  );
}
