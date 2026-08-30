import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import '../../core/di/providers.dart';
import '../../core/utils/result.dart';
import '../../domain/models/character.dart';
import 'favourites_notifier.dart';
import '../widgets/character_card.dart';
import '../detail/character_detail_screen.dart';

final favouriteCharacterProvider = FutureProvider.family<Character, int>((ref, id) async {
  final repo = ref.read(characterRepositoryProvider);
  final result = await repo.getCharacter(id);
  if (result is Success<Character>) {
    return result.data;
  }
  throw (result as Failure).error;
});

class FavouritesScreen extends ConsumerWidget {
  const FavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favouritesAsync = ref.watch(favouritesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
      ),
      body: favouritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading favourites')),
        data: (favourites) {
          if (favourites.isEmpty) {
            return Center(
              child: Text(
                'No favourites yet',
                style: TextStyle(fontSize: 16.sp, color: Colors.white70),
              ),
            );
          }

          final favList = favourites.toList();

          return ListView.builder(
            itemCount: favList.length,
            itemBuilder: (context, index) {
              final id = favList[index];
              final charAsync = ref.watch(favouriteCharacterProvider(id));

              return charAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => const SizedBox.shrink(), // Ignore or show error tile
                data: (character) {
                  return CharacterCard(
                    character: character,
                    isFavourite: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CharacterDetailScreen(character: character),
                        ),
                      );
                    },
                    onFavouriteToggle: () {
                      ref.read(favouritesNotifierProvider.notifier).toggleFavourite(character.id);
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
