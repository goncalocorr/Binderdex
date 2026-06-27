import 'package:drift/drift.dart';

import '../../domain/entities/card_filter.dart';
import '../../domain/entities/tcg_card.dart';
import '../local/database.dart';
import '../remote/tcg_api.dart';

/// Item da grelha de cartas: a carta + estado de coleção resumido.
/// [dupCount] = maior nº de cópias numa única variante (duplicados reais).
typedef CardItem = ({
  TcgCard card,
  bool owned,
  bool ownedHolo,
  bool ownedReverse,
  int dupCount,
});

CardItem _toItem(CardRow r) {
  final e = r.entry;
  final owned =
      (e?.ownedNormal ?? false) || (e?.ownedHolo ?? false) || (e?.ownedReverse ?? false);
  final dup = [e?.qtyNormal ?? 0, e?.qtyHolo ?? 0, e?.qtyReverse ?? 0]
      .reduce((a, b) => a > b ? a : b);
  return (
    card: _toCard(r.card),
    owned: owned,
    ownedHolo: e?.ownedHolo ?? false,
    ownedReverse: e?.ownedReverse ?? false,
    dupCount: dup,
  );
}

TcgCard _toCard(TcgCardRow r) => TcgCard(
      id: r.id,
      setId: r.setId,
      name: r.name,
      number: r.number,
      numberSort: r.numberSort,
      rarity: r.rarity,
      supertype: r.supertype,
      type: r.type,
      imageSmall: r.imageSmall,
      imageLarge: r.imageLarge,
      hp: r.hp,
      atk: r.atk,
      price: r.price,
    );

class CardsRepository {
  final AppDatabase db;
  final TcgApi api;
  CardsRepository(this.db, this.api);

  /// Garante que as cartas do set estão em cache. Busca à API só na 1ª vez
  /// (ou se ainda não tiver sido sincronizado). Lança em caso de erro de rede.
  Future<void> ensureSetSynced(String setId, {bool force = false}) async {
    if (!force && await db.isSetSynced(setId)) return;
    final cards = await api.fetchCardsForSet(setId);
    await db.bulkInsertCards(cards
        .map((c) => TcgCardsCompanion.insert(
              id: c.id,
              setId: c.setId,
              name: c.name,
              number: c.number,
              numberSort: c.numberSort,
              rarity: Value(c.rarity),
              supertype: Value(c.supertype),
              type: Value(c.type),
              imageSmall: c.imageSmall,
              imageLarge: c.imageLarge,
              hp: Value(c.hp),
              atk: Value(c.atk),
              price: Value(c.price),
            ))
        .toList());
    await db.markSetSynced(setId);
  }

  /// Re-sincroniza (força) os sets indicados — usado para "atualizar preços"
  /// dos sets onde tenho cartas. Ignora erros de um set isolado.
  Future<void> refreshPricesFor(Iterable<String> setIds) async {
    for (final id in setIds.toSet()) {
      try {
        await ensureSetSynced(id, force: true);
      } catch (_) {/* set isolado falhou — continua */}
    }
  }

  Stream<List<CardItem>> watchCards(String setId, CardFilter f) => db
      .watchCardsInSet(
        setId: setId,
        query: f.query,
        rarity: f.rarity,
        status: f.status.name,
      )
      .map((rows) => rows.map(_toItem).toList());

  /// Contagens (total/possuídas) de um set — para as abas.
  Stream<({int total, int owned})> setCounts(String setId) =>
      db.watchSetCounts(setId);

  /// Cartas da wishlist (desejadas e ainda não possuídas).
  Stream<List<CardItem>> watchWishlist() =>
      db.watchWishlist().map((rows) => rows.map(_toItem).toList());

  /// Contagem de cartas desejadas.
  Stream<int> wishlistCount() => db.watchWishlistCount();

  /// Pesquisa global em todas as cartas em cache.
  Stream<List<CardItem>> searchAll({
    required String query,
    required List<String> types,
    required CardStatusFilter status,
  }) =>
      db
          .watchAllCards(query: query, types: types, status: status.name)
          .map((rows) => rows.map(_toItem).toList());

  Future<List<String>> rarities(String setId) => db.raritiesInSet(setId);

  Future<TcgCard?> byId(String id) async {
    final r = await db.cardById(id);
    return r == null ? null : _toCard(r);
  }
}
