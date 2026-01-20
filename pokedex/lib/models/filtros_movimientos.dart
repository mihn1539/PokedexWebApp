class MovimientoFilters {
  String? tipo;
  String? categoria; // physical, special, status
  
  MovimientoFilters({
    this.tipo,
    this.categoria,
  });

  bool get hasActiveFilters => tipo != null || categoria != null;

  // Method to reset all filters
  void resetFilters() {
    tipo = null;
    categoria = null;
  }

  // Method to apply filters to a list of moves
  List<Map<String, dynamic>> applyFilters(List<Map<String, dynamic>> movimientos) {
    return movimientos.where((movimiento) {
      bool matches = true;

      // Filter by type
      if (tipo != null) {
        // Si no tiene detalles cargados, excluirlo cuando hay filtro activo
        if (movimiento['tipo'] != null) {
          matches = matches && (movimiento['tipo'] == tipo);
        }
      }

      // Filter by category
      if (categoria != null) {
        // Si no tiene detalles cargados, excluirlo cuando hay filtro activo
        if (movimiento['categoria'] != null) {
          matches = matches && (movimiento['categoria'] == categoria);
        }
      }

      return matches;
    }).toList();
  }

  // Obtener lista de tipos disponibles
  static List<String> getTipos() {
    return [
      'normal', 'fighting', 'flying', 'poison', 'ground', 'rock',
      'bug', 'ghost', 'steel', 'fire', 'water', 'grass',
      'electric', 'psychic', 'ice', 'dragon', 'dark', 'fairy'
    ];
  }

  // Obtener lista de categorías disponibles
  static List<Map<String, String>> getCategorias() {
    return [
      {'value': 'physical', 'display': 'Físico'},
      {'value': 'special', 'display': 'Especial'},
      {'value': 'status', 'display': 'Estado'},
    ];
  }

  // Obtener el nombre de display de una categoría por su valor
  static String? getCategoriaDisplay(String? value) {
    if (value == null) return null;
    final categoria = getCategorias().firstWhere(
      (c) => c['value'] == value,
      orElse: () => {'value': '', 'display': ''},
    );
    return categoria['display'];
  }
}
