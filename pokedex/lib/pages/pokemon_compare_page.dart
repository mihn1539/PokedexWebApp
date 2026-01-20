import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../widgets/menu_lateral.dart';
import '../widgets/pokemon_selector.dart';
import '../widgets/pokemon_info_card.dart';
import '../widgets/empty_pokemon_placeholder.dart';
import '../widgets/pokemon_stats_radar_chart.dart';
import '../widgets/damage_calculator.dart';
import '../utils/app_theme.dart';
import '../utils/pokemon_helpers.dart';
import '../utils/pokemon_constants.dart';
import '../utils/pokemon_stat_calculator.dart';
import '../utils/screen_utils.dart';
import 'package:pokedex/pages/pokedex_page.dart';
import '../services/pokemon_type_service.dart';

class PokemonComparePage extends StatefulWidget {
  const PokemonComparePage({super.key});

  @override
  State<PokemonComparePage> createState() => _PokemonComparePageState();
}

class _PokemonComparePageState extends State<PokemonComparePage> {
  // Pokemons a comparar
  Pokemon? pokemon1;
  Pokemon? pokemon2;
  // Lista completa de Pokémons
  List<Pokemon> allPokemons = [];

  bool isLoading = true;

  // Calculadora de daño y niveles
  final TextEditingController _levelController1 = TextEditingController(
    text: '50',
  );
  final TextEditingController _levelController2 = TextEditingController(
    text: '50',
  );
  final TextEditingController _powerController = TextEditingController(
    text: '90',
  );
  int level1 = 50;
  int level2 = 50;
  String _selectedAttackType = 'normal';
  int? lastDamage;
  int? minDamage;
  int currentDefenderHp = 0;
  int maxDefenderHp = 0;
  bool hasCalculated = false;
  double killPercentage = 0.0;

  final List<String> _pokemonTypes = [
    'normal',
    'fire',
    'water',
    'grass',
    'electric',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'steel',
    'dark',
    'fairy',
  ];

  @override
  void initState() {
    super.initState();
    _loadPokemons();
    _levelController1.addListener(_level1Listener);
    _levelController2.addListener(_level2Listener);
  }

  void _level1Listener() {
    final text = _levelController1.text.trim();
    if (text.isEmpty) return;
    final value = int.tryParse(text);
    if (value != null) {
      final clampedValue = value.clamp(1, 100);
      if (clampedValue != level1) {
        setState(() {
          level1 = clampedValue;
          if (value != clampedValue) {
            _levelController1.text = clampedValue.toString();
          }
        });
      }
    }
  }

  void _level2Listener() {
    final text = _levelController2.text.trim();
    if (text.isEmpty) return;
    final value = int.tryParse(text);
    if (value != null) {
      final clampedValue = value.clamp(1, 100);
      if (clampedValue != level2) {
        setState(() {
          level2 = clampedValue;
          if (value != clampedValue) {
            _levelController2.text = clampedValue.toString();
          }
        });
      }
    }
  }

  // Cargar lista completa de Pokémons usando caché si existe
  Future<void> _loadPokemons() async {
    try {
      final cached = PokedexPage.getAllPokemons();
      if (cached.isNotEmpty) {
        allPokemons = cached;
      } else {
        allPokemons = await fetchPokemons();
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _executeBattle() {
    if (pokemon1 == null || pokemon2 == null) return;

    final level1 = int.tryParse(_levelController1.text) ?? 50;
    final level2 = int.tryParse(_levelController2.text) ?? 50;

    final baseAtk = pokemon1!.stats?['attack'] ?? 50;
    final baseDef = pokemon2!.stats?['defense'] ?? 50;
    final baseHp = pokemon2!.stats?['hp'] ?? 100;

    final atk = PokemonStatCalculator.calculateStatAtLevel(baseAtk, level1);
    final def = PokemonStatCalculator.calculateStatAtLevel(baseDef, level2);
    final hp = PokemonStatCalculator.calculateStatAtLevel(
      baseHp,
      level2,
      isHp: true,
    );

    final power = int.tryParse(_powerController.text) ?? 90;
    final attackType = _selectedAttackType;

    final defTypes = pokemon2!.tipos ?? ['normal'];
    final atkTypes = pokemon1!.tipos ?? ['normal'];

    final dmg = damageCalculation(
      atk,
      def,
      atkTypes,
      defTypes,
      attackType,
      level1,
      power,
    );

    setState(() {
      lastDamage = dmg;
      minDamage = (dmg * 0.85).toInt();
      maxDefenderHp = hp;
      currentDefenderHp = (hp - dmg) < 0 ? 0 : (hp - dmg);
      hasCalculated = true;
      killPercentage = porcentajeKill(dmg, hp);
    });
  }

  int damageCalculation(
    int attack,
    int defense,
    List<String> attackerTypes,
    List<String> defenderTypes,
    String attackType,
    int level,
    int power,
  ) {
    double bonus = 1;
    if (attackerTypes.contains(attackType)) {
      bonus = 1.5;
    }
    double effectiveness = _calculateEffectiveness(attackType, defenderTypes);

    double damage =
        (((2 * level / 5 + 2) * power * attack / defense) / 50 + 2) *
        bonus *
        effectiveness;

    return damage.toInt();
  }

  double _calculateEffectiveness(
    String attackType,
    List<String> defenderTypes,
  ) {
    double totalEffectiveness = 1.0;

    // Calcular efectividad contra cada tipo del defensor usando la tabla de PokemonConstants
    for (String defenderType in defenderTypes) {
      final key = '$attackType,$defenderType';
      final effectiveness = PokemonConstants.typeEffectiveness[key] ?? 1.0;
      totalEffectiveness *= effectiveness;
    }

    return totalEffectiveness;
  }

  double porcentajeKill(int damage, int maxHp) {
    double variance = 0.85;
    int contador = 0;
    while (variance <= 1.0) {
      if (maxHp <= damage * variance) {
        contador++;
      }
      variance += 0.01;
    }
    return (contador / 16) * 100;
  }

  @override
  void dispose() {
    _levelController1.removeListener(_level1Listener);
    _levelController2.removeListener(_level2Listener);
    _levelController1.dispose();
    _levelController2.dispose();
    _powerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      drawer: const MenuLateral(), // Agrega el botón del menú lateral
      appBar: AppBar(title: const Text('Comparador de Pokémon')),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primary))
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 800;
                // Diseño personalizado según el ancho disponible
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Center(
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 3,
                                    child: _buildSelectionSide(true),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: _buildCenterChart(
                                      constraints.maxWidth,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: _buildSelectionSide(false),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(width: 8),
                                  _buildSelectionSide(true),
                                  _buildCenterChart(constraints.maxWidth),
                                  _buildSelectionSide(false),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Construir el lado de selección de Pokémon
  Widget _buildSelectionSide(bool isLeft) {
    final pokemon = isLeft ? pokemon1 : pokemon2;
    final levelController = isLeft ? _levelController1 : _levelController2;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ScreenUtils.getHorizontalMargin(context),
        vertical: ScreenUtils.getVerticalMargin(context) * 0.3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PokemonSelector(
            allPokemons: allPokemons,
            selectedPokemon: pokemon,
            onPokemonSelected: (p) {
              setState(() {
                if (isLeft) {
                  pokemon1 = p;
                } else {
                  pokemon2 = p;
                }
              });
            },
            label: isLeft ? 'Primer Pokémon' : 'Segundo Pokémon',
            color: isLeft ? Colors.blue : Colors.red,
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 600,
            child: pokemon != null
                ? PokemonInfoCard(
                    pokemon: pokemon,
                    isLeft: isLeft,
                    level: isLeft ? level1 : level2,
                    levelController: levelController,
                  )
                : EmptyPokemonPlaceholder(isLeft: isLeft),
          ),
        ],
      ),
    );
  }

  // Construir el gráfico central de comparación
  Widget _buildCenterChart(double width) {
    // Ajustar tamaño según el ancho disponible
    final size = width < 400 ? width * 0.8 : 360.0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Comparativa',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Construir el gráfico de radar
                      const SizedBox(height: 8),
                      Expanded(
                        child: PokemonStatsRadarChart(
                          pokemon1: pokemon1,
                          pokemon2: pokemon2,
                          level1: level1,
                          level2: level2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (pokemon1 != null && pokemon2 != null) ...[
              DamageCalculator(
                pokemon1: pokemon1,
                pokemon2: pokemon2,
                levelController1: _levelController1,
                levelController2: _levelController2,
                powerController: _powerController,
                selectedAttackType: _selectedAttackType,
                pokemonTypes: _pokemonTypes,
                onAttackTypeChanged: (newValue) {
                  setState(() => _selectedAttackType = newValue);
                },
                onCalculate: _executeBattle,
                hasCalculated: hasCalculated,
                lastDamage: lastDamage,
                minDamage: minDamage,
                currentDefenderHp: currentDefenderHp,
                maxDefenderHp: maxDefenderHp,
                killPercentage: killPercentage,
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  final isDark = theme.brightness == Brightness.dark;
                  return ElevatedButton.icon(
                    onPressed: _simulateBattle,
                    icon: const Icon(Icons.flash_on, size: 28),
                    label: const Text(
                      'Simular Duelo',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      side: BorderSide(
                        color: isDark ? Colors.white : Colors.black,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Simular duelo entre los dos Pokémons
  Future<void> _simulateBattle() async {
    if (pokemon1 == null || pokemon2 == null) return;

    final p1 = pokemon1!;
    final p2 = pokemon2!;

    // Calcular efectividad de tipos
    double typeAdvantage1 = 1.0;
    double typeAdvantage2 = 1.0;

    if (p1.tipos != null &&
        p1.tipos!.isNotEmpty &&
        p2.tipos != null &&
        p2.tipos!.isNotEmpty) {
      try {
        final effectiveness1 =
            await PokemonTypeService.calculateTypeEffectiveness(p1.tipos!);
        final effectiveness2 =
            await PokemonTypeService.calculateTypeEffectiveness(p2.tipos!);

        // Verificar ventajas de tipo
        for (var tipo in p2.tipos!) {
          if (effectiveness1.debilidadX4.contains(tipo)) {
            typeAdvantage2 *= 4.0;
          } else if (effectiveness1.debilidadX2.contains(tipo)) {
            typeAdvantage2 *= 2.0;
          } else if (effectiveness1.resistenciaMitad.contains(tipo)) {
            typeAdvantage2 *= 0.5;
          } else if (effectiveness1.resistenciaUnCuarto.contains(tipo)) {
            typeAdvantage2 *= 0.25;
          } else if (effectiveness1.inmune.contains(tipo)) {
            typeAdvantage2 *= 0.0;
          }
        }

        for (var tipo in p1.tipos!) {
          if (effectiveness2.debilidadX4.contains(tipo)) {
            typeAdvantage1 *= 4.0;
          } else if (effectiveness2.debilidadX2.contains(tipo)) {
            typeAdvantage1 *= 2.0;
          } else if (effectiveness2.resistenciaMitad.contains(tipo)) {
            typeAdvantage1 *= 0.5;
          } else if (effectiveness2.resistenciaUnCuarto.contains(tipo)) {
            typeAdvantage1 *= 0.25;
          } else if (effectiveness2.inmune.contains(tipo)) {
            typeAdvantage1 *= 0.0;
          }
        }
      } catch (e) {
        // Si falla la consulta de tipos, continuar sin ventaja de tipo
      }
    }

    // Obtener estadísticas
    final stats1 = p1.stats ?? {};
    final stats2 = p2.stats ?? {};

    // Calcular poder total de combate
    final attack1 = (stats1['attack'] as num?)?.toDouble() ?? 0;
    final spAttack1 = (stats1['special-attack'] as num?)?.toDouble() ?? 0;
    final defense1 = (stats1['defense'] as num?)?.toDouble() ?? 0;
    final spDefense1 = (stats1['special-defense'] as num?)?.toDouble() ?? 0;
    final hp1 = (stats1['hp'] as num?)?.toDouble() ?? 0;
    final speed1 = (stats1['speed'] as num?)?.toDouble() ?? 0;

    final attack2 = (stats2['attack'] as num?)?.toDouble() ?? 0;
    final spAttack2 = (stats2['special-attack'] as num?)?.toDouble() ?? 0;
    final defense2 = (stats2['defense'] as num?)?.toDouble() ?? 0;
    final spDefense2 = (stats2['special-defense'] as num?)?.toDouble() ?? 0;
    final hp2 = (stats2['hp'] as num?)?.toDouble() ?? 0;
    final speed2 = (stats2['speed'] as num?)?.toDouble() ?? 0;

    // Calcular poder ofensivo y defensivo
    final offensive1 = (attack1 + spAttack1) * typeAdvantage1;
    final defensive1 = (defense1 + spDefense1 + hp1);
    final power1 = offensive1 + defensive1 + speed1 * 0.5;

    final offensive2 = (attack2 + spAttack2) * typeAdvantage2;
    final defensive2 = (defense2 + spDefense2 + hp2);
    final power2 = offensive2 + defensive2 + speed2 * 0.5;

    // Determinar ganador
    Pokemon winner;
    double winnerPower;
    double loserPower;
    String typeMessage = '';

    if (power1 > power2) {
      winner = p1;
      winnerPower = power1;
      loserPower = power2;
    } else if (power2 > power1) {
      winner = p2;
      winnerPower = power2;
      loserPower = power1;
    } else {
      // Empate, usar velocidad como desempate
      if (speed1 > speed2) {
        winner = p1;
        winnerPower = power1;
        loserPower = power2;
      } else {
        winner = p2;
        winnerPower = power2;
        loserPower = power1;
      }
    }

    // Mensaje sobre ventaja de tipo
    if (typeAdvantage1 > typeAdvantage2) {
      typeMessage =
          '${capitalizar(p1.nombre)} tiene ventaja de tipo (${typeAdvantage1.toStringAsFixed(1)}x vs ${typeAdvantage2.toStringAsFixed(1)}x)';
    } else if (typeAdvantage2 > typeAdvantage1) {
      typeMessage =
          '${capitalizar(p2.nombre)} tiene ventaja de tipo (${typeAdvantage2.toStringAsFixed(1)}x vs ${typeAdvantage1.toStringAsFixed(1)}x)';
    } else {
      typeMessage =
          'Ambos tienen el mismo multiplicador de tipo (${typeAdvantage1.toStringAsFixed(1)}x)';
    }

    final difference = ((winnerPower - loserPower) / loserPower * 100)
        .toStringAsFixed(1);

    // Mostrar diálogo con resultado
    if (!mounted) return;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flash_on, color: Colors.amber, size: 30),
            const SizedBox(width: 8),
            const Text('Resultado del Duelo'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen del ganador
              Image.network(
                winner.imagenUrl,
                height: 120,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.error, size: 100),
              ),
              const SizedBox(height: 16),
              // Nombre del ganador
              Text(
                '¡${capitalizar(winner.nombre)} gana!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Detalles
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Poder de combate:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          capitalizar(p1.nombre),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        Text(
                          power1.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: winner.nombre == p1.nombre
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          capitalizar(p2.nombre),
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                        Text(
                          power2.toStringAsFixed(1),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: winner.nombre == p2.nombre
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      typeMessage,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${capitalizar(winner.nombre)} es un $difference% más fuerte',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
