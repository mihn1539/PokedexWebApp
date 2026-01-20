// Clase que contiene constantes para interactuar con la PokeAPI
class PokeApiConstants {
  // Base URL
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  // Endpoints específicos
  static const String pokemonEndpoint = '$baseUrl/pokemon';
  static const String moveEndpoint = '$baseUrl/move';
  static const String typeEndpoint = '$baseUrl/type';
  static const String generationEndpoint = '$baseUrl/generation';
  static const String colorEndpoint = '$baseUrl/pokemon-color';

  // Límites comunes
  static const int moveListLimit = 2000;

  // Métodos helper para construir URLs
  static String getPokemonUrl(int id) => '$pokemonEndpoint/$id';
  static String getMoveUrl(String name) => '$moveEndpoint/$name';
  static String getTypeUrl(String type) => '$typeEndpoint/$type';
  static String getGenerationUrl(String generation) =>
      '$generationEndpoint/$generation';
  static String getColorUrl(String color) => '$colorEndpoint/$color';
  static String getAllMovesUrl() => '$moveEndpoint?limit=$moveListLimit';
}
