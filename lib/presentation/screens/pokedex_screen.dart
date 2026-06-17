import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/pokemon_card.dart';

/// Grelha principal: pesquisa + filtros + cartões.
class PokedexScreen extends ConsumerWidget {
  const PokedexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final listAsync = ref.watch(pokedexListProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: t.searchHint,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    final f = ref.read(filterProvider);
                    ref.read(filterProvider.notifier).state =
                        f.copyWith(query: v);
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                tooltip: t.filterStatus,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (_) => const FilterSheet(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: listAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (items) => items.isEmpty
                ? const Center(child: Text('—'))
                : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final it = items[i];
                      return PokemonCard(
                        pokemon: it.pokemon,
                        caught: it.caught,
                        shiny: it.shiny,
                        onTap: () => context.push('/pokemon/${it.pokemon.id}'),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
