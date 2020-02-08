import 'datamanager.dart';
import 'models.dart';

abstract class IFavoritesManager {
  Future<List<Station>> getFavorites();
  void saveAsFavorite(Station station);
  void removeAsFavorite(Station station);
}

class FavoritesManager extends IFavoritesManager {
  static const String FAVORITE_KEY = 'favoriteStations';

  List<Station> _favorites;
  IDataManager _dataManager;

  FavoritesManager(IDataManager dataManager) {
    _dataManager = dataManager;
  }

  Future<bool> init() async {
    // fecth list from file
    var ids = await _dataManager.loadString(FAVORITE_KEY);

    // For now we store just the IDs, when we have a more advanced storage we should save also other info
    _favorites = ids != null
        ? ids.map((id) => Station(int.parse(id))).toList()
        : List<Station>();

    return true;
  }

  @override
  Future<List<Station>> getFavorites() async {
    if (_favorites == null) {
      await init();
    }

    return _favorites;
  }

  @override
  void saveAsFavorite(Station station) {
    if (_favorites == null) {
      init();
    }

    if (!_favorites.any((s) => s.id == station.id)) {
      _favorites.add(station);

      // save in data storage
      _dataManager.saveStrings(
          FAVORITE_KEY, _favorites.map((st) => st.id.toString()).toList());
    }
  }

  @override
  void removeAsFavorite(Station station) {
    if (_favorites == null) {
      init();
    }

    _favorites.removeWhere((s) => s.id == station.id);

    // save in data storage
    _dataManager.saveStrings(
        FAVORITE_KEY, _favorites.map((st) => st.id.toString()).toList());
  }
}
