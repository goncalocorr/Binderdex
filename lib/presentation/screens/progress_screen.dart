import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Progresso global e por geração.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final global = ref.watch(globalProgressProvider);
    final byGen = ref.watch(progressByGenProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        global.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Erro: $e'),
          data: (p) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.progressGlobal,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                  '${p.caught} / ${p.total}  (${(p.percent * 100).toStringAsFixed(1)}%)'),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: p.percent, minHeight: 12),
              const SizedBox(height: 4),
              Text(t.missingCount(p.missing)),
            ],
          ),
        ),
        const Divider(height: 32),
        byGen.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('Erro: $e'),
          data: (map) {
            final entries = map.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));
            return Column(
              children: entries
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${t.progressGeneration(e.key)} — ${e.value.caught}/${e.value.total}'),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(value: e.value.percent),
                          ],
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}
