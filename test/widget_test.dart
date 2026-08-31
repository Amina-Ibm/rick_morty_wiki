import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hive/hive.dart';
import 'package:rick_morty_wiki/core/di/providers.dart';
import 'package:rick_morty_wiki/core/utils/result.dart';
import 'package:rick_morty_wiki/domain/models/character.dart';
import 'package:rick_morty_wiki/domain/models/origin.dart';
import 'package:rick_morty_wiki/domain/models/paginated_list.dart';
import 'package:rick_morty_wiki/domain/repositories/character_repository.dart';
import 'package:rick_morty_wiki/main.dart';
import 'package:rick_morty_wiki/presentation/widgets/character_card.dart';

class MockCharacterRepository extends Mock implements CharacterRepository {}

void main() {
  late MockCharacterRepository mockRepo;
  late String tempPath;

  setUp(() async {
    tempPath = Directory.systemTemp.createTempSync().path;
    Hive.init(tempPath);
    await Hive.openBox('themeBox');
    await Hive.openBox('favouritesBox');
    
    mockRepo = MockCharacterRepository();
  });

  tearDown(() async {
    await Hive.close();
    try {
      Directory(tempPath).deleteSync(recursive: true);
    } catch (_) {}
  });

  testWidgets('List screen renders characters and interacts', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final characters = [
      Character(
        id: 1,
        name: 'Rick Sanchez',
        status: CharacterStatus.alive,
        species: 'Human',
        imageUrl: 'url1',
        gender: 'Male',
        origin: Origin(name: 'Earth', url: 'url'),
        location: 'Earth',
      ),
      Character(
        id: 2,
        name: 'Morty Smith',
        status: CharacterStatus.alive,
        species: 'Human',
        imageUrl: 'url2',
        gender: 'Male',
        origin: Origin(name: 'Earth', url: 'url'),
        location: 'Earth',
      ),
    ];

    when(
      () => mockRepo.getCharacters(
        page: any(named: 'page'),
        name: any(named: 'name'),
        status: any(named: 'status'),
        species: any(named: 'species'),
      ),
    ).thenAnswer(
      (_) async => Success(
        PaginatedList(items: characters, hasMore: false, isFromCache: false),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [characterRepositoryProvider.overrideWithValue(mockRepo)],
        child: const MyApp(),
      ),
    );

    // Initial loading state
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    // Wait for the async requests to finish
    await tester.pumpAndSettle();

    // The list should now be rendered
    expect(find.text('Rick Sanchez'), findsOneWidget);
    expect(find.text('Morty Smith'), findsOneWidget);
    expect(find.byType(CharacterCard), findsNWidgets(2));
  });
}
