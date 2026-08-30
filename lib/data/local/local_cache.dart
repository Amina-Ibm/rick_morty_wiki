abstract class LocalCache {
  Future<void> saveCharactersPage(int page, String? query, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCharactersPage(int page, String? query);
  
  Future<void> saveCharacter(int id, Map<String, dynamic> json);
  Future<Map<String, dynamic>?> getCharacter(int id);

  Future<List<Map<String, dynamic>>> getAllCachedCharacters();
}
