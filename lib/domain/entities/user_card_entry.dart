import 'tcg_card.dart';

/// Registo de coleção do utilizador para uma carta.
class UserCardEntry {
  final String cardId;
  final bool owned;
  final int quantity;
  final CardVariant variant;
  final String notes;
  final DateTime updatedAt;

  const UserCardEntry({
    required this.cardId,
    this.owned = false,
    this.quantity = 0,
    this.variant = CardVariant.normal,
    this.notes = '',
    required this.updatedAt,
  });

  UserCardEntry copyWith({
    bool? owned,
    int? quantity,
    CardVariant? variant,
    String? notes,
    DateTime? updatedAt,
  }) =>
      UserCardEntry(
        cardId: cardId,
        owned: owned ?? this.owned,
        quantity: quantity ?? this.quantity,
        variant: variant ?? this.variant,
        notes: notes ?? this.notes,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
