import '../../core/utils/result.dart';
import '../models/character.dart';
import '../models/paginated_list.dart';

abstract class CharacterRepository {
  Future<Result<PaginatedList<Character>>> getCharacters({
    int page = 1,
    String? name,
  });

  Future<Result<Character>> getCharacter(int id);
}
