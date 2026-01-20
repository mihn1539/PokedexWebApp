import 'package:flutter/material.dart';
import 'pokemon.dart';
import 'movimientos.dart';
import 'movimiento_detail_view.dart';
import '../utils/app_theme.dart';
import '../utils/pokemon_helpers.dart';
import '../utils/translation_helpers.dart';

class PokemonEncuentros extends StatefulWidget {
  final Pokemon pokemon;
  const PokemonEncuentros({super.key, required this.pokemon});

  @override
  State<PokemonEncuentros> createState() => _PokemonEncuentrosState();
}

class _PokemonEncuentrosState extends State<PokemonEncuentros> {
  final Map<String, Movimiento> _movimientosCargados = {};
  bool _cargandoMovimientos = true;

  @override
  void initState() {
    super.initState();
    _cargarMovimientosEnBatch();
  }

  Future<void> _cargarMovimientosEnBatch() async {
    final ataques = widget.pokemon.ataques;
    if (ataques == null || ataques.isEmpty) {
      setState(() => _cargandoMovimientos = false);
      return;
    }

    // Obtener lista única de nombres de movimientos
    final nombresUnicos = ataques.keys.toSet();
    
    // Cargar todos los movimientos en paralelo (limitando a 10 a la vez)
    final futures = <Future<void>>[];
    final nombres = nombresUnicos.toList();
    
    for (int i = 0; i < nombres.length; i += 10) {
      final batch = nombres.skip(i).take(10);
      for (final nombre in batch) {
        futures.add(
          fetchMovimiento(nombre).then((mov) {
            if (mounted) {
              _movimientosCargados[nombre] = mov;
            }
          }).catchError((_) {
            // Ignorar errores individuales
          })
        );
      }
      // Esperar que termine cada batch antes de continuar
      await Future.wait(futures);
      futures.clear();
      
      // Actualizar UI después de cada batch
      if (mounted) {
        setState(() {});
      }
    }
    
    if (mounted) {
      setState(() => _cargandoMovimientos = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final lugares = widget.pokemon.lugaresDeCaptura;
    final ataques = widget.pokemon.ataques;
    
    // Crear lista única de movimientos (sin duplicados, sin separación por versión)
    Set<String> nombresUnicos = {};
    List<Map<String, dynamic>> movimientosUnicos = [];
    
    ataques?.forEach((nombre, data) {
      if (!nombresUnicos.contains(nombre)) {
        nombresUnicos.add(nombre);
        // Obtener info del primer registro para nivel y método
        final detalles = data["version_groups"] as List;
        if (detalles.isNotEmpty) {
          final movCargado = _movimientosCargados[nombre];
          movimientosUnicos.add({
            "nombre": nombre,
            "tipo": movCargado?.tipo,
            "categoria": movCargado?.categoria,
            "level": detalles[0]["level"],
            "method": detalles[0]["method"],
          });
        }
      }
    });
    
    // Ordenar por nivel (nulos al final) y luego por nombre
    movimientosUnicos.sort((a, b) {
      final levelA = a["level"] as int?;
      final levelB = b["level"] as int?;
      
      // Si ambos tienen nivel, ordenar por nivel
      if (levelA != null && levelB != null) {
        final nivelComparison = levelA.compareTo(levelB);
        if (nivelComparison != 0) return nivelComparison;
        // Si tienen el mismo nivel, ordenar por nombre
        return a["nombre"].toString().compareTo(b["nombre"].toString());
      }
      
      // Los que tienen nivel van primero
      if (levelA != null && levelB == null) return -1;
      if (levelA == null && levelB != null) return 1;
      
      // Si ninguno tiene nivel, ordenar por nombre
      return a["nombre"].toString().compareTo(b["nombre"].toString());
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card para lugares de captura
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.location_on, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Lugares de captura',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),
                  Wrap(
                    spacing: 6.0,
                    runSpacing: 6.0,
                    children: (lugares?.entries.map((entry) {
                          final lugar = entry.key.replaceAll('-', ' ');
                          final versiones = entry.value.join(', ');
                          return Chip(
                            avatar: const Icon(Icons.place, size: 16),
                            label: Text(
                              '$lugar (${versiones.isEmpty ? "sin versiones" : versiones})',
                              style: const TextStyle(fontSize: 13.0),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          );
                        }).toList()) ??
                        [
                          const Text('No se encontraron lugares de captura.', 
                            style: TextStyle(fontSize: 14.0)),
                        ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12.0),

          // Card para ataques
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flash_on, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Ataques aprendidos por ${widget.pokemon.nombre}',
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${movimientosUnicos.length} movimientos',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: theme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  
                  // Lista de movimientos estilo buscador
                  if (_cargandoMovimientos && movimientosUnicos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ...movimientosUnicos.map((mov) {
                      final nombreCapitalizado = capitalizar(mov["nombre"]);
                      final tipoTraducido = mov["tipo"] != null 
                          ? traducirTipo(mov["tipo"]) 
                          : null;
                      final categoriaTraducida = mov["categoria"] != null 
                          ? traducirCategoria(mov["categoria"]) 
                          : null;
                      
                      return _MovimientoCardStatic(
                        nombre: mov["nombre"],
                        nombreCapitalizado: nombreCapitalizado,
                        nivel: mov["level"],
                        tipo: mov["tipo"],
                        categoria: mov["categoria"],
                        tipoTraducido: tipoTraducido,
                        categoriaTraducida: categoriaTraducida,
                      );
                    })
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovimientoCardStatic extends StatelessWidget {
  final String nombre;
  final String nombreCapitalizado;
  final dynamic nivel;
  final String? tipo;
  final String? categoria;
  final String? tipoTraducido;
  final String? categoriaTraducida;

  const _MovimientoCardStatic({
    required this.nombre,
    required this.nombreCapitalizado,
    required this.nivel,
    required this.tipo,
    required this.categoria,
    required this.tipoTraducido,
    required this.categoriaTraducida,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final movimiento = await fetchMovimiento(nombre);
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovimientoDetailView(movimiento: movimiento),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Icono del movimiento
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.flash_on,
                  color: theme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Información del movimiento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombreCapitalizado,
                      style: theme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (tipoTraducido != null && categoriaTraducida != null)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.getPokemonTypeColor(tipo!),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              tipoTraducido!,
                              style: theme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: theme.secondary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              categoriaTraducida!,
                              style: theme.bodyMedium?.copyWith(
                                fontSize: 11,
                                color: theme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (nivel != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: theme.onSurface.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Nv. $nivel',
                                style: theme.bodyMedium?.copyWith(
                                  fontSize: 11,
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
                          fontSize: 11,
                          color: theme.onSurface.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
              // Icono de flecha
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

