import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../utils/pokemon_helpers.dart';
import 'hp_bar.dart';

class DamageCalculator extends StatelessWidget {
  final Pokemon? pokemon1;
  final Pokemon? pokemon2;
  final TextEditingController levelController1;
  final TextEditingController levelController2;
  final TextEditingController powerController;
  final String selectedAttackType;
  final List<String> pokemonTypes;
  final Function(String) onAttackTypeChanged;
  final Function() onCalculate;
  final bool hasCalculated;
  final int? lastDamage;
  final int? minDamage;
  final int currentDefenderHp;
  final int maxDefenderHp;
  final double killPercentage;

  const DamageCalculator({
    super.key,
    required this.pokemon1,
    required this.pokemon2,
    required this.levelController1,
    required this.levelController2,
    required this.powerController,
    required this.selectedAttackType,
    required this.pokemonTypes,
    required this.onAttackTypeChanged,
    required this.onCalculate,
    required this.hasCalculated,
    required this.lastDamage,
    required this.minDamage,
    required this.currentDefenderHp,
    required this.maxDefenderHp,
    required this.killPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Calculadora de Daño',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: levelController1,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nivel ${pokemon1?.nombre ?? "P1"}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: levelController2,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nivel ${pokemon2?.nombre ?? "P2"}',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: powerController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Poder del Movimiento',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedAttackType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Ataque',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: pokemonTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(capitalizar(type)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onAttackTypeChanged(newValue);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCalculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calcular Daño'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            if (hasCalculated) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Daño: $minDamage - $lastDamage',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'HP Defensor: $currentDefenderHp / $maxDefenderHp',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              Text(
                'Probabilidad de KO: ${killPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              HpBar(currentHp: currentDefenderHp, maxHp: maxDefenderHp),
            ],
          ],
        ),
      ),
    );
  }
}
