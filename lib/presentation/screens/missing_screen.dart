import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../domain/entities/stats_scope.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';
import '../widgets/scope_bar.dart';

/// Em falta com âmbito: total por minhas coleções / todas / coleção focada,
/// e a lista das minhas coleções (tocar foca o total).
class MissingScreen extends ConsumerWidget {
  const MissingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final scope = ref.watch(missingScopeProvider);
    final missing = ref.watch(missingScopedProvider);
    final sets = ref.watch(setsListProvider);

    final scopeTitle = scope.isSet
        ? (scope.setName ?? '')
        : (scope.all ? t.allCards : t.myCollections);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        ScopeBar(
          provider: missingScopeProvider,
          mineLabel: t.myCollections,
          allLabel: t.allCards,
        ),
        const SizedBox(height: 16),
        // Total em falta do âmbito
        Container(
          padding: const EdgeInsets.all(18),
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
          child: missing.when(
            loading: () => const SizedBox(
                height: 48, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('$e'),
            data: (p) => Row(
              children: [
                Icon(Icons.search_off, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.missingTotal,
                          style: Theme.of(context).textTheme.titleMedium),
                      Text(scopeTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Text('${p.missing}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700, color: cs.primary)),
              ],
            ),
          ),
        ),
        if (scope.isSet) ...[
          const SizedBox(height: 10),
          FilledButton.icon(
            icon: const Icon(Icons.grid_view, size: 18),
            label: Text(t.viewMissingCards),
            onPressed: () =>
                context.push('/set/${scope.setId}?status=missing'),
          ),
        ],
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(t.myCollections.toUpperCase(),
              style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant)),
        ),
        sets.when(
          loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => Text('$e'),
          data: (list) {
            final mine = list
                .where((s) => s.progress.owned > 0 && s.progress.missing > 0)
                .toList();
            if (mine.isEmpty) {
              return EmptyState(
                  icon: Icons.collections_bookmark_outlined,
                  title: t.noStartedCollections,
                  description: t.noStartedCollectionsBody);
            }
            return Column(
              children: mine.map((s) {
                final focused = scope.setId == s.set.id;
                final tint = Color.alphaBlend(
                    cs.primary.withValues(alpha: 0.14),
                    cs.surfaceContainerHigh);
                return ListTile(
                  selected: focused,
                  selectedTileColor: cs.primaryContainer,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DexRadii.md)),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tint,
                      borderRadius: BorderRadius.circular(DexRadii.md),
                    ),
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(6),
                    child: s.set.symbolUrl.isEmpty
                        ? Icon(Icons.style, size: 20, color: cs.primary)
                        : CachedNetworkImage(
                            imageUrl: s.set.symbolUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox.shrink(),
                            errorWidget: (_, __, ___) =>
                                Icon(Icons.style, size: 20, color: cs.primary),
                          ),
                  ),
                  title: Text(s.set.name,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text('${s.progress.owned}/${s.progress.total}',
                      style: AppTheme.mono(fontSize: 11)),
                  trailing: Text(
                    t.missingCount(s.progress.missing),
                    style: AppTheme.mono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant),
                  ),
                  // Tocar foca o total nesta coleção.
                  onTap: () => ref.read(missingScopeProvider.notifier).state =
                      StatsScope(setId: s.set.id, setName: s.set.name),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
