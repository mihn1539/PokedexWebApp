import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controlador para la trivia diaria de "¿Quién es ese Pokémon?"
class DailyTriviaController extends ChangeNotifier {
  static const String _lastDateKey = 'trivia_last_date';
  static const String _pokemonIdKey = 'trivia_pokemon_id';
  static const String _attemptsKey = 'trivia_attempts';
  static const String _hintsUsedKey = 'trivia_hints_used';
  static const String _completedKey = 'trivia_completed';
  static const String _wonKey = 'trivia_won';

  int? _currentPokemonId;
  int _attemptsRemaining = 3;
  int _hintsRevealed = 0;
  bool _isCompleted = false;
  bool _hasWon = false;
  bool _isLoading = true;

  // Getters
  int? get currentPokemonId => _currentPokemonId;
  int get attemptsRemaining => _attemptsRemaining;
  int get hintsRevealed => _hintsRevealed;
  bool get isCompleted => _isCompleted;
  bool get hasWon => _hasWon;
  bool get isLoading => _isLoading;
  bool get canRevealHint => _hintsRevealed < 3 && !_isCompleted;
  bool get canAttempt => _attemptsRemaining > 0 && !_isCompleted;

  /// Inicializa la trivia diaria
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();
    final lastDate = prefs.getString(_lastDateKey);

    // Si es un nuevo día, resetear la trivia
    if (lastDate != today) {
      await _resetTrivia(prefs, today);
    } else {
      // Cargar estado guardado (sin sobrescribir si ya hay un pokemonId establecido)
      _currentPokemonId ??= prefs.getInt(_pokemonIdKey);
      _attemptsRemaining = prefs.getInt(_attemptsKey) ?? 3;
      _hintsRevealed = prefs.getInt(_hintsUsedKey) ?? 0;
      _isCompleted = prefs.getBool(_completedKey) ?? false;
      _hasWon = prefs.getBool(_wonKey) ?? false;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Resetea la trivia para un nuevo día
  Future<void> _resetTrivia(SharedPreferences prefs, String date) async {
    // Preservar el pokemonId si ya se estableció (puede haber sido establecido antes de este reset)
    final pokemonIdExistente = _currentPokemonId ?? prefs.getInt(_pokemonIdKey);
    
    _attemptsRemaining = 3;
    _hintsRevealed = 0;
    _isCompleted = false;
    _hasWon = false;

    // Guardar en SharedPreferences
    await prefs.setString(_lastDateKey, date);
    await prefs.setInt(_attemptsKey, _attemptsRemaining);
    await prefs.setInt(_hintsUsedKey, _hintsRevealed);
    await prefs.setBool(_completedKey, _isCompleted);
    await prefs.setBool(_wonKey, _hasWon);
    
    // Si había un pokemonId, restaurarlo
    if (pokemonIdExistente != null) {
      _currentPokemonId = pokemonIdExistente;
      await prefs.setInt(_pokemonIdKey, pokemonIdExistente);
    } else {
      _currentPokemonId = null;
    }
  }
  
  /// Establece el Pokémon del día (llamado desde el widget cuando tiene la lista)
  Future<void> setPokemonOfTheDay(int pokemonId) async {
    if (_currentPokemonId == pokemonId) {
      return;
    }
    
    _currentPokemonId = pokemonId;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_pokemonIdKey, pokemonId);
  }

  /// Revela la siguiente pista
  Future<void> revealHint() async {
    if (!canRevealHint) return;

    _hintsRevealed++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hintsUsedKey, _hintsRevealed);
    notifyListeners();
  }

  /// Intenta adivinar el Pokémon
  Future<bool> makeGuess(int pokemonId) async {
    if (!canAttempt) return false;

    final isCorrect = pokemonId == _currentPokemonId;
    
    if (isCorrect) {
      _hasWon = true;
      _isCompleted = true;
    } else {
      _attemptsRemaining--;
      if (_attemptsRemaining == 0) {
        _isCompleted = true;
      }
    }

    // Guardar estado
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_attemptsKey, _attemptsRemaining);
    await prefs.setBool(_completedKey, _isCompleted);
    await prefs.setBool(_wonKey, _hasWon);

    notifyListeners();
    return isCorrect;
  }

  /// Obtiene la fecha actual como string
  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Genera una semilla basada en la fecha actual para el Random
  static int getTodaySeed() {
    final now = DateTime.now();
    final date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final parts = date.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);
    return year * 10000 + month * 100 + day;
  }
}
