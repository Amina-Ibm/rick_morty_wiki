import '../../core/utils/result.dart';
import '../../domain/models/character.dart';
import '../../domain/repositories/character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  // Dependencies like Dio and LocalCache will be injected here.
  
  // final Dio _apiClient;
  // final LocalCache _cache;
  
  // CharacterRepositoryImpl({required Dio apiClient, required LocalCache cache}) 
  //     : _apiClient = apiClient, _cache = cache;

  @override
  Future<Result<List<Character>>> getCharacters({int page = 1, String? name}) async {
    // TODO: Implement API call, DTO mapping, caching, and error handling.
    // Important: Handle 404 for empty search as Success([]) instead of Failure.
    throw UnimplementedError();
  }

  @override
  Future<Result<Character>> getCharacter(int id) async {
    // TODO: Implement API call, local cache lookup for offline, and mapping.
    throw UnimplementedError();
  }
}
