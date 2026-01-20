import 'package:flutter/material.dart';
import 'movimientos.dart';
import 'pokemon.dart';
import '../pages/pokedex_page.dart';
import '../pages/pokemon_detail_page.dart';
import '../utils/pokemon_helpers.dart';
import '../utils/screen_utils.dart';
import '../utils/app_theme.dart';
import '../controllers/favorites_controller.dart';

class MovimientosAprendidos extends StatefulWidget {
  final Movimiento movimiento;

  const MovimientosAprendidos({super.key, required this.movimiento});

  @override
  State<MovimientosAprendidos> createState() => _MovimientosAprendidosState();
}

class _MovimientosAprendidosState extends State<MovimientosAprendidos> {

  List<Pokemon> _getPokemonFromNames() {
    final allPokemons = PokedexPage.getAllPokemons();
    final pokemonList = <Pokemon>[];
    
    for (final pokemonName in widget.movimiento.pokemon) {
      final pokemon = allPokemons.firstWhere(
        (p) => p.nombre.toLowerCase() == pokemonName.toLowerCase(),
        orElse: () => Pokemon(
          id: 0,
          nombre: pokemonName,
          imagenUrl: '',
          tipos: [],
        ),
      );
      if (pokemon.id != 0) {
        pokemonList.add(pokemon);
      }
    }
    
    return pokemonList;
  }

  @override
  Widget build(BuildContext context) {
    final pokemonList = _getPokemonFromNames();
    final theme = AppTheme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.catching_pokemon, color: theme.primary, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    "Aprendido por ${pokemonList.length} Pokémon",
                    style: theme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (pokemonList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No se encontraron Pokémon que aprendan este movimiento',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ScreenUtils.getGridColumns(context),
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: pokemonList.length,
              itemBuilder: (context, index) {
                final poke = pokemonList[index];
                final name = capitalizar(poke.nombre);
                final isFav = FavoritesController.instance.isFavorite(poke.id);

                return GestureDetector(
                  onTap: () => verDetallePokemon(context, poke),
                  child: Material(
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => verDetallePokemon(context, poke),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'N.° ${poke.id}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Image.network(
                                poke.imagenUrl,
                                height: 120,
                                fit: BoxFit.contain,
                                cacheWidth: 240,
                                cacheHeight: 240,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    height: 120,
                                    child: Icon(Icons.error_outline, size: 40),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 2,
                            top: 2,
                            child: IconButton(
                              tooltip: isFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                              icon: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Theme.of(context).colorScheme.primary : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  FavoritesController.instance.toggle(poke.id);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
