// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:dio/dio.dart';
import '../../data/repositories/character_repository_impl.dart';
import '../../domain/repositories/character_repository.dart';

/*
// --- API Client ---
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://rickandmortyapi.com/api',
  ));
});

// --- Local Storage / Cache ---
// Mock local cache provider for now
final localCacheProvider = Provider<dynamic>((ref) => throw UnimplementedError());

// --- Repositories ---
final characterRepositoryProvider = Provider<CharacterRepository>((ref) {
  return CharacterRepositoryImpl(
    apiClient: ref.watch(dioProvider),
    cache: ref.watch(localCacheProvider),
  );
});
*/
