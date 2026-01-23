import 'package:pokedex/models/filtros_pokedex.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/pages/pokemon_detail_page.dart';
import 'package:pokedex/widgets/menu_lateral.dart';
import 'package:pokedex/widgets/daily_trivia_widget.dart';
import 'package:pokedex/controllers/favorites_controller.dart';
import 'package:pokedex/utils/screen_utils.dart';
import 'package:pokedex/utils/pokemon_helpers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});

  // Método estático para acceder a la lista de Pokémon desde cualquier lugar
  static List<Pokemon> getAllPokemons() {
    return _PokedexPageState.allPokemons;
  }

  @override
  State<PokedexPage> createState() => _PokedexPageState();
}

// Estado de la Pokédex
class _PokedexPageState extends State<PokedexPage> {
  static List<Pokemon> allPokemons = []; // Lista completa de Pokémon
  List<Pokemon> pokemons = []; // Lista de Pokémon cargados (para busqueda)

  bool cargando = false; // indica si se esta cargando mas pokemon
  final ScrollController _scrollController = ScrollController(); // controlador de scroll para scroll infinito
  final TextEditingController _textController = TextEditingController(); // controlador del campo de texto
  Timer? _debounceTimer; // temporizador para debounce de búsqueda

  // filtros persistentes en el estado
  PokemonFilters filtros = PokemonFilters();
  String? selectedType1Display;
  String? selectedType2Display;
  String? selectedGenerationDisplay;
  String? selectedColorDisplay;
  String? selectedRouteDisplay;
  List<String> availableLocations = [];

  // Caches para evitar repetir consultas pesadas
  final Map<String, Set<int>> _colorCache = {};
  final Map<String, Set<int>> _typeCache = {};
  final Map<String, Set<int>> _generationCache = {};
  final Map<String, Set<int>> _routeCache = {};
  final Map<String, List<String>> _locationsByGenerationCache = {};

  // función para obtener pokemon desde la pokeAPI o caché
  Future<void> cargarPokemons() async {
    setState(() => cargando = true);

    try {
      if (allPokemons.isEmpty) {
        // Intentar cargar desde caché primero
        final preferences = await SharedPreferences.getInstance();
        final cachedData = preferences.getString('pokedex_cache');
        
        if (cachedData != null) {
          // Cargar desde caché
          final List<dynamic> jsonList = jsonDecode(cachedData);
          allPokemons = jsonList.map((json) => Pokemon.fromJson(json)).toList();
        } else {
          // Si no hay caché, cargar desde API
          allPokemons = await fetchPokemons();
          
          // Guardar en caché para próximas veces
          final jsonList = allPokemons.map((p) => p.toJson()).toList();
          await preferences.setString('pokedex_cache', jsonEncode(jsonList));
        }
      }

      pokemons = allPokemons.toList();
      setState(() => cargando = false);
    } catch (e) {
      setState(() => cargando = false);
      throw Exception('Falla al cargar Pokémon');
    }
  }

  // Helpers para obtener conjuntos de ids (con cache)
  Future<Set<int>> _fetchIdsForType(String type) async {
    if (_typeCache.containsKey(type)) return _typeCache[type]!;
    final uri = Uri.parse('https://pokeapi.co/api/v2/type/$type');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return {};
    final data = jsonDecode(resp.body);
    final List typePokemons = data['pokemon'] as List;
    final Set<int> ids = typePokemons.map<int>((e) {
      final url = e['pokemon']['url'] as String;
      return int.parse(url.split('/')[6]);
    }).toSet();
    _typeCache[type] = ids;
    return ids;
  }

  // Obtener ids para generación (con cache)
  Future<Set<int>> _fetchIdsForGeneration(String generationName) async {
    if (_generationCache.containsKey(generationName)) {
      return _generationCache[generationName]!;
    }
    final uri = Uri.parse(
      'https://pokeapi.co/api/v2/generation/$generationName',
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return {};
    final data = jsonDecode(resp.body);
    final List species = data['pokemon_species'] as List;
    final Set<int> ids = species.map<int>((e) {
      final url = e['url'] as String;
      final parts = url.split('/');
      return int.parse(parts[parts.length - 2]);
    }).toSet();
    _generationCache[generationName] = ids;
    return ids;
  }

  // Obtener ids para color (con cache)
  Future<Set<int>> _fetchIdsForColor(String colorName) async {
    if (_colorCache.containsKey(colorName)) return _colorCache[colorName]!;
    final uri = Uri.parse('https://pokeapi.co/api/v2/pokemon-color/$colorName');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return {};
    final data = jsonDecode(resp.body);
    final List species = data['pokemon_species'] as List;
    final Set<int> ids = species.map<int>((e) {
      final url = e['url'] as String;
      final parts = url.split('/');
      return int.parse(parts[parts.length - 2]);
    }).toSet();
    _colorCache[colorName] = ids;
    return ids;
  }

  // Obtener ids para ubicación/ruta (con cache)
  Future<Set<int>> _fetchIdsForLocation(String locationArea) async {
    if (_routeCache.containsKey(locationArea)) return _routeCache[locationArea]!;
    final uri = Uri.parse('https://pokeapi.co/api/v2/location-area/$locationArea');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return {};
    final data = jsonDecode(resp.body);
    final List encounters = data['pokemon_encounters'] as List;
    final Set<int> ids = encounters.map<int>((e) {
      final url = e['pokemon']['url'] as String;
      return int.parse(url.split('/')[6]);
    }).toSet();
    _routeCache[locationArea] = ids;
    return ids;
  }

  // Obtener lista de ubicaciones para una generación (con cache)
  Future<List<String>> _fetchLocationsForGeneration(String generationName) async {
    if (_locationsByGenerationCache.containsKey(generationName)) {
      return _locationsByGenerationCache[generationName]!;
    }
    final uri = Uri.parse('https://pokeapi.co/api/v2/generation/$generationName');
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];
    final data = jsonDecode(resp.body);
    
    // Obtener región principal
    final mainRegion = data['main_region'];
    if (mainRegion == null) return [];
    
    // Obtener ubicaciones de la región principal
    List<String> allLocationAreas = [];
    final regionUrl = mainRegion['url'] as String;
    final regionResp = await http.get(Uri.parse(regionUrl));
    if (regionResp.statusCode == 200) {
      final regionData = jsonDecode(regionResp.body);
      final List locations = regionData['locations'] as List;
      
      // Para cada ubicación, obtener sus áreas
      for (var loc in locations) {
        final locationUrl = loc['url'] as String;
        final locResp = await http.get(Uri.parse(locationUrl));
        if (locResp.statusCode == 200) {
          final locData = jsonDecode(locResp.body);
          final List areas = locData['areas'] as List;
          for (var area in areas) {
            allLocationAreas.add(area['name'] as String);
          }
        }
      }
    }
    
    _locationsByGenerationCache[generationName] = allLocationAreas;
    return allLocationAreas;
  }

  // Precargar ubicaciones de todas las generaciones
  Future<void> _preloadAllLocations() async {
    final generations = [
      'generation-i',
      'generation-ii',
      'generation-iii',
      'generation-iv',
      'generation-v',
      'generation-vi',
      'generation-vii',
      'generation-viii',
      'generation-ix',
    ];

    // Cargar en paralelo las ubicaciones de todas las generaciones
    await Future.wait(
      generations.map((gen) => _fetchLocationsForGeneration(gen)),
    );
  }

  // Aplica todos los filtros combinados: type, generation, region, legendary
  Future<void> _applyFilters() async {
    setState(() => cargando = true);
    try {
      // Base: todos los ids disponibles
      Set<int> resultIds = allPokemons.map((p) => p.id).toSet();

      // Tipo 1
      if (filtros.type1 != null) {
        final ids = await _fetchIdsForType(filtros.type1!);
        resultIds = resultIds.intersection(ids);
      }

      // Tipo 2
      if (filtros.type2 != null) {
        final ids = await _fetchIdsForType(filtros.type2!);
        resultIds = resultIds.intersection(ids);
      }

      // Generación
      if (filtros.generation != null) {
        final ids = await _fetchIdsForGeneration(filtros.generation!);
        resultIds = resultIds.intersection(ids);
      }

      // Color
      if (filtros.color != null) {
        final ids = await _fetchIdsForColor(filtros.color!);
        resultIds = resultIds.intersection(ids);
      }

      // Ruta (solo si hay filtro de generación activo)
      if (filtros.route != null && filtros.generation != null) {
        final ids = await _fetchIdsForLocation(filtros.route!);
        resultIds = resultIds.intersection(ids);
      }

      setState(() {
        pokemons = allPokemons.where((p) => resultIds.contains(p.id)).toList();
      });
    } finally {
      setState(() => cargando = false);
    }
  }

  // Buscar Pokémon por nombre o id
  void _buscarPokemon() async {
    final text = _textController.text.toLowerCase().trim();
    if (cargando) return;

    if (_filtersActive()) {
      // Recalcular filtros (async) para asegurar que pokemons contiene los resultados filtrados
      await _applyFilters();
    } else {
      setState(() => pokemons = allPokemons.toList());
    }

    // Si el texto de búsqueda está vacío, no filtrar más
    if (text.isEmpty) {
      return;
    }

    // Buscar en la base correcta: si hay filtros activos, buscar dentro de la lista filtrada actual;
    // si no, buscar en la lista completa.
    final base = pokemons;
    final resultados = base.where((poke) {
      final nombre = poke.nombre.toLowerCase();
      final idStr = poke.id.toString();
      return nombre.contains(text) || idStr == text;
    }).toList();

    setState(() => pokemons = resultados);
  }

  // Wrapper con debounce para evitar búsquedas excesivas al escribir
  void _buscarPokemonDebounced() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), _buscarPokemon);
  }

  @override
  void initState() {
    super.initState();
    // seleccionar valores por defecto y cargar pokemons
    selectedType1Display = 'Tipo 1';
    selectedType2Display = 'Tipo 2';
    selectedColorDisplay = 'Todos los colores';
    selectedGenerationDisplay = null;
    cargarPokemons(); // cargar los primeros pokemon al iniciar
    _preloadAllLocations(); // precargar ubicaciones de todas las generaciones
    // asegurar que no haya filtro activo al inicio
    filtros.type1 = null;
    filtros.type2 = null;
    filtros.generation = null;
    filtros.color = null;
    _applyFilters();
    _textController.addListener(_buscarPokemonDebounced);

    // Listener para scroll infinito
    _scrollController.addListener(() {
      // si llegamos cerca del final del scroll y no estamos cargando
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !cargando) {
        // Si hay filtros activos, no cargamos automáticamente
        if (!_filtersActive()) {
          cargarPokemons(); // cargar más Pokémon automáticamente
        }
      }
    });
  }

  // Verifica si hay filtros activos
  bool _filtersActive() {
    return (filtros.type1 != null) ||
        (filtros.type2 != null) ||
        (filtros.generation != null) ||
        (filtros.color != null) ||
        (filtros.route != null);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose(); // limpiar el controlador al cerrar el widget
    _textController.dispose(); // limpiar el controlador de texto
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final margenHorizontal = ScreenUtils.getHorizontalMargin(context);
    final margenVertical = ScreenUtils.getVerticalMargin(context);
    final anchoGrid = ScreenUtils.getGridWidth(context);

    // Mapeo entre nombres en español mostrados en el dropdown y los nombres de tipo en la API
    final Map<String, String?> spanishToApiType = {
      'Todos los tipos': null,
      'Normal': 'normal',
      'Fuego': 'fire',
      'Agua': 'water',
      'Planta': 'grass',
      'Eléctrico': 'electric',
      'Hielo': 'ice',
      'Lucha': 'fighting',
      'Veneno': 'poison',
      'Tierra': 'ground',
      'Volador': 'flying',
      'Psíquico': 'psychic',
      'Bicho': 'bug',
      'Roca': 'rock',
      'Fantasma': 'ghost',
      'Dragón': 'dragon',
      'Siniestro': 'dark',
      'Acero': 'steel',
      'Hada': 'fairy',
    };
    // Scaffold principal de la página
    return Scaffold(
      drawer: const MenuLateral(), // Agrega el botón del menú lateral
      appBar: AppBar(
        title: const Text("Pokédex"),
      ),

      // Cuerpo principal con padding y centrado
      body: Padding(
        // Margenes proporcionales
        padding: EdgeInsets.symmetric(
          horizontal: margenHorizontal,
          vertical: margenVertical,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: anchoGrid,
            ), // limita ancho máximo
            child: Column(
              children: [
                TextField(
                  controller: _textController, // controlador del campo de texto
                  decoration: InputDecoration(
                    labelText: 'Ingresa su nombre o id',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                // Trivia diaria (solo si no hay búsqueda ni filtros activos y hay pokémon cargados)
                if (_textController.text.isEmpty && !_filtersActive() && allPokemons.isNotEmpty)
                  Card(
                    elevation: 4,
                    child: ExpansionTile(
                      title: const Text(
                        '¿Quién es ese Pokémon?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      leading: const Icon(Icons.quiz),
                      children: [
                        DailyTriviaWidget(
                          allPokemons: allPokemons,
                        ),
                      ],
                    ),
                  ),
                if (_textController.text.isEmpty && !_filtersActive() && allPokemons.isNotEmpty)
                  const SizedBox(height: 16),
                // Widget de expansión para filtros
                ExpansionTile(
                  title: const Text('Filtros'),
                  leading: const Icon(Icons.filter_list), // Icono
                  trailing: _filtersActive()
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const SizedBox(
                              width: 8,
                              height: 8,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.expand_more),
                        ],
                      )
                    : null,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0), // Un padding interno
                      child: Column(
                        children: [
                          // Filtros de Tipo (dos en la misma fila)
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo 1',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      <String>[
                                        'Tipo 1',
                                        'Normal',
                                        'Fuego',
                                        'Agua',
                                        'Planta',
                                        'Eléctrico',
                                        'Hielo',
                                        'Lucha',
                                        'Veneno',
                                        'Tierra',
                                        'Volador',
                                        'Psíquico',
                                        'Bicho',
                                        'Roca',
                                        'Fantasma',
                                        'Dragón',
                                        'Siniestro',
                                        'Acero',
                                        'Hada',
                                      ].map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  initialValue:
                                      selectedType1Display ?? 'Tipo 1',
                                  onChanged: (String? newValue) {
                                    final apiType = newValue == 'Tipo 1'
                                        ? null
                                        : spanishToApiType[newValue];
                                    setState(() {
                                      selectedType1Display = newValue;
                                      filtros.type1 = apiType;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo 2',
                                    border: OutlineInputBorder(),
                                  ),
                                  items:
                                      <String>[
                                        'Tipo 2',
                                        'Normal',
                                        'Fuego',
                                        'Agua',
                                        'Planta',
                                        'Eléctrico',
                                        'Hielo',
                                        'Lucha',
                                        'Veneno',
                                        'Tierra',
                                        'Volador',
                                        'Psíquico',
                                        'Bicho',
                                        'Roca',
                                        'Fantasma',
                                        'Dragón',
                                        'Siniestro',
                                        'Acero',
                                        'Hada',
                                      ].map<DropdownMenuItem<String>>((
                                        String value,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                  initialValue:
                                      selectedType2Display ?? 'Tipo 2',
                                  onChanged: (String? newValue) {
                                    final apiType = newValue == 'Tipo 2'
                                        ? null
                                        : spanishToApiType[newValue];
                                    setState(() {
                                      selectedType2Display = newValue;
                                      filtros.type2 = apiType;
                                    });
                                    _applyFilters();
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Filtro de Generación
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Generación',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                <Map<String, String>>[
                                  {
                                    'label': 'Todas las generaciones',
                                    'value': '',
                                  },
                                  {
                                    'label': 'Generation I (Kanto)',
                                    'value': 'generation-i',
                                  },
                                  {
                                    'label': 'Generation II (Johto)',
                                    'value': 'generation-ii',
                                  },
                                  {
                                    'label': 'Generation III (Hoenn)',
                                    'value': 'generation-iii',
                                  },
                                  {
                                    'label': 'Generation IV (Sinnoh)',
                                    'value': 'generation-iv',
                                  },
                                  {
                                    'label': 'Generation V (Unova)',
                                    'value': 'generation-v',
                                  },
                                  {
                                    'label': 'Generation VI (Kalos)',
                                    'value': 'generation-vi',
                                  },
                                  {
                                    'label': 'Generation VII (Alola)',
                                    'value': 'generation-vii',
                                  },
                                  {
                                    'label': 'Generation VIII (Galar)',
                                    'value': 'generation-viii',
                                  },
                                  {
                                    'label': 'Generation IX (Paldea)',
                                    'value': 'generation-ix',
                                  },
                                ].map<DropdownMenuItem<String>>((opt) {
                                  return DropdownMenuItem<String>(
                                    value: opt['value'] == ''
                                        ? null
                                        : opt['value'],
                                    child: Text(opt['label']!),
                                  );
                                }).toList(),
                            initialValue: selectedGenerationDisplay,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedGenerationDisplay = newValue;
                                filtros.generation = newValue;
                                // Resetear ruta cuando cambia la generación
                                selectedRouteDisplay = null;
                                filtros.route = null;
                                // Obtener ubicaciones del caché (ya precargadas)
                                availableLocations = newValue != null
                                    ? (_locationsByGenerationCache[newValue] ?? [])
                                    : [];
                              });
                              _applyFilters();
                            },
                          ),

                          const SizedBox(height: 8),

                          // Filtro de Color
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Color',
                              border: OutlineInputBorder(),
                            ),
                            items:
                                <Map<String, String?>>[
                                  {'label': 'Todos los colores', 'value': null},
                                  {'label': 'Negro', 'value': 'black'},
                                  {'label': 'Azul', 'value': 'blue'},
                                  {'label': 'Marrón', 'value': 'brown'},
                                  {'label': 'Gris', 'value': 'gray'},
                                  {'label': 'Verde', 'value': 'green'},
                                  {'label': 'Rosa', 'value': 'pink'},
                                  {'label': 'Púrpura', 'value': 'purple'},
                                  {'label': 'Rojo', 'value': 'red'},
                                  {'label': 'Blanco', 'value': 'white'},
                                  {'label': 'Amarillo', 'value': 'yellow'},
                                ].map<DropdownMenuItem<String>>((opt) {
                                  return DropdownMenuItem<String>(
                                    value: opt['value'],
                                    child: Text(opt['label']!),
                                  );
                                }).toList(),
                            initialValue: filtros.color,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedColorDisplay = newValue == null
                                    ? 'Todos los colores'
                                    : {
                                        'black': 'Negro',
                                        'blue': 'Azul',
                                        'brown': 'Marrón',
                                        'gray': 'Gris',
                                        'green': 'Verde',
                                        'pink': 'Rosa',
                                        'purple': 'Púrpura',
                                        'red': 'Rojo',
                                        'white': 'Blanco',
                                        'yellow': 'Amarillo',
                                      }[newValue]!;
                                filtros.color = newValue;
                              });
                              _applyFilters();
                            },
                          ),

                          const SizedBox(height: 8),

                          // Filtro de Ruta (solo habilitado cuando hay generación seleccionada)
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Ruta/Ubicación',
                              border: const OutlineInputBorder(),
                              enabled: filtros.generation != null && availableLocations.isNotEmpty,
                              helperText: filtros.generation == null
                                  ? 'Selecciona una generación primero'
                                  : availableLocations.isEmpty
                                      ? 'Cargando ubicaciones...'
                                      : null,
                            ),
                            value: filtros.route,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('Todas las ubicaciones'),
                              ),
                              ...availableLocations.map((location) {
                                final displayName = location.replaceAll('-', ' ');
                                return DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(
                                    displayName.length > 1
                                        ? displayName[0].toUpperCase() + displayName.substring(1)
                                        : displayName.toUpperCase(),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (filtros.generation != null && availableLocations.isNotEmpty)
                                ? (String? newValue) {
                                    setState(() {
                                      selectedRouteDisplay = newValue;
                                      filtros.route = newValue;
                                    });
                                    _applyFilters();
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: ScreenUtils.getMaxFormWidth(context),
                      // Botón para reiniciar filtros
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            // Resetear los valores mostrados
                            selectedType1Display = 'Tipo 1';
                            selectedType2Display = 'Tipo 2';
                            selectedColorDisplay = 'Todos los colores';
                            selectedGenerationDisplay = null;
                            selectedRouteDisplay = null;
                            availableLocations = [];
                            // Resetear los filtros
                            filtros.resetFilters();
                          });
                          _applyFilters();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reiniciar Filtros'), 
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const SizedBox(height: 8),
                // Grid de Pokémon con trivia diaria al inicio
                Expanded(
                  child: AnimatedBuilder(
                    animation: FavoritesController.instance,
                    builder: (context, _) {
                      if (pokemons.isEmpty && !cargando) {
                        return const Center(
                          child: Text(
                            'No se encontraron coincidencias.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        );
                      }
                      return CustomScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          // Grid de Pokémon
                          SliverGrid(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ScreenUtils.getGridColumns(context),
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index == pokemons.length) {
                                  return cargando
                                      ? const Center(child: CircularProgressIndicator())
                                      : const SizedBox();
                                }

                                final poke = pokemons[index];
                                final name = capitalizar(poke.nombre);
                                final isFav = FavoritesController.instance.isFavorite(poke.id);

                                return RepaintBoundary(
                                  key: ValueKey(poke.id),
                                  child: GestureDetector(
                                    onTap: () => verDetallePokemon(context, poke),
                                    child: Material(
                                      elevation: 2,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () => verDetallePokemon(context, poke),
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
                                                  height: 120,
                                                  fit: BoxFit.contain,
                                                  cacheWidth: 240,
                                                  cacheHeight: 240,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return const SizedBox(
                                                      height: 120,
                                                      child: Center(
                                                        child: CircularProgressIndicator(strokeWidth: 2),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const SizedBox(
                                                      height: 120,
                                                      child: Icon(Icons.error_outline, size: 40),
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
                                              right: 2,
                                              top: 2,
                                              child: IconButton(
                                                tooltip: isFav ? 'Quitar de favoritos' : 'Agregar a favoritos',
                                                icon: Icon(
                                                  isFav ? Icons.favorite : Icons.favorite_border,
                                                  color: isFav ? Theme.of(context).colorScheme.primary : null,
                                                ),
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
                              childCount: pokemons.length + 1,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
