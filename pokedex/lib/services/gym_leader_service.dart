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
          GymPokemon(pokemonId: 51, nombre: 'Dugtrio', nivel: 48),
          GymPokemon(pokemonId: 34, nombre: 'Nidoking', nivel: 49),
          GymPokemon(pokemonId: 112, nombre: 'Rhydon', nivel: 49),
          GymPokemon(pokemonId: 464, nombre: 'Rhyperior', nivel: 52),
        ],
        descripcion:
            'Especialista en Pokémon tipo Tierra. Octavo y último líder de gimnasio de Kanto. También es el líder del Team Rocket.',
      ),
    ];
  }

  // Datos de los líderes de gimnasio de Johto
  static List<GymLeader> getJohtoGymLeaders() {
    return [
      // 1. Falkner - Gimnasio de Ciudad Malva
      GymLeader(
        nombre: 'Falkner',
        nombreOriginal: 'Hayato',
        ciudad: 'Ciudad Malva',
        tipo: 'flying',
        medalla: 'Medalla Cefiro',
        orden: 1,
        region: 'Johto',
        equipo: [
          GymPokemon(pokemonId: 16, nombre: 'Pidgey', nivel: 12),
          GymPokemon(pokemonId: 17, nombre: 'Pidgeotto', nivel: 14),
        ],
        descripcion:
            'Especialista en Pokémon tipo Volador. Primer líder de gimnasio de Johto.',
      ),

      // 2. Bugsy - Gimnasio de Ciudad Azalea
      GymLeader(
        nombre: 'Bugsy',
        nombreOriginal: 'Tsukushi',
        ciudad: 'Ciudad Azalea',
        tipo: 'bug',
        medalla: 'Medalla Colmena',
        orden: 2,
        region: 'Johto',
        equipo: [
          GymPokemon(pokemonId: 12, nombre: 'Butterfree', nivel: 17),
          GymPokemon(pokemonId: 15, nombre: 'Beedrill', nivel: 17),
          GymPokemon(pokemonId: 123, nombre: 'Scyther', nivel: 19),
        ],
        descripcion:
            'Especialista en Pokémon tipo Bicho. Segundo líder de gimnasio de Johto.',
      ),

      // 3. Whitney - Gimnasio de Ciudad Trigal
      GymLeader(
        nombre: 'Whitney',
        nombreOriginal: 'Akane',
        ciudad: 'Ciudad Trigal',
        tipo: 'normal',
        medalla: 'Medalla Lisa',
        orden: 3,
        region: 'Johto',
        equipo: [
          GymPokemon(pokemonId: 35, nombre: 'Clefairy', nivel: 23),
          GymPokemon(pokemonId: 216, nombre: 'Teddiursa', nivel: 23),
          GymPokemon(pokemonId: 241, nombre: 'Miltank', nivel: 23),
        ],
        descripcion:
            'Especialista en Pokémon tipo Normal. Tercera líder de gimnasio de Johto. Famosa por su Miltank extremadamente difícil.',
      ),

      // 4. Morty - Gimnasio de Ciudad Iris
      GymLeader(
        nombre: 'Morty',
        nombreOriginal: 'Matsuba',
        ciudad: 'Ciudad Iris',
        tipo: 'ghost',
        medalla: 'Medalla Niebla',
        orden: 4,
        region: 'Johto',
        equipo: [
          GymPokemon(pokemonId: 93, nombre: 'Haunter', nivel: 27),
          GymPokemon(pokemonId: 200, nombre: 'Misdreavus', nivel: 27),
          GymPokemon(pokemonId: 94, nombre: 'Gengar', nivel: 29),
        ],
        descripcion:
            'Especialista en Pokémon tipo Fantasma. Cuarto líder de gimnasio de Johto.',
      ),

      // 5. Chuck - Gimnasio de Ciudad Orquídea
      GymLeader(
        nombre: 'Chuck',
        nombreOriginal: 'Shijima',
        ciudad: 'Ciudad Orquídea',
        tipo: 'fighting',
        medalla: 'Medalla Tormenta',
        orden: 5,
        region: 'Johto',
        equipo: [
          GymPokemon(pokemonId: 66, nombre: 'Machoke', nivel: 32),
          GymPokemon(pokemonId: 57, nombre: 'Primeape', nivel: 32),
          GymPokemon(pokemonId: 237, nombre: 'Hitmontop', nivel: 32),
          GymPokemon(pokemonId: 62, nombre: 'Poliwrath', nivel: 34),
        ],
        descripcion:
            'Especialista en Pokémon tipo Lucha. Quinto líder de gimnasio de Johto.',
      ),

      // 6. Jasmine - Gimnasio de Ciudad Olivine
      GymLeader(
        nombre: 'Jasmine',
        nombreOriginal: 'Mikan',
        ciudad: 'Ciudad Olivine',
        tipo: 'steel',
        medalla: 'Medalla Mineral',
        orden: 6,
        region: 'Johto',
        equipo: [
          GymPokemon(pokemonId: 205, nombre: 'Forretress', nivel: 34),
          GymPokemon(pokemonId: 227, nombre: 'Skarmory', nivel: 34),
          GymPokemon(pokemonId: 82, nombre: 'Magneton', nivel: 34),
          GymPokemon(pokemonId: 208, nombre: 'Steelix', nivel: 36),
        ],
        descripcion:
            'Especialista en Pokémon tipo Acero. Sexta líder de gimnasio de Johto.',
      ),

      // 7. Pryce - Gimnasio de Ciudad Caoba
      GymLeader(
        nombre: 'Pryce',
        nombreOriginal: 'Yanagi',
        ciudad: 'Ciudad Caoba',
        tipo: 'ice',
        medalla: 'Medalla Glaciar',
        orden: 7,
        region: 'Johto',
        equipo: [
          GymPokemon(pokemonId: 471, nombre: 'Glaceon', nivel: 35),
          GymPokemon(pokemonId: 91, nombre: 'Cloyster', nivel: 35),
          GymPokemon(pokemonId: 87, nombre: 'Dewgong', nivel: 36),
          GymPokemon(pokemonId: 131, nombre: 'Lapras', nivel: 36),
          GymPokemon(pokemonId: 473, nombre: 'Mamoswine', nivel: 38),
        ],
        descripcion:
            'Especialista en Pokémon tipo Hielo. Séptimo líder de gimnasio de Johto.',
      ),

      // 8. Clair - Gimnasio de Ciudad Blackthorn
      GymLeader(
        nombre: 'Clair',
        nombreOriginal: 'Ibuki',
        ciudad: 'Ciudad Blackthorn',
        tipo: 'dragon',
        medalla: 'Medalla Aumento',
        orden: 8,
        region: 'Johto',
        equipo: [
          GymPokemon(pokemonId: 148, nombre: 'Dragonair', nivel: 42),
          GymPokemon(pokemonId: 148, nombre: 'Dragonair', nivel: 42),
          GymPokemon(pokemonId: 142, nombre: 'Aerodactyl', nivel: 42),
          GymPokemon(pokemonId: 130, nombre: 'Gyarados', nivel: 42),
          GymPokemon(pokemonId: 230, nombre: 'Kingdra', nivel: 44),
        ],
        descripcion:
            'Especialista en Pokémon tipo Dragón. Octava y última líder de gimnasio de Johto. Prima de Lance.',
      ),
    ];
  }

  // Datos de los líderes de gimnasio de Hoenn
  static List<GymLeader> getHoennGymLeaders() {
    return [
      // 1. Roxanne - Gimnasio de Ciudad Férrica
      GymLeader(
        nombre: 'Roxanne',
        nombreOriginal: 'Tsutsuji',
        ciudad: 'Ciudad Férrica',
        tipo: 'rock',
        medalla: 'Medalla Roca',
        orden: 1,
        region: 'Hoenn',
        equipo: [
          GymPokemon(pokemonId: 304, nombre: 'Aron', nivel: 12),
          GymPokemon(pokemonId: 74, nombre: 'Geodude', nivel: 12),
          GymPokemon(pokemonId: 299, nombre: 'Nosepass', nivel: 15),
        ],
        descripcion:
            'Especialista en Pokémon tipo Roca. Primera líder de gimnasio de Hoenn.',
      ),

      // 2. Brawly - Gimnasio de Pueblo Azuliza
      GymLeader(
        nombre: 'Brawly',
        nombreOriginal: 'Touki',
        ciudad: 'Pueblo Azuliza',
        tipo: 'fighting',
        medalla: 'Medalla Nudillo',
        orden: 2,
        region: 'Hoenn',
        equipo: [
          GymPokemon(pokemonId: 66, nombre: 'Machop', nivel: 15),
          GymPokemon(pokemonId: 307, nombre: 'Meditite', nivel: 17),
          GymPokemon(pokemonId: 296, nombre: 'Makuhita', nivel: 19),
        ],
        descripcion:
            'Especialista en Pokémon tipo Lucha. Segundo líder de gimnasio de Hoenn.',
      ),

      // 3. Wattson - Gimnasio de Ciudad Malvalona
      GymLeader(
        nombre: 'Wattson',
        nombreOriginal: 'Tessen',
        ciudad: 'Ciudad Malvalona',
        tipo: 'electric',
        medalla: 'Medalla Dinamo',
        orden: 3,
        region: 'Hoenn',
        equipo: [
          GymPokemon(pokemonId: 309, nombre: 'Electrike', nivel: 21),
          GymPokemon(pokemonId: 82, nombre: 'Magneton', nivel: 21),
          GymPokemon(pokemonId: 100, nombre: 'Voltorb', nivel: 21),
          GymPokemon(pokemonId: 310, nombre: 'Manectric', nivel: 24),
        ],
        descripcion:
            'Especialista en Pokémon tipo Eléctrico. Tercer líder de gimnasio de Hoenn.',
      ),

      // 4. Flannery - Gimnasio de Pueblo Lavacalda
      GymLeader(
        nombre: 'Flannery',
        nombreOriginal: 'Asuna',
        ciudad: 'Pueblo Lavacalda',
        tipo: 'fire',
        medalla: 'Medalla Calor',
        orden: 4,
        region: 'Hoenn',
        equipo: [
          GymPokemon(pokemonId: 322, nombre: 'Numel', nivel: 26),
          GymPokemon(pokemonId: 218, nombre: 'Slugma', nivel: 26),
          GymPokemon(pokemonId: 323, nombre: 'Camerupt', nivel: 27),
          GymPokemon(pokemonId: 324, nombre: 'Torkoal', nivel: 29),
        ],
        descripcion:
            'Especialista en Pokémon tipo Fuego. Cuarta líder de gimnasio de Hoenn.',
      ),

      // 5. Norman - Gimnasio de Ciudad Petalia
      GymLeader(
        nombre: 'Norman',
        nombreOriginal: 'Senri',
        ciudad: 'Ciudad Petalia',
        tipo: 'normal',
        medalla: 'Medalla Equilibrio',
        orden: 5,
        region: 'Hoenn',
        equipo: [
          GymPokemon(pokemonId: 289, nombre: 'Zangoose', nivel: 28),
          GymPokemon(pokemonId: 288, nombre: 'Vigoroth', nivel: 28),
          GymPokemon(pokemonId: 264, nombre: 'Linoone', nivel: 29),
          GymPokemon(pokemonId: 327, nombre: 'Spinda', nivel: 29),
          GymPokemon(pokemonId: 289, nombre: 'Slaking', nivel: 31),
        ],
        descripcion:
            'Especialista en Pokémon tipo Normal. Quinto líder de gimnasio de Hoenn. Padre del protagonista.',
      ),

      // 6. Winona - Gimnasio de Ciudad Arborada
      GymLeader(
        nombre: 'Winona',
        nombreOriginal: 'Nagi',
        ciudad: 'Ciudad Arborada',
        tipo: 'flying',
        medalla: 'Medalla Pluma',
        orden: 6,
        region: 'Hoenn',
        equipo: [
          GymPokemon(pokemonId: 357, nombre: 'Tropius', nivel: 32),
          GymPokemon(pokemonId: 277, nombre: 'Swellow', nivel: 32),
          GymPokemon(pokemonId: 227, nombre: 'Skarmory', nivel: 33),
          GymPokemon(pokemonId: 279, nombre: 'Pelipper', nivel: 33),
          GymPokemon(pokemonId: 334, nombre: 'Altaria', nivel: 35),
        ],
        descripcion:
            'Especialista en Pokémon tipo Volador. Sexta líder de gimnasio de Hoenn.',
      ),

      // 7. Tate & Liza - Gimnasio de Ciudad Algaria
      GymLeader(
        nombre: 'Tate & Liza',
        nombreOriginal: 'Fuu & Ran',
        ciudad: 'Ciudad Algaria',
        tipo: 'psychic',
        medalla: 'Medalla Mental',
        orden: 7,
        region: 'Hoenn',
        equipo: [
          GymPokemon(pokemonId: 344, nombre: 'Claydol', nivel: 40),
          GymPokemon(pokemonId: 326, nombre: 'Grumpig', nivel: 40),
          GymPokemon(pokemonId: 337, nombre: 'Lunatone', nivel: 41),
          GymPokemon(pokemonId: 338, nombre: 'Solrock', nivel: 41),
        ],
        descripcion:
            'Especialistas en Pokémon tipo Psíquico. Séptimos líderes de gimnasio de Hoenn. Gemelos que luchan en batallas dobles.',
      ),

      // 8. Juan - Gimnasio de Ciudad Arrecípolis
      GymLeader(
        nombre: 'Juan',
        nombreOriginal: 'Adan',
        ciudad: 'Ciudad Arrecípolis',
        tipo: 'water',
        medalla: 'Medalla Lluvia',
        orden: 8,
        region: 'Hoenn',
        equipo: [
          GymPokemon(pokemonId: 342, nombre: 'Crawdaunt', nivel: 43),
          GymPokemon(pokemonId: 368, nombre: 'Gorebyss', nivel: 43),
          GymPokemon(pokemonId: 340, nombre: 'Whiscash', nivel: 44),
          GymPokemon(pokemonId: 365, nombre: 'Walrein', nivel: 44),
          GymPokemon(pokemonId: 230, nombre: 'Kingdra', nivel: 45),
        ],
        descripcion:
            'Especialista en Pokémon tipo Agua. Octavo y último líder de gimnasio de Hoenn. Maestro de Wallace.',
      ),
    ];
  }

  // Datos de los líderes de gimnasio de Sinnoh
  static List<GymLeader> getSinnohGymLeaders() {
    return [
      // 1. Roark - Gimnasio de Ciudad Pirita
      GymLeader(
        nombre: 'Roark',
        nombreOriginal: 'Hyouta',
        ciudad: 'Ciudad Pirita',
        tipo: 'rock',
        medalla: 'Medalla Carbón',
        orden: 1,
        region: 'Sinnoh',
        equipo: [
          GymPokemon(pokemonId: 74, nombre: 'Geodude', nivel: 12),
          GymPokemon(pokemonId: 95, nombre: 'Onix', nivel: 12),
          GymPokemon(pokemonId: 408, nombre: 'Cranidos', nivel: 14),
        ],
        descripcion:
            'Especialista en Pokémon tipo Roca. Primer líder de gimnasio de Sinnoh. Hijo de Byron.',
      ),

      // 2. Gardenia - Gimnasio de Ciudad Vetusta
      GymLeader(
        nombre: 'Gardenia',
        nombreOriginal: 'Natane',
        ciudad: 'Ciudad Vetusta',
        tipo: 'grass',
        medalla: 'Medalla Bosque',
        orden: 2,
        region: 'Sinnoh',
        equipo: [
          GymPokemon(pokemonId: 387, nombre: 'Turtwig', nivel: 18),
          GymPokemon(pokemonId: 455, nombre: 'Carnivine', nivel: 19),
          GymPokemon(pokemonId: 421, nombre: 'Cherrim', nivel: 20),
          GymPokemon(pokemonId: 407, nombre: 'Roserade', nivel: 22),
        ],
        descripcion:
            'Especialista en Pokémon tipo Planta. Segunda líder de gimnasio de Sinnoh.',
      ),

      // 3. Fantina - Gimnasio de Ciudad Corazonada
      GymLeader(
        nombre: 'Fantina',
        nombreOriginal: 'Melissa',
        ciudad: 'Ciudad Corazonada',
        tipo: 'ghost',
        medalla: 'Medalla Reliquia',
        orden: 3,
        region: 'Sinnoh',
        equipo: [
          GymPokemon(pokemonId: 425, nombre: 'Drifloon', nivel: 23),
          GymPokemon(pokemonId: 426, nombre: 'Drifblim', nivel: 24),
          GymPokemon(pokemonId: 429, nombre: 'Mismagius', nivel: 25),
        ],
        descripcion:
            'Especialista en Pokémon tipo Fantasma. Tercera líder de gimnasio de Sinnoh.',
      ),

      // 4. Maylene - Gimnasio de Ciudad Rocavelo
      GymLeader(
        nombre: 'Maylene',
        nombreOriginal: 'Sumomo',
        ciudad: 'Ciudad Rocavelo',
        tipo: 'fighting',
        medalla: 'Medalla Adoquín',
        orden: 4,
        region: 'Sinnoh',
        equipo: [
          GymPokemon(pokemonId: 66, nombre: 'Machop', nivel: 27),
          GymPokemon(pokemonId: 307, nombre: 'Meditite', nivel: 28),
          GymPokemon(pokemonId: 448, nombre: 'Lucario', nivel: 30),
        ],
        descripcion:
            'Especialista en Pokémon tipo Lucha. Cuarta líder de gimnasio de Sinnoh.',
      ),

      // 5. Crasher Wake - Gimnasio de Ciudad Pradera
      GymLeader(
        nombre: 'Crasher Wake',
        nombreOriginal: 'Maximum Mask',
        ciudad: 'Ciudad Pradera',
        tipo: 'water',
        medalla: 'Medalla Ciénaga',
        orden: 5,
        region: 'Sinnoh',
        equipo: [
          GymPokemon(pokemonId: 418, nombre: 'Buizel', nivel: 31),
          GymPokemon(pokemonId: 419, nombre: 'Floatzel', nivel: 32),
          GymPokemon(pokemonId: 130, nombre: 'Gyarados', nivel: 34),
        ],
        descripcion:
            'Especialista en Pokémon tipo Agua. Quinto líder de gimnasio de Sinnoh. Luchador enmascarado.',
      ),

      // 6. Byron - Gimnasio de Ciudad Canal
      GymLeader(
        nombre: 'Byron',
        nombreOriginal: 'Tougan',
        ciudad: 'Ciudad Canal',
        tipo: 'steel',
        medalla: 'Medalla Mina',
        orden: 6,
        region: 'Sinnoh',
        equipo: [
          GymPokemon(pokemonId: 81, nombre: 'Magnemite', nivel: 38),
          GymPokemon(pokemonId: 208, nombre: 'Bronzor', nivel: 38),
          GymPokemon(pokemonId: 411, nombre: 'Bastiodon', nivel: 40),
        ],
        descripcion:
            'Especialista en Pokémon tipo Acero. Sexto líder de gimnasio de Sinnoh. Padre de Roark.',
      ),

      // 7. Candice - Gimnasio de Ciudad Puntaneva
      GymLeader(
        nombre: 'Candice',
        nombreOriginal: 'Suzuna',
        ciudad: 'Ciudad Puntaneva',
        tipo: 'ice',
        medalla: 'Medalla Témpano',
        orden: 7,
        region: 'Sinnoh',
        equipo: [
          GymPokemon(pokemonId: 361, nombre: 'Snorunt', nivel: 40),
          GymPokemon(pokemonId: 362, nombre: 'Glalie', nivel: 41),
          GymPokemon(pokemonId: 460, nombre: 'Abomasnow', nivel: 43),
        ],
        descripcion:
            'Especialista en Pokémon tipo Hielo. Séptima líder de gimnasio de Sinnoh.',
      ),

      // 8. Volkner - Gimnasio de Ciudad Fresa
      GymLeader(
        nombre: 'Volkner',
        nombreOriginal: 'Denji',
        ciudad: 'Ciudad Fresa',
        tipo: 'electric',
        medalla: 'Medalla Faro',
        orden: 8,
        region: 'Sinnoh',
        equipo: [
          GymPokemon(pokemonId: 425, nombre: 'Electrike', nivel: 46),
          GymPokemon(pokemonId: 26, nombre: 'Raichu', nivel: 47),
          GymPokemon(pokemonId: 462, nombre: 'Magnezone', nivel: 49),
        ],
        descripcion:
            'Especialista en Pokémon tipo Eléctrico. Octavo y último líder de gimnasio de Sinnoh. Mejor amigo de Flint del Alto Mando.',
      ),
    ];
  }

  // Obtener todos los líderes de gimnasio
  static List<GymLeader> getAllGymLeaders() {
    return [
      ...getKantoGymLeaders(),
      ...getJohtoGymLeaders(),
      ...getHoennGymLeaders(),
      ...getSinnohGymLeaders(),
    ];
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
