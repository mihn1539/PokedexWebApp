import 'dart:convert';
import 'package:http/http.dart' as http;

class Movimiento {
  final String nombre;
  final String tipo;
  final String categoria;
  final int potencia;
  final int precision;
  final int pp;
  final String descripcion;
  final List<String> pokemon;
  Map<String,String>? discos;//almacenar el nombre de la vercion como key y la url de la maquina como value y mostrar la info desde le visual
  String? probabilidadCritico;
  String? efectoSecundario;
  String? probabilidadEfectoSecundario;
  String? prioridad;
  String? objetivo;
  String? curacion;
  String? probabilidadRetroceso;
  Map<String,String>? efectoConcurso;
  String? drenado;
  


  Movimiento({
    required this.nombre,
    required this.tipo,
    required this.categoria,
    required this.potencia,
    required this.precision,
    required this.pp,
    required this.descripcion,
    required this.pokemon,
    this.discos,
    this.probabilidadCritico,
    this.efectoSecundario,
    this.probabilidadEfectoSecundario,
    this.prioridad,
    this.objetivo,
    this.curacion,
    this.probabilidadRetroceso,
    this.efectoConcurso,
    this.drenado,

  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      nombre: json['name'],
      tipo: json['type']['name'],
      categoria: json['damage_class']['name'],
      potencia: json['power'] ?? 0,
      precision: json['accuracy'] ?? 0,
      pp: json['pp'] ?? 0,
      descripcion: (json['flavor_text_entries'] as List)
          .firstWhere((entry) => entry['language']['name'] == 'en')['flavor_text'],
      pokemon: json['learned_by_pokemon']
          .map<String>((poke) => poke['name'] as String)
          .toList(),
      discos: {for (var machine in json['machines'])
              machine['version_group']['name']: machine['machine']['url']
          },
      probabilidadCritico: json['meta'] != null && json['meta']['crit_rate'] != null
          ? json['meta']['crit_rate'].toString()
          : null,
      efectoSecundario: json['meta'] != null && json['meta']['ailment'] != null
          ? json['meta']['ailment']['name']
          : null,
      probabilidadEfectoSecundario: json['meta'] != null && json['meta']['ailment_chance'] != null
          ? json['meta']['ailment_chance'].toString()
          : null,
      prioridad: json['priority']?.toString(),
      objetivo: json['target'] != null
          ? json['target']['name']
          : null,
      curacion: json['meta'] != null && json['meta']['drain'] != null
          ? json['meta']['drain'].toString()
          : null,
      probabilidadRetroceso: json['meta'] != null && json['meta']['flinch_chance'] != null
          ? json['meta']['flinch_chance'].toString()
          : null,
      drenado: json['meta'] != null && json['meta']['drain'] != null
          ? json['meta']['drain'].toString()
          : null,
      
      
                      
    );
  }
} 
Future<Movimiento> fetchMovimiento(String nombre) async {
  final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/move/$nombre'));

  if (response.statusCode == 200) {
    return Movimiento.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load movimiento');
  }
}

Future<String> fecthNombreMt(String urlmt) async {
  final response = await http.get(Uri.parse(urlmt));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['item']['name'];
  } else {
    throw Exception('Failed to load MT name');
  }
}
