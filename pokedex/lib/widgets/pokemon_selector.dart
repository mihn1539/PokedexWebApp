import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import '../models/pokemon.dart';
import '../utils/pokemon_helpers.dart';
import '../utils/app_theme.dart';

class PokemonSelector extends StatefulWidget {
  final List<Pokemon> allPokemons;
  final Pokemon? selectedPokemon;
  final Function(Pokemon?) onPokemonSelected;
  final String label;
  final Color color;

  const PokemonSelector({
    super.key,
    required this.allPokemons,
    required this.selectedPokemon,
    required this.onPokemonSelected,
    required this.label,
    required this.color,
  });

  @override
  State<PokemonSelector> createState() => _PokemonSelectorState();
}

class _PokemonSelectorState extends State<PokemonSelector> {
  final TextEditingController _controller = TextEditingController();
  List<Pokemon> _filtered = [];
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_controllerListener);
  }

  void _controllerListener() {
    if (_controller.text.trim().isEmpty) {
      widget.onPokemonSelected(null);
      setState(() {
        _filtered = [];
        _showSuggestions = false;
      });
    }
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(text);
    });
  }

  void _performSearch(String text) {
    final q = text.toLowerCase().trim();
    if (q.isEmpty) {
      setState(() {
        _filtered = [];
        _showSuggestions = false;
      });
      return;
    }

    final matches = widget.allPokemons
        .where((p) {
          return p.nombre.toLowerCase().contains(q) || p.id.toString() == q;
        })
        .take(12)
        .toList();

    setState(() {
      if (matches.isEmpty) {
        _filtered = [
          Pokemon(
            id: -1,
            nombre: "No se encontraron resultados",
            imagenUrl: '',
          ),
        ];
      } else {
        _filtered = matches;
      }
      _showSuggestions = true;
    });
  }

  Future<void> _selectPokemon(Pokemon p) async {
    final response = await http.get(
      Uri.parse("https://pokeapi.co/api/v2/pokemon/${p.id}"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final detailed = Pokemon.detailed(data);
      widget.onPokemonSelected(detailed);
      _controller.text = capitalizar(detailed.nombre);
      setState(() {
        _showSuggestions = false;
        _filtered = [];
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            labelText: widget.label,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                widget.onPokemonSelected(null);
                _controller.clear();
                setState(() {
                  _filtered = [];
                  _showSuggestions = false;
                });
              },
            ),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        if (_showSuggestions) _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    return SizedBox(
      height: 200,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: ListView.separated(
          itemCount: _filtered.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final p = _filtered[index];
            if (p.id == -1) {
              return ListTile(
                title: Text(
                  'No se encontraron resultados',
                  style: TextStyle(
                    color: context.colors.onSurface.withOpacity(0.5),
                  ),
                ),
              );
            }
            return ListTile(
              leading: Image.network(
                p.imagenUrl,
                width: 40,
                errorBuilder: (_, __, ___) => const Icon(Icons.error),
              ),
              title: Text(capitalizar(p.nombre)),
              subtitle: Text('#${p.id}'),
              onTap: () => _selectPokemon(p),
            );
          },
        ),
      ),
    );
  }
}
