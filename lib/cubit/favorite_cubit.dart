import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:weather_app/cubit/favorite_state.dart';
import 'package:weather_app/services/widget_service.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final SharedPreferences sharedPreferences;

  FavoriteCubit(this.sharedPreferences) : super(FavoriteInitial()) {
    _loadFavorites();
  }

  void _loadFavorites() {
    final favoriteCities = sharedPreferences.getStringList('favoriteCities') ?? [];
    if (favoriteCities.isNotEmpty) {
      emit(FavoriteLoaded(favoriteCities));
      // Update widget with current favorites
      WidgetService.updateWidget(favoriteCities);
    }
  }

  void _saveFavorites(List<String> favoriteCities) {
    sharedPreferences.setStringList('favoriteCities', favoriteCities);
    // Update widget when favorites change
    WidgetService.updateWidget(favoriteCities);
  }

  void addFavoriteCity(String cityName) {
    if (state is FavoriteLoaded) {
      final currentFavorites = (state as FavoriteLoaded).favorites;
      if (!currentFavorites.contains(cityName)) {
        final updatedFavorites = [...currentFavorites, cityName];
        _updateFavorites(updatedFavorites);
      }
    } else {
      _updateFavorites([cityName]);
    }
    // Update widget when adding favorite
    WidgetService.addFavorite(cityName);
  }

  void removeFavoriteCity(String cityName) {
    if (state is FavoriteLoaded) {
      final updatedFavorites =
          (state as FavoriteLoaded).favorites.where((city) => city != cityName).toList();
      _updateFavorites(updatedFavorites);
    }
    // Update widget when removing favorite
    WidgetService.removeFavorite(cityName);
  }

  void _updateFavorites(List<String> favoriteCities) {
    emit(FavoriteLoaded(favoriteCities));
    _saveFavorites(favoriteCities);
  }
}
