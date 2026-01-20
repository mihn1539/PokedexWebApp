import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_theme.dart';
import '../widgets/cached_pokemon_image.dart';

class PokemonSpecieInfo extends StatefulWidget {
  final Pokemon pokemon;
  const PokemonSpecieInfo({super.key, required this.pokemon});

  @override
  _PokemonSpecieInfoState createState() => _PokemonSpecieInfoState();
}

class _PokemonSpecieInfoState extends State<PokemonSpecieInfo> {
  List<Map<String, dynamic>> evoluciones = [];

  @override
  void initState() {
    super.initState();
    fetchEspecies();
  }

  Future<void> fetchEspecies() async {
    final url = widget.pokemon.urlEvolucion ?? '';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final chain = data['chain'];
      _recorrerChain(chain, null);
      setState(() {});
    } else {
      throw Exception('Failed to load evolution chain');
    }
  }

  //funcion recurciva para recorrer la cadena de evoluciones desde la primera especie
  void _recorrerChain(
    Map<String, dynamic> evolutionData,
    String? evolutionRequirement,
  ) {
    final species = evolutionData['species'];
    final name = species['name'];
    final urlParts = species['url'].split('/');
    final id = int.parse(urlParts[urlParts.length - 2]);
    final spriteUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png';

    //añadimos a la lista de evoluciones
    evoluciones.add({
      'name': name,
      'id': id,
      'spriteUrl': spriteUrl,
      'evolutionDetails': evolutionRequirement ?? 'Base',
      'isBase': evolutionRequirement == null,
    });

    // vamos iterando en los evoluciones siguientes
    final evolvesTo = evolutionData['evolves_to'] as List<dynamic>;
    for (var nextEvolution in evolvesTo) {
      final details = (nextEvolution['evolution_details'] as List).isNotEmpty
          ? _formatEvolutionDetails(nextEvolution['evolution_details'][0])
          : 'Desconocido';

      _recorrerChain(nextEvolution, details);
    }
  }

  //terminar esto con las demas formas de evolucion
  String _formatEvolutionDetails(Map<String, dynamic> details) {
    if (details.containsKey('min_level') && details['min_level'] != null) {
      return 'Nivel ${details['min_level']}';
    }
    if (details.containsKey('item') && details['item'] != null) {
      return 'Usar ${details['item']['name']}';
    }
    return 'Desconocido';
  }

  List<Widget> _buildEvolutionChainHorizontal() {
    final theme = AppTheme.of(context);
    List<Widget> widgets = [];
    
    for (int i = 0; i < evoluciones.length; i++) {
      final evolucion = evoluciones[i];
      
      // Widget del Pokémon
      widgets.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen del Pokémon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CachedPokemonImage(
                imageUrl: evolucion['spriteUrl'],
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 8),
            // Nombre del Pokémon
            Text(
              capitalizar(evolucion['name']).toUpperCase(),
              style: theme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
      
      // Flecha y requisito de evolución (si no es el último)
      if (i < evoluciones.length - 1) {
        final nextEvolution = evoluciones[i + 1];
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_forward,
                  color: theme.primary,
                  size: 32,
                ),
                const SizedBox(height: 6),
                // Requisito de evolución
                if (!nextEvolution['isBase'])
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      nextEvolution['evolutionDetails'],
                      style: theme.bodyMedium!.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: theme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    }
    
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card de Cadena de Evolución
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rocket_launch, color: theme.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Cadena de Evolución',
                        style: theme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  // Cadena evolutiva horizontal
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildEvolutionChainHorizontal(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8.0),
          
          // Card de Información de la Especie
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.primary, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        'Información de la Especie',
                        style: theme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Text(
                    widget.pokemon.entradasPokedexSp != null
                        ? widget.pokemon.entradasPokedexSp!
                            .entries
                            .map((entry) =>
                                '${capitalizar(entry.key)}: ${entry.value.replaceAll('\n', ' ')}')
                            .join('\n\n')
                        : 'No hay entradas de la pokédex disponibles.',
                    style: theme.bodyMedium!.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String capitalizar(String s) => s[0].toUpperCase() + s.substring(1);
}
