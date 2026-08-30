import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../detail/character_detail_screen.dart';
import '../favourites/favourites_notifier.dart';
import '../widgets/character_card.dart';
import '../widgets/offline_banner.dart';
import 'character_list_notifier.dart';

class CharacterListScreen extends ConsumerStatefulWidget {
  const CharacterListScreen({super.key});

  @override
  ConsumerState<CharacterListScreen> createState() =>
      _CharacterListScreenState();
}

class _CharacterListScreenState extends ConsumerState<CharacterListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(characterListNotifierProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(characterListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rick & Morty'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(8.h),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => ref
                  .read(characterListNotifierProvider.notifier)
                  .onSearchChanged(val),
              decoration: InputDecoration(
                hintText: 'Search characters...',
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54),
                  onPressed: () {
                    _searchController.clear();
                    ref
                        .read(characterListNotifierProvider.notifier)
                        .onSearchChanged('');
                  },
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _searchController.clear();
          await ref.read(characterListNotifierProvider.notifier).refresh();
        },
        child: stateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Something went wrong', style: TextStyle(fontSize: 14.sp)),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => ref
                      .read(characterListNotifierProvider.notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (state) {
            final isOffline = state.isFromCache;
            final characters = state.characters;

            return Column(
              children: [
                if (isOffline) OfflineBanner(cachedAt: state.cachedAt),
                if (characters.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        'No characters found for "${state.query}"',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          characters.length + (state.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == characters.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final character = characters[index];
                        final isFav =
                            ref
                                .watch(favouritesNotifierProvider)
                                .value
                                ?.contains(character.id) ??
                            false;

                        return CharacterCard(
                          character: character,
                          isFavourite: isFav,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CharacterDetailScreen(character: character),
                              ),
                            );
                          },
                          onFavouriteToggle: () {
                            ref
                                .read(favouritesNotifierProvider.notifier)
                                .toggleFavourite(character.id);
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
