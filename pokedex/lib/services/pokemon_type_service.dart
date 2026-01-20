import 'dart:convert';
import 'package:http/http.dart' as http;

/// Clase que representa la efectividad de tipos de un Pokémon
class TypeEffectiveness {
  final List<String> debilidadX4 = [];
  final List<String> debilidadX2 = [];
  final List<String> neutral = [];
  final List<String> resistenciaMitad = [];
  final List<String> resistenciaUnCuarto = [];
  final List<String> inmune = [];

  // Contadores internos para calcular multiplicadores
  final Map<String, int> _weaknessCount = {};
  final Map<String, int> _resistanceCount = {};
  final Set<String> _immunities = {};

  TypeEffectiveness.empty();

  void _addWeakness(String tipo) {
    _weaknessCount[tipo] = (_weaknessCount[tipo] ?? 0) + 1;
  }

  void _addResistance(String tipo) {
    _resistanceCount[tipo] = (_resistanceCount[tipo] ?? 0) + 1;
  }

  void _addImmunity(String tipo) {
    _immunities.add(tipo);
    inmune.add(tipo);
  }

  /// Calcula el multiplicador de daño para un tipo específico
  double _getMultiplier(String tipo) {
    // Las inmunidades anulan todo
    if (_immunities.contains(tipo)) return 0;

    final weak = _weaknessCount[tipo] ?? 0;
    final resist = _resistanceCount[tipo] ?? 0;
    final net = weak - resist;

    if (net == 2) return 4;
    if (net == 1) return 2;
    if (net == 0) return 1;
    if (net == -1) return 0.5;
    if (net == -2) return 0.25;

    return 1;
  }
}

/// Servicio para manejar las relaciones de tipos de Pokémon
class PokemonTypeService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2/type';

  /// Calcula las debilidades y resistencias de un Pokémon basado en sus tipos
  static Future<TypeEffectiveness> calculateTypeEffectiveness(
    List<String> tipos,
  ) async {
    if (tipos.isEmpty) {
      return TypeEffectiveness.empty();
    }

    final effectiveness = TypeEffectiveness.empty();

    // Procesar primer tipo
    final tipo1Data = await _fetchTypeData(tipos[0]);
    _addTypeRelations(effectiveness, tipo1Data);

    // Procesar segundo tipo si existe
    if (tipos.length > 1) {
      final tipo2Data = await _fetchTypeData(tipos[1]);
      _addTypeRelations(effectiveness, tipo2Data);
    }

    // Calcular multiplicadores finales
    _calculateFinalEffectiveness(effectiveness);

    return effectiveness;
  }

  /// Obtiene los datos de un tipo desde la API
  static Future<Map<String, dynamic>> _fetchTypeData(String tipo) async {
    final url = Uri.parse('$_baseUrl/$tipo');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener datos del tipo $tipo');
    }
  }

  /// Agrega las relaciones de tipo a la efectividad
  static void _addTypeRelations(
    TypeEffectiveness effectiveness,
    Map<String, dynamic> typeData,
  ) {
    final damageRelations = typeData['damage_relations'];

    // Agregar debilidades (recibe daño doble)
    for (var type in damageRelations['double_damage_from'] as List) {
      effectiveness._addWeakness(type['name'] as String);
    }

    // Agregar resistencias (recibe daño reducido)
    for (var type in damageRelations['half_damage_from'] as List) {
      effectiveness._addResistance(type['name'] as String);
    }

    // Agregar inmunidades (no recibe daño)
    for (var type in damageRelations['no_damage_from'] as List) {
      effectiveness._addImmunity(type['name'] as String);
    }
  }

  /// Calcula la efectividad final considerando multiplicadores
  static void _calculateFinalEffectiveness(TypeEffectiveness effectiveness) {
    final typesList = [
      'normal', 'fighting', 'flying', 'poison', 'ground', 'rock',
      'bug', 'ghost', 'steel', 'fire', 'water', 'grass',
      'electric', 'psychic', 'ice', 'dragon', 'dark', 'fairy',
    ];

    for (var tipo in typesList) {
      final multiplier = effectiveness._getMultiplier(tipo);

      if (multiplier == 0) {
        // Ya está en inmune, no hacer nada
      } else if (multiplier == 4) {
        effectiveness.debilidadX4.add(tipo);
      } else if (multiplier == 2) {
        effectiveness.debilidadX2.add(tipo);
      } else if (multiplier == 0.5) {
        effectiveness.resistenciaMitad.add(tipo);
      } else if (multiplier == 0.25) {
        effectiveness.resistenciaUnCuarto.add(tipo);
      } else if (multiplier == 1) {
        effectiveness.neutral.add(tipo);
      }
    }
  }
}
