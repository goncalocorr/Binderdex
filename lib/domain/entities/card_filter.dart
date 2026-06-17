/// Estado de coleção para filtrar cartas dentro de um set.
enum CardStatusFilter { all, owned, missing }

/// Filtros aplicados à grelha de cartas de um set (traduzidos para SQL no Drift).
class CardFilter {
  final String query; // nome ou número
  final String? rarity; // null = todas
  final CardStatusFilter status;

  const CardFilter({
    this.query = '',
    this.rarity,
    this.status = CardStatusFilter.all,
  });

  CardFilter copyWith({
    String? query,
    String? rarity,
    bool clearRarity = false,
    CardStatusFilter? status,
  }) =>
      CardFilter(
        query: query ?? this.query,
        rarity: clearRarity ? null : (rarity ?? this.rarity),
        status: status ?? this.status,
      );
}
