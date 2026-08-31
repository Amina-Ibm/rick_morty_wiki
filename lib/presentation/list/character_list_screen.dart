import 'package:choice/choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

import '../detail/character_detail_screen.dart';
import '../favourites/favourites_notifier.dart';
import '../theme/theme_provider.dart';
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

  final List<String> statusOptions = ['alive', 'dead'];
  final List<String> speciesOptions = ['human', 'alien'];

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
    final currentStatus = stateAsync.value?.status;
    final currentSpecies = stateAsync.value?.species;
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rick & Morty'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(20.h),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => ref
                      .read(characterListNotifierProvider.notifier)
                      .onSearchChanged(val),
                  decoration: InputDecoration(
                    hintText: 'Search characters',
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(characterListNotifierProvider.notifier)
                            .onSearchChanged('');
                      },
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Text(
                      'Filter by status:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: InlineChoice<String>(
                        clearable: true,
                        multiple: false,
                        value: ChoiceSingle.value(currentStatus),
                        onChanged: ChoiceSingle.onChanged((val) {
                          ref
                              .read(characterListNotifierProvider.notifier)
                              .onFilterChanged(
                                status: val,
                                species: currentSpecies,
                              );
                        }),
                        itemCount: statusOptions.length,
                        itemBuilder: (state, i) {
                          return ChoiceChip(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                              child: Text(
                                statusOptions[i],
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            selected: state.selected(statusOptions[i]),
                            onSelected: state.onSelected(statusOptions[i]),
                          );
                        },
                        listBuilder: ChoiceList.createScrollable(
                          spacing: 3.w,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Filter by species:',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 3.w),

                    Expanded(
                      child: InlineChoice<String>(
                        clearable: true,
                        multiple: false,
                        value: ChoiceSingle.value(currentSpecies),
                        onChanged: ChoiceSingle.onChanged((val) {
                          ref
                              .read(characterListNotifierProvider.notifier)
                              .onFilterChanged(
                                status: currentStatus,
                                species: val,
                              );
                        }),
                        itemCount: speciesOptions.length,
                        itemBuilder: (state, i) {
                          return ChoiceChip(
                            label: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 1.w),
                              child: Text(
                                speciesOptions[i],
                                maxLines: 1,
                                overflow: TextOverflow.visible,
                              ),
                            ),
                            selected: state.selected(speciesOptions[i]),
                            onSelected: state.onSelected(speciesOptions[i]),
                          );
                        },
                        listBuilder: ChoiceList.createScrollable(
                          spacing: 3.w,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
                          color: themeMode == ThemeMode.dark
                              ? Colors.white70
                              : Colors.black54,
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
