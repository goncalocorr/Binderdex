/// Variante possuída de uma carta (substitui o antigo "shiny").
enum CardVariant {
  normal,
  holo,
  reverseHolo;

  static CardVariant fromName(String s) =>
      CardVariant.values.firstWhere((v) => v.name == s,
          orElse: () => CardVariant.normal);
}

/// Uma carta de um set.
class TcgCard {
  final String id; // ex.: "base1-4"
  final String setId; // ex.: "base1"
  final String name; // ex.: "Charizard"
  final String number; // ex.: "4" (pode ser "TG01", "SV01")
  final int numberSort; // dígitos do número para ordenar (fallback grande)
  final String? rarity; // ex.: "Rare Holo"
  final String? supertype; // "Pokémon" | "Trainer" | "Energy"
  final String? type; // primeiro tipo de energia (ex.: "Fire")
  final String imageSmall;
  final String imageLarge;
  final int? hp; // pontos de vida (cartas de Pokémon)
  final int? atk; // dano do primeiro ataque
  final double? price; // valor estimado em € (Cardmarket trendPrice)

  const TcgCard({
    required this.id,
    required this.setId,
    required this.name,
    required this.number,
    required this.numberSort,
    this.rarity,
    this.supertype,
    this.type,
    required this.imageSmall,
    required this.imageLarge,
    this.hp,
    this.atk,
    this.price,
  });
}
