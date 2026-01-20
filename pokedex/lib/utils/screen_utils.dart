import 'package:flutter/material.dart';

/// Utilidades para obtener dimensiones de pantalla de forma global
class ScreenUtils {
  /// Obtiene el ancho de la pantalla
  static double getWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Obtiene el alto de la pantalla
  static double getHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Calcula el margen horizontal proporcional (2% del ancho)
  static double getHorizontalMargin(BuildContext context) {
    return getWidth(context) * 0.02;
  }

  /// Calcula el margen vertical proporcional (3% del alto)
  static double getVerticalMargin(BuildContext context) {
    return getHeight(context) * 0.03;
  }

  /// Calcula el ancho disponible para un grid restando márgenes
  static double getGridWidth(BuildContext context) {
    final width = getWidth(context);
    final margin = getHorizontalMargin(context);
    return width - 4 * margin;
  }

  /// Determina el número de columnas para un grid responsivo
  static int getGridColumns(BuildContext context) {
    final width = getWidth(context);
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  /// Ancho responsivo para tableros de juego (80% en móvil, max 600 en desktop)
  static double getGameBoardWidth(BuildContext context) {
    final width = getWidth(context);
    return width < 600 ? width * 0.9 : 600;
  }

  /// Alto responsivo para tableros de juego
  static double getGameBoardHeight(BuildContext context) {
    final width = getGameBoardWidth(context);
    return width * 1.1; // Mantiene proporción 1:1.1
  }

  /// Ancho máximo para botones y formularios
  static double getMaxFormWidth(BuildContext context) {
    final width = getWidth(context);
    return width < 400 ? width * 0.9 : 300;
  }
}
