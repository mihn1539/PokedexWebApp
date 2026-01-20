import 'package:pokedex/models/pokemon.dart';

class PokemonFilters {
  // Filter parameters
  String? type1; // Primer tipo
  String? type2; // Segundo tipo
  String? generation;
  String? color;

  PokemonFilters({this.type1, this.type2, this.generation, this.color});

  // Method to apply filters to a list of Pokemon
  List<Pokemon> applyFilters(List<Pokemon> pokemons) {
    return pokemons.where((pokemon) {
      bool matches = true;

      // Filter by types
      if (pokemon.tipos != null) {
        if (type1 != null) {
          matches = matches && pokemon.tipos!.contains(type1);
        }
        if (type2 != null) {
          matches = matches && pokemon.tipos!.contains(type2);
        }
      }

      // Filter by generation
      if (generation != null) {
        matches = matches && (pokemon.generacion == generation);
      }

      // Filter by color
      if (color != null && pokemon.color != null) {
        matches = matches && (pokemon.color == color);
      }

      return matches;
    }).toList();
  }

  // Method to reset all filters
  void resetFilters() {
    type1 = null;
    type2 = null;
    generation = null;
    color = null;
  }
}
