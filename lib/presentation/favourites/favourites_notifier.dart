import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';

class FavouritesNotifier extends AutoDisposeAsyncNotifier<Set<int>> {
  @override
  FutureOr<Set<int>> build() async {
    final store = ref.watch(favouritesStoreProvider);
    return await store.loadFavourites();
  }

  Future<void> toggleFavourite(int id) async {
    final currentFavourites = state.value;
    if (currentFavourites == null) return;

    final newFavourites = Set<int>.from(currentFavourites);
    if (newFavourites.contains(id)) {
      newFavourites.remove(id);
    } else {
      newFavourites.add(id);
    }

    // Optimistic UI update
    state = AsyncData(newFavourites);
    
    // Persist to local storage
    try {
      final store = ref.read(favouritesStoreProvider);
      await store.saveFavourites(newFavourites);
    } catch (e) {
      // If saving fails, revert to previous state
      state = AsyncData(currentFavourites);
      // Depending on requirements, we could also log this error or show a snackbar
    }
  }

  bool isFavourite(int id) {
    return state.value?.contains(id) ?? false;
  }
}

final favouritesNotifierProvider =
    AsyncNotifierProvider.autoDispose<FavouritesNotifier, Set<int>>(
  () => FavouritesNotifier(),
);
