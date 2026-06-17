/// Uma coleção = um set/expansão oficial do TCG (ex.: Base Set, 151).
class CardSet {
  final String id; // ex.: "base1", "sv3pt5"
  final String name; // ex.: "Base", "151"
  final String series; // ex.: "Base", "Scarlet & Violet"
  final int printedTotal; // nº oficialmente impresso (ex.: 102)
  final int total; // total incl. secretas — denominador do progresso
  final String releaseDate; // "1999/01/09"
  final String symbolUrl;
  final String logoUrl;

  const CardSet({
    required this.id,
    required this.name,
    required this.series,
    required this.printedTotal,
    required this.total,
    required this.releaseDate,
    required this.symbolUrl,
    required this.logoUrl,
  });
}
