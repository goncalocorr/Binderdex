import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';
import '../screens/want_cards_picker.dart';

/// Campo "Cartas que quero em troca": botão que abre o [WantCardsPicker] e
/// mostra as cartas escolhidas como miniaturas. Usado no publicar e no editar.
class WantCardsField extends StatelessWidget {
  final List<CardRef> cards;
  final ValueChanged<List<CardRef>> onChanged;
  const WantCardsField({super.key, required this.cards, required this.onChanged});

  Future<void> _pick(BuildContext context) async {
    final result = await Navigator.of(context).push<List<CardRef>>(
      MaterialPageRoute(builder: (_) => WantCardsPicker(initial: cards)),
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.add_card, size: 18),
          label: Text('${t.wantedCards} (${cards.length})'),
          onPressed: () => _pick(context),
        ),
        if (cards.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final c = cards[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: c.cardImage.isEmpty
                        ? Container(width: 46, height: 64, color: Colors.grey)
                        : CachedNetworkImage(
                            imageUrl: c.cardImage,
                            width: 46,
                            height: 64,
                            fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
