import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/dex_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/card_tile.dart';
import '../widgets/dex_ui.dart';

/// Pesquisa global de cartas em todas as coleções já em cache.
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  static const _types = [
    'Fire',
    'Water',
    'Grass',
    'Lightning',
    'Psychic',
    'Fighting',
    'Darkness',
    'Metal',
    'Dragon',
    'Fairy',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final results = ref.watch(searchResultsProvider);
    final selTypes = ref.watch(searchTypesProvider);
    final missingOnly = ref.watch(searchMissingOnlyProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.tabSearch)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.searchAllHint,
              ),
              onChanged: (v) =>
                  ref.read(searchQueryProvider.notifier).state = v,
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                FilterChip(
                  label: Text(t.missingOnly),
                  selected: missingOnly,
                  onSelected: (v) =>
                      ref.read(searchMissingOnlyProvider.notifier).state = v,
                ),
                const SizedBox(width: 8),
                ..._types.map((ty) {
                  final on = selTypes.contains(ty);
                  final color = colorForCardType(ty);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(ty),
                      selected: on,
                      selectedColor: color.withValues(alpha: 0.22),
                      side: BorderSide(
                          color: on ? color : cs.outline),
                      onSelected: (_) {
                        final next = [...selTypes];
                        on ? next.remove(ty) : next.add(ty);
                        ref.read(searchTypesProvider.notifier).state = next;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    title: t.noMatch,
                    description: t.searchEmptyBody,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                      child: Text(t.cardsCountLabel(items.length),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: items.length,
                        itemBuilder: (_, i) => CardTile(
                          item: items[i],
                          onTap: () =>
                              context.push('/card/${items[i].card.id}'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
