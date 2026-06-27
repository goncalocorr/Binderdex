import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/app_notification.dart';
import 'package:pokedex/domain/entities/card_set.dart';
import 'package:pokedex/domain/entities/listing.dart';

CardSet _set(String id) => CardSet(
      id: id,
      name: id,
      series: 's',
      printedTotal: 1,
      total: 1,
      releaseDate: '2024/01/01',
      symbolUrl: '',
      logoUrl: '',
    );

Listing _listing(String owner) => Listing(
      id: 'l_$owner',
      ownerUid: owner,
      ownerName: owner,
      ownerAvatar: '',
      cardId: 'c',
      cardName: 'C',
      cardImage: '',
      setId: 's',
      mode: TradeMode.trade,
      condition: CardCondition.good,
      wantText: null,
      note: null,
      createdAt: DateTime.now(),
    );

void main() {
  test('newSetsFrom: seen nulo → nenhum é novo', () {
    expect(newSetsFrom([_set('a'), _set('b')], null), isEmpty);
  });

  test('newSetsFrom: devolve só os não vistos', () {
    final res = newSetsFrom([_set('a'), _set('b')], {'a'});
    expect(res.map((s) => s.id), ['b']);
  });

  test('wishlistMatchesFrom: exclui os meus e os bloqueados', () {
    final res = wishlistMatchesFrom(
      [_listing('me'), _listing('rui'), _listing('bad')],
      'me',
      {'bad'},
    );
    expect(res.map((l) => l.ownerUid), ['rui']);
  });
}
