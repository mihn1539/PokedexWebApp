/// Utilidades y helpers para Pokémon

/// Capitaliza la primera letra de un string
String capitalizar(String texto) {
  if (texto.isEmpty) return texto;
  return texto[0].toUpperCase() + texto.substring(1);
}

/// Mapeo de generación a versión por defecto
String obtenerVersionPorGeneracion(String generacion) {
  return switch (generacion) {
    'generation-i' => 'red',
    'generation-ii' => 'gold',
    'generation-iii' => 'emerald',
    'generation-iv' => 'diamond',
    'generation-v' => 'black',
    'generation-vi' => 'x',
    'generation-vii' => 'sun',
    'generation-viii' => 'sword',
    'generation-ix' => 'scarlet',
    _ => 'unknown'
  };
}

/// Mapeo de generación a región
String obtenerRegionPorGeneracion(String generacion) {
  return switch (generacion) {
    'generation-i' => 'kanto',
    'generation-ii' => 'johto',
    'generation-iii' => 'hoenn',
    'generation-iv' => 'sinnoh',
    'generation-v' => 'unova',
    'generation-vi' => 'kalos',
    'generation-vii' => 'alola',
    'generation-viii' => 'galar',
    'generation-ix' => 'paldea',
    _ => 'unknown'
  };
}

/// Mapeo de nombre de tipo a ID de sprite
int tipoNameToSpriteId(String tipoName) {
  return switch (tipoName.toLowerCase()) {
    'normal' => 1,
    'fighting' => 2,
    'flying' => 3,
    'poison' => 4,
    'ground' => 5,
    'rock' => 6,
    'bug' => 7,
    'ghost' => 8,
    'steel' => 9,
    'fire' => 10,
    'water' => 11,
    'grass' => 12,
    'electric' => 13,
    'psychic' => 14,
    'ice' => 15,
    'dragon' => 16,
    'dark' => 17,
    'fairy' => 18,
    _ => 0
  };
}

/// Obtiene la URL del sprite de un tipo
String getTipoSpriteUrl(String tipoName) {
  final spriteId = tipoNameToSpriteId(tipoName);
  return "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/types/generation-vi/omega-ruby-alpha-sapphire/$spriteId.png";
}

/// Constantes de la API
class PokeApiConstants {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const String spritesBaseUrl = 
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';
  
  static String pokemonUrl(int id) => '$baseUrl/pokemon/$id';
  static String speciesUrl(int id) => '$baseUrl/pokemon-species/$id';
  static String encountersUrl(int id) => '$baseUrl/pokemon/$id/encounters';
  static String artworkUrl(int id) => '$spritesBaseUrl/$id.png';
}
