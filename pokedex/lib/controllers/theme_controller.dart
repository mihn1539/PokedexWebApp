import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController._() {
    _loadFromStorage();
  }
  static final ThemeController instance = ThemeController._();

  ThemeMode _mode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('theme_mode');
      if (raw != null) {
        _mode = ThemeMode.values.firstWhere(
          (e) => e.name == raw,
          orElse: () => ThemeMode.light,
        );
      } else {
        // Primera vez: detectar el tema del sistema y establecerlo explícitamente
        final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
        _mode = brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
        await prefs.setString('theme_mode', _mode.name);
      }
    } catch (e) {
      debugPrint('[THEME] Error cargando: $e');
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Espera a que el controlador termine de cargar el tema guardado
  Future<void> waitForInitialization() async {
    if (_isInitialized) return;
    
    // Esperar hasta que se inicialice (máximo 2 segundos)
    var attempts = 0;
    while (!_isInitialized && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', _mode.name);
    } catch (_) {}
  }

  void toggle() {
    _mode = (_mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
    notifyListeners();
    _persist();
  }

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
    _persist();
  }
}
