import 'package:pokedex/models/gym_leader.dart';

class GymLeaderService {
  // Datos de los líderes de gimnasio de Kanto
  static List<GymLeader> getKantoGymLeaders() {
    return [
      // 1. Brock - Gimnasio de Ciudad Plateada
      GymLeader(
        nombre: 'Brock',
        nombreOriginal: 'Takeshi',
        ciudad: 'Ciudad Plateada',
        tipo: 'rock',
        medalla: 'Medalla Roca',
        orden: 1,
        region: 'Kanto',
        equipo: [
          GymPokemon(pokemonId: 74, nombre: 'Geodude', nivel: 10),
          GymPokemon(pokemonId: 95, nombre: 'Onix', nivel: 12),
        ],
        descripcion:
            'Especialista en Pokémon tipo Roca. Primer líder de gimnasio de Kanto.',
      ),

      // 2. Misty - Gimnasio de Ciudad Celeste
      GymLeader(
        nombre: 'Misty',
        nombreOriginal: 'Kasumi',
        ciudad: 'Ciudad Celeste',
        tipo: 'water',
        medalla: 'Medalla Cascada',
        orden: 2,
        region: 'Kanto',
        equipo: [
          GymPokemon(pokemonId: 118, nombre: 'Goldeen', nivel: 16),
          GymPokemon(pokemonId: 54, nombre: 'Psyduck', nivel: 18),
          GymPokemon(pokemonId: 121, nombre: 'Starmie', nivel: 20),
        ],
        descripcion:
            'Especialista en Pokémon tipo Agua. Segunda líder de gimnasio de Kanto.',
      ),

      // 3. Lt. Surge - Gimnasio de Ciudad Carmín
      GymLeader(
        nombre: 'Lt. Surge',
        nombreOriginal: 'Matis',
        ciudad: 'Ciudad Carmín',
        tipo: 'electric',
        medalla: 'Medalla Trueno',
        orden: 3,
        region: 'Kanto',
        equipo: [
          GymPokemon(pokemonId: 100, nombre: 'Voltorb', nivel: 25),
          GymPokemon(pokemonId: 239, nombre: 'Elekid', nivel: 25),
          GymPokemon(pokemonId: 81, nombre: 'Magnemite', nivel: 25),
          GymPokemon(pokemonId: 26, nombre: 'Raichu', nivel: 27),
        ],
        descripcion:
            'Especialista en Pokémon tipo Eléctrico. Tercer líder de gimnasio de Kanto.',
      ),

      // 4. Erika - Gimnasio de Ciudad Azafrán (Celadon)
      GymLeader(
        nombre: 'Erika',
        nombreOriginal: 'Erika',
        ciudad: 'Ciudad Azafrán',
        tipo: 'grass',
        medalla: 'Medalla Arcoíris',
        orden: 4,
        region: 'Kanto',
        equipo: [
          GymPokemon(pokemonId: 114, nombre: 'Tangela', nivel: 30),
          GymPokemon(pokemonId: 45, nombre: 'Vileplume', nivel: 31),
          GymPokemon(pokemonId: 71, nombre: 'Victreebel', nivel: 31),
          GymPokemon(pokemonId: 182, nombre: 'Bellossom', nivel: 33),
        ],
        descripcion:
            'Especialista en Pokémon tipo Planta. Cuarta líder de gimnasio de Kanto.',
      ),

      // 5. Koga - Gimnasio de Ciudad Fucsia
      GymLeader(
        nombre: 'Koga',
        nombreOriginal: 'Kyou',
        ciudad: 'Ciudad Fucsia',
        tipo: 'poison',
        medalla: 'Medalla Alma',
        orden: 5,
        region: 'Kanto',
        equipo: [
          GymPokemon(pokemonId: 89, nombre: 'Muk', nivel: 41),
          GymPokemon(pokemonId: 110, nombre: 'Weezing', nivel: 41),
          GymPokemon(pokemonId: 49, nombre: 'Venomoth', nivel: 41),
          GymPokemon(pokemonId: 169, nombre: 'Crobat', nivel: 43),
        ],
        descripcion:
            'Especialista en Pokémon tipo Veneno. Quinto líder de gimnasio de Kanto.',
      ),

      // 6. Sabrina - Gimnasio de Ciudad Azafrán
      GymLeader(
        nombre: 'Sabrina',
        nombreOriginal: 'Natsume',
        ciudad: 'Ciudad Azafrán',
        tipo: 'psychic',
        medalla: 'Medalla Pantano',
        orden: 6,
        region: 'Kanto',
        equipo: [
          GymPokemon(pokemonId: 122, nombre: 'Mr. Mime', nivel: 40),
          GymPokemon(pokemonId: 80, nombre: 'Slowbro', nivel: 40),
          GymPokemon(pokemonId: 196, nombre: 'Espeon', nivel: 40),
          GymPokemon(pokemonId: 124, nombre: 'Jynx', nivel: 41),
          GymPokemon(pokemonId: 65, nombre: 'Alakazam', nivel: 43),
        ],
        descripcion:
            'Especialista en Pokémon tipo Psíquico. Sexta líder de gimnasio de Kanto.',
      ),

      // 7. Blaine - Gimnasio de Isla Canela
      GymLeader(
        nombre: 'Blaine',
        nombreOriginal: 'Katsura',
        ciudad: 'Isla Canela',
        tipo: 'fire',
        medalla: 'Medalla Volcán',
        orden: 7,
        region: 'Kanto',
        equipo: [
          GymPokemon(pokemonId: 38, nombre: 'Ninetales', nivel: 44),
          GymPokemon(pokemonId: 213, nombre: 'Magcargo', nivel: 44),
          GymPokemon(pokemonId: 126, nombre: 'Magmar', nivel: 44),
          GymPokemon(pokemonId: 78, nombre: 'Rapidash', nivel: 45),
          GymPokemon(pokemonId: 59, nombre: 'Arcanine', nivel: 47),
        ],
        descripcion:
            'Especialista en Pokémon tipo Fuego. Séptimo líder de gimnasio de Kanto.',
      ),

      // 8. Giovanni - Gimnasio de Ciudad Verde
      GymLeader(
        nombre: 'Giovanni',
        nombreOriginal: 'Sakaki',
        ciudad: 'Ciudad Verde',
        tipo: 'ground',
        medalla: 'Medalla Tierra',
        orden: 8,
        region: 'Kanto',
        equipo: [
          GymPokemon(pokemonId: 31, nombre: 'Nidoqueen', nivel: 40),
          GymPokemon(pokemonId: 34, nombre: 'Nidoking', nivel: 49),
          GymPokemon(pokemonId: 112, nombre: 'Rhydon', nivel: 49),
          GymPokemon(pokemonId: 51, nombre: 'Dugtrio', nivel: 48),
          GymPokemon(pokemonId: 464, nombre: 'Rhyperior', nivel: 52),
        ],
        descripcion:
            'Especialista en Pokémon tipo Tierra. Octavo y último líder de gimnasio de Kanto. También es el líder del Team Rocket.',
      ),
    ];
  }

  // Obtener todos los líderes de gimnasio
  static List<GymLeader> getAllGymLeaders() {
    return getKantoGymLeaders();
  }

  // Obtener líderes por región
  static List<GymLeader> getGymLeadersByRegion(String region) {
    return getAllGymLeaders()
        .where((leader) => leader.region == region)
        .toList();
  }

  // Obtener líder por nombre
  static GymLeader? getGymLeaderByName(String name) {
    try {
      return getAllGymLeaders().firstWhere(
        (leader) => leader.nombre.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Obtener líder por ciudad
  static GymLeader? getGymLeaderByCity(String city) {
    try {
      return getAllGymLeaders().firstWhere(
        (leader) => leader.ciudad.toLowerCase() == city.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Obtener regiones disponibles
  static List<String> getAvailableRegions() {
    return getAllGymLeaders().map((leader) => leader.region).toSet().toList();
  }
}
