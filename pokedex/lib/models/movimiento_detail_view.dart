import 'package:flutter/material.dart';
import 'movimientos.dart';
import 'detalle_movimientos.dart';
import 'movimientos_aprendidos.dart';
import '../utils/app_theme.dart';
import '../utils/pokemon_helpers.dart';

class MovimientoDetailView extends StatefulWidget {
  final Movimiento movimiento;
  const MovimientoDetailView({super.key, required this.movimiento});

  @override
  State<MovimientoDetailView> createState() => _PokemonDetailViewState();
}

class _PokemonDetailViewState extends State<MovimientoDetailView> {
  int estadoActual = 0;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    Widget contenido;

    
    switch (estadoActual) {
      case 0:
        contenido = DetalleMovimiento(movimiento: widget.movimiento);
        break;
      case 1:
        contenido = MovimientosAprendidos(movimiento: widget.movimiento);
        break;
      
      default:
        contenido = const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(capitalizar(widget.movimiento.nombre)),
      ),
      body: SingleChildScrollView(
        child: contenido,
      ), 
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: theme.primary,
        unselectedItemColor: theme.onSurface.withOpacity(0.6),
        backgroundColor: theme.surface,
        currentIndex: estadoActual,
        onTap: (index) {
          setState(() {
            estadoActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: "Información",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.catching_pokemon_outlined),
            activeIcon: Icon(Icons.catching_pokemon),
            label: "Pokémon",
          ),
        ],
      ),
    );
  }
}