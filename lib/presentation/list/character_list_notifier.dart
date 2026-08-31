import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/connectivity/connectivity_provider.dart';
import '../../core/di/providers.dart';
import '../../core/utils/result.dart';
import '../../domain/models/character.dart';
import '../../domain/models/paginated_list.dart';
import 'character_list_state.dart';

class CharacterListNotifier extends AsyncNotifier<CharacterListState> {
  int _page = 1;
  String _currentQuery = '';
  String? _currentStatus;
  String? _currentSpecies;
  Timer? _debounceTimer;
  int _fetchId = 0;

  @override
  FutureOr<CharacterListState> build() async {
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // Auto-recover when connectivity returns
    ref.listen(connectivityProvider, (previous, next) {
      final results = next.value;
      if (results != null && !results.contains(ConnectivityResult.none)) {
        final currentState = state.value;
        // If we are currently showing cached data and network comes back, auto-refresh
        if (currentState != null && currentState.isFromCache) {
          _silentRetry();
        }
      }
    });

    return _fetchInitial();
  }

  Future<void> _silentRetry() async {
    _fetchId++;
    final currentFetchId = _fetchId;

    final repo = ref.read(characterRepositoryProvider);
    final result = await repo.getCharacters(
      page: 1,
      name: _currentQuery,
      status: _currentStatus,
      species: _currentSpecies,
    );

    if (currentFetchId != _fetchId) return;

    if (result is Success<PaginatedList<Character>>) {
      _page = 1;
      final data = result.data;
      state = AsyncData(
        CharacterListState(
          characters: data.items,
          hasMore: data.hasMore,
          isLoadingMore: false,
          isFromCache: data.isFromCache,
          query: _currentQuery,
          status: _currentStatus,
          species: _currentSpecies,
          cachedAt: data.cachedAt,
        ),
      );
    }
  }

  Future<CharacterListState> _fetchInitial() async {
    _page = 1;
    final repo = ref.watch(characterRepositoryProvider);
    final result = await repo.getCharacters(
      page: _page,
      name: _currentQuery,
      status: _currentStatus,
      species: _currentSpecies,
    );

    if (result is Success<PaginatedList<Character>>) {
      final data = result.data;
      return CharacterListState(
        characters: data.items,
        hasMore: data.hasMore,
        isLoadingMore: false,
        isFromCache: data.isFromCache,
        query: _currentQuery,
        status: _currentStatus,
        species: _currentSpecies,
        cachedAt: data.cachedAt,
      );
    } else {
      throw (result as Failure).error;
    }
  }

  void onSearchChanged(String query) {
    if (query == _currentQuery) return;

    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _currentQuery = query;
      _currentStatus = null;
      _currentSpecies = null;
      _fetchId++;
      final currentFetchId = _fetchId;

      state = const AsyncLoading();

      _fetchInitial()
          .then((newState) {
            if (currentFetchId == _fetchId) state = AsyncData(newState);
          })
          .catchError((error, stackTrace) {
            if (currentFetchId == _fetchId) {
              state = AsyncError(error, stackTrace);
            }
          });
    });
  }

  void onFilterChanged({String? status, String? species}) {
    _currentStatus = status;
    _currentSpecies = species;

    _debounceTimer?.cancel();
    _fetchId++;
    final currentFetchId = _fetchId;

    state = const AsyncLoading();

    _fetchInitial()
        .then((newState) {
          if (currentFetchId == _fetchId) state = AsyncData(newState);
        })
        .catchError((error, stackTrace) {
          if (currentFetchId == _fetchId) state = AsyncError(error, stackTrace);
        });
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        !currentState.hasMore) {
      return;
    }

    state = AsyncData(currentState.copyWith(isLoadingMore: true));

    final nextPage = _page + 1;
    final repo = ref.read(characterRepositoryProvider);
    final currentFetchId = _fetchId;

    final result = await repo.getCharacters(
      page: nextPage,
      name: _currentQuery,
      status: _currentStatus,
      species: _currentSpecies,
    );

    if (currentFetchId != _fetchId) return;

    if (result is Success<PaginatedList<Character>>) {
      _page = nextPage;
      final data = result.data;
      state = AsyncData(
        currentState.copyWith(
          characters: [...currentState.characters, ...data.items],
          hasMore: data.hasMore,
          isLoadingMore: false,
          isFromCache: data.isFromCache,
          cachedAt: data.cachedAt,
        ),
      );
    } else {
      state = AsyncData(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> refresh() async {
    _debounceTimer?.cancel();
    _fetchId++;
    _currentQuery = '';
    _currentStatus = null;
    _currentSpecies = null;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchInitial());
  }
}

final characterListNotifierProvider =
    AsyncNotifierProvider.autoDispose<
      CharacterListNotifier,
      CharacterListState
    >(() => CharacterListNotifier());
