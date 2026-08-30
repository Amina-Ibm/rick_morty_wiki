import 'package:dio/dio.dart';
import '../../core/utils/result.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/character.dart';
import '../../domain/models/paginated_list.dart';
import '../../domain/repositories/character_repository.dart';
import '../local/local_cache.dart';
import '../remote/dtos/character_dto.dart';
import '../remote/dtos/paginated_response_dto.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final Dio _apiClient;
  final LocalCache _cache;
  
  CharacterRepositoryImpl({required Dio apiClient, required LocalCache cache}) 
      : _apiClient = apiClient, _cache = cache;

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.sendTimeout ||
           e.type == DioExceptionType.connectionError ||
           e.type == DioExceptionType.unknown; // Sometimes socket exceptions fall here
  }

  @override
  Future<Result<PaginatedList<Character>>> getCharacters({int page = 1, String? name}) async {
    try {
      final queryParams = {'page': page};
      if (name != null && name.isNotEmpty) {
        queryParams['name'] = name;
      }

      final response = await _apiClient.get('/character', queryParameters: queryParams);
      
      final data = response.data as Map<String, dynamic>;
      final dto = PaginatedResponseDto<CharacterDto>.fromJson(
        data, 
        (json) => CharacterDto.fromJson(json)
      );
      
      final characters = dto.results.map((c) => Character.fromDto(c)).toList();
      final hasMore = dto.next != null;

      // Save raw JSON to cache
      await _cache.saveCharactersPage(page, name, data);

      return Success(PaginatedList(
        items: characters, 
        hasMore: hasMore,
        isFromCache: false,
      ));

    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // API returns 404 when search yields zero results. 
        // We catch this and return an empty list instead of a failure.
        return const Success(PaginatedList(items: [], hasMore: false));
      }

      if (_isNetworkError(e)) {
        // Attempt to serve from cache when offline
        try {
          final cachedData = await _cache.getCharactersPage(page, name);
          if (cachedData != null) {
            final dto = PaginatedResponseDto<CharacterDto>.fromJson(
              cachedData, 
              (json) => CharacterDto.fromJson(json)
            );
            final characters = dto.results.map((c) => Character.fromDto(c)).toList();
            return Success(PaginatedList(
              items: characters, 
              hasMore: dto.next != null,
              isFromCache: true, // Flag as cached data
            ));
          }
        } catch (cacheError) {
          return const Failure(ParseFailure('Failed to parse cached data'));
        }
        return const Failure(NetworkFailure());
      }
      return Failure(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return const Failure(ParseFailure());
    }
  }

  @override
  Future<Result<Character>> getCharacter(int id) async {
    try {
      final response = await _apiClient.get('/character/$id');
      final data = response.data as Map<String, dynamic>;
      
      final dto = CharacterDto.fromJson(data);
      final character = Character.fromDto(dto);

      await _cache.saveCharacter(id, data);

      return Success(character);
    } on DioException catch (e) {
      if (_isNetworkError(e)) {
        try {
          final cachedData = await _cache.getCharacter(id);
          if (cachedData != null) {
             final dto = CharacterDto.fromJson(cachedData);
             return Success(Character.fromDto(dto));
          }
        } catch (_) {}
        return const Failure(NetworkFailure());
      }
      if (e.response?.statusCode == 404) {
        return const Failure(NotFoundFailure('Character not found'));
      }
      return Failure(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return const Failure(ParseFailure());
    }
  }
}
