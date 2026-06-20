import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../domain/entities/card_filter.dart';
import '../../domain/entities/stats_scope.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/completion_ring.dart';
import '../widgets/dex_ui.dart';
import '../widgets/scope_bar.dart';

/// Estatísticas com âmbito: anel + cartões + por tipo reagem ao âmbito
/// (as minhas coleções / todas / uma coleção focada).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  void _openCards(BuildContext context, WidgetRef ref, StatsScope scope,
      CardStatusFilter status) {
    if (scope.isSet) {
      context.push('/set/${scope.setId}?status=${status.name}');
    } else {
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(searchTypesProvider.notifier).state = const [];
      ref.read(searchStatusProvider.notifier).state = status;
      context.push('/search');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final scope = ref.watch(progressScopeProvider);
    final progress = ref.watch(progressScopedProvider);
    final counts = ref.watch(progressStatsScopedProvider);
    final byType = ref.watch(progressByTypeScopedProvider);
    final sets = ref.watch(setsListProvider);

    final scopeTitle = scope.isSet
        ? (scope.setName ?? '')
        : (scope.all ? t.allCards : t.myCollections);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ScopeBar(
          provider: progressScopeProvider,
          mineLabel: t.myCollections,
          allLabel: t.allCards,
        ),
        const SizedBox(height: 16),
        // Anel do âmbito atual
        Center(
          child: progress.when(
            loading: () => const SizedBox(
                height: 148, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('$e'),
            data: (p) => Column(
              children: [
                CompletionRing(
                    percent: p.percent,
                    size: 148,
                    stroke: 14,
                    sublabel: '${p.owned}/${p.total}'),
                const SizedBox(height: 10),
                Text(scopeTitle,
                    style: Theme.of(context).textTheme.titleMedium),
                Text(t.missingCount(p.missing),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Cartões-resumo (do âmbito)
        counts.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('$e'),
          data: (c) => Row(
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
        const SizedBox(height: 14),
        // Ver as que tenho / em falta (do âmbito)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.style, size: 18),
                label: Text(t.statusOwned),
                onPressed: () =>
                    _openCards(context, ref, scope, CardStatusFilter.owned),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.search_off, size: 18),
                label: Text(t.statusMissing),
                onPressed: () =>
                    _openCards(context, ref, scope, CardStatusFilter.missing),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Coleção por tipo (do âmbito)
        byType.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('$e'),
          data: (rows) {
            if (rows.isEmpty) return const SizedBox.shrink();
            final max = rows.first.owned;
            return _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.statsByType.toUpperCase(),
                      style: AppTheme.mono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant)),
                  const SizedBox(height: 14),
                  ...rows.take(8).map((r) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            SizedBox(
                                width: 120,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: TypeBadge(r.type, soft: true))),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(DexRadii.pill),
                                child: LinearProgressIndicator(
                                  value: max <= 0
                                      ? 0
                                      : (r.owned / max).clamp(0.0, 1.0),
                                  minHeight: 10,
                                  color: colorForCardType(r.type),
                                  backgroundColor: cs.surfaceContainerHigh,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 34,
                              child: Text(' ${r.owned}',
                                  textAlign: TextAlign.right,
                                  style: AppTheme.mono(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurface)),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // As minhas coleções — tocar foca o âmbito
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(t.myCollections.toUpperCase(),
              style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant)),
        ),
        sets.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('$e'),
          data: (list) {
            final mine = list.where((s) => s.progress.owned > 0).toList();
            if (mine.isEmpty) {
              return Text(t.noStartedCollectionsBody,
                  style: TextStyle(color: cs.onSurfaceVariant));
            }
            return Column(
              children: mine.map((s) {
                final done = s.progress.owned >= s.progress.total;
                final color = done ? DexColors.gold500 : DexColors.green500;
                final focused = scope.setId == s.set.id;
                return InkWell(
                  borderRadius: BorderRadius.circular(DexRadii.md),
                  onTap: () => ref.read(progressScopeProvider.notifier).state =
                      StatsScope(setId: s.set.id, setName: s.set.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    decoration: BoxDecoration(
                      color: focused ? cs.primaryContainer : null,
                      borderRadius: BorderRadius.circular(DexRadii.md),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(s.set.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                            ),
                            Text('${s.progress.owned}/${s.progress.total}',
                                style: AppTheme.mono(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: color)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(DexRadii.pill),
                          child: LinearProgressIndicator(
                            value: s.progress.percent,
                            minHeight: 6,
                            color: color,
                            backgroundColor: cs.surfaceContainerHigh,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(DexRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.35
                    : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
