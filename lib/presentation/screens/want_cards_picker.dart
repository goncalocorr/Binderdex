import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/cards_repository.dart';
import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';

/// Seletor das cartas que o utilizador quer em troca. Devolve `List<CardRef>`
/// via `Navigator.pop`. Mostra a wishlist quando não há pesquisa; ao escrever,
/// pesquisa o catálogo. Máximo de [_max] cartas.
class WantCardsPicker extends ConsumerStatefulWidget {
  final List<CardRef> initial;
  const WantCardsPicker({super.key, this.initial = const []});

  @override
  ConsumerState<WantCardsPicker> createState() => _WantCardsPickerState();
}

class _WantCardsPickerState extends ConsumerState<WantCardsPicker> {
  static const int _max = 10;
  final _searchController = TextEditingController();
  String _query = '';
  late final Map<String, CardRef> _selected = {
    for (final c in widget.initial) c.cardId: c,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  CardRef _refOf(CardItem it) => CardRef(
        cardId: it.card.id,
        cardName: it.card.name,
        cardImage: it.card.imageSmall,
        setId: it.card.setId,
      );

  void _toggle(CardItem it) {
    final id = it.card.id;
    setState(() {
      if (_selected.containsKey(id)) {
        _selected.remove(id);
      } else {
        if (_selected.length >= _max) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(SnackBar(
                content: Text(AppLocalizations.of(context)!.wantCardsLimit)));
          return;
        }
        _selected[id] = _refOf(it);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final searching = _query.trim().isNotEmpty;
    final cardsAsync = searching
        ? ref.watch(marketCardSearchProvider(_query))
        : ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${t.wantedCards} (${_selected.length})'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected.values.toList()),
            child: Text(t.save),
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.searchCardHint,
            ),
          ),
        ),
        if (_selected.isNotEmpty) _selectedStrip(),
        Expanded(
          child: cardsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (items) {
              if (items.isEmpty) {
                return searching
                    ? Center(child: Text(t.noMatch))
                    : EmptyState(
                        imageAsset: 'assets/wishlist_empty.png',
                        icon: Icons.favorite_border,
                        title: t.wishlistEmpty,
                        alignment: const Alignment(0, -0.35),
                      );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.72,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) =>
                    _GridCard(item: items[i], selected: _selected.containsKey(items[i].card.id), onTap: () => _toggle(items[i])),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _selectedStrip() {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: _selected.values.map((c) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: c.cardImage.isEmpty
                    ? Container(width: 48, height: 64, color: Colors.grey)
                    : CachedNetworkImage(
                        imageUrl: c.cardImage,
                        width: 48,
                        height: 64,
                        fit: BoxFit.cover),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: IconButton(
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.cancel),
                  onPressed: () => setState(() => _selected.remove(c.cardId)),
                ),
              ),
            ]),
          );
        }).toList(),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final CardItem item;
  final bool selected;
  final VoidCallback onTap;
  const _GridCard(
      {required this.item, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = item.card;
    return GestureDetector(
      onTap: onTap,
      child: Stack(fit: StackFit.expand, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: c.imageSmall.isEmpty
              ? Container(color: cs.surfaceContainerHigh)
              : CachedNetworkImage(imageUrl: c.imageSmall, fit: BoxFit.cover),
        ),
        if (selected)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.primary, width: 3),
              color: cs.primary.withValues(alpha: 0.18),
            ),
            alignment: Alignment.topRight,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.check_circle, color: Colors.white),
            ),
          ),
      ]),
    );
  }
}
