import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/local/hive_local_cache.dart';
import '../../data/local/local_cache.dart';
import '../../data/local/favourites_store.dart';
import '../../data/local/hive_favourites_store.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../domain/repositories/character_repository.dart';

// --- API Client ---
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://rickandmortyapi.com/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

// --- Local Storage / Cache ---
final localCacheProvider = Provider<LocalCache>((ref) {
  return HiveLocalCache();
});

final favouritesStoreProvider = Provider<FavouritesStore>((ref) {
  return HiveFavouritesStore();
});

// --- Repositories ---
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepositoryImpl(
    apiClient: ref.watch(dioProvider),
    cache: ref.watch(localCacheProvider),
  );
});
