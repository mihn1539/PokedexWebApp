import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../utils/pokemon_helpers.dart';
import '../utils/pokemon_stat_calculator.dart';
import '../utils/screen_utils.dart';

class PokemonInfoCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool isLeft;
  final int level;
  final TextEditingController levelController;

  const PokemonInfoCard({
    super.key,
    required this.pokemon,
    required this.isLeft,
    required this.level,
    required this.levelController,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, int> calculatedStats = {};

    if (pokemon.stats != null) {
      calculatedStats.addAll(
        PokemonStatCalculator.calculateAllStatsAtLevel(pokemon.stats!, level),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isLeft ? Colors.blue.shade700 : Colors.red.shade700,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
        color: (isLeft ? Colors.blue : Colors.red).withOpacity(0.05),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtils.getHorizontalMargin(context) * 0.5,
      ),
      padding: EdgeInsets.all(ScreenUtils.getHorizontalMargin(context)),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Image.network(
            pokemon.imagenUrl,
            height: 150,
            errorBuilder: (_, __, ___) => const Icon(Icons.error, size: 100),
          ),
          const SizedBox(height: 8),
          Text('#${pokemon.id}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            capitalizar(pokemon.nombre),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (pokemon.tipos != null)
            Wrap(
              children: pokemon.tipos!.map((tipo) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Image.network(
                    getTipoSpriteUrl(tipo),
                    height: 30,
                    errorBuilder: (_, __, ___) => const Icon(Icons.error),
                  ),
                );
              }).toList(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Nivel: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 60,
                  child: TextField(
                    controller: levelController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (calculatedStats.isNotEmpty)
            Card(
              color: isLeft ? Colors.blue[400] : Colors.red[400],
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: calculatedStats.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(capitalizar(entry.key)),
                          Text(entry.value.toString()),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
