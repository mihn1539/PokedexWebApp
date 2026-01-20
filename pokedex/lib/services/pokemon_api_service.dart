import 'package:http/http.dart' as http;
import 'dart:convert';

/// Servicio para realizar peticiones a la PokeAPI
class PokemonApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  /// Obtiene los tipos de un Pokémon
  static Future<List<String>> fetchPokemonTypes(String pokemonName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon/${pokemonName.toLowerCase()}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> types = data['types'];
        return types
            .map((t) => t['type']['name'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene los movimientos que puede aprender un Pokémon
  static Future<List<String>> fetchPokemonMoves(String pokemonName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon/${pokemonName.toLowerCase()}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> moves = data['moves'];
        return moves
            .map((m) => m['move']['name'] as String)
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Obtiene las estadísticas totales de un Pokémon
  static Future<int> fetchStats(String pokemonName) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/pokemon/${pokemonName.toLowerCase()}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> statsData = data['stats'];

        return statsData.fold<int>(
          0,
          (sum, stat) => sum + (stat["base_stat"] as int),
        );
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }
}

/// Cache global para las peticiones a la API
class PokemonCache {
  static final Map<String, List<String>> _typesCache = {};
  static final Map<String, List<String>> _movesCache = {};
  static final Map<String, int> _statsCache = {};
  static final Map<int, Map<String, dynamic>> _detailsCache = {};

  /// Obtiene los detalles completos de un Pokémon con cache
  static Future<Map<String, dynamic>> getDetails(int id) async {
    if (_detailsCache.containsKey(id)) return _detailsCache[id]!;

    final response = await http.get(
      Uri.parse('${PokemonApiService._baseUrl}/pokemon/$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _detailsCache[id] = data;
      return data;
    }
    
    throw Exception('Error al cargar detalles del Pokémon $id');
  }

  /// Obtiene los tipos con cache
  static Future<List<String>> getTypes(String name) async {
    final key = name.toLowerCase();
    if (_typesCache.containsKey(key)) return _typesCache[key]!;
    
    final types = await PokemonApiService.fetchPokemonTypes(name);
    _typesCache[key] = types;
    return types;
  }

  /// Obtiene los movimientos con cache
  static Future<List<String>> getMoves(String name) async {
    final key = name.toLowerCase();
    if (_movesCache.containsKey(key)) return _movesCache[key]!;
    
    final moves = await PokemonApiService.fetchPokemonMoves(name);
    _movesCache[key] = moves;
    return moves;
  }

  /// Obtiene las estadísticas con cache
  static Future<int> getStats(String name) async {
    final key = name.toLowerCase();
    if (_statsCache.containsKey(key)) return _statsCache[key]!;
    
    final total = await PokemonApiService.fetchStats(name);
    _statsCache[key] = total;
    return total;
  }

  /// Limpia el cache
  static void clearCache() {
    _typesCache.clear();
    _movesCache.clear();
    _statsCache.clear();
    _detailsCache.clear();
  }

  /// Limpia solo el cache de tipos
  static void clearTypesCache() => _typesCache.clear();

  /// Limpia solo el cache de movimientos
  static void clearMovesCache() => _movesCache.clear();

  /// Limpia solo el cache de estadísticas
  static void clearStatsCache() => _statsCache.clear();

  /// Limpia solo el cache de detalles
  static void clearDetailsCache() => _detailsCache.clear();
}
