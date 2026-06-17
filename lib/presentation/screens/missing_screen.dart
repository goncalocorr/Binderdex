import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Coleções com cartas em falta. Tocar abre o set já filtrado por "em falta".
class MissingScreen extends ConsumerWidget {
  const MissingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final sets = ref.watch(setsListProvider);

    return sets.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (list) {
        // Mostra coleções onde ainda faltam cartas (ou ainda nada possuído).
        final incomplete =
            list.where((s) => s.progress.missing > 0).toList();
        if (incomplete.isEmpty) return Center(child: Text(t.noSets));
        return ListView.builder(
          itemCount: incomplete.length,
          itemBuilder: (_, i) {
            final s = incomplete[i];
            return ListTile(
              title: Text(s.set.name),
              subtitle: Text(s.set.series),
              trailing: Text(t.missingCount(s.progress.missing)),
              onTap: () => context.push('/set/${s.set.id}?status=missing'),
            );
          },
        );
      },
    );
  }
}
