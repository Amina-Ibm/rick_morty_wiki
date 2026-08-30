import 'dart:convert';
import 'package:hive/hive.dart';
import 'local_cache.dart';

class HiveLocalCache implements LocalCache {
  static const String _pageBoxName = 'characters_page_box';
  static const String _characterBoxName = 'character_detail_box';

  Future<Box<String>> _openPageBox() async => await Hive.openBox<String>(_pageBoxName);
  Future<Box<String>> _openCharacterBox() async => await Hive.openBox<String>(_characterBoxName);

  String _buildPageKey(int page, String? query) {
    return 'page_${page}_query_${query?.toLowerCase() ?? "none"}';
  }

  @override
  Future<void> saveCharactersPage(int page, String? query, Map<String, dynamic> json) async {
    final box = await _openPageBox();
    await box.put(_buildPageKey(page, query), jsonEncode(json));
  }

  @override
  Future<Map<String, dynamic>?> getCharactersPage(int page, String? query) async {
    final box = await _openPageBox();
    final data = box.get(_buildPageKey(page, query));
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<void> saveCharacter(int id, Map<String, dynamic> json) async {
    final box = await _openCharacterBox();
    await box.put(id.toString(), jsonEncode(json));
  }

  @override
  Future<Map<String, dynamic>?> getCharacter(int id) async {
    final box = await _openCharacterBox();
    final data = box.get(id.toString());
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllCachedCharacters() async {
    final pageBox = await _openPageBox();
    final List<Map<String, dynamic>> allCharacters = [];
    final seenIds = <int>{};

    for (final key in pageBox.keys) {
      final dataStr = pageBox.get(key);
      if (dataStr != null) {
        final data = jsonDecode(dataStr) as Map<String, dynamic>;
        final results = data['results'] as List<dynamic>?;
        if (results != null) {
          for (final item in results) {
            final charMap = item as Map<String, dynamic>;
            final id = charMap['id'] as int;
            if (!seenIds.contains(id)) {
              seenIds.add(id);
              allCharacters.add(charMap);
            }
          }
        }
      }
    }
    return allCharacters;
  }
}
