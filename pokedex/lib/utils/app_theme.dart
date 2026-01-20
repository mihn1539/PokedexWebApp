import 'package:flutter/material.dart';

/// Clase de utilidad para acceder fácilmente a los colores y estilos del tema actual
/// 
/// Uso:
/// ```dart
/// // En cualquier widget con BuildContext
/// Color primary = AppTheme.of(context).primary;
/// TextStyle title = AppTheme.of(context).titleLarge;
/// bool isDark = AppTheme.of(context).isDark;
/// ```
class AppTheme {
  final BuildContext context;
  
  AppTheme.of(this.context);

  // ========== Acceso al tema actual ==========
  ThemeData get theme => Theme.of(context);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textStyles => theme.textTheme;

  // ========== Estado del tema ==========
  bool get isDark => theme.brightness == Brightness.dark;
  bool get isLight => theme.brightness == Brightness.light;

  // ========== Colores principales ==========
  Color get primary => colors.primary;
  Color get secondary => colors.secondary;
  Color get surface => colors.surface;
  Color get surfaceContainer => colors.surfaceContainer;
  Color get error => colors.error;
  
  // Colores de texto
  Color get onPrimary => colors.onPrimary;
  Color get onSecondary => colors.onSecondary;
  Color get onSurface => colors.onSurface;
  Color get onError => colors.onError;

  // ========== Colores personalizados específicos de Pokédex ==========
  
  // Colores para cards de Pokémon
  Color get pokemonCardBackground => isDark 
      ? const Color(0xFF2D2D2D) 
      : Colors.white;
  
  Color get pokemonCardShadow => isDark 
      ? Colors.black.withOpacity(0.5) 
      : Colors.grey.withOpacity(0.3);

  // Colores para búsqueda y filtros
  Color get searchBarBackground => isDark 
      ? const Color(0xFF3D3D3D) 
      : Colors.grey.shade100;

  Color get searchBarText => isDark 
      ? Colors.white70 
      : Colors.black87;

  Color get filterChipBackground => isDark 
      ? const Color(0xFF3D3D3D) 
      : Colors.grey.shade200;

  Color get filterChipSelected => isDark 
      ? Colors.red.shade400 
      : Colors.red.shade700;

  // Colores para tipos de Pokémon
  Color getPokemonTypeColor(String type) {
    final typeColors = {
      'normal': const Color(0xFFA8A878),
      'fire': const Color(0xFFF08030),
      'water': const Color(0xFF6890F0),
      'electric': const Color(0xFFF8D030),
      'grass': const Color(0xFF78C850),
      'ice': const Color(0xFF98D8D8),
      'fighting': const Color(0xFFC03028),
      'poison': const Color(0xFFA040A0),
      'ground': const Color(0xFFE0C068),
      'flying': const Color(0xFFA890F0),
      'psychic': const Color(0xFFF85888),
      'bug': const Color(0xFFA8B820),
      'rock': const Color(0xFFB8A038),
      'ghost': const Color(0xFF705898),
      'dragon': const Color(0xFF7038F8),
      'dark': const Color(0xFF705848),
      'steel': const Color(0xFFB8B8D0),
      'fairy': const Color(0xFFEE99AC),
    };
    
    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }

  // Color con opacidad ajustada según el tema
  Color getPokemonTypeColorWithOpacity(String type) {
    return getPokemonTypeColor(type).withOpacity(isDark ? 0.8 : 1.0);
  }

  // ========== Gradientes ==========
  
  // Gradiente para AppBar o headers
  LinearGradient get primaryGradient => LinearGradient(
    colors: isDark
        ? [Colors.red.shade800, Colors.red.shade900]
        : [Colors.red.shade700, Colors.red.shade900],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradiente para backgrounds
  LinearGradient get backgroundGradient => LinearGradient(
    colors: isDark
        ? [const Color(0xFF1E1E1E), const Color(0xFF2D2D2D)]
        : [Colors.grey.shade50, Colors.grey.shade100],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ========== Estilos de texto ==========
  
  TextStyle? get displayLarge => textStyles.displayLarge;
  TextStyle? get displayMedium => textStyles.displayMedium;
  TextStyle? get displaySmall => textStyles.displaySmall;
  TextStyle? get headlineMedium => textStyles.headlineMedium;
  TextStyle? get titleLarge => textStyles.titleLarge;
  TextStyle? get titleMedium => textStyles.titleMedium;
  TextStyle? get bodyLarge => textStyles.bodyLarge;
  TextStyle? get bodyMedium => textStyles.bodyMedium;
  TextStyle? get labelLarge => textStyles.labelLarge;

  // Estilos personalizados para Pokédex
  TextStyle get pokemonName => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: isDark ? Colors.white : Colors.black87,
  );

  TextStyle get pokemonNumber => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: isDark ? Colors.white60 : Colors.black54,
  );

  TextStyle get pokemonType => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  TextStyle get sectionTitle => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: isDark ? Colors.white : Colors.black87,
  );

  // ========== Sombras ==========
  
  List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: pokemonCardShadow,
      blurRadius: isDark ? 8 : 4,
      offset: const Offset(0, 2),
    ),
  ];

  List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: pokemonCardShadow,
      blurRadius: isDark ? 12 : 8,
      offset: const Offset(0, 4),
    ),
  ];

  // ========== Bordes y decoraciones ==========
  
  BorderRadius get cardRadius => BorderRadius.circular(12);
  BorderRadius get buttonRadius => BorderRadius.circular(8);
  BorderRadius get chipRadius => BorderRadius.circular(20);

  // Decoración para cards de Pokémon
  BoxDecoration get pokemonCardDecoration => BoxDecoration(
    color: pokemonCardBackground,
    borderRadius: cardRadius,
    boxShadow: cardShadow,
  );

  // Decoración para contenedores elevados
  BoxDecoration get elevatedDecoration => BoxDecoration(
    color: surfaceContainer,
    borderRadius: cardRadius,
    boxShadow: elevatedShadow,
  );

  // ========== Espaciado consistente ==========
  
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  // ========== Tamaños de iconos ==========
  
  static const double iconSizeSm = 16;
  static const double iconSizeMd = 24;
  static const double iconSizeLg = 32;
  static const double iconSizeXl = 48;

  // ========== Dimensiones de cards ==========
  
  static const double pokemonCardHeight = 120;
  static const double pokemonCardWidth = 160;
}

/// Extension para acceder rápidamente al tema desde cualquier BuildContext
extension ThemeExtension on BuildContext {
  AppTheme get appTheme => AppTheme.of(this);
  
  // Atajos rápidos
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
