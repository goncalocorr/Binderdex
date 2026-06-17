import 'package:drift/drift.dart';

import '../../domain/entities/card_filter.dart';
import '../../domain/entities/tcg_card.dart';
import '../local/database.dart';
import '../remote/tcg_api.dart';

/// Item da grelha de cartas: a carta + estado de coleção resumido.
typedef CardItem = ({TcgCard card, bool owned, CardVariant variant});

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
    );

class CardsRepository {
  final AppDatabase db;
  final TcgApi api;
  CardsRepository(this.db, this.api);

  /// Garante que as cartas do set estão em cache. Busca à API só na 1ª vez
  /// (ou se ainda não tiver sido sincronizado). Lança em caso de erro de rede.
  Future<void> ensureSetSynced(String setId) async {
    if (await db.isSetSynced(setId)) return;
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
            ))
        .toList());
    await db.markSetSynced(setId);
  }

  Stream<List<CardItem>> watchCards(String setId, CardFilter f) => db
      .watchCardsInSet(
        setId: setId,
        query: f.query,
        rarity: f.rarity,
        status: f.status.name,
      )
      .map((rows) => rows
          .map((r) => (
                card: _toCard(r.card),
                owned: r.entry?.owned ?? false,
                variant: r.entry == null
                    ? CardVariant.normal
                    : CardVariant.fromName(r.entry!.variant),
              ))
          .toList());

  Future<List<String>> rarities(String setId) => db.raritiesInSet(setId);

  Future<TcgCard?> byId(String id) async {
    final r = await db.cardById(id);
    return r == null ? null : _toCard(r);
  }
}
