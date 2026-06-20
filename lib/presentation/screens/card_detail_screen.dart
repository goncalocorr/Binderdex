import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../domain/entities/tcg_card.dart';
import '../../domain/entities/user_card_entry.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';

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
    final cs = Theme.of(context).colorScheme;
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
              final sheen = sheenColorsForCard(
                rarity: card.rarity,
                ownedHolo: entry.ownedHolo,
                ownedReverse: entry.ownedReverse,
                ownedAny: entry.anyOwned,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(DexRadii.lg),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(DexRadii.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            CachedNetworkImage(
                              imageUrl: card.imageLarge.isNotEmpty
                                  ? card.imageLarge
                                  : card.imageSmall,
                              height: 360,
                              placeholder: (_, __) => const SizedBox(
                                height: 360,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (_, __, ___) => const Icon(
                                  Icons.image_not_supported, size: 96),
                            ),
                            if (sheen != null)
                              Positioned.fill(
                                  child: AnimatedSheen(
                                      colors: sheen, opacity: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('#${card.number}',
                          style: AppTheme.mono(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(card.name,
                            style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (card.type != null)
                        _Badge(
                            label: card.type!,
                            color: colorForCardType(card.type)),
                      if (card.rarity != null)
                        _Badge(
                            label: card.rarity!,
                            color: colorForRarity(card.rarity)),
                      if (card.supertype != null)
                        _Badge(
                            label: card.supertype!,
                            color: cs.onSurfaceVariant,
                            outlined: true),
                    ],
                  ),
                  if (card.hp != null || card.atk != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(DexRadii.lg),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                                alpha: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 0.35
                                    : 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (card.hp != null)
                            StatBar(
                                label: 'HP',
                                value: card.hp!,
                                color: DexColors.green500,
                                max: 340),
                          if (card.hp != null && card.atk != null)
                            const SizedBox(height: 10),
                          if (card.atk != null)
                            StatBar(
                                label: 'ATK',
                                value: card.atk!,
                                color: colorForCardType(card.type),
                                max: 300),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 32),

                  // --- A minha coleção (uma linha por variante) ---
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 4),
                    child: Text(t.myCollection.toUpperCase(),
                        style: AppTheme.mono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant)),
                  ),
                  for (final v in CardVariant.values)
                    _VariantRow(
                      label: _variantLabel(t, v),
                      owned: entry.ownedOf(v),
                      qty: entry.qtyOf(v),
                      onOwned: (val) => save(entry.setOwned(v, val)),
                      onQty: (q) => save(entry.setQty(v, q)),
                    ),
                  const SizedBox(height: 8),
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

/// Pequeno badge em pílula (tipo / raridade / supertipo).
class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final bool outlined;
  const _Badge({required this.label, required this.color, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color,
        border: outlined ? Border.all(color: color) : null,
        borderRadius: BorderRadius.circular(DexRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: outlined ? color : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// Linha de edição de uma variante: toggle "tenho" + contador de cópias.
class _VariantRow extends StatelessWidget {
  final String label;
  final bool owned;
  final int qty;
  final ValueChanged<bool> onOwned;
  final ValueChanged<int> onQty;
  const _VariantRow({
    required this.label,
    required this.owned,
    required this.qty,
    required this.onOwned,
    required this.onQty,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Switch(value: owned, onChanged: onOwned),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          if (owned)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  visualDensity: VisualDensity.compact,
                  onPressed: qty > 0 ? () => onQty(qty - 1) : null,
                ),
                SizedBox(
                  width: 22,
                  child: Text('$qty',
                      textAlign: TextAlign.center,
                      style: AppTheme.mono(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  visualDensity: VisualDensity.compact,
                  onPressed: () => onQty(qty + 1),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text('—', style: TextStyle(color: cs.onSurfaceVariant)),
            ),
        ],
      ),
    );
  }
}
