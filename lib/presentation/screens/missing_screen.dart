import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
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
        final cs = Theme.of(context).colorScheme;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: incomplete.length,
          itemBuilder: (_, i) {
            final s = incomplete[i];
            final tint = Color.alphaBlend(
                cs.primary.withValues(alpha: 0.14), cs.surfaceContainerHigh);
            return ListTile(
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
              subtitle: Text(s.set.series),
              trailing: Text(
                t.missingCount(s.progress.missing),
                style: AppTheme.mono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant),
              ),
              onTap: () => context.push('/set/${s.set.id}?status=missing'),
            );
          },
        );
      },
    );
  }
}
