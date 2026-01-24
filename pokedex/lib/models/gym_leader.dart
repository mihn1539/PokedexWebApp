class GymLeader {
  final String nombre;
  final String nombreOriginal; // Nombre en inglés/japonés si es necesario
  final String ciudad;
  final String tipo;
  final String medalla;
  final int orden; // Orden del gimnasio (1-8)
  final String region;
  final List<GymPokemon> equipo;
  final String? imagenUrl;
  final String? descripcion;

  GymLeader({
    required this.nombre,
    required this.nombreOriginal,
    required this.ciudad,
    required this.tipo,
    required this.medalla,
    required this.orden,
    required this.region,
    required this.equipo,
    this.imagenUrl,
    this.descripcion,
  });

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'nombreOriginal': nombreOriginal,
    'ciudad': ciudad,
    'tipo': tipo,
    'medalla': medalla,
    'orden': orden,
    'region': region,
    'equipo': equipo.map((p) => p.toJson()).toList(),
    'imagenUrl': imagenUrl,
    'descripcion': descripcion,
  };

  factory GymLeader.fromJson(Map<String, dynamic> json) => GymLeader(
    nombre: json['nombre'],
    nombreOriginal: json['nombreOriginal'],
    ciudad: json['ciudad'],
    tipo: json['tipo'],
    medalla: json['medalla'],
    orden: json['orden'],
    region: json['region'],
    equipo: (json['equipo'] as List)
        .map((p) => GymPokemon.fromJson(p))
        .toList(),
    imagenUrl: json['imagenUrl'],
    descripcion: json['descripcion'],
  );
}

class GymPokemon {
  final int pokemonId;
  final String nombre;
  final int nivel;
  final List<String>? movimientos;

  GymPokemon({
    required this.pokemonId,
    required this.nombre,
    required this.nivel,
    this.movimientos,
  });

  Map<String, dynamic> toJson() => {
    'pokemonId': pokemonId,
    'nombre': nombre,
    'nivel': nivel,
    'movimientos': movimientos,
  };

  factory GymPokemon.fromJson(Map<String, dynamic> json) => GymPokemon(
    pokemonId: json['pokemonId'],
    nombre: json['nombre'],
    nivel: json['nivel'],
    movimientos: json['movimientos'] != null
        ? List<String>.from(json['movimientos'])
        : null,
  );
}
