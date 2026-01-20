import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/widgets/menu_lateral.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pokedex/models/pokemon_detail_view.dart';

// aca se cargan los datos de la pagina de detalle del pokemon
class PokemonDetailPage extends StatelessWidget {
  const PokemonDetailPage({super.key, required this.pokemon});
  final Pokemon pokemon;

  Future<Pokemon> fetchPokemon() async {
    final response = await http.get(  
      Uri.parse("https://pokeapi.co/api/v2/pokemon/${pokemon.id}"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pokemon = Pokemon.detailed(data); //creamos instancia de pokemon cuando elejimos a uno
      await pokemon.cargarSp(); //cargamos informacion adicional del pokemon
      await pokemon.cargarLocaciones(); //cargamos las locaciones del pokemon
      await pokemon.cargarDebilidades(); //cargamos las debilidades del pokemon
      await pokemon.cargarDescripcionHabilidades(); //cargamos la descripcion de las habilidades del pokemon
      return pokemon;  
    } else {
      throw Exception('Failed to load Pokémon details');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return Scaffold(
      drawer: const MenuLateral(), // Agrega el botón del menú lateral
      appBar: AppBar(
        title: Text(pokemon.nombre.toUpperCase()),
      ),
      body: FutureBuilder<Pokemon>(
              future: fetchPokemon(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) { // si el builder esta esperando la informacion (future)
                  return Center(
                    child: CircularProgressIndicator(color: theme.primary),
                  ); // muestra un circulo de carga
                } else if (snapshot.hasError) { // si el snapshot tiene un error
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: theme.error),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          'Error al cargar',
                          style: theme.titleLarge,
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          '${snapshot.error}',
                          style: theme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ); // se muestra un texto con el error correspondiente
                } else if (snapshot.hasData) { // si la carga es exitosa
                  final pokemonDetallado = snapshot.data!; // se crea una nueva version del pokemon con la data cargada
                  return PokemonDetailView(pokemon: pokemonDetallado);
                } else {
                  return Center(
                    child: Text(
                      'No se pudo cargar la información',
                      style: theme.bodyLarge,
                    ),
                  );
                }
              })
    );
  }
}

// funcion para ver la pagina de un pokemon con su informacion detallada
Future<void> verDetallePokemon(BuildContext context, Pokemon pokemon) async {
  await Navigator.push(context, MaterialPageRoute(
    builder: (context) => PokemonDetailPage(pokemon: pokemon)
    )
  );
}
