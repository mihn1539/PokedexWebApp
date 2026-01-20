import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController._() {
    _loadFromStorage();
  }
  static final FavoritesController instance = FavoritesController._();

  final Set<int> _favoriteIds = <int>{};

  Set<int> get favoriteIds => _favoriteIds;
  bool isFavorite(int id) => _favoriteIds.contains(id);

  void _loadFromStorage() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getStringList('favorites') ?? <String>[];
      _favoriteIds
        ..clear()
        ..addAll(raw.map(int.parse));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _mantener() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setStringList(
        'favorites',
        _favoriteIds.map((e) => e.toString()).toList(),
      );
    } catch (_) {}
  }

  void toggle(int id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
    _mantener();
  }

  void clear() {
    _favoriteIds.clear();
    notifyListeners();
    _mantener();
  }
}
