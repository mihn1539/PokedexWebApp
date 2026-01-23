import 'package:flutter/material.dart';
import 'package:pokedex/utils/translation_helpers.dart';
import 'package:pokedex/utils/app_theme.dart';
import 'package:pokedex/widgets/menu_lateral.dart';
import 'package:pokedex/widgets/type_badge.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Página que muestra la tabla de tipos de Pokémon con sus fortalezas y debilidades
class TypeChartPage extends StatefulWidget {
  const TypeChartPage({super.key});

  @override
  State<TypeChartPage> createState() => _TypeChartPageState();
}

class _TypeChartPageState extends State<TypeChartPage> {
  String? selectedType;
  Map<String, dynamic>? typeData;
  bool loading = false;
  bool initialLoading = true;
  
  // Caché de datos de tipos
  final Map<String, Map<String, dynamic>> _typeDataCache = {};

  // Lista de todos los tipos
  final List<String> allTypes = [
    'normal', 'fire', 'water', 'grass', 'electric', 'ice',
    'fighting', 'poison', 'ground', 'flying', 'psychic', 'bug',
    'rock', 'ghost', 'dragon', 'dark', 'steel', 'fairy'
  ];
  
  @override
  void initState() {
    super.initState();
    _preloadAllTypes();
  }

  /// Pre-carga todos los tipos en paralelo al inicio
  Future<void> _preloadAllTypes() async {
    setState(() {
      initialLoading = true;
    });

    try {
      // Crear todas las peticiones en paralelo
      final futures = allTypes.map((type) async {
        try {
          final url = Uri.parse('https://pokeapi.co/api/v2/type/$type');
          final response = await http.get(url);
          
          if (response.statusCode == 200) {
            _typeDataCache[type] = jsonDecode(response.body);
          }
        } catch (e) {
          // Ignorar errores individuales para no bloquear la carga completa
          debugPrint('Error cargando tipo $type: $e');
        }
      });

      // Esperar a que todas las peticiones terminen
      await Future.wait(futures);

      if (mounted) {
        setState(() {
          initialLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          initialLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar tipos: $e')),
        );
      }
    }
  }

  /// Obtiene la información de un tipo específico (ahora desde el caché)
  void _loadTypeData(String type) {
    setState(() {
      selectedType = type;
      
      // Si ya está en caché, usar inmediatamente
      if (_typeDataCache.containsKey(type)) {
        typeData = _typeDataCache[type];
        loading = false;
      } else {
        // Si no está en caché (no debería pasar), cargar
        loading = true;
        _fetchTypeDataFromApi(type);
      }
    });
  }

  /// Fallback para cargar desde la API si no está en caché
  Future<void> _fetchTypeDataFromApi(String type) async {
    try {
      final url = Uri.parse('https://pokeapi.co/api/v2/type/$type');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _typeDataCache[type] = data;
          typeData = data;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
          typeData = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al cargar datos del tipo')),
          );
        }
      }
    } catch (e) {
      setState(() {
        loading = false;
        typeData = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tabla de Tipos'),
        elevation: 0,
      ),
      drawer: const MenuLateral(),
      body: initialLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando datos de tipos...',
                    style: TextStyle(color: theme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_typeDataCache.length}/${allTypes.length} tipos',
                    style: TextStyle(
                      color: theme.onSurface.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // Área fija superior con título y desplegable
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título de la sección
                      Text(
                        'Selecciona un Tipo',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Desplegable de tipos
                      _buildTypeDropdown(theme),
                    ],
                  ),
                ),
                
                // Área scrolleable con detalles
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Información detallada del tipo seleccionado
                        if (selectedType != null) ...[
                          Text(
                            'Detalles de ${traducirTipo(selectedType!)}',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (loading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (typeData != null)
                            _buildTypeDetails(theme),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// Construye el desplegable de tipos
  Widget _buildTypeDropdown(AppTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedType,
          hint: Text(
            'Selecciona un tipo...',
            style: TextStyle(
              color: theme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: theme.primary),
          dropdownColor: theme.surface,
          borderRadius: BorderRadius.circular(12),
          items: allTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: TypeBadge(
                  type: type,
                  maxWidth: 90,
                  fontSize: 13,
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _loadTypeData(newValue);
            }
          },
        ),
      ),
    );
  }

  /// Construye los detalles del tipo seleccionado
  Widget _buildTypeDetails(AppTheme theme) {
    final damageRelations = typeData!['damage_relations'];
    
    return Column(
      children: [
        // Ataques efectivos (este tipo es fuerte contra...)
        _buildRelationSection(
          title: 'Fuerte contra (x2 daño)',
          types: (damageRelations['double_damage_to'] as List)
              .map((e) => e['name'] as String)
              .toList(),
          color: Colors.green,
          theme: theme,
        ),
        
        const SizedBox(height: 16),
        
        // Ataques débiles (este tipo es débil contra...)
        _buildRelationSection(
          title: 'Débil contra (x0.5 daño)',
          types: (damageRelations['half_damage_to'] as List)
              .map((e) => e['name'] as String)
              .toList(),
          color: Colors.orange,
          theme: theme,
        ),
        
        const SizedBox(height: 16),
        
        // No hace daño
        _buildRelationSection(
          title: 'Sin efecto contra (x0 daño)',
          types: (damageRelations['no_damage_to'] as List)
              .map((e) => e['name'] as String)
              .toList(),
          color: Colors.grey,
          theme: theme,
        ),
        
        const SizedBox(height: 24),
        
        Divider(color: theme.onSurface.withOpacity(0.24)),
        
        const SizedBox(height: 16),
        
        // Resistencias (recibe menos daño de...)
        _buildRelationSection(
          title: 'Resiste ataques de (x0.5 recibido)',
          types: (damageRelations['half_damage_from'] as List)
              .map((e) => e['name'] as String)
              .toList(),
          color: Colors.blue,
          theme: theme,
        ),
        
        const SizedBox(height: 16),
        
        // Debilidades (recibe más daño de...)
        _buildRelationSection(
          title: 'Débil a ataques de (x2 recibido)',
          types: (damageRelations['double_damage_from'] as List)
              .map((e) => e['name'] as String)
              .toList(),
          color: Colors.red,
          theme: theme,
        ),
        
        const SizedBox(height: 16),
        
        // Inmunidades (no recibe daño de...)
        _buildRelationSection(
          title: 'Inmune a ataques de (x0 recibido)',
          types: (damageRelations['no_damage_from'] as List)
              .map((e) => e['name'] as String)
              .toList(),
          color: Colors.purple,
          theme: theme,
        ),
      ],
    );
  }

  /// Construye una sección de relaciones de tipo
  Widget _buildRelationSection({
    required String title,
    required List<String> types,
    required Color color,
    required AppTheme theme,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getIconForSection(title),
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (types.isEmpty)
            Text(
              'Ninguno',
              style: TextStyle(
                color: theme.onSurface.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: types.map((type) {
                return TypeBadge(
                  type: type,
                  fontSize: 12,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Retorna el icono apropiado para cada sección
  IconData _getIconForSection(String title) {
    if (title.contains('Fuerte contra')) return Icons.arrow_upward;
    if (title.contains('Débil contra') || title.contains('Débil a')) {
      return Icons.arrow_downward;
    }
    if (title.contains('Sin efecto') || title.contains('Inmune')) {
      return Icons.shield;
    }
    if (title.contains('Resiste')) return Icons.security;
    return Icons.info_outline;
  }
}
