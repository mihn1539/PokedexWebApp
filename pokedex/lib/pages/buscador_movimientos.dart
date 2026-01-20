import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pokedex/models/movimientos.dart';
import 'package:pokedex/models/movimiento_detail_view.dart';
import 'package:pokedex/models/filtros_movimientos.dart';
import 'package:pokedex/widgets/menu_lateral.dart';
import '../utils/app_theme.dart';
import '../utils/pokemon_helpers.dart';
import '../utils/translation_helpers.dart';
import '../utils/screen_utils.dart';



class BuscadorMovimientos extends StatefulWidget {
  @override
  _BuscadorMovimientosState createState() => _BuscadorMovimientosState();
}

class _BuscadorMovimientosState extends State<BuscadorMovimientos> {
  List<Map<String, dynamic>> movimientos = [];
  List<Map<String, dynamic>> filtrados = [];
  bool cargando = true;
  final TextEditingController _textController = TextEditingController();
  MovimientoFilters filtrosMovimiento = MovimientoFilters();
  
  String? selectedTipoDisplay;
  String? selectedCategoriaDisplay;

  @override
  void initState() {
    super.initState();
    selectedTipoDisplay = 'Todos los tipos';
    selectedCategoriaDisplay = 'Todas las categorías';
    cargarMovimientos();
  }

  Future<void> cargarMovimientos() async {
    setState(() => cargando = true);
    
    try {
      final url = Uri.parse("https://pokeapi.co/api/v2/move?limit=2000");
      final res = await http.get(url);

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        List<Map<String, dynamic>> movimientosConDetalles = [];
        
        // Cargar detalles de todos los movimientos en paralelo (máximo 50 a la vez para no saturar)
        final movimientosList = data['results'] as List;
        
        for (int i = 0; i < movimientosList.length; i += 50) {
          final batch = movimientosList.skip(i).take(50).toList();
          final futures = batch.map((mov) async {
            try {
              final response = await http.get(Uri.parse(mov['url']));
              if (response.statusCode == 200) {
                final detalle = json.decode(response.body);
                return {
                  'name': mov['name'],
                  'url': mov['url'],
                  'tipo': detalle['type']['name'],
                  'categoria': detalle['damage_class']['name'],
                };
              }
            } catch (e) {
              // En caso de error, retornar con valores null
            }
            return {
              'name': mov['name'],
              'url': mov['url'],
              'tipo': null,
              'categoria': null,
            };
          }).toList();
          
          final results = await Future.wait(futures);
          movimientosConDetalles.addAll(results);
          
          // Actualizar UI progresivamente
          setState(() {
            movimientos = List.from(movimientosConDetalles);
            filtrados = movimientos;
          });
        }
        
        setState(() => cargando = false);
      }
    } catch (e) {
      setState(() => cargando = false);
    }
  }

  void aplicarFiltros() {
    setState(() {
      // Primero aplicar filtros de tipo y categoría
      List<Map<String, dynamic>> resultado = filtrosMovimiento.applyFilters(movimientos);
      
      // Luego aplicar búsqueda por texto si existe
      if (_textController.text.isNotEmpty) {
        resultado = resultado.where((m) {
          return m['name'].toLowerCase().contains(_textController.text.toLowerCase());
        }).toList();
      }
      
      filtrados = resultado;
    });
  }

  void filtrar(String texto) {
    aplicarFiltros();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return Scaffold(
      drawer: MenuLateral(),
      appBar: AppBar(
        title: const Text('Buscador de Movimientos'),
      ),
      body: cargando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Cargando movimientos...',
                    style: theme.bodyLarge,
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtils.getHorizontalMargin(context),
                    vertical: ScreenUtils.getVerticalMargin(context) * 0.5,
                  ),
                  child: TextField(
                    controller: _textController,
                    onChanged: filtrar,
                    decoration: InputDecoration(
                      labelText: "Buscar movimiento",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _textController.clear();
                        },
                      ),
                    ),
                  ),
                ),
                
                // Widget de expansión para filtros (estilo Pokédex)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtils.getHorizontalMargin(context),
                  ),
                  child: ExpansionTile(
                    title: const Text('Filtros'),
                    leading: const Icon(Icons.filter_list),
                    trailing: filtrosMovimiento.hasActiveFilters
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const SizedBox(
                                width: 8,
                                height: 8,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.expand_more),
                          ],
                        )
                      : null,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Tipo',
                                border: OutlineInputBorder(),
                              ),
                              items: tiposEspanol.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              initialValue:
                               selectedTipoDisplay ?? 'Todos los tipos',
                              onChanged: (String? newValue) {
                                final apiType = spanishToApiType[newValue];
                                setState(() {
                                  selectedTipoDisplay = newValue;
                                  filtrosMovimiento.tipo = apiType;
                                  aplicarFiltros();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Filtro de Categoría
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'Categoría',
                                border: OutlineInputBorder(),
                              ),
                              items: <String>[
                                'Todas las categorías',
                                'Físico',
                                'Especial',
                                'Estado',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              initialValue: selectedCategoriaDisplay ?? 'Todas las categorías',
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCategoriaDisplay = newValue;
                                  if (newValue == 'Todas las categorías') {
                                    filtrosMovimiento.categoria = null;
                                  } else {
                                    // Mapear de español a API
                                    filtrosMovimiento.categoria = {
                                      'Físico': 'physical',
                                      'Especial': 'special',
                                      'Estado': 'status',
                                    }[newValue];
                                  }
                                  aplicarFiltros();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Botón para limpiar filtros
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: ScreenUtils.getMaxFormWidth(context),
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              filtrosMovimiento.resetFilters();
                              selectedTipoDisplay = 'Todos los tipos';
                              selectedCategoriaDisplay = 'Todas las categorías';
                              aplicarFiltros();
                            });
                          },
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Limpiar filtros'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ],
                  ),
                ),

                Expanded(
                  child: filtrados.isEmpty
                      ? Center(
                          child: Text(
                            'No se encontraron movimientos',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtils.getHorizontalMargin(context),
                            vertical: ScreenUtils.getVerticalMargin(context) * 0.3,
                          ),
                          itemCount: filtrados.length,
                          itemBuilder: (context, index) {
                            final mov = filtrados[index];
                            final nombreCapitalizado = capitalizar(mov['name'].replaceAll('-', ' '));
                            final tipoTraducido = mov['tipo'] != null ? traducirTipo(mov['tipo']) : null;
                            final categoriaTraducida = mov['categoria'] != null ? traducirCategoria(mov['categoria']) : null;
                            
                            return Card(
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                vertical: ScreenUtils.getVerticalMargin(context) * 0.2,
                                horizontal: ScreenUtils.getHorizontalMargin(context) * 0.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final movimiento = await fetchMovimiento(mov['name']);
                                  
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MovimientoDetailView(movimiento: movimiento),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      // Icono del movimiento
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: theme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.auto_awesome,
                                          color: theme.primary,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Información del movimiento
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nombreCapitalizado,
                                              style: theme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            if (tipoTraducido != null && categoriaTraducida != null)
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: theme.getPokemonTypeColor(mov['tipo']),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      tipoTraducido,
                                                      style: theme.bodyMedium?.copyWith(
                                                        fontSize: 12,
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: theme.secondary.withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      categoriaTraducida,
                                                      style: theme.bodyMedium?.copyWith(
                                                        fontSize: 12,
                                                        color: theme.secondary,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Text(
                                                'Cargando...',
                                                style: theme.bodyMedium?.copyWith(
                                                  fontSize: 12,
                                                  color: theme.onSurface.withOpacity(0.5),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Icono de flecha
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
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

