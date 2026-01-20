import 'package:flutter/material.dart';
import 'package:pokedex/controllers/daily_trivia_controller.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:pokedex/utils/pokemon_helpers.dart';
import 'package:provider/provider.dart';
import 'dart:math';

/// Widget de la trivia diaria "¿Quién es ese Pokémon?"
class DailyTriviaWidget extends StatefulWidget {
  final List<Pokemon> allPokemons;

  const DailyTriviaWidget({
    super.key,
    required this.allPokemons,
  });

  @override
  State<DailyTriviaWidget> createState() => _DailyTriviaWidgetState();
}

class _DailyTriviaWidgetState extends State<DailyTriviaWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Pokemon> _filteredPokemons = [];
  bool _showSuggestions = false;
  Pokemon? _currentPokemon;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentPokemon();
    });
  }

  Future<void> _loadCurrentPokemon() async {
    if (!mounted || widget.allPokemons.isEmpty) return;
    
    final controller = context.read<DailyTriviaController>();
    
    try {
      Pokemon pokemon;
      int pokemonId;
      
      // Si el controlador no tiene un Pokémon asignado, seleccionar uno aleatorio
      if (controller.currentPokemonId == null) {
        // Usar la semilla de la fecha para obtener el mismo Pokémon todo el día
        final random = Random(DailyTriviaController.getTodaySeed());
        final randomIndex = random.nextInt(widget.allPokemons.length);
        pokemon = widget.allPokemons[randomIndex];
        pokemonId = pokemon.id;
        
        // Establecer el Pokémon del día en el controlador ANTES de continuar
        await controller.setPokemonOfTheDay(pokemonId);
      } else {
        // Ya hay un Pokémon asignado, buscarlo en la lista
        pokemonId = controller.currentPokemonId!;
        pokemon = widget.allPokemons.firstWhere(
          (p) => p.id == pokemonId,
          orElse: () => widget.allPokemons[0],
        );
      }
      
      // Si el Pokémon no tiene detalles cargados, cargarlos desde la API
      if (!pokemon.tieneDetallesCargados) {
        pokemon = await pokemon.cargarDetalles();
      }
      
      _currentPokemon = pokemon;
    } catch (e) {
      debugPrint('[DAILY TRIVIA] Error cargando Pokémon del día: $e');
    }
    
    if (mounted) setState(() {});
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredPokemons = [];
        _showSuggestions = false;
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredPokemons = widget.allPokemons
          .where((p) =>
              p.nombre.toLowerCase().contains(lowercaseQuery) ||
              p.id.toString() == query)
          .take(5)
          .toList();
      _showSuggestions = true;
    });
  }

  Future<void> _makeGuess(Pokemon pokemon) async {
    final controller = context.read<DailyTriviaController>();
    
    final isCorrect = await controller.makeGuess(pokemon.id);

    if (!mounted) return;

    setState(() {
      _searchController.clear();
      _showSuggestions = false;
      _filteredPokemons = [];
    });

    // Mostrar resultado
    if (isCorrect) {
      _showResultDialog(true, pokemon);
    } else if (controller.attemptsRemaining == 0) {
      _showResultDialog(false, pokemon);
    } else {
      _showIncorrectSnackbar();
    }
  }

  void _showIncorrectSnackbar() {
    final controller = context.read<DailyTriviaController>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Incorrecto! Te quedan ${controller.attemptsRemaining} intentos',
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showResultDialog(bool won, Pokemon guessedPokemon) {
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.surface,
        title: Row(
          children: [
            Text(
              won ? '¡Correcto!' : '¡Fallaste!',
              style: theme.titleLarge!.copyWith(
                color: won ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_currentPokemon != null) ...[
              Image.network(
                _currentPokemon!.imagenUrl,
                height: 150,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.catching_pokemon,
                  size: 150,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                won
                    ? '¡Era ${capitalizar(_currentPokemon!.nombre)}!'
                    : 'Era ${capitalizar(_currentPokemon!.nombre)}',
                style: theme.titleMedium,
                textAlign: TextAlign.center,
              ),
              if (!won) ...[
                const SizedBox(height: 8),
                Text(
                  'Adivinaste: ${capitalizar(guessedPokemon.nombre)}',
                  style: theme.bodyMedium!.copyWith(
                    color: theme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
            const SizedBox(height: 16),
            Text(
              won
                  ? '¡Vuelve mañana para un nuevo desafío!'
                  : 'Vuelve mañana para intentarlo de nuevo',
              style: theme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  List<String> _getHints() {
    if (_currentPokemon == null) return [];

    // Preparar los tipos
    String tipoInfo = 'Desconocido';
    if (_currentPokemon!.tipos != null && _currentPokemon!.tipos!.isNotEmpty) {
      tipoInfo = _currentPokemon!.tipos!.map((t) => capitalizar(t)).join(' / ');
    }

    // Preparar la altura
    String alturaInfo = 'Desconocida';
    if (_currentPokemon!.altura != null && _currentPokemon!.altura! > 0) {
      alturaInfo = '${_currentPokemon!.altura!.toInt()} cm';
    }

    return [
      'Tipo: $tipoInfo',
      'Generación: ${_getGeneration(_currentPokemon!.id)}',
      'Altura: $alturaInfo',
    ];
  }

  String _getGeneration(int id) {
    if (id <= 151) return 'I (Kanto)';
    if (id <= 251) return 'II (Johto)';
    if (id <= 386) return 'III (Hoenn)';
    if (id <= 493) return 'IV (Sinnoh)';
    if (id <= 649) return 'V (Unova)';
    if (id <= 721) return 'VI (Kalos)';
    if (id <= 809) return 'VII (Alola)';
    if (id <= 905) return 'VIII (Galar)';
    return 'IX (Paldea)';
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final controller = context.watch<DailyTriviaController>();

    if (controller.isLoading || _currentPokemon == null) {
      return Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Center(
          child: CircularProgressIndicator(color: theme.primary),
        ),
      );
    }

    final hints = _getHints();

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

            // Imagen del Pokémon (silueta si no está completado)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.onSurface.withOpacity(0.1),
                ),
              ),
              child: Center(
                child: controller.isCompleted
                    ? Image.network(
                        _currentPokemon!.imagenUrl,
                        height: 180,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.catching_pokemon,
                          size: 100,
                          color: theme.onSurface.withOpacity(0.3),
                        ),
                      )
                    : ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                        child: Image.network(
                          _currentPokemon!.imagenUrl,
                          height: 180,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.catching_pokemon,
                            size: 100,
                            color: theme.onSurface.withOpacity(0.3),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Intentos restantes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      'Intentos: ${controller.attemptsRemaining}',
                      style: theme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      'Pistas: ${controller.hintsRevealed}/3',
                      style: theme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),

            // Pistas reveladas
            if (controller.hintsRevealed > 0) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingXs),
                        Text(
                          'Pistas:',
                          style: theme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    ...List.generate(
                      controller.hintsRevealed,
                      (index) => Padding(
                        padding: const EdgeInsets.only(
                          top: AppTheme.spacingXs,
                        ),
                        child: Text(
                          '- ${hints[index]}',
                          style: theme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),
            ],

            // Botón de pista
            if (controller.canRevealHint)
              OutlinedButton.icon(
                onPressed: () => controller.revealHint(),
                icon: const Icon(Icons.lightbulb_outline),
                label: const Text('Revelar pista'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.amber.shade700,
                  side: BorderSide(color: Colors.amber.shade700),
                ),
              ),

            if (controller.canRevealHint) const SizedBox(height: AppTheme.spacingSm),

            // Campo de búsqueda o resultado
            if (controller.isCompleted) ...[
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                decoration: BoxDecoration(
                  color: controller.hasWon
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: controller.hasWon ? Colors.green : Colors.red,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      controller.hasWon
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: controller.hasWon ? Colors.green : Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      controller.hasWon
                          ? '¡Felicitaciones!'
                          : 'Mejor suerte mañana',
                      style: theme.titleMedium!.copyWith(
                        color: controller.hasWon ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Era ${capitalizar(_currentPokemon!.nombre)}!',
                      style: theme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Campo de búsqueda con autocompletado
              Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Escribe el nombre del Pokémon...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: theme.surfaceContainer,
                    ),
                  ),
                  if (_showSuggestions && _filteredPokemons.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.onSurface.withOpacity(0.2),
                        ),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredPokemons.length,
                        itemBuilder: (context, index) {
                          final pokemon = _filteredPokemons[index];
                          return ListTile(
                            leading: Image.network(
                              pokemon.imagenUrl,
                              width: 40,
                              height: 40,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.catching_pokemon,
                              ),
                            ),
                            title: Text(capitalizar(pokemon.nombre)),
                            subtitle: Text('#${pokemon.id}'),
                            onTap: () => _makeGuess(pokemon),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
