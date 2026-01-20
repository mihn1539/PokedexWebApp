import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pokemon.dart';
import '../utils/pokemon_stat_calculator.dart';

class PokemonStatsRadarChart extends StatelessWidget {
  final Pokemon? pokemon1;
  final Pokemon? pokemon2;
  final int level1;
  final int level2;

  const PokemonStatsRadarChart({
    super.key,
    required this.pokemon1,
    required this.pokemon2,
    required this.level1,
    required this.level2,
  });

  @override
  Widget build(BuildContext context) {
    final stats1 = pokemon1?.stats;
    final stats2 = pokemon2?.stats;

    final Map<String, double> calculatedStats1 = {};
    final Map<String, double> calculatedStats2 = {};

    if (stats1 != null) {
      final stats = PokemonStatCalculator.calculateAllStatsAtLevel(
        stats1,
        level1,
      );
      stats.forEach((key, value) {
        calculatedStats1[key] = value.toDouble();
      });
    }

    if (stats2 != null) {
      final stats = PokemonStatCalculator.calculateAllStatsAtLevel(
        stats2,
        level2,
      );
      stats.forEach((key, value) {
        calculatedStats2[key] = value.toDouble();
      });
    }

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
        tickBorderData: const BorderSide(color: Colors.grey),
        gridBorderData: const BorderSide(color: Colors.grey),
        dataSets: [
          // Dataset invisible para el mínimo
          RadarDataSet(
            dataEntries: [
              RadarEntry(value: 11),
              RadarEntry(value: 6),
              RadarEntry(value: 6),
              RadarEntry(value: 6),
              RadarEntry(value: 6),
              RadarEntry(value: 6),
            ],
            borderColor: Colors.transparent,
            fillColor: Colors.transparent,
          ),
          // Dataset invisible para el máximo
          RadarDataSet(
            dataEntries: [
              RadarEntry(value: 714),
              RadarEntry(value: 526),
              RadarEntry(value: 526),
              RadarEntry(value: 526),
              RadarEntry(value: 526),
              RadarEntry(value: 526),
            ],
            borderColor: Colors.transparent,
            fillColor: Colors.transparent,
          ),
          RadarDataSet(
            fillColor: Colors.blue.withOpacity(0.5),
            borderColor: Colors.blue,
            entryRadius: 2,
            dataEntries: [
              RadarEntry(value: calculatedStats1['hp'] ?? 0),
              RadarEntry(value: calculatedStats1['attack'] ?? 0),
              RadarEntry(value: calculatedStats1['defense'] ?? 0),
              RadarEntry(value: calculatedStats1['special-attack'] ?? 0),
              RadarEntry(value: calculatedStats1['special-defense'] ?? 0),
              RadarEntry(value: calculatedStats1['speed'] ?? 0),
            ],
          ),
          RadarDataSet(
            fillColor: Colors.red.withOpacity(0.5),
            borderColor: Colors.red,
            entryRadius: 2,
            dataEntries: [
              RadarEntry(value: calculatedStats2['hp'] ?? 0),
              RadarEntry(value: calculatedStats2['attack'] ?? 0),
              RadarEntry(value: calculatedStats2['defense'] ?? 0),
              RadarEntry(value: calculatedStats2['special-attack'] ?? 0),
              RadarEntry(value: calculatedStats2['special-defense'] ?? 0),
              RadarEntry(value: calculatedStats2['speed'] ?? 0),
            ],
          ),
        ],
        titleTextStyle: const TextStyle(fontSize: 12),
        getTitle: (index, angle) {
          return switch (index) {
            0 => RadarChartTitle(text: 'PS'),
            1 => RadarChartTitle(text: 'Ataque'),
            2 => RadarChartTitle(text: 'Defensa'),
            3 => RadarChartTitle(text: 'At. Esp.'),
            4 => RadarChartTitle(text: 'Def. Esp.'),
            5 => RadarChartTitle(text: 'Velocidad'),
            _ => RadarChartTitle(text: ''),
          };
        },
      ),
    );
  }
}
