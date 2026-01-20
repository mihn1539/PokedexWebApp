import 'package:pokedex/pages/pokedex_page.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/widgets/menu_lateral.dart';
import 'package:pokedex/utils/screen_utils.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:pokedex/utils/pokemon_constants.dart';
import 'package:pokedex/services/pokemon_api_service.dart';
import 'package:pokedex/utils/pokemon_helpers.dart';
import 'dart:math';
import 'dart:async';

class PokeGridGame extends StatefulWidget {
  final List<Pokemon> pokedex;

  const PokeGridGame({super.key, required this.pokedex});

  @override
  State<PokeGridGame> createState() => PokeGridGameState();
}

class PokeGridGameState extends State<PokeGridGame> {
  bool isGenerating = false;
  // Condiciones agrupadas de la grid (null si aún no hay configuración válida)
  GridConditions? gridConditions;
  // Conjunto de nombres válidos (lowercase) por celda después de generar la grid
  List<Set<String>>? cellValidNames;
  // Caché de candidatos precomputados durante la generación
  Map<int, List<Pokemon>>? _lastComputedCandidates;

  // Constantes movidas a PokemonConstants
  // Métodos de API movidos a PokemonApiService y PokemonCache

  String getCondicionHorizontal(int i) {
    if (gridConditions == null) return "";
    if (i < 3) return gridConditions!.horizontal[0];
    if (i < 6) return gridConditions!.horizontal[1];
    return gridConditions!.horizontal[2];
  }

  String getCondicionVertical(int i) {
    int columna = i % 3;
    if (gridConditions == null) return "";
    return gridConditions!.vertical[columna];
  }

  final int gridSize = 3;
  List<bool> disabled = List.filled(9, false);
  List<Pokemon?> pokemonsSeleccionados = List.filled(9, null);
  List<Pokemon> pokemonsusados = [];
  int intentosRestantes = 3;

  @override
  void initState() {
    super.initState();
    // Precargar datos de todos los pokémon en paralelo
    _precargaDatos();
    // Generar una grid aleatoria al entrar por primera vez
    crearnuevaGrid();
  }

  Future<void> _precargaDatos() async {
    // Cargar en paralelo los primeros 1025 pokémon (o todos si hay menos)
    final batch = widget.pokedex.take(1025).toList();
    await Future.wait([
      for (final p in batch) ...[
        PokemonCache.getTypes(p.nombre),
        PokemonCache.getMoves(p.nombre),
        PokemonCache.getStats(p.nombre),
      ],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final bool gridReady = gridConditions != null;
    
    return Scaffold(
      drawer: const MenuLateral(),
      appBar: AppBar(
        title: const Text('Pokémon Grid Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PokedexPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: theme.surface,
      body: Center(
        child: SizedBox(
          width: ScreenUtils.getGameBoardWidth(context),
          height: ScreenUtils.getGameBoardHeight(context),
          child: Container(
            decoration: BoxDecoration(
              color: theme.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              boxShadow: theme.elevatedShadow,
            ),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Top categories
                ElevatedButton.icon(
                  onPressed: isGenerating ? null : crearnuevaGrid,
                  icon: const Icon(Icons.shuffle),
                  label: const Text("Crear nueva Grid"),
                ),
                const SizedBox(height: 8),
                if (gridReady)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: intentosRestantes > 1
                          ? theme.getPokemonTypeColor('grass').withOpacity(theme.isDark ? 0.3 : 0.2)
                          : theme.error.withOpacity(theme.isDark ? 0.3 : 0.2),
                      borderRadius: theme.buttonRadius,
                      border: Border.all(
                        color: intentosRestantes > 1
                            ? theme.getPokemonTypeColor('grass')
                            : theme.error,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          color: intentosRestantes > 1
                              ? theme.getPokemonTypeColor('grass')
                              : theme.error,
                          size: 20,
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          'Intentos restantes: $intentosRestantes',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: intentosRestantes > 1
                                ? theme.getPokemonTypeColor('grass')
                                : theme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),

                Expanded(
                  child: Column(
                    children: [
                      // Encabezado de columnas (superior)
                      Row(
                        children: [
                          const SizedBox(width: 80), // Espacio para las filas
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    child: Text(
                                      gridReady
                                          ? 'Aprende\n${capitalizar(gridConditions!.vertical[0])}'
                                          : 'Generando…',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    child: Text(
                                      gridReady
                                          ? 'Stats Totales\n> ${gridConditions!.vertical[1]}'
                                          : '…',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    alignment: Alignment.center,
                                    child: Text(
                                      gridReady
                                          ? 'Resiste\n${capitalizar(gridConditions!.vertical[2])}'
                                          : '…',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Grid con etiquetas de fila
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Columna de etiquetas (filas)
                            SizedBox(
                              width: 80,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (gridReady)
                                    _CategoryIcon(
                                      icon:
                                          PokemonConstants.obtenerIconoPorTipo(
                                              gridConditions!.horizontal[0]),
                                      label: capitalizar(
                                        gridConditions!.horizontal[0],
                                      ),
                                      color: theme.getPokemonTypeColor(
                                        gridConditions!.horizontal[0],
                                      ),
                                    )
                                  else
                                    const _SkeletonCategory(),
                                  if (gridReady)
                                    _CategoryIcon(
                                      icon:
                                          PokemonConstants.obtenerIconoPorTipo(
                                              gridConditions!.horizontal[1]),
                                      label: capitalizar(
                                        gridConditions!.horizontal[1],
                                      ),
                                      color: theme.getPokemonTypeColor(
                                        gridConditions!.horizontal[1],
                                      ),
                                    )
                                  else
                                    const _SkeletonCategory(),
                                  if (gridReady)
                                    _CategoryIcon(
                                      icon:
                                          PokemonConstants.obtenerIconoPorTipo(
                                              gridConditions!.horizontal[2]),
                                      label: capitalizar(
                                        gridConditions!.horizontal[2],
                                      ),
                                      color: theme.getPokemonTypeColor(
                                        gridConditions!.horizontal[2],
                                      ),
                                    )
                                  else
                                    const _SkeletonCategory(),
                                ],
                              ),
                            ),

                            // Grid
                            Expanded(
                              child: gridReady
                                  ? LayoutBuilder(
                                      builder: (context, constraints) {
                                        // Calcular el tamaño de celda basado en el espacio disponible
                                        final gridWidth = constraints.maxWidth;
                                        final cellSize = (gridWidth / 3).clamp(
                                          60.0,
                                          150.0,
                                        );
                                        final imageSize = (cellSize * 0.6)
                                            .clamp(40.0, 80.0);

                                        return GridView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing:
                                                    constraints.maxWidth * 0.01,
                                                mainAxisSpacing:
                                                    constraints.maxHeight *
                                                    0.01,
                                                childAspectRatio: 1.0,
                                              ),
                                          itemCount: 9,
                                          itemBuilder: (context, index) {
                                            final pokemon =
                                                pokemonsSeleccionados[index];
                                            return IgnorePointer(
                                              ignoring:
                                                  disabled[index] ||
                                                  intentosRestantes <= 0,
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (intentosRestantes > 0) {
                                                    _showInputDialog(
                                                      context,
                                                      index,
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: theme.pokemonCardBackground,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    border: Border.all(
                                                      color: theme.onSurface.withOpacity(0.2),
                                                      width: 2,
                                                    ),
                                                    boxShadow: theme.cardShadow,
                                                  ),
                                                  child: Center(
                                                    child: pokemon == null
                                                        ? Icon(
                                                            Icons.add,
                                                            size:
                                                                imageSize * 0.7,
                                                            color: theme.onSurface.withOpacity(0.3),
                                                          )
                                                        : Image.network(
                                                            pokemon.imagenUrl,
                                                            height: imageSize,
                                                            width: imageSize,
                                                            fit: BoxFit.contain,
                                                            errorBuilder:
                                                                (
                                                                  _,
                                                                  __,
                                                                  ___,
                                                                ) => Icon(
                                                                  Icons
                                                                      .catching_pokemon,
                                                                  size:
                                                                      imageSize *
                                                                      0.7,
                                                                  color: theme.onSurface.withOpacity(0.5),
                                                                ),
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : Center(
                                      child: isGenerating
                                          ? CircularProgressIndicator(
                                              color: theme.primary,
                                            )
                                          : Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Text(
                                                  'Pulsa "Crear nueva Grid"',
                                                ),
                                                const SizedBox(height: 12),
                                                FilledButton.icon(
                                                  onPressed: crearnuevaGrid,
                                                  icon: const Icon(
                                                    Icons.shuffle,
                                                  ),
                                                  label: const Text('Generar'),
                                                ),
                                              ],
                                            ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Función movida a PokemonConstants.obtenerResistenciasPokemon

  Future<void> crearnuevaGrid() async {
    if (isGenerating) return;
    setState(() {
      isGenerating = true;
    });

    // Intentar generar una grid solucionable
    bool exito = false;
    String h1 = "";
    String h2 = "";
    String h3 = "";
    String v1 = "";
    String v2 = "";
    String v3 = "";

    while (!exito) {
      final numeroRandom = statsRand();
      final numeroEnString = numeroRandom.toString();

      final tiposUnicos = obtenerTiposAleatoriosUnicos(3);
      h1 = tiposUnicos[0];
      h2 = tiposUnicos[1];
      h3 = tiposUnicos[2];

      v1 = PokemonConstants.obtenerMovimientoAleatorio();
      v2 = numeroEnString;
      v3 = obtenerTipoAleatorio(excluir: {h1, h2, h3});

      final ok = await _gridHasDistinctSolution(h1, h2, h3, v1, v2, v3);
      if (ok) {
        exito = true;
        break;
      }
    }

    if (exito) {
      setState(() {
        gridConditions = GridConditions(
          horizontal: [h1, h2, h3],
          vertical: [v1, v2, v3],
        );
        pokemonsSeleccionados = List.filled(9, null);
        disabled = List.filled(9, false);
        pokemonsusados.clear();
        intentosRestantes = 3;
        isGenerating = false;
      });
      // Reutilizar candidatos ya calculados en lugar de recalcular
      if (_lastComputedCandidates != null) {
        final temp = List<Set<String>>.filled(9, <String>{}, growable: false);
        for (int i = 0; i < 9; i++) {
          temp[i] = _lastComputedCandidates![i]!
              .map((p) => p.nombre.toLowerCase())
              .toSet();
        }
        cellValidNames = temp;
      }
    } else {
      setState(() {
        isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo generar una Grid válida. Intenta de nuevo.',
            ),
          ),
        );
      }
    }
  }

  // Métodos movidos a PokemonCache

  Future<bool> _gridHasDistinctSolution(
    String h1,
    String h2,
    String h3,
    String v1,
    String v2,
    String v3,
  ) async {
    final rowTypes = [h1, h2, h3];
    final colConds = [v1, v2, v3];

    // 1. Precomputar todos los candidatos válidos por celda EN PARALELO
    final cellCandidates = <int, List<Pokemon>>{};
    final futures = <Future<void>>[];
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 3; c++) {
        final idx = r * 3 + c;
        futures.add(
          _getAllValidCandidates(rowTypes[r], c, colConds[c]).then((
            candidates,
          ) {
            cellCandidates[idx] = candidates;
          }),
        );
      }
    }
    await Future.wait(futures);

    // Verificar que todas las celdas tengan candidatos
    for (int i = 0; i < 9; i++) {
      if (cellCandidates[i]?.isEmpty ?? true) {
        _lastComputedCandidates = null;
        return false;
      }
    }

    // Guardar candidatos para reutilizar
    _lastComputedCandidates = cellCandidates;

    // 2. Ordenar celdas por cantidad de candidatos (menos opciones = más restrictiva)
    final cells = List.generate(9, (i) => i);
    cells.sort(
      (a, b) => cellCandidates[a]!.length.compareTo(cellCandidates[b]!.length),
    );

    // 3. Backtracking con candidatos precomputados
    final used = <String>{};

    bool solve(int step) {
      if (step == 9) return true;
      final cellIdx = cells[step];

      for (final p in cellCandidates[cellIdx]!) {
        final key = p.nombre.toLowerCase();
        if (used.contains(key)) continue;

        used.add(key);
        if (solve(step + 1)) return true;
        used.remove(key);
      }
      return false;
    }

    return solve(0);
  }

  Future<List<Pokemon>> _getAllValidCandidates(
    String rowType,
    int column,
    String colCond,
  ) async {
    final valid = <Pokemon>[];

    for (final candidate in widget.pokedex) {
      final tipos = await PokemonCache.getTypes(candidate.nombre);
      if (!tipos.contains(rowType)) continue;

      bool ok = false;
      if (column == 0) {
        final moves = await PokemonCache.getMoves(candidate.nombre);
        ok = moves.contains(colCond);
      } else if (column == 1) {
        final threshold = int.tryParse(colCond) ?? 0;
        final stat = await PokemonCache.getStats(candidate.nombre);
        ok = stat >= threshold;
      } else {
        final resist = PokemonConstants.obtenerResistenciasPokemon(tipos);
        ok = resist.contains(colCond);
      }

      if (ok) valid.add(candidate);
    }

    return valid;
  }

  int statsRand() {
    final random = Random();
    int rango = 175 + random.nextInt(760 - 175 + 1); // rango entre 175 y 760
    return rango;
  }

  // Método movido a PokemonApiService.fetchStats

  void _showInputDialog(BuildContext context, int index) {
    final theme = AppTheme.of(context);
    final controller = TextEditingController();
    List<Pokemon> filtered = [];
    bool showSuggestions = false;
    Timer? debounce;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            void onChanged(String text) {
              debounce?.cancel();
              debounce = Timer(const Duration(milliseconds: 300), () {
                final q = text.toLowerCase().trim();
                if (q.isEmpty) {
                  setLocalState(() {
                    filtered = [];
                    showSuggestions = false;
                  });
                  return;
                }
                final baseMatches = widget.pokedex.where(
                  (p) =>
                      p.nombre.toLowerCase().contains(q) ||
                      p.id.toString() == q,
                );
                List<Pokemon> result = baseMatches.take(12).toList();

                if (result.isEmpty) {
                  result = [
                    Pokemon(
                      id: -1,
                      nombre: 'No se encontraron resultados',
                      imagenUrl: '',
                    ),
                  ];
                }
                setLocalState(() {
                  filtered = result;
                  showSuggestions = true;
                });
              });
            }

            Future<void> onAccept() async {
              final nombrePoke = controller.text.trim().toLowerCase();
              Navigator.of(dialogContext).pop();
              try {
                final pokeEscogido = widget.pokedex.firstWhere(
                  (p) =>
                      p.nombre.toLowerCase() == nombrePoke ||
                      p.id.toString() == nombrePoke,
                  orElse: () => throw Exception('Pokemon no encontrado'),
                );
                await _tryPlacePokemon(pokeEscogido, index, context, theme);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al buscar Pokemon')),
                );
              }
            }

            return AlertDialog(
              title: const Text('Nombre del Pokémon'),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      onChanged: onChanged,
                      decoration: const InputDecoration(
                        hintText: 'Nombre o ID del Pokémon',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (showSuggestions)
                      SizedBox(
                        height: 220,
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (c, i) {
                              final p = filtered[i];
                              if (p.id == -1) {
                                return ListTile(
                                  title: Text(
                                    'No se encontraron resultados',
                                    style: TextStyle(
                                      color: theme.onSurface.withOpacity(0.5),
                                    ),
                                  ),
                                );
                              }
                              return ListTile(
                                leading: p.imagenUrl.isNotEmpty
                                    ? Image.network(
                                        p.imagenUrl,
                                        width: 40,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.error),
                                      )
                                    : const SizedBox(width: 40),
                                title: Text(p.nombre),
                                subtitle: Text('#${p.id}'),
                                onTap: () async {
                                  Navigator.of(dialogContext).pop();
                                  await _tryPlacePokemon(p, index, context, theme);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: onAccept, child: const Text('Aceptar')),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _tryPlacePokemon(
    Pokemon pokeEscogido,
    int index,
    BuildContext scaffoldContext,
    AppTheme theme,
  ) async {
    try {
      // Usar versiones cacheadas para evitar llamadas repetidas
      final tipos = await PokemonCache.getTypes(pokeEscogido.nombre);
      final movimientos = await PokemonCache.getMoves(pokeEscogido.nombre);
      final stats = await PokemonCache.getStats(pokeEscogido.nombre);
      final resistencias = PokemonConstants.obtenerResistenciasPokemon(tipos);

      if (!pokemonsusados.contains(pokeEscogido)) {
        String condicionH = getCondicionHorizontal(index);
        String condicionV = getCondicionVertical(index);
        int columna = index % 3;

        bool placed = false;
        if (!tipos.contains(condicionH)) {
          setState(() {
            intentosRestantes--;
          });

          if (intentosRestantes <= 0) {
            _showDefeatDialog(scaffoldContext);
          } else {
            ScaffoldMessenger.of(scaffoldContext).showSnackBar(
              SnackBar(
                content: Text(
                  'El Pokemon debe ser de tipo $condicionH. Intentos restantes: $intentosRestantes',
                ),
                backgroundColor: theme.error,
              ),
            );
          }
          return false;
        }

        if (columna == 0) {
          // Debe aprender el movimiento especificado
          if (movimientos.contains(condicionV)) {
            setState(() {
              pokemonsSeleccionados[index] = pokeEscogido;
              pokemonsusados.add(pokeEscogido);
              disabled[index] = true;
              placed = true;
            });
            // Validar automáticamente si la grid está completa
            if (pokemonsSeleccionados.every((p) => p != null)) {
              Future.delayed(const Duration(milliseconds: 300), () {
                _validateGrid(scaffoldContext);
              });
            }
          } else {
            setState(() {
              intentosRestantes--;
            });

            if (intentosRestantes <= 0) {
              _showDefeatDialog(scaffoldContext);
            } else {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'El Pokemon debe poder aprender $condicionV. Intentos restantes: $intentosRestantes',
                  ),
                  backgroundColor: theme.error,
                ),
              );
            }
          }
        } else if (columna == 1) {
          // Debe tener stats totales >= umbral
          final threshold = int.tryParse(condicionV) ?? 0;
          if (stats >= threshold) {
            setState(() {
              pokemonsSeleccionados[index] = pokeEscogido;
              pokemonsusados.add(pokeEscogido);
              disabled[index] = true;
              placed = true;
            });
            // Validar automáticamente si la grid está completa
            if (pokemonsSeleccionados.every((p) => p != null)) {
              Future.delayed(const Duration(milliseconds: 300), () {
                _validateGrid(scaffoldContext);
              });
            }
          } else {
            setState(() {
              intentosRestantes--;
            });

            if (intentosRestantes <= 0) {
              _showDefeatDialog(scaffoldContext);
            } else {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'El Pokemon no tiene los stats necesarios. Intentos restantes: $intentosRestantes',
                  ),
                  backgroundColor: theme.error,
                ),
              );
            }
          }
        } else {
          // Debe resistir el tipo especificado
          if (resistencias.contains(condicionV)) {
            setState(() {
              pokemonsSeleccionados[index] = pokeEscogido;
              pokemonsusados.add(pokeEscogido);
              disabled[index] = true;
              placed = true;
            });
            // Validar automáticamente si la grid está completa
            if (pokemonsSeleccionados.every((p) => p != null)) {
              Future.delayed(const Duration(milliseconds: 300), () {
                _validateGrid(scaffoldContext);
              });
            }
          } else {
            setState(() {
              intentosRestantes--;
            });

            if (intentosRestantes <= 0) {
              _showDefeatDialog(scaffoldContext);
            } else {
              ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                SnackBar(
                  content: Text(
                    'El Pokemon debe ser resistente a $condicionV. Intentos restantes: $intentosRestantes',
                  ),
                  backgroundColor: theme.error,
                ),
              );
            }
          }
        }
        return placed;
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(content: Text('Este Pokemon ya ha sido usado')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Error al validar el Pokémon')),
      );
      return false;
    }
  }

  Future<void> _validateGrid(BuildContext context) async {
    // Revalidar cada celda; si alguna falla, mostrar error general.
    bool hasError = false;
    String errorMessage = '';

    for (int index = 0; index < pokemonsSeleccionados.length; index++) {
      final p = pokemonsSeleccionados[index];
      if (p == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La Grid no está completa')),
        );
        return;
      }
      final tipos = await PokemonCache.getTypes(p.nombre);
      final movimientos = await PokemonCache.getMoves(p.nombre);
      final stats = await PokemonCache.getStats(p.nombre);
      final resistencias = PokemonConstants.obtenerResistenciasPokemon(tipos);
      final condicionH = getCondicionHorizontal(index);
      final condicionV = getCondicionVertical(index);
      final col = index % 3;
      if (!tipos.contains(condicionH)) {
        hasError = true;
        errorMessage = 'Error en celda ${index + 1}: tipo no coincide';
        break;
      }
      bool ok;
      if (col == 0) {
        ok = movimientos.contains(condicionV);
      } else if (col == 1) {
        final threshold = int.tryParse(condicionV) ?? 0;
        ok = stats >= threshold;
      } else {
        ok = resistencias.contains(condicionV);
      }
      if (!ok) {
        hasError = true;
        errorMessage =
            'Error en celda ${index + 1}: condición vertical incorrecta';
        break;
      }
    }

    // Si hay error, decrementar intentos
    if (hasError) {
      setState(() {
        intentosRestantes--;
      });

      if (intentosRestantes <= 0) {
        // Mostrar diálogo de derrota
        _showDefeatDialog(context);
      } else {
        final currentTheme = AppTheme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$errorMessage. Intentos restantes: $intentosRestantes',
            ),
            backgroundColor: currentTheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    // Todas correctas -> victoria
    _showVictoryDialog(context);
  }

  void _showVictoryDialog(BuildContext context) {
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.isDark 
                  ? [const Color(0xFFB8860B), const Color(0xFFDAA520)]
                  : [const Color(0xFFFFD700), const Color(0xFFFFA500)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                '¡VICTORIA!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¡Felicidades!',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Has completado la Grid correctamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        crearnuevaGrid();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: theme.isDark 
                            ? const Color(0xFFDAA520)
                            : const Color(0xFFFFA500),
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Jugar de nuevo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDefeatDialog(BuildContext context) {
    final theme = AppTheme.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: theme.isDark 
                  ? [const Color(0xFF8B0000), const Color(0xFFB22222)]
                  : [const Color(0xFF8B0000), const Color(0xFFDC143C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cancel, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                '¡DERROTA!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Se agotaron los intentos',
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'No has completado la Grid correctamente',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        crearnuevaGrid();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFDC143C),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Intentar de nuevo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryIcon({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// Función movida a PokemonConstants.obtenerMovimientoAleatorio()

String obtenerTipoAleatorio({Set<String>? excluir}) {
  List<String> tipos = List.from(PokemonConstants.tiposPokemon);
  // Excluir tipos si se proporcionan
  if (excluir != null && excluir.isNotEmpty) {
    tipos = tipos.where((t) => !excluir.contains(t)).toList();
  }
  final random = Random();
  int numeroRandom = random.nextInt(tipos.length);
  return tipos[numeroRandom];
}

List<String> obtenerTiposAleatoriosUnicos(
  int cantidad, {
  Set<String>? excluir,
}) {
  List<String> base = List.from(PokemonConstants.tiposPokemon);
  if (excluir != null && excluir.isNotEmpty) {
    base = base.where((t) => !excluir.contains(t)).toList();
  }
  base.shuffle();
  if (cantidad > base.length) cantidad = base.length;
  return base.take(cantidad).toList();
}

// Placeholder visual mientras se genera la grid
class _SkeletonCategory extends StatelessWidget {
  const _SkeletonCategory();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: theme.onSurface.withOpacity(0.1),
          child: Icon(Icons.help, color: theme.onSurface.withOpacity(0.4)),
        ),
        const SizedBox(height: 4),
        Container(
          width: 48,
          height: 10,
          decoration: BoxDecoration(
            color: theme.onSurface.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// Estructura que agrupa las condiciones válidas de la grid
class GridConditions {
  final List<String> horizontal; // Tipos de las filas
  final List<String>
  vertical; // Condiciones de columnas [movimiento, statsMin, tipoResist]
  const GridConditions({required this.horizontal, required this.vertical});
}
