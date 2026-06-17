import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/sprites.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Lista dedicada aos Pokémon ainda em falta.
class MissingScreen extends ConsumerWidget {
  const MissingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final missing = ref.watch(missingListProvider);

    return missing.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (items) {
        if (items.isEmpty) {
          return Center(child: Text('${t.missingCount(0)} 🎉'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) {
            final p = items[i].pokemon;
            return ListTile(
              leading: SizedBox(
                width: 44,
                height: 44,
                child: CachedNetworkImage(
                  imageUrl: Sprites.artwork(p.id),
                  // Silhueta, para reforçar que ainda falta.
                  color: Colors.black,
                  colorBlendMode: BlendMode.srcIn,
                  placeholder: (_, __) =>
                      const Icon(Icons.catching_pokemon, size: 24),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.catching_pokemon, size: 24),
                ),
              ),
              title: Text(p.name),
              subtitle: Text('#${p.id} • ${t.progressGeneration(p.generation)}'),
              onTap: () => context.push('/pokemon/${p.id}'),
            );
          },
        );
      },
    );
  }
}
