import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rick_morty_wiki/data/local/local_cache.dart';
import 'package:rick_morty_wiki/data/repositories/character_repository_impl.dart';
import 'package:rick_morty_wiki/core/utils/result.dart';
import 'package:rick_morty_wiki/domain/models/paginated_list.dart';
import 'package:rick_morty_wiki/domain/models/character.dart';
import 'package:rick_morty_wiki/domain/failures/app_failure.dart';

class MockDio extends Mock implements Dio {}
class MockLocalCache extends Mock implements LocalCache {}

void main() {
  late MockDio mockDio;
  late MockLocalCache mockCache;
  late CharacterRepositoryImpl repository;

  setUp(() {
    mockDio = MockDio();
    mockCache = MockLocalCache();
    repository = CharacterRepositoryImpl(apiClient: mockDio, cache: mockCache);
  });

  test('getCharacters returns success path', () async {
    final responseData = {
      'info': {'count': 1, 'pages': 1, 'next': null, 'prev': null},
      'results': [
        {
          'id': 1,
          'name': 'Rick Sanchez',
          'status': 'Alive',
          'species': 'Human',
          'image': 'img.jpg',
          'gender': 'Male',
          'origin': {'name': 'Earth', 'url': 'url'},
          'location': {'name': 'Earth', 'url': 'url'},
          'episode': [],
        }
      ]
    };

    when(() => mockDio.get('/character', queryParameters: any(named: 'queryParameters')))
        .thenAnswer((_) async => Response(
              data: responseData,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/character'),
            ));
    
    when(() => mockCache.saveCharactersPage(any(), any(), any())).thenAnswer((_) async {});

    final result = await repository.getCharacters();

    expect(result, isA<Success<PaginatedList<Character>>>());
    final success = result as Success<PaginatedList<Character>>;
    expect(success.data.items.length, 1);
    expect(success.data.items.first.name, 'Rick Sanchez');
  });

  test('getCharacters returns empty on 404', () async {
    when(() => mockDio.get('/character', queryParameters: any(named: 'queryParameters')))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: '/character'),
      response: Response(statusCode: 404, requestOptions: RequestOptions(path: '/character')),
    ));

    final result = await repository.getCharacters(name: 'unknown_character');

    expect(result, isA<Success<PaginatedList<Character>>>());
    final success = result as Success<PaginatedList<Character>>;
    expect(success.data.items, isEmpty);
  });

  test('getCharacters returns NetworkFailure on connection error when cache is empty', () async {
    when(() => mockDio.get('/character', queryParameters: any(named: 'queryParameters')))
        .thenThrow(DioException(
      requestOptions: RequestOptions(path: '/character'),
      type: DioExceptionType.connectionTimeout,
    ));
    
    when(() => mockCache.getCharactersPage(any(), any())).thenAnswer((_) async => null);

    final result = await repository.getCharacters();

    expect(result, isA<Failure<PaginatedList<Character>>>());
    final failure = result as Failure<PaginatedList<Character>>;
    expect(failure.error, isA<NetworkFailure>());
  });
}
