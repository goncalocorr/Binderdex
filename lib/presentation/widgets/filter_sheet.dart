import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/pokedex_filter.dart';
import '../../domain/entities/pokemon.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Bottom sheet que edita o filtro global (estado, geração, tipo).
class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  String _statusLabel(AppLocalizations t, StatusFilter s) => switch (s) {
        StatusFilter.all => t.statusAll,
        StatusFilter.caught => t.statusCaught,
        StatusFilter.missing => t.statusMissing,
        StatusFilter.shiny => t.statusShiny,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final f = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.filterStatus, style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: StatusFilter.values
                  .map((s) => ChoiceChip(
                        label: Text(_statusLabel(t, s)),
                        selected: f.status == s,
                        onSelected: (_) =>
                            notifier.state = f.copyWith(status: s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(t.filterGeneration,
                style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: List.generate(9, (i) => i + 1)
                  .map((g) => ChoiceChip(
                        label: Text('$g'),
                        selected: f.generation == g,
                        onSelected: (sel) => notifier.state = sel
                            ? f.copyWith(generation: g)
                            : f.copyWith(clearGeneration: true),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(t.filterType, style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: PokemonType.values
                  .map((ty) => ChoiceChip(
                        label: Text(ty.name),
                        selected: f.type == ty,
                        onSelected: (sel) => notifier.state = sel
                            ? f.copyWith(type: ty)
                            : f.copyWith(clearType: true),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
