import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  final int currentHp;
  final int maxHp;

  const HpBar({super.key, required this.currentHp, required this.maxHp});

  @override
  Widget build(BuildContext context) {
    if (maxHp == 0) return const SizedBox();

    double percentage = currentHp / maxHp;

    Color barColor = Colors.green;
    if (percentage < 0.2) {
      barColor = Colors.red;
    } else if (percentage < 0.5) {
      barColor = Colors.amber;
    }

    return Container(
      height: 24,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[600]!, width: 2),
      ),
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
                width: constraints.maxWidth * percentage,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            },
          ),
          Center(
            child: Text(
              '${(percentage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
