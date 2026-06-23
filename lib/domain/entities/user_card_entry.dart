import 'tcg_card.dart';

/// Registo de coleção de uma carta, com posse independente por variante.
/// Ter a mesma carta em normal + holo + reverse não conta como duplicado.
class UserCardEntry {
  final String cardId;
  final bool ownedNormal;
  final bool ownedHolo;
  final bool ownedReverse;
  final int qtyNormal;
  final int qtyHolo;
  final int qtyReverse;
  final String notes;

  /// Na lista de desejos (wishlist), independente da posse.
  final bool wishlisted;
  final DateTime updatedAt;

  const UserCardEntry({
    required this.cardId,
    this.ownedNormal = false,
    this.ownedHolo = false,
    this.ownedReverse = false,
    this.qtyNormal = 0,
    this.qtyHolo = 0,
    this.qtyReverse = 0,
    this.notes = '',
    this.wishlisted = false,
    required this.updatedAt,
  });

  bool get anyOwned => ownedNormal || ownedHolo || ownedReverse;

  /// Maior quantidade numa única variante (para o badge de duplicados ×N).
  int get maxQty => [qtyNormal, qtyHolo, qtyReverse]
      .reduce((a, b) => a > b ? a : b);

  bool ownedOf(CardVariant v) => switch (v) {
        CardVariant.normal => ownedNormal,
        CardVariant.holo => ownedHolo,
        CardVariant.reverseHolo => ownedReverse,
      };

  int qtyOf(CardVariant v) => switch (v) {
        CardVariant.normal => qtyNormal,
        CardVariant.holo => qtyHolo,
        CardVariant.reverseHolo => qtyReverse,
      };

  UserCardEntry setOwned(CardVariant v, bool owned) => copyWith(
        ownedNormal: v == CardVariant.normal ? owned : null,
        ownedHolo: v == CardVariant.holo ? owned : null,
        ownedReverse: v == CardVariant.reverseHolo ? owned : null,
        // Ao marcar como possuída, garante quantidade mínima de 1.
        qtyNormal: v == CardVariant.normal && owned && qtyNormal == 0 ? 1 : null,
        qtyHolo: v == CardVariant.holo && owned && qtyHolo == 0 ? 1 : null,
        qtyReverse:
            v == CardVariant.reverseHolo && owned && qtyReverse == 0 ? 1 : null,
      );

  UserCardEntry setQty(CardVariant v, int qty) {
    final q = qty < 0 ? 0 : qty;
    return copyWith(
      qtyNormal: v == CardVariant.normal ? q : null,
      qtyHolo: v == CardVariant.holo ? q : null,
      qtyReverse: v == CardVariant.reverseHolo ? q : null,
      // Quantidade 0 implica não possuída nessa variante.
      ownedNormal: v == CardVariant.normal && q == 0 ? false : null,
      ownedHolo: v == CardVariant.holo && q == 0 ? false : null,
      ownedReverse: v == CardVariant.reverseHolo && q == 0 ? false : null,
    );
  }

  UserCardEntry copyWith({
    bool? ownedNormal,
    bool? ownedHolo,
    bool? ownedReverse,
    int? qtyNormal,
    int? qtyHolo,
    int? qtyReverse,
    String? notes,
    bool? wishlisted,
    DateTime? updatedAt,
  }) =>
      UserCardEntry(
        cardId: cardId,
        ownedNormal: ownedNormal ?? this.ownedNormal,
        ownedHolo: ownedHolo ?? this.ownedHolo,
        ownedReverse: ownedReverse ?? this.ownedReverse,
        qtyNormal: qtyNormal ?? this.qtyNormal,
        qtyHolo: qtyHolo ?? this.qtyHolo,
        qtyReverse: qtyReverse ?? this.qtyReverse,
        notes: notes ?? this.notes,
        wishlisted: wishlisted ?? this.wishlisted,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
