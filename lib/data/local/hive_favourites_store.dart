import 'package:hive/hive.dart';
import 'favourites_store.dart';

class HiveFavouritesStore implements FavouritesStore {
  static const String _boxName = 'favourites_box';
  static const String _key = 'favourite_ids';

  Future<Box<List<dynamic>>> _openBox() async => await Hive.openBox<List<dynamic>>(_boxName);

  @override
  Future<Set<int>> loadFavourites() async {
    final box = await _openBox();
    final list = box.get(_key, defaultValue: <dynamic>[]);
    return list?.cast<int>().toSet() ?? <int>{};
  }

  @override
  Future<void> saveFavourites(Set<int> ids) async {
    final box = await _openBox();
    await box.put(_key, ids.toList());
  }
}
