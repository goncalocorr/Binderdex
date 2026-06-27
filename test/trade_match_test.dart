import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/listing.dart';
import 'package:pokedex/domain/entities/market_tier.dart';
import 'package:pokedex/domain/entities/trade_match.dart';

Listing _listing({
  required String id,
  required String owner,
  required String cardId,
  TradeMode mode = TradeMode.trade,
  List<CardRef> wants = const [],
}) =>
    Listing(
      id: id,
      ownerUid: owner,
      ownerName: owner,
      ownerAvatar: '',
      cardId: cardId,
      cardName: cardId,
      cardImage: '',
      setId: 's',
      mode: mode,
      condition: CardCondition.good,
      wantText: null,
      note: null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
      wantCards: wants,
    );

CardRef _ref(String id) =>
    CardRef(cardId: id, cardName: id, cardImage: '', setId: 's');

void main() {
  test('match perfeito: oferece o que quero e quer a minha repetida', () {
    final res = perfectTradesFrom(
      wishlistListings: [
        _listing(id: 'a', owner: 'rui', cardId: 'charizard', wants: [
          _ref('pikachu'),
        ]),
      ],
      myDuplicateIds: {'pikachu'},
      meUid: 'me',
      blocked: const {},
    );
    expect(res.length, 1);
    expect(res.first.iGive.map((c) => c.cardId), ['pikachu']);
  });

  test('exclui meu / bloqueado / venda-só / sem carta mútua', () {
    final res = perfectTradesFrom(
      wishlistListings: [
        _listing(id: 'mine', owner: 'me', cardId: 'c', wants: [_ref('pikachu')]),
        _listing(id: 'blk', owner: 'bad', cardId: 'c', wants: [_ref('pikachu')]),
        _listing(
            id: 'sell',
            owner: 'rui',
            cardId: 'c',
            mode: TradeMode.sell,
            wants: [_ref('pikachu')]),
        _listing(id: 'nowant', owner: 'rui', cardId: 'c'),
        _listing(id: 'nodupe', owner: 'rui', cardId: 'c', wants: [_ref('mewtwo')]),
      ],
      myDuplicateIds: {'pikachu'},
      meUid: 'me',
      blocked: const {'bad'},
    );
    expect(res, isEmpty);
  });

  test('modo "ambos" conta como troca', () {
    final res = perfectTradesFrom(
      wishlistListings: [
        _listing(
            id: 'a',
            owner: 'rui',
            cardId: 'c',
            mode: TradeMode.both,
            wants: [_ref('pikachu')]),
      ],
      myDuplicateIds: {'pikachu'},
      meUid: 'me',
      blocked: const {},
    );
    expect(res.length, 1);
  });

  group('MarketTier — limite de trocas por nível', () {
    test('limites: 0 / 20 / 75 / ilimitado', () {
      expect(MarketTier.tradeMatchViewsFor(0), 0);
      expect(MarketTier.tradeMatchViewsFor(1), 20);
      expect(MarketTier.tradeMatchViewsFor(2), 75);
      expect(MarketTier.tradeMatchViewsFor(3), -1);
    });

    test('limitTradeMatches aplica o corte (-1 = tudo)', () {
      final all = List.generate(100, (i) => i);
      expect(MarketTier.limitTradeMatches(all, 0).length, 0);
      expect(MarketTier.limitTradeMatches(all, 1).length, 20);
      expect(MarketTier.limitTradeMatches(all, 2).length, 75);
      expect(MarketTier.limitTradeMatches(all, 3).length, 100);
    });
  });
}
