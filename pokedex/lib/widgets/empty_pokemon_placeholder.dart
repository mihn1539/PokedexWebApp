import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../utils/screen_utils.dart';

class EmptyPokemonPlaceholder extends StatelessWidget {
  final bool isLeft;

  const EmptyPokemonPlaceholder({super.key, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: (isLeft ? Colors.blue : Colors.red).withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: (isLeft ? Colors.blue : Colors.red).withOpacity(0.02),
      ),
      margin: EdgeInsets.symmetric(
        horizontal: ScreenUtils.getHorizontalMargin(context) * 0.5,
      ),
      padding: EdgeInsets.all(ScreenUtils.getHorizontalMargin(context)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.catching_pokemon,
              size: 80,
              color: (isLeft ? Colors.blue : Colors.red).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isLeft
                  ? 'Selecciona el primer Pokémon'
                  : 'Selecciona el segundo Pokémon',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: context.colors.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Busca por nombre o número',
              style: TextStyle(
                fontSize: 12,
                color: context.colors.onSurface.withOpacity(0.3),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
