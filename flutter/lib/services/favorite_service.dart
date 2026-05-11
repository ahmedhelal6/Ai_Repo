import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _key = 'favorite_exercise_ids';

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList(_key) ?? [];

    return list.toSet();
  }

  Future<Set<String>> toggleFavorite(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList(_key) ?? [];
    final favorites = list.toSet();

    if (favorites.contains(exerciseId)) {
      favorites.remove(exerciseId);
    } else {
      favorites.add(exerciseId);
    }

    await prefs.setStringList(_key, favorites.toList());

    return favorites;
  }

  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}