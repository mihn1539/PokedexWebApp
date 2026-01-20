import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/utils/pokemon_helpers.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:pokedex/widgets/cached_pokemon_image.dart';

class PokemonCombateInfo extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonCombateInfo({super.key, required this.pokemon});

  /// Construye una fila compacta de tipos para la tabla de efectividad
  Widget _buildTipoRowCompact(String titulo, List<String> tipos, AppTheme theme) {
    if (tipos.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: theme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: tipos.map((tipo) {
            return Container(
              decoration: BoxDecoration(
                color: theme.getPokemonTypeColor(tipo).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.getPokemonTypeColor(tipo),
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.all(6),
              child: CachedPokemonImage(
                imageUrl: getTipoSpriteUrl(tipo),
                height: 32,
                fit: BoxFit.contain,
                errorWidget: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  child: Text(
                    capitalizar(tipo),
                    style: theme.bodyMedium!.copyWith(
                      color: theme.getPokemonTypeColor(tipo),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card de Habilidades
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.stars, color: theme.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Habilidades',
                        style: theme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (pokemon.habilidades != null && pokemon.habilidades!.isNotEmpty)
                    Wrap(
                      spacing: AppTheme.spacingSm,
                      runSpacing: AppTheme.spacingSm,
                      children: [
                        for (int i = 0; i < pokemon.habilidades!.length; i++)
                          Tooltip(
                            message:
                                (pokemon.descripcion != null &&
                                    pokemon.descripcion!.length > i)
                                ? pokemon.descripcion![i]
                                : 'Descripción no disponible.',
                            decoration: BoxDecoration(
                              color: theme.isDark ? theme.surfaceContainer : Colors.black87,
                              borderRadius: theme.cardRadius,
                            ),
                            textStyle: TextStyle(
                              color: theme.isDark ? theme.onSurface : Colors.white,
                              fontSize: 13,
                            ),
                            child: Chip(
                              label: Text(
                                pokemon.habilidades![i],
                                style: theme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: theme.primary.withOpacity(0.15),
                              side: BorderSide(
                                color: theme.primary.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Card de Estadísticas
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bar_chart, color: theme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Estadísticas Base',
                        style: theme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  if (pokemon.stats != null)
                    Column(
                      children: pokemon.stats!.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    capitalizar(entry.key),
                                    style: theme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    entry.value.toString(),
                                    style: theme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getStatColor(entry.value, theme),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: entry.value / 255,
                                  backgroundColor: theme.onSurface.withOpacity(0.1),
                                  color: _getStatColor(entry.value, theme),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Card de EVs
          if (pokemon.ev != null && pokemon.ev!.isNotEmpty) ...[
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.trending_up, color: theme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Puntos de Esfuerzo (EVs)',
                          style: theme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Wrap(
                      spacing: AppTheme.spacingSm,
                      runSpacing: AppTheme.spacingSm,
                      children: pokemon.ev!.entries.map((entry) {
                        return Chip(
                          avatar: Icon(
                            Icons.add_circle,
                            color: theme.primary,
                            size: 20,
                          ),
                          label: Text(
                            '${capitalizar(entry.key)}: ${entry.value}',
                            style: theme.bodyMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: theme.primary.withOpacity(0.15),
                          side: BorderSide(
                            color: theme.primary,
                            width: 1.5,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
          
          // Card de Efectividad
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: theme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Efectividad de Tipos',
                        style: theme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  
                  // Debilidades
                  if (pokemon.debilidadX4.isNotEmpty || pokemon.debilidadX2.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.getPokemonTypeColor('fire').withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.getPokemonTypeColor('fire').withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.arrow_downward, color: theme.getPokemonTypeColor('fire'), size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'DEBILIDADES',
                                style: theme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.getPokemonTypeColor('fire'),
                                ),
                              ),
                            ],
                          ),
                          if (pokemon.debilidadX4.isNotEmpty || pokemon.debilidadX2.isNotEmpty)
                            const SizedBox(height: 8),
                          _buildTipoRowCompact('Superdébil (x4)', pokemon.debilidadX4, theme),
                          _buildTipoRowCompact('Débil (x2)', pokemon.debilidadX2, theme),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Resistencias
                  if (pokemon.resistenciaMitad.isNotEmpty || pokemon.resistenciaUnCuarto.isNotEmpty || pokemon.inmune.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.getPokemonTypeColor('steel').withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.getPokemonTypeColor('steel').withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.shield_outlined, color: theme.getPokemonTypeColor('steel'), size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'RESISTENCIAS',
                                style: theme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.getPokemonTypeColor('steel'),
                                ),
                              ),
                            ],
                          ),
                          if (pokemon.resistenciaMitad.isNotEmpty || pokemon.resistenciaUnCuarto.isNotEmpty || pokemon.inmune.isNotEmpty)
                            const SizedBox(height: 8),
                          _buildTipoRowCompact('Resistente (x0.5)', pokemon.resistenciaMitad, theme),
                          _buildTipoRowCompact('Muy Resistente (x0.25)', pokemon.resistenciaUnCuarto, theme),
                          _buildTipoRowCompact('Inmune (x0)', pokemon.inmune, theme),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Neutral
                  if (pokemon.neutral.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.onSurface.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.onSurface.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.remove, color: theme.onSurface.withOpacity(0.7), size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'NEUTRAL',
                                style: theme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildTipoRowCompact('Daño normal (x1)', pokemon.neutral, theme),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color para una estadística según su valor
  Color _getStatColor(int value, AppTheme theme) {
    if (value >= 150) return theme.getPokemonTypeColor('dragon');
    if (value >= 120) return theme.getPokemonTypeColor('fire');
    if (value >= 90) return theme.getPokemonTypeColor('electric');
    if (value >= 60) return theme.getPokemonTypeColor('water');
    return theme.onSurface.withOpacity(0.5);
  }
}
