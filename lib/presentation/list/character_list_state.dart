import '../../domain/models/character.dart';

class CharacterListState {
  final List<Character> characters;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isFromCache;
  final String query;
  final String? status;
  final String? species;
  final DateTime? cachedAt;

  const CharacterListState({
    required this.characters,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isFromCache,
    required this.query,
    this.status,
    this.species,
    this.cachedAt,
  });

  CharacterListState copyWith({
    List<Character>? characters,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFromCache,
    String? query,
    String? status,
    String? species,
    DateTime? cachedAt,
  }) {
    return CharacterListState(
      characters: characters ?? this.characters,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFromCache: isFromCache ?? this.isFromCache,
      query: query ?? this.query,
      status: status ?? this.status,
      species: species ?? this.species,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }
}
