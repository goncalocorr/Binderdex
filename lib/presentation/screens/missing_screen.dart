import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';

/// Em falta: total global + as minhas coleções (sets já começados) com o que falta.
class MissingScreen extends ConsumerWidget {
  const MissingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final global = ref.watch(globalProgressProvider);
    final sets = ref.watch(setsListProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Total em falta
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
          child: global.when(
            loading: () => const SizedBox(
                height: 48, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('$e'),
            data: (p) => Row(
              children: [
                Icon(Icons.search_off, color: cs.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(t.missingTotal,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                Text('${p.missing}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                            fontWeight: FontWeight.w700, color: cs.primary)),
              ],
            ),
          ),
        ),
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
                final tint = Color.alphaBlend(
                    cs.primary.withValues(alpha: 0.14),
                    cs.surfaceContainerHigh);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
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
                  onTap: () =>
                      context.push('/set/${s.set.id}?status=missing'),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
