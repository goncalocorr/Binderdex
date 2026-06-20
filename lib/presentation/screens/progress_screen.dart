import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/completion_ring.dart';
import '../widgets/dex_ui.dart';

/// Estatísticas: anel global, cartões-resumo e distribuição por tipo.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final global = ref.watch(globalProgressProvider);
    final counts = ref.watch(statsCountsProvider);
    final byType = ref.watch(ownedByTypeProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Anel global
        Center(
          child: global.when(
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
                Text(t.progressGlobal,
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
        // Cartões-resumo
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
        const SizedBox(height: 16),
        // Coleção por tipo
        byType.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('$e'),
          data: (rows) {
            if (rows.isEmpty) return const SizedBox.shrink();
            final max = rows.first.owned;
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
                        child: StatBar(
                          label: r.type,
                          value: r.owned,
                          max: max,
                          color: colorForCardType(r.type),
                          labelWidth: 76,
                        ),
                      )),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
