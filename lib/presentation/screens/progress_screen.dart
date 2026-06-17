import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Progresso global e por coleção (set).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final global = ref.watch(globalProgressProvider);
    final sets = ref.watch(setsListProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        global.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('$e'),
          data: (p) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.progressGlobal,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                  '${p.owned} / ${p.total}  (${(p.percent * 100).toStringAsFixed(1)}%)'),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: p.percent, minHeight: 10),
              ),
              Text(t.missingCount(p.missing)),
            ],
          ),
        ),
        const Divider(height: 32),
        sets.when(
          loading: () => const SizedBox.shrink(),
          error: (e, _) => Text('$e'),
          data: (list) => Column(
            children: list
                .map((s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              '${s.set.name} — ${s.progress.owned}/${s.progress.total}'),
                          const SizedBox(height: 2),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                                value: s.progress.percent, minHeight: 6),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
