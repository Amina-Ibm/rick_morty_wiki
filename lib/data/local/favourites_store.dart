abstract class FavouritesStore {
  Future<void> saveFavourites(Set<int> ids);
  Future<Set<int>> loadFavourites();
}
