import 'listing.dart';

/// Uma "troca perfeita": um anúncio cuja carta EU quero (está na minha wishlist)
/// e cujo dono quer alguma carta que EU tenho repetida (troca mútua).
class TradeMatch {
  /// O anúncio do outro — o que eu RECEBO (`listing.cardName/cardImage`).
  final Listing listing;

  /// Cartas que o dono quer e que eu tenho repetidas — o que eu DOU.
  final List<CardRef> iGive;

  const TradeMatch(this.listing, this.iGive);
}

/// Calcula as trocas perfeitas a partir dos anúncios cujo `cardId` já está na
/// minha wishlist. Fica com os que: não são meus nem de bloqueados, são
/// troca/ambos (vender-só não conta), e o dono quer ≥1 carta que eu tenho
/// repetida. Mais recentes primeiro.
List<TradeMatch> perfectTradesFrom({
  required List<Listing> wishlistListings,
  required Set<String> myDuplicateIds,
  required String? meUid,
  required Set<String> blocked,
}) {
  final out = <TradeMatch>[];
  for (final l in wishlistListings) {
    if (l.ownerUid == meUid) continue;
    if (blocked.contains(l.ownerUid)) continue;
    if (l.mode == TradeMode.sell) continue; // só troca/ambos
    final iGive =
        l.wantCards.where((c) => myDuplicateIds.contains(c.cardId)).toList();
    if (iGive.isEmpty) continue; // perfeita = mútua
    out.add(TradeMatch(l, iGive));
  }
  out.sort((a, b) => b.listing.createdAt.compareTo(a.listing.createdAt));
  return out;
}
