import 'package:flutter/material.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:pokedex/utils/translation_helpers.dart';

/// Widget reutilizable para mostrar un badge de tipo Pokémon
class TypeBadge extends StatelessWidget {
  final String type;
  final double? width;
  final double? height;
  final double fontSize;
  final EdgeInsets padding;
  final double maxWidth;

  const TypeBadge({
    super.key,
    required this.type,
    this.width,
    this.height,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    this.maxWidth = 120, // Ancho máximo por defecto
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width ?? maxWidth,
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: theme.getPokemonTypeColor(type),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            traducirTipo(type),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              shadows: const [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
