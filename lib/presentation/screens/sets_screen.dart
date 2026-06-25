import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/completion_ring.dart';
import '../widgets/set_tile.dart';

/// Ecrã inicial: cartão "hero" de progresso global + lista de coleções (sets).
class SetsScreen extends ConsumerWidget {
  const SetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final setsAsync = ref.watch(setsListProvider);
    final query = ref.watch(setSearchProvider).toLowerCase();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.searchSetsHint,
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
              // Cabeçalhos fixos; os SetTile (até 173) são construídos
              // preguiçosamente à medida que entram no ecrã.
              final header = <Widget>[
                if (query.isEmpty) _HeroProgress(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Text(t.tabSets.toUpperCase(),
                      style: AppTheme.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant)),
                ),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(child: Text(t.noSets)),
                  ),
              ];
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: header.length + filtered.length,
                itemBuilder: (context, i) {
                  if (i < header.length) return header[i];
                  final s = filtered[i - header.length];
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

class _HeroProgress extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final global = ref.watch(globalProgressProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(DexRadii.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                  alpha: Theme.of(context).brightness == Brightness.dark
                      ? 0.35
                      : 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: global.when(
          loading: () => const SizedBox(
              height: 92, child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('$e'),
          data: (p) => Row(
            children: [
              CompletionRing(percent: p.percent, size: 92, stroke: 10),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${p.owned} / ${p.total}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(t.cardsCollected,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(t.missingCount(p.missing),
                        style: AppTheme.mono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: DexColors.gold500)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
