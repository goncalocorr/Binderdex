import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/listing.dart';

void main() {
  test('TradeMode/CardCondition convertem id ida-e-volta', () {
    for (final m in TradeMode.values) {
      expect(TradeMode.fromId(m.id), m);
    }
    for (final c in CardCondition.values) {
      expect(CardCondition.fromId(c.id), c);
    }
  });

  test('toMap inclui os campos esperados e omite createdAt', () {
    final l = Listing(
      id: 'x', ownerUid: 'u1', ownerName: 'Ana', ownerAvatar: 'a1',
      cardId: 'base1-4', cardName: 'Charizard', cardImage: 'img', setId: 'base1',
      mode: TradeMode.both, condition: CardCondition.good,
      wantText: 'Pikachu', note: 'tenho 3',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    final m = l.toMap();
    expect(m['ownerUid'], 'u1');
    expect(m['cardId'], 'base1-4');
    expect(m['mode'], 'both');
    expect(m['condition'], 'good');
    expect(m['wantText'], 'Pikachu');
    expect(m.containsKey('createdAt'), false);
    expect(m['status'], 'active');
  });

  test('fromMap lê os campos e tolera createdAt nulo', () {
    final l = Listing.fromMap('doc1', {
      'ownerUid': 'u1', 'ownerName': 'Ana', 'ownerAvatar': 'a1',
      'cardId': 'base1-4', 'cardName': 'Charizard', 'cardImage': 'img',
      'setId': 'base1', 'mode': 'sell', 'condition': 'mint',
      'wantText': null, 'note': null, 'status': 'active', 'createdAt': null,
    });
    expect(l.id, 'doc1');
    expect(l.mode, TradeMode.sell);
    expect(l.condition, CardCondition.mint);
    expect(l.createdAt.millisecondsSinceEpoch, 0);
  });
}
