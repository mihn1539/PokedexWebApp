import 'package:flutter/material.dart';
import 'package:pokedex/models/gym_leader.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/services/gym_leader_service.dart';
import 'package:pokedex/widgets/type_badge.dart';
import 'package:pokedex/widgets/menu_lateral.dart';
import 'package:pokedex/pages/pokemon_detail_page.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GymLeadersPage extends StatefulWidget {
  const GymLeadersPage({super.key});

  @override
  State<GymLeadersPage> createState() => _GymLeadersPageState();
}

class _GymLeadersPageState extends State<GymLeadersPage> {
  String selectedRegion = 'Kanto';
  List<GymLeader> gymLeaders = [];

  @override
  void initState() {
    super.initState();
    _loadGymLeaders();
  }

  void _loadGymLeaders() {
    setState(() {
      gymLeaders = GymLeaderService.getGymLeadersByRegion(selectedRegion);
    });
  }

  // Función helper para cargar un Pokémon completo desde la API
  Future<Pokemon?> _fetchPokemonById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("https://pokeapi.co/api/v2/pokemon/$id"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pokemon = Pokemon.detailed(data);
        await pokemon.cargarSp();
        await pokemon.cargarLocaciones();
        await pokemon.cargarDebilidades();
        await pokemon.cargarDescripcionHabilidades();
        return pokemon;
      }
    } catch (e) {
      // Error al cargar el Pokémon
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar el Pokémon')),
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Líderes de Gimnasio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const MenuLateral(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.primary.withOpacity(0.1), theme.surface],
          ),
        ),
        child: Column(
          children: [
            // Selector de región
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.pokemonCardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Región:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.onSurface,
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedRegion,
                    dropdownColor: theme.pokemonCardBackground,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.primary,
                    ),
                    underline: Container(),
                    items: GymLeaderService.getAvailableRegions().map((region) {
                      return DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedRegion = value;
                          _loadGymLeaders();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),

            // Lista de líderes
            Expanded(
              child: gymLeaders.isEmpty
                  ? Center(
                      child: Text(
                        'No hay líderes disponibles para esta región',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: gymLeaders.length,
                      itemBuilder: (context, index) {
                        final leader = gymLeaders[index];
                        return _buildGymLeaderCard(leader, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymLeaderCard(GymLeader leader, AppTheme theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.pokemonCardBackground,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showGymLeaderDetails(leader),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado del líder
              Row(
                children: [
                  // Número del gimnasio
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: theme.getPokemonTypeColor(
                        leader.tipo.toLowerCase(),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${leader.orden}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Nombre y ciudad
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leader.nombre,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.onSurface,
                          ),
                        ),
                        Text(
                          leader.ciudad,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tipo
                  TypeBadge(type: leader.tipo.toLowerCase(), fontSize: 14),
                ],
              ),
              const SizedBox(height: 12),

              // Medalla
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme
                      .getPokemonTypeColor(leader.tipo.toLowerCase())
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.military_tech,
                      size: 16,
                      color: theme.getPokemonTypeColor(
                        leader.tipo.toLowerCase(),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      leader.medalla,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: theme.getPokemonTypeColor(
                          leader.tipo.toLowerCase(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Equipo Pokémon
              Text(
                'Equipo:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: leader.equipo.map((pokemon) {
                  return _buildPokemonChip(pokemon, theme);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonChip(GymPokemon pokemon, AppTheme theme) {
    return InkWell(
      onTap: () async {
        // Necesitamos cargar el Pokémon completo desde la API
        final pokemonCompleto = await _fetchPokemonById(pokemon.pokemonId);
        if (pokemonCompleto != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PokemonDetailPage(pokemon: pokemonCompleto),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.pokemonCardBackground,
          border: Border.all(color: theme.primary.withOpacity(0.3), width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen del Pokémon
            Image.network(
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.pokemonId}.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.catching_pokemon, size: 32);
              },
            ),
            const SizedBox(width: 8),
            // Nombre y nivel
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pokemon.nombre,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.onSurface,
                  ),
                ),
                Text(
                  'Nv. ${pokemon.nivel}',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGymLeaderDetails(GymLeader leader) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildGymLeaderDetailsSheet(leader),
    );
  }

  Widget _buildGymLeaderDetailsSheet(GymLeader leader) {
    final theme = AppTheme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.pokemonCardBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: theme.getPokemonTypeColor(
                                leader.tipo.toLowerCase(),
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${leader.orden}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leader.nombre,
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: theme.onSurface,
                                  ),
                                ),
                                Text(
                                  leader.ciudad,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Información
                      _buildDetailRow(
                        'Tipo:',
                        TypeBadge(type: leader.tipo.toLowerCase()),
                        theme,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        'Medalla:',
                        Text(
                          leader.medalla,
                          style: TextStyle(color: theme.onSurface),
                        ),
                        theme,
                      ),

                      if (leader.descripcion != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          leader.descripcion!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.onSurface.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      Text(
                        'Equipo Pokémon',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Lista detallada del equipo
                      ...leader.equipo.map((pokemon) {
                        return _buildPokemonDetailCard(
                          pokemon,
                          leader.tipo,
                          theme,
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, Widget value, AppTheme theme) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        value,
      ],
    );
  }

  Widget _buildPokemonDetailCard(
    GymPokemon pokemon,
    String leaderType,
    AppTheme theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.surface,
      child: InkWell(
        onTap: () async {
          // Necesitamos cargar el Pokémon completo desde la API
          final pokemonCompleto = await _fetchPokemonById(pokemon.pokemonId);
          if (pokemonCompleto != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PokemonDetailPage(pokemon: pokemonCompleto),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen
              Image.network(
                'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.pokemonId}.png',
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.catching_pokemon, size: 60);
                },
              ),
              const SizedBox(width: 16),
              // Detalles
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pokemon.nombre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme
                            .getPokemonTypeColor(leaderType.toLowerCase())
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Nivel ${pokemon.nivel}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.getPokemonTypeColor(
                            leaderType.toLowerCase(),
                          ),
                        ),
                      ),
                    ),
                    if (pokemon.movimientos != null &&
                        pokemon.movimientos!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: pokemon.movimientos!.map((move) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.onSurface.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              move,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
