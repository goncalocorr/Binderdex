import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/completion_ring.dart';
import '../widgets/dex_ui.dart';
import '../widgets/set_tile.dart';
import 'my_cards_screen.dart';

/// "O meu binder": painel pessoal único que reúne o progresso das minhas
/// coleções (as que já comecei = tenho ≥1 carta) — cartão hero, estatísticas
/// (sets feitos, holos, duplicados), coleção por tipo e a lista das minhas
/// coleções. Substitui as antigas tabs "Em falta" e "Progresso".
class MyBinderScreen extends ConsumerWidget {
  const MyBinderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final setsAsync = ref.watch(setsListProvider);
    final counts = ref.watch(statsCountsProvider);

    return setsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (sets) {
        // As minhas coleções = sets onde já tenho pelo menos 1 carta.
        final mine = sets.where((s) => s.progress.owned > 0).toList();

        if (mine.isEmpty) {
          return EmptyState(
            icon: Icons.collections_bookmark_outlined,
            title: t.noStartedCollections,
            description: t.noStartedCollectionsBody,
          );
        }

        final owned = mine.fold<int>(0, (a, s) => a + s.progress.owned);
        final total = mine.fold<int>(0, (a, s) => a + s.progress.total);
        final percent = total == 0 ? 0.0 : owned / total;

        return ListView(
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            // Subtítulo: N sets seguidos.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                t.setsFollowed(mine.length),
                style: AppTheme.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant),
              ),
            ),

            // Entrada para o marketplace da Comunidade.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.storefront),
                label: Text(AppLocalizations.of(context)!.sellOrTrade),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MyCardsScreen())),
              ),
            ),

            // Cartão hero de progresso das minhas coleções.
            _BinderHero(owned: owned, total: total, percent: percent),

            // Cartões-resumo (sets feitos / holos / duplicados).
            counts.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              data: (c) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                          icon: Icons.check_circle,
                          value: '${c.setsDone}',
                          label: t.statsSetsDone,
                          color: DexColors.gold500),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                          icon: Icons.auto_awesome,
                          value: '${c.holos}',
                          label: t.statsHolos,
                          color: DexColors.rarityHolo),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: StatCard(
                          icon: Icons.content_copy,
                          value: '${c.dupes}',
                          label: t.statsDuplicates,
                          color: DexColors.rarityRare),
                    ),
                  ],
                ),
              ),
            ),

            // Etiqueta + lista das minhas coleções (toca para abrir o set).
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Text(
                t.myCollections.toUpperCase(),
                style: AppTheme.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant),
              ),
            ),
            ...mine.map((s) => SetTile(
                  data: s,
                  onTap: () => context.push('/set/${s.set.id}'),
                )),
          ],
        );
      },
    );
  }
}

class _BinderHero extends StatelessWidget {
  final int owned;
  final int total;
  final double percent;
  const _BinderHero({
    required this.owned,
    required this.total,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: _Card(
        child: Row(
          children: [
            CompletionRing(percent: percent, size: 92, stroke: 10),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.cardsCountLabel(total)
                        .replaceFirst(RegExp(r'^\d+'), '$owned / $total'),
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.keepCompleting,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartão branco com sombra suave (estilo do Dex Design System).
class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
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
      child: child,
    );
  }
}
