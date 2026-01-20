/// Utilidades para calcular estadísticas de Pokémon
class PokemonStatCalculator {
  /// Calcula una estadística de un Pokémon a un nivel específico
  ///
  /// Usa la fórmula estándar de cálculo de estadísticas de Pokémon:
  /// - Para HP: ((2 * baseStat + IV + EV/4) * level / 100) + level + 10
  /// - Para otras stats: (((2 * baseStat + IV + EV/4) * level / 100) + 5) * nature
  ///
  /// Por defecto usa IV=15, EV=0 y nature=1.0
  static int calculateStatAtLevel(
    int baseStat,
    int level, {
    bool isHp = false,
  }) {
    const int iv = 15;
    const int ev = 0;
    const double nature = 1.0;

    if (isHp) {
      return ((2 * baseStat + iv + (ev / 4).floor()) * level / 100).floor() +
          level +
          10;
    } else {
      return ((((2 * baseStat + iv + (ev / 4).floor()) * level / 100).floor() +
                  5) *
              nature)
          .toInt();
    }
  }

  /// Calcula todas las estadísticas de un Pokémon a un nivel específico
  static Map<String, int> calculateAllStatsAtLevel(
    Map<String, dynamic> baseStats,
    int level,
  ) {
    final Map<String, int> calculatedStats = {};

    baseStats.forEach((key, baseStat) {
      calculatedStats[key] = calculateStatAtLevel(
        baseStat as int,
        level,
        isHp: key == 'hp',
      );
    });

    return calculatedStats;
  }
}
