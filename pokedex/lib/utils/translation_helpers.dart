/// Utilidades para traducir términos de la PokeAPI al español

/// Traduce el nombre de un tipo de Pokémon del inglés al español
String traducirTipo(String tipo) {
  const Map<String, String> traducciones = {
    'normal': 'Normal',
    'fire': 'Fuego',
    'water': 'Agua',
    'grass': 'Planta',
    'electric': 'Eléctrico',
    'ice': 'Hielo',
    'fighting': 'Lucha',
    'poison': 'Veneno',
    'ground': 'Tierra',
    'flying': 'Volador',
    'psychic': 'Psíquico',
    'bug': 'Bicho',
    'rock': 'Roca',
    'ghost': 'Fantasma',
    'dragon': 'Dragón',
    'dark': 'Siniestro',
    'steel': 'Acero',
    'fairy': 'Hada',
  };
  return traducciones[tipo] ??
      tipo.substring(0, 1).toUpperCase() + tipo.substring(1);
}

/// Traduce la categoría de daño de un movimiento del inglés al español
String traducirCategoria(String categoria) {
  const Map<String, String> traducciones = {
    'physical': 'Físico',
    'special': 'Especial',
    'status': 'Estado',
  };
  return traducciones[categoria] ??
      categoria.substring(0, 1).toUpperCase() + categoria.substring(1);
}

/// Mapeo de nombres de tipos en español a sus equivalentes en la API
const Map<String, String?> spanishToApiType = {
  'Todos los tipos': null,
  'Normal': 'normal',
  'Fuego': 'fire',
  'Agua': 'water',
  'Planta': 'grass',
  'Eléctrico': 'electric',
  'Hielo': 'ice',
  'Lucha': 'fighting',
  'Veneno': 'poison',
  'Tierra': 'ground',
  'Volador': 'flying',
  'Psíquico': 'psychic',
  'Bicho': 'bug',
  'Roca': 'rock',
  'Fantasma': 'ghost',
  'Dragón': 'dragon',
  'Siniestro': 'dark',
  'Acero': 'steel',
  'Hada': 'fairy',
};

/// Lista de todos los tipos en español (para dropdowns)
const List<String> tiposEspanol = [
  'Todos los tipos',
  'Normal',
  'Fuego',
  'Agua',
  'Planta',
  'Eléctrico',
  'Hielo',
  'Lucha',
  'Veneno',
  'Tierra',
  'Volador',
  'Psíquico',
  'Bicho',
  'Roca',
  'Fantasma',
  'Dragón',
  'Siniestro',
  'Acero',
  'Hada',
];
