import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokedex/services/pokemon_type_service.dart';
import 'package:pokedex/services/pokemon_api_service.dart';
import 'package:pokedex/utils/pokemon_helpers.dart';

class Pokemon {
  // Atributos principales del Pokémon
  final int id; //recordar que los id igual sirven para la sp
  final String nombre;
  final String imagenUrl;
  final List<String>? tipos;
  final double? altura; //esto podria ser int y talves eso da el error?
  final double? peso;
  List<String>? habilidades; //cambiar luego el nombre de las habilidades a español
  List<String>? descripcion; //descrripcion de las habilidades, primero almacenamos url y luego reemplazamos por la descripcion
  final Map<String, int>? stats;
  final Map<String, int>? ev;
  String? grupoHuevo;
  String? grupoHuevo2;
  List<String> debilidadX4 = [];
  List<String> debilidadX2 = [];
  List<String> neutral = [];
  List<String> resistenciaMitad = [];
  List<String> resistenciaUnCuarto = [];
  List<String> inmune = [];
  String? urlCadenaEvolutiva;
  String? generacion;
  String? region;
  String? version; //utilisaremos solo una para poder buscar una entrada en la pokedex
  String? color;
  String? entradaPokedex; //entrada de la pokedex de la version en la que se introdujo el pokemon
  Map<String,List<String>>? lugaresCaptura;
  Map? entradasPokedexSp;
  Map<String, Map<String, dynamic>>? movimientos;

  // Constructor
  Pokemon({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    this.tipos,
    this.altura,
    this.peso,
    this.habilidades,
    this.stats,
    this.ev,
    this.descripcion,
    this.generacion,
    this.region,
    this.color,
    this.movimientos,
  });

  // Método movido a pokemon_helpers.dart

  // Constructor para crear un Pokémon básico con ID, nombre y URL de imagen
  factory Pokemon.basic(int id, String name, String imagenUrl) {
    return Pokemon(id: id, nombre: name, imagenUrl: imagenUrl);
  }

  /// Carga los detalles completos del Pokémon desde la API (con caché)
  Future<Pokemon> cargarDetalles() async {
    final json = await PokemonCache.getDetails(id);
    return Pokemon.detailed(json);
  }

  /// Verifica si el Pokémon tiene datos completos cargados
  bool get tieneDetallesCargados => tipos != null && altura != null;

  // Métodos para serialización (guardar/cargar desde cache)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'imagenUrl': imagenUrl,
      if (tipos != null) 'tipos': tipos,
      if (altura != null) 'altura': altura,
      if (peso != null) 'peso': peso,
      if (habilidades != null) 'habilidades': habilidades,
      if (stats != null) 'stats': stats,
      if (ev != null) 'ev': ev,
    };
  }

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Si tiene datos completos, crear con ellos
    if (json.containsKey('tipos') && json.containsKey('altura')) {
      return Pokemon(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        imagenUrl: json['imagenUrl'] as String,
        tipos: json['tipos'] != null ? List<String>.from(json['tipos']) : null,
        altura: json['altura'] != null ? (json['altura'] as num).toDouble() : null,
        peso: json['peso'] != null ? (json['peso'] as num).toDouble() : null,
        habilidades: json['habilidades'] != null ? List<String>.from(json['habilidades']) : null,
        stats: json['stats'] != null 
            ? Map<String, int>.from(json['stats'].map((k, v) => MapEntry(k as String, v as int)))
            : null,
        ev: json['ev'] != null 
            ? Map<String, int>.from(json['ev'].map((k, v) => MapEntry(k as String, v as int)))
            : null,
      );
    }
    
    // Si solo tiene datos básicos, crear con constructor basic
    return Pokemon.basic(
      json['id'] as int,
      json['nombre'] as String,
      json['imagenUrl'] as String,
    );
  }
  // Constructor para crear un Pokémon con datos detallados (de la API)
  factory Pokemon.detailed(Map<String, dynamic> json) {
    final id = json['id'];
    return Pokemon(
      id: id,
      nombre: json['name'],
      color: json['color'],
      imagenUrl:
          "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png",
      tipos: (json['types'] as List)
          .map((typeInfo) => typeInfo['type']['name'] as String)
          .toList(),
      altura: json['height'] * 10, // convertir a cm
      peso: json['weight'] / 10, // convertir a kg
      habilidades: (json['abilities'] as List)
          .map((abilityInfo) => abilityInfo['ability']['name'] as String)
          .toList(),
      descripcion: (json['abilities'] as List)
          .map((abilityInfo) => abilityInfo['ability']['url'] as String)
          .toList(),
      stats: Map.fromEntries(
        (json['stats'] as List).map(
          (statInfo) => MapEntry(
            statInfo['stat']['name'] as String,
            statInfo['base_stat'] as int,
          ),
        ),
      ),
      ev: Map.fromEntries(
        (json['stats'] as List)
            .where((statInfo) => statInfo['effort'] > 0)
            .map(
              (statInfo) => MapEntry(
                statInfo['stat']['name'] as String,
                statInfo['effort'] as int,
              ),
            ),
      ),
       movimientos:Map.fromEntries(
          (json['moves'] as List).map(
            (ataque) {
              final nombre = ataque['move']['name'] as String;
              final url = ataque['move']['url'] as String;

              
              final versionGroups = (ataque['version_group_details'] as List).map(
                (detail) => {
                  "level": detail['level_learned_at'],
                  "method": detail['move_learn_method']['name'],
                  "version_group": detail['version_group']['name'],
                },
              ).toList();
              return MapEntry(
                nombre,
                {
                  "url": url,
                  "version_groups": versionGroups,
                },
              );
            },
          ),
        ),
    );
  }
  /// Calcula y carga las debilidades y resistencias del Pokémon
  Future<void> cargarDebilidades() async {
    if (tipos == null || tipos!.isEmpty) return;

    final effectiveness = await PokemonTypeService.calculateTypeEffectiveness(tipos!);
    
    debilidadX4 = effectiveness.debilidadX4;
    debilidadX2 = effectiveness.debilidadX2;
    neutral = effectiveness.neutral;
    resistenciaMitad = effectiveness.resistenciaMitad;
    resistenciaUnCuarto = effectiveness.resistenciaUnCuarto;
    inmune = effectiveness.inmune;
  }

  /// Carga las descripciones de las habilidades en español
  Future<void> cargarDescripcionHabilidades() async {
    if (descripcion == null || descripcion!.isEmpty) return;

    final descripcionesObtenidas = <String>[];
    final nombresObtenidos = <String>[];

    for (var url in descripcion!) {
      try {
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          // Obtener nombre en español
          final nombre = _obtenerTextoEspanol(
            data['names'] as List,
            'Nombre no disponible',
          );
          nombresObtenidos.add(nombre);
          
          // Obtener descripción en español
          final descripcionTexto = _obtenerDescripcionEspanol(data);
          descripcionesObtenidas.add(descripcionTexto);
        } else {
          nombresObtenidos.add('Error');
          descripcionesObtenidas.add('Error al obtener la descripción.');
        }
      } catch (e) {
        nombresObtenidos.add('Error');
        descripcionesObtenidas.add('Error al procesar la habilidad.');
      }
    }

    descripcion = descripcionesObtenidas;
    habilidades = nombresObtenidos;
  }

  /// Extrae texto en español de una lista de traducciones
  String _obtenerTextoEspanol(List data, String defaultValue) {
    final entryEs = data.firstWhere(
      (entry) => entry['language']['name'] == 'es',
      orElse: () => null,
    );
    return entryEs != null ? entryEs['name'] as String : defaultValue;
  }

  /// Obtiene la descripción de una habilidad en español
  String _obtenerDescripcionEspanol(Map<String, dynamic> data) {
    // Intentar obtener de effect_entries
    final efectos = data['effect_entries'] as List?;
    if (efectos != null) {
      final efectosEs = efectos.firstWhere(
        (entry) => entry['language']['name'] == 'es',
        orElse: () => null,
      );
      if (efectosEs != null) {
        return efectosEs['effect'] as String;
      }
    }

    // Si no, intentar obtener de flavor_text_entries
    final flavorTexts = data['flavor_text_entries'] as List?;
    if (flavorTexts != null) {
      final flavorEs = flavorTexts.firstWhere(
        (entry) => entry['language']['name'] == 'es',
        orElse: () => null,
      );
      if (flavorEs != null) {
        return flavorEs['flavor_text'] as String;
      }
    }

    return 'Descripción no disponible en español.';
  }

  // Getters
  String? get urlEvolucion => urlCadenaEvolutiva;
  Map? get entradasPokedex => entradasPokedexSp;
  Map<String, List<String>>? get lugaresDeCaptura => lugaresCaptura;
  Map<String, Map<String, dynamic>>? get ataques => movimientos; 

  /// Carga las locaciones donde se puede capturar este Pokémon
  Future<void> cargarLocaciones() async {
    final url = Uri.parse(PokeApiConstants.encountersUrl(id));
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener locaciones para el pokemon');
    }

    final data = jsonDecode(response.body);
    
    if (data is List && data.isNotEmpty) {
      lugaresCaptura = {};
      for (var location in data) {
        final lugar = location['location_area']['name'] as String;
        final versiones = (location['version_details'] as List)
            .map((v) => v['version']['name'] as String)
            .toList();
        lugaresCaptura![lugar] = versiones;
      }
    } else {
      lugaresCaptura = {'No se encontraron locaciones de captura para este Pokémon.': []};
    }
  }

  /// Carga la información de especie del Pokémon
  Future<void> cargarSp() async {
    final url = Uri.parse(PokeApiConstants.speciesUrl(id));
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al obtener informacion de especie para el pokemon');
    }

    final data = jsonDecode(response.body);

    // Grupos huevo
    final eggGroups = data['egg_groups'] as List;
    grupoHuevo = eggGroups.map((e) => e['name'] as String).toString();
    grupoHuevo2 = eggGroups.length > 1 ? eggGroups[1]['name'] as String : null;

    // Cadena evolutiva
    urlCadenaEvolutiva = data['evolution_chain']['url'] as String;

    // Entradas de Pokédex en español
    entradasPokedexSp = {};
    for (var entry in data['flavor_text_entries']) {
      if (entry['language']['name'] == 'es') {
        entradasPokedexSp![entry['version']['name']] = entry['flavor_text'];
      }
    }

    // Generación y región
    generacion = data['generation']['name'] as String;
    version = obtenerVersionPorGeneracion(generacion!);
    region = obtenerRegionPorGeneracion(generacion!);

    // Entrada por defecto (versión Y)
    entradaPokedex = (data['flavor_text_entries'] as List)
        .firstWhere(
          (entry) => entry['language']['name'] == 'es' && 
                     entry['version']['name'] == 'y',
          orElse: () => null,
        )?['flavor_text'] as String?;
  }
}

/// Obtiene la lista completa de Pokémon desde la API
Future<List<Pokemon>> fetchPokemons() async {
  final responses = await Future.wait([
    http.get(Uri.parse('${PokeApiConstants.baseUrl}/pokemon?limit=1025')),
    http.get(Uri.parse('${PokeApiConstants.baseUrl}/pokemon?offset=10000&limit=10277')),
  ]);

  if (responses.any((r) => r.statusCode != 200)) {
    throw Exception('Error al cargar la lista de Pokémon');
  }

  final data1 = jsonDecode(responses[0].body);
  final data2 = jsonDecode(responses[1].body);
  final List results = data1['results'] + data2['results'];

  return results.map((pokemon) {
    final url = pokemon['url'] as String;
    final id = int.parse(url.split('/')[6]);
    return Pokemon.basic(id, pokemon['name'], PokeApiConstants.artworkUrl(id));
  }).toList();
}
