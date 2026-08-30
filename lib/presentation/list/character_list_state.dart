import '../../domain/failures/app_failure.dart';
import '../../domain/models/character.dart';

class CharacterListState {
  final List<Character> characters;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isFromCache;
  final String query;

  const CharacterListState({
    required this.characters,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isFromCache,
    required this.query,
  });

  CharacterListState copyWith({
    List<Character>? characters,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isFromCache,
    String? query,
  }) {
    return CharacterListState(
      characters: characters ?? this.characters,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFromCache: isFromCache ?? this.isFromCache,
      query: query ?? this.query,
    );
  }
}
