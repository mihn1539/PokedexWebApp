import 'package:flutter/material.dart';
import 'movimientos.dart';
import '../utils/app_theme.dart';
import '../utils/pokemon_helpers.dart';

class DetalleMovimiento extends StatelessWidget {
  final Movimiento movimiento;

  const DetalleMovimiento({super.key, required this.movimiento});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card principal con información básica
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      capitalizar(movimiento.nombre),
                      style: theme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    Icons.catching_pokemon,
                    'Tipo',
                    capitalizar(movimiento.tipo),
                    theme,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.category,
                    'Categoría',
                    capitalizar(movimiento.categoria),
                    theme,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.flash_on,
                    'Potencia',
                    movimiento.potencia.toString(),
                    theme,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.my_location,
                    'Precisión',
                    movimiento.precision.toString(),
                    theme,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.battery_charging_full,
                    'PP',
                    movimiento.pp.toString(),
                    theme,
                  ),
                  _buildInfoRow(
                    context,
                    Icons.gps_fixed,
                    'Objetivo',
                    capitalizar(movimiento.objetivo ?? 'Desconocido'),
                    theme,
                  ),
                  if (movimiento.curacion != "0")
                    _buildInfoRow(
                      context,
                      Icons.healing,
                      'Curación',
                      movimiento.curacion ?? '0',
                      theme,
                    ),
                  if (movimiento.probabilidadRetroceso != "0")
                    _buildInfoRow(
                      context,
                      Icons.warning,
                      'Prob. Retroceso',
                      '${movimiento.probabilidadRetroceso}%',
                      theme,
                    ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Card de descripción
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description, color: theme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Descripción',
                        style: theme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movimiento.descripcion,
                    style: theme.bodyLarge?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          
          // Card de máquinas (si existen)
          if (movimiento.discos != null && movimiento.discos!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.album, color: theme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Máquinas (MT/MO/DT)',
                          style: theme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...movimiento.discos!.entries.map((entry) {
                      final version = entry.key;
                      final machineUrl = entry.value;

                      return FutureBuilder<String>(
                        future: fecthNombreMt(machineUrl),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Cargando...',
                                    style: theme.bodyMedium,
                                  ),
                                ],
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '• Error cargando MT de $version',
                                style: theme.bodyMedium?.copyWith(
                                  color: theme.error,
                                ),
                              ),
                            );
                          }

                          final nombreMT = snapshot.data ?? 'Desconocido';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: theme.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$nombreMT',
                                    style: theme.bodyLarge,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    capitalizar(version),
                                    style: theme.bodyMedium?.copyWith(
                                      fontSize: 12,
                                      color: theme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    AppTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.primary.withOpacity(0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label:',
              style: theme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: theme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}