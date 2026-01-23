import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/utils/pokemon_helpers.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:pokedex/widgets/cached_pokemon_image.dart';
import 'package:pokedex/widgets/type_badge.dart';

class PokemonInfoBasica extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonInfoBasica({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card principal con nombre e imagen
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primary.withOpacity(0.1),
                    theme.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    capitalizar(pokemon.nombre),
                    style: theme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'N.° ${pokemon.id.toString().padLeft(3, '0')}',
                      style: theme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: CachedPokemonImage(
                      imageUrl: pokemon.imagenUrl,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Card de información física
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.height,
                      label: 'Altura',
                      value: '${pokemon.altura} cm',
                      theme: theme,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: theme.onSurface.withOpacity(0.2),
                  ),
                  Expanded(
                    child: _buildInfoCard(
                      icon: Icons.monitor_weight,
                      label: 'Peso',
                      value: '${pokemon.peso} kg',
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Card de tipos
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
                      Icon(Icons.category, color: theme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Tipos',
                        style: theme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  if (pokemon.tipos != null && pokemon.tipos!.isNotEmpty)
                    Wrap(
                      spacing: AppTheme.spacingSm,
                      runSpacing: AppTheme.spacingSm,
                      alignment: WrapAlignment.center,
                      children: pokemon.tipos!.map((tipo) {
                        return TypeBadge(
                          type: tipo,
                          width: 100,
                          height: 40,
                          fontSize: 14,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Card de entrada Pokédex
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
                      Icon(Icons.menu_book, color: theme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Entrada Pokédex',
                        style: theme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    pokemon.entradaPokedex ?? 'No hay entrada de Pokédex disponible.',
                    style: theme.bodyLarge!.copyWith(
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required AppTheme theme,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 24,
          color: theme.primary.withOpacity(0.7),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.bodyMedium!.copyWith(
            fontSize: 12,
            color: theme.onSurface.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.titleMedium!.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: theme.primary,
          ),
        ),
      ],
    );
  }
}
