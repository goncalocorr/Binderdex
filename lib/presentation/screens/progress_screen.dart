import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/completion_ring.dart';

/// Progresso global (anel) e por coleção (set).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final global = ref.watch(globalProgressProvider);
    final sets = ref.watch(setsListProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Cartão do progresso global, com anel.
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
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
                height: 132, child: Center(child: CircularProgressIndicator())),
            error: (e, _) => Text('$e'),
            data: (p) => Column(
              children: [
                Text(t.progressGlobal.toUpperCase(),
                    style: AppTheme.mono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant)),
                const SizedBox(height: 16),
                CompletionRing(
                  percent: p.percent,
                  sublabel: '${p.owned}/${p.total}',
                ),
                const SizedBox(height: 12),
                Text(t.missingCount(p.missing),
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(t.tabSets.toUpperCase(),
              style: AppTheme.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant)),
        ),
        sets.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('$e'),
          data: (list) => Column(
            children: list.map((s) {
              final done =
                  s.progress.total > 0 && s.progress.owned >= s.progress.total;
              final color = done ? DexColors.gold500 : DexColors.green500;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 7),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(s.set.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium),
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
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
