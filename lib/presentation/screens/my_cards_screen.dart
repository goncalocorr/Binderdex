import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/publish_sheet.dart';

/// Converte a seleção (ids) em CardRef para publicar. Top-level p/ ser testável.
List<CardRef> cardRefsFrom(List<OwnedCard> all, Set<String> selectedIds) => all
    .where((o) => selectedIds.contains(o.card.id))
    .map((o) => CardRef(
          cardId: o.card.id,
          cardName: o.card.name,
          cardImage: o.card.imageLarge,
          setId: o.card.setId,
        ))
    .toList();

class MyCardsScreen extends ConsumerStatefulWidget {
  final bool startDuplicates;
  const MyCardsScreen({super.key, this.startDuplicates = false});

  @override
  ConsumerState<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends ConsumerState<MyCardsScreen> {
  late bool _onlyDupes = widget.startDuplicates;
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cardsAsync = ref.watch(ownedCardsProvider(_onlyDupes));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.sellOrTrade),
        actions: [
          Row(children: [
            Text(t.onlyDuplicates),
            Switch(
              value: _onlyDupes,
              onChanged: (v) => setState(() {
                _onlyDupes = v;
                _selected.clear();
              }),
            ),
          ]),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (cards) => GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.72, mainAxisSpacing: 8,
              crossAxisSpacing: 8),
          itemCount: cards.length,
          itemBuilder: (_, i) {
            final o = cards[i];
            final sel = _selected.contains(o.card.id);
            return GestureDetector(
              onTap: () => setState(() =>
                  sel ? _selected.remove(o.card.id) : _selected.add(o.card.id)),
              child: Stack(fit: StackFit.expand, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: o.card.imageLarge.isEmpty
                      ? Container(color: Theme.of(context).colorScheme.surfaceContainerHigh)
                      : CachedNetworkImage(
                          imageUrl: o.card.imageLarge,
                          fit: BoxFit.cover,
                          memCacheWidth: 400),
                ),
                if (sel)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary, width: 3),
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                    ),
                    alignment: Alignment.topRight,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.check_circle, color: Colors.white),
                    ),
                  ),
              ]),
            );
          },
        ),
      ),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.storefront),
                  label: Text(t.addToCommunity(_selected.length)),
                  onPressed: () async {
                    final all = ref.read(ownedCardsProvider(_onlyDupes)).valueOrNull ?? [];
                    final refs = cardRefsFrom(all, _selected);
                    final ok = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => PublishSheet(cards: refs),
                    );
                    if (ok == true && mounted) {
                      setState(() => _selected.clear());
                    }
                  },
                ),
              ),
            ),
    );
  }
}
