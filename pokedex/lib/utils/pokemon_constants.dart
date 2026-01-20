import 'package:flutter/material.dart';

/// Constantes relacionadas con los tipos de Pokémon
class PokemonConstants {
  // Lista de todos los tipos de Pokémon
  static const List<String> tiposPokemon = [
    "normal",
    "fighting",
    "flying",
    "poison",
    "ground",
    "rock",
    "bug",
    "ghost",
    "steel",
    "fire",
    "water",
    "grass",
    "electric",
    "psychic",
    "ice",
    "dragon",
    "dark",
    "fairy",
  ];

  // Mapa de resistencias por tipo de Pokémon
  static const Map<String, List<String>> resistenciasPorTipo = {
    "normal": [],
    "fire": ["fire", "grass", "ice", "steel", "fairy", "bug"],
    "water": ["fire", "water", "ice", "steel"],
    "electric": ["electric", "flying", "steel"],
    "grass": ["water", "electric", "grass", "ground"],
    "ice": ["ice"],
    "fighting": ["bug", "rock", "dark"],
    "poison": ["grass", "fighting", "poison", "bug", "fairy"],
    "ground": ["poison", "rock"],
    "flying": ["grass", "fighting", "bug"],
    "psychic": ["psychic", "fighting"],
    "bug": ["grass", "fighting", "ground"],
    "rock": ["fire", "normal", "flying", "poison"],
    "ghost": ["poison", "bug"],
    "dragon": ["fire", "water", "grass", "electric"],
    "dark": ["ghost", "dark"],
    "steel": [
      "normal",
      "grass",
      "ice",
      "flying",
      "psychic",
      "bug",
      "rock",
      "dragon",
      "steel",
      "fairy",
    ],
    "fairy": ["fighting", "bug", "dark"],
  };

  // Mapa de iconos por tipo de Pokémon
  static const Map<String, IconData> iconoPorTipo = {
    "fire": Icons.local_fire_department,
    "water": Icons.water_drop,
    "grass": Icons.eco,
    "electric": Icons.flash_on,
    "ice": Icons.ac_unit,
    "rock": Icons.landscape,
    "ground": Icons.terrain,
    "fighting": Icons.sports_mma,
    "psychic": Icons.visibility,
    "dark": Icons.nights_stay,
    "ghost": Icons.catching_pokemon,
    "dragon": Icons.token,
    "fairy": Icons.auto_awesome,
    "normal": Icons.circle_outlined,
    "poison": Icons.science,
    "bug": Icons.bug_report,
    "flying": Icons.air,
    "steel": Icons.shield,
  };

  // Lista de movimientos aleatorios para el juego
  static const List<String> movimientosAleatorios = [
    "tackle",
    "scratch",
    "growl",
    "ember",
    "water-gun",
    "vine-whip",
    "thunder-shock",
    "gust",
    "quick-attack",
    "bite",
    "confusion",
    "razor-leaf",
    "rock-throw",
    "bubble",
    "karate-chop",
    "poison-sting",
    "pound",
    "leer",
    "sand-attack",
    "double-kick",
    "slam",
    "flamethrower",
    "ice-beam",
    "surf",
    "thunderbolt",
  ];
   static const Map<String, double> typeEffectiveness = {
  // --- NORMAL ---
  'normal,rock': 0.5,
  'normal,ghost': 0.0,
  'normal,steel': 0.5,

  // --- FIRE ---
  'fire,fire': 0.5,
  'fire,water': 0.5,
  'fire,grass': 2.0,
  'fire,ice': 2.0,
  'fire,bug': 2.0,
  'fire,rock': 0.5,
  'fire,dragon': 0.5,
  'fire,steel': 2.0,

  // --- WATER ---
  'water,fire': 2.0,
  'water,water': 0.5,
  'water,grass': 0.5,
  'water,ground': 2.0,
  'water,rock': 2.0,
  'water,dragon': 0.5,

  // --- ELECTRIC ---
  'electric,water': 2.0,
  'electric,electric': 0.5,
  'electric,grass': 0.5,
  'electric,ground': 0.0,
  'electric,flying': 2.0,
  'electric,dragon': 0.5,

  // --- GRASS ---
  'grass,fire': 0.5,
  'grass,water': 2.0,
  'grass,grass': 0.5,
  'grass,poison': 0.5,
  'grass,ground': 2.0,
  'grass,flying': 0.5,
  'grass,bug': 0.5,
  'grass,rock': 2.0,
  'grass,dragon': 0.5,
  'grass,steel': 0.5,

  // --- ICE ---
  'ice,fire': 0.5,
  'ice,water': 0.5,
  'ice,grass': 2.0,
  'ice,ice': 0.5,
  'ice,ground': 2.0,
  'ice,flying': 2.0,
  'ice,dragon': 2.0,
  'ice,steel': 0.5,

  // --- FIGHTING ---
  'fighting,normal': 2.0,
  'fighting,ice': 2.0,
  'fighting,poison': 0.5,
  'fighting,flying': 0.5,
  'fighting,psychic': 0.5,
  'fighting,bug': 0.5,
  'fighting,rock': 2.0,
  'fighting,ghost': 0.0,
  'fighting,dark': 2.0,
  'fighting,steel': 2.0,
  'fighting,fairy': 0.5,

  // --- POISON ---
  'poison,grass': 2.0,
  'poison,poison': 0.5,
  'poison,ground': 0.5,
  'poison,rock': 0.5,
  'poison,ghost': 0.5,
  'poison,steel': 0.0,
  'poison,fairy': 2.0,

  // --- GROUND ---
  'ground,fire': 2.0,
  'ground,electric': 2.0,
  'ground,grass': 0.5,
  'ground,poison': 2.0,
  'ground,flying': 0.0,
  'ground,bug': 0.5,
  'ground,rock': 2.0,
  'ground,steel': 2.0,

  // --- FLYING ---
  'flying,electric': 0.5,
  'flying,grass': 2.0,
  'flying,fighting': 2.0,
  'flying,bug': 2.0,
  'flying,rock': 0.5,
  'flying,steel': 0.5,

  // --- PSYCHIC ---
  'psychic,fighting': 2.0,
  'psychic,poison': 2.0,
  'psychic,psychic': 0.5,
  'psychic,dark': 0.0,
  'psychic,steel': 0.5,

  // --- BUG ---
  'bug,fire': 0.5,
  'bug,grass': 2.0,
  'bug,fighting': 0.5,
  'bug,poison': 0.5,
  'bug,flying': 0.5,
  'bug,psychic': 2.0,
  'bug,ghost': 0.5,
  'bug,dark': 2.0,
  'bug,steel': 0.5,
  'bug,fairy': 0.5,

  // --- ROCK ---
  'rock,fire': 2.0,
  'rock,ice': 2.0,
  'rock,fighting': 0.5,
  'rock,ground': 0.5,
  'rock,flying': 2.0,
  'rock,bug': 2.0,
  'rock,steel': 0.5,

  // --- GHOST ---
  'ghost,normal': 0.0,
  'ghost,psychic': 2.0,
  'ghost,ghost': 2.0,
  'ghost,dark': 0.5,

  // --- DRAGON ---
  'dragon,dragon': 2.0,
  'dragon,steel': 0.5,
  'dragon,fairy': 0.0,

  // --- STEEL ---
  'steel,fire': 0.5,
  'steel,water': 0.5,
  'steel,electric': 0.5,
  'steel,ice': 2.0,
  'steel,rock': 2.0,
  'steel,steel': 0.5,
  'steel,fairy': 2.0,

  // --- DARK ---
  'dark,fighting': 0.5,
  'dark,psychic': 2.0,
  'dark,ghost': 2.0,
  'dark,dark': 0.5,
  'dark,fairy': 0.5,

  // --- FAIRY ---
  'fairy,fire': 0.5,
  'fairy,fighting': 2.0,
  'fairy,poison': 0.5,
  'fairy,dragon': 2.0,
  'fairy,dark': 2.0,
  'fairy,steel': 0.5,
};

  /// Obtiene un movimiento aleatorio de la lista
  static String obtenerMovimientoAleatorio() {
    return movimientosAleatorios[
        (DateTime.now().millisecondsSinceEpoch % movimientosAleatorios.length)];
  }

  /// Obtiene las resistencias de un Pokémon basado en sus tipos
  static List<String> obtenerResistenciasPokemon(List<String> tipos) {
    final Set<String> resistencias = {};
    for (final tipo in tipos) {
      final tipoKey = tipo.toLowerCase();
      if (resistenciasPorTipo.containsKey(tipoKey)) {
        resistencias.addAll(resistenciasPorTipo[tipoKey]!);
      }
    }
    return resistencias.toList();
  }

  /// Obtiene el icono correspondiente a un tipo de Pokémon
  static IconData obtenerIconoPorTipo(String tipo) {
    return iconoPorTipo[tipo.toLowerCase()] ?? Icons.help_outline;
  }
}
