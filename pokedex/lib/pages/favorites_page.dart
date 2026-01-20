import 'package:flutter/material.dart';
import 'package:pokedex/controllers/favorites_controller.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/utils/pokemon_helpers.dart';
import 'package:pokedex/pages/pokedex_page.dart';
import 'package:pokedex/pages/pokemon_detail_page.dart';
import 'package:pokedex/widgets/menu_lateral.dart';
import 'package:pokedex/utils/screen_utils.dart';
import 'package:pokedex/utils/app_theme.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Pokemon> _all = [];
  bool _loading = false;

  Future<void> _ensureData() async {
    if (_all.isNotEmpty) return;
    setState(() => _loading = true);
    final cached = PokedexPage.getAllPokemons();
    if (cached.isNotEmpty) {
      _all = cached;
      setState(() => _loading = false);
      return;
    }
    try {
      _all = await fetchPokemons();
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _ensureData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: AppBar(
        title: const Text('Favoritos'),
      ),
      body: AnimatedBuilder(
        animation: FavoritesController.instance,
        builder: (context, _) {
          if (_loading) {
            return Center(
              child: CircularProgressIndicator(
                color: theme.primary,
              ),
            );
          }
          final favIds = FavoritesController.instance.favoriteIds;
          final favs = _all.where((p) => favIds.contains(p.id)).toList();

          if (favs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: theme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Aún no tienes Pokémon favoritos',
                    style: theme.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Explora la Pokédex y marca tus favoritos',
                    style: theme.bodyMedium?.copyWith(
                      color: theme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            cacheExtent: 800,
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ScreenUtils.getGridColumns(context),
                crossAxisSpacing: AppTheme.spacingSm,
                mainAxisSpacing: AppTheme.spacingSm,
                childAspectRatio: 0.8,
            ),
            itemCount: favs.length,
            itemBuilder: (context, index) {
              final poke = favs[index];
              final name = capitalizar(poke.nombre);
              return RepaintBoundary(
                key: ValueKey(poke.id),
                child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PokemonDetailPage(pokemon: poke),
                  ),
                ),
                child: Container(
                  decoration: theme.pokemonCardDecoration,
                  child: InkWell(
                    borderRadius: theme.cardRadius,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PokemonDetailPage(pokemon: poke),
                      ),
                    ),
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
                            height: 80,
                            fit: BoxFit.contain,
                            cacheWidth: 160,
                            cacheHeight: 160,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const SizedBox(
                                height: 80,
                                child: Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                height: 80,
                                child: Icon(Icons.error_outline, size: 32),
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
                        right: 4,
                        top: 4,
                        child: IconButton(
                          tooltip: 'Quitar de favoritos',
                          icon: Icon(Icons.favorite, color: theme.primary),
                          onPressed: () {
                            FavoritesController.instance.toggle(poke.id);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
            },
          );
        },
      ),
    );
  }
}
