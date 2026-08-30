import '../../core/utils/result.dart';
import '../models/character.dart';

abstract class CharacterRepository {
  /// Fetches a paginated list of characters, optionally filtered by name.
  /// Returns an empty list if search yields no results (404 handled gracefully).
  Future<Result<List<Character>>> getCharacters({int page = 1, String? name});
  
  /// Fetches details for a single character by id.
  Future<Result<Character>> getCharacter(int id);
}
