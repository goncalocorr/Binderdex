import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/card_filter.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Bottom sheet de filtros das cartas de um set (estado + raridade).
class CardFilterSheet extends ConsumerWidget {
  final String setId;
  const CardFilterSheet(this.setId, {super.key});

  String _statusLabel(AppLocalizations t, CardStatusFilter s) => switch (s) {
        CardStatusFilter.all => t.statusAll,
        CardStatusFilter.owned => t.statusOwned,
        CardStatusFilter.missing => t.statusMissing,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final f = ref.watch(cardFilterProvider(setId));
    final notifier = ref.read(cardFilterProvider(setId).notifier);
    final raritiesAsync = ref.watch(raritiesProvider(setId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: CardStatusFilter.values
                  .map((s) => ChoiceChip(
                        label: Text(_statusLabel(t, s)),
                        selected: f.status == s,
                        onSelected: (_) =>
                            notifier.state = f.copyWith(status: s),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text(t.rarity, style: Theme.of(context).textTheme.titleSmall),
            raritiesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(8),
                child: LinearProgressIndicator(),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (rarities) => Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: Text(t.statusAll),
                    selected: f.rarity == null,
                    onSelected: (_) =>
                        notifier.state = f.copyWith(clearRarity: true),
                  ),
                  ...rarities.map((r) => ChoiceChip(
                        label: Text(r),
                        selected: f.rarity == r,
                        onSelected: (sel) => notifier.state = sel
                            ? f.copyWith(rarity: r)
                            : f.copyWith(clearRarity: true),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
