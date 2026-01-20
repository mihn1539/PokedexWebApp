import 'package:pokedex/models/pokemon_encuentros.dart';
import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'pokemon_info_basica.dart';
import 'pokemon_combate_info.dart';
import 'pokemon_specie_info.dart';

class PokemonDetailView extends StatefulWidget {
  final Pokemon pokemon;
  const PokemonDetailView({super.key, required this.pokemon});

  @override
  State<PokemonDetailView> createState() => _PokemonDetailViewState();
}

class _PokemonDetailViewState extends State<PokemonDetailView> {
  int estadoActual = 0;

  @override
  Widget build(BuildContext context) {
    Widget contenido;

    
    switch (estadoActual) {
      case 0:
        contenido = PokemonInfoBasica(pokemon: widget.pokemon);
        break;
      case 1:
        contenido = PokemonCombateInfo(pokemon: widget.pokemon);
        break;
      case 2:
        contenido = PokemonSpecieInfo(pokemon: widget.pokemon);
        break;
      case 3:
        contenido = PokemonEncuentros(pokemon:  widget.pokemon);
        break;
      default:
        contenido = const SizedBox.shrink();
    }

    return Scaffold(
      
      body: contenido, 
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.amber,
        unselectedItemColor: const Color.fromARGB(179, 0, 0, 0),
        currentIndex: estadoActual,
        onTap: (index) {
          setState(() {
            estadoActual = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "Información",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Combate",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories), 
            label: "Especie",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: "Encuentros",
          ),
        ],
      ),
    );
  }

  String capitalizar(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
