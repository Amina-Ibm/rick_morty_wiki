import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import '../../domain/models/character.dart';
import '../theme/app_theme.dart';
import '../favourites/favourites_notifier.dart';

class CharacterDetailScreen extends ConsumerWidget {
  final Character character;

  const CharacterDetailScreen({super.key, required this.character});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favouritesNotifierProvider).value?.contains(character.id) ?? false;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.redAccent : Colors.white,
              size: 24.sp,
            ),
            onPressed: () {
              ref.read(favouritesNotifierProvider.notifier).toggleFavourite(character.id);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: 'character_${character.id}',
              child: Image.network(
                character.imageUrl,
                height: 50.h,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 50.h,
                  color: Colors.grey,
                  child: const Icon(Icons.broken_image, size: 100),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    character.name,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.creamText,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Container(
                        width: 3.w,
                        height: 3.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: character.status == CharacterStatus.alive
                              ? Colors.green
                              : character.status == CharacterStatus.dead
                                  ? Colors.red
                                  : Colors.grey,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${character.status.name.toUpperCase()} - ${character.species}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  // Add more details here (e.g. Origin, Location) as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
