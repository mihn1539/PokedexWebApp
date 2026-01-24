import 'package:flutter/material.dart';
import 'package:pokedex/pages/pokedex_page.dart';
import 'package:pokedex/pages/pokemon_compare_page.dart';
import 'package:pokedex/pages/pokemon_game.dart';
import 'package:pokedex/controllers/theme_controller.dart';
import 'package:pokedex/pages/favorites_page.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:pokedex/pages/buscador_movimientos.dart';
import 'package:pokedex/pages/type_chart_page.dart';
import 'package:pokedex/pages/gym_leaders_page.dart';

class MenuLateral extends StatelessWidget {
  const MenuLateral({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    // Construcción del Drawer (menú lateral)
    return Drawer(
      semanticLabel: 'Menú lateral de navegación',
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Encabezado del menú lateral con botón de cerrar
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.catching_pokemon,
                        size: 48,
                        color: Theme.of(context).appBarTheme.foregroundColor,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Pokédex',
                          style: Theme.of(context).appBarTheme.titleTextStyle,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                        tooltip: 'Cerrar menú',
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                // Opciones del menú lateral
                ListTile(
                  leading: Icon(Icons.home, color: theme.primary),
                  title: const Text('Pokédex'),
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const PokedexPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.favorite, color: theme.primary),
                  title: const Text('Favoritos'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.search, color: theme.primary),
                  title: const Text('Buscador de Movimientos'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuscadorMovimientos(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.table_chart, color: theme.primary),
                  title: const Text('Tabla de Tipos'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TypeChartPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.military_tech, color: theme.primary),
                  title: const Text('Líderes de Gimnasio'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GymLeadersPage(),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: theme.onSurface.withOpacity(0.24)),
                ListTile(
                  leading: Icon(Icons.compare_arrows, color: theme.primary),
                  title: const Text('Comparar Pokémon'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PokemonComparePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.gamepad, color: theme.primary),
                  title: const Text('Juego Pokémon'),
                  onTap: () {
                    Navigator.pop(context);
                    // Acceder a la lista estática de Pokémon desde PokedexPage
                    final allPokemons = PokedexPage.getAllPokemons();
                    if (allPokemons.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cargando Pokémon... Intenta de nuevo en un momento',
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PokeGridGame(pokedex: allPokemons),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.onSurface.withOpacity(0.24)),
          SafeArea(
            top: false,
            child: ListTile(
              leading: Icon(
                theme.isDark ? Icons.light_mode : Icons.dark_mode,
                color: theme.primary,
              ),
              title: Text(
                theme.isDark ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
              ),
              onTap: () {
                ThemeController.instance.toggle();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
