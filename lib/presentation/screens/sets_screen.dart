import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/set_tile.dart';

/// Ecrã inicial: lista de coleções (sets) com progresso.
class SetsScreen extends ConsumerWidget {
  const SetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final setsAsync = ref.watch(setsListProvider);
    final query = ref.watch(setSearchProvider).toLowerCase();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.searchSetsHint,
              isDense: true,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => ref.read(setSearchProvider.notifier).state = v,
          ),
        ),
        Expanded(
          child: setsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (sets) {
              final filtered = query.isEmpty
                  ? sets
                  : sets
                      .where((s) =>
                          s.set.name.toLowerCase().contains(query) ||
                          s.set.series.toLowerCase().contains(query))
                      .toList();
              if (filtered.isEmpty) return Center(child: Text(t.noSets));
              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final s = filtered[i];
                  return SetTile(
                    data: s,
                    onTap: () => context.push('/set/${s.set.id}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
