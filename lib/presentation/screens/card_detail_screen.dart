import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/tcg_card.dart';
import '../../domain/entities/user_card_entry.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Detalhe de uma carta + edição do registo de coleção.
class CardDetailScreen extends ConsumerWidget {
  final String id;
  const CardDetailScreen({super.key, required this.id});

  String _variantLabel(AppLocalizations t, CardVariant v) => switch (v) {
        CardVariant.normal => t.variantNormal,
        CardVariant.holo => t.variantHolo,
        CardVariant.reverseHolo => t.variantReverse,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cardAsync = ref.watch(cardByIdProvider(id));
    final entryAsync = ref.watch(entryProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text(cardAsync.valueOrNull?.name ?? '')),
      body: cardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (card) {
          if (card == null) return const Center(child: Text('—'));
          return entryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (entry) {
              final repo = ref.read(collectionRepositoryProvider);
              void save(UserCardEntry e) =>
                  repo.save(e.copyWith(updatedAt: DateTime.now()));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: CachedNetworkImage(
                      imageUrl: card.imageLarge.isNotEmpty
                          ? card.imageLarge
                          : card.imageSmall,
                      height: 360,
                      placeholder: (_, __) => const SizedBox(
                        height: 360,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 96),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('#${card.number}  ${card.name}',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (card.rarity != null || card.supertype != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        [card.supertype, card.rarity]
                            .whereType<String>()
                            .join(' • '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  const Divider(height: 32),

                  // --- Edição da coleção ---
                  SwitchListTile(
                    title: Text(t.owned),
                    value: entry.owned,
                    onChanged: (v) => save(entry.copyWith(owned: v)),
                  ),
                  ListTile(
                    title: Text(t.variant),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SegmentedButton<CardVariant>(
                        segments: CardVariant.values
                            .map((v) => ButtonSegment(
                                  value: v,
                                  label: Text(_variantLabel(t, v)),
                                ))
                            .toList(),
                        selected: {entry.variant},
                        onSelectionChanged: (s) =>
                            save(entry.copyWith(variant: s.first)),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(t.quantity),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: entry.quantity > 0
                              ? () => save(entry.copyWith(
                                  quantity: entry.quantity - 1))
                              : null,
                        ),
                        Text('${entry.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => save(
                              entry.copyWith(quantity: entry.quantity + 1)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TextFormField(
                      key: ValueKey('notes_${card.id}'),
                      initialValue: entry.notes,
                      decoration: InputDecoration(
                        labelText: t.notes,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      // ⭐ PREMIUM: notas longas/ilimitadas poderão ser premium.
                      onChanged: (v) => save(entry.copyWith(notes: v)),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
