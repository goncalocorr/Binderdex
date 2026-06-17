import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/tcg_card.dart';
import 'package:pokedex/presentation/widgets/card_tile.dart';

const _card = TcgCard(
  id: 'base1-4',
  setId: 'base1',
  name: 'Charizard',
  number: '4',
  numberSort: 4,
  rarity: 'Rare Holo',
  imageSmall: 'https://example.com/4.png',
  imageLarge: 'https://example.com/4_hires.png',
);

void main() {
  testWidgets('mostra o número da carta e badge de variante holo', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CardTile(
          item: (card: _card, owned: true, variant: CardVariant.holo),
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('#4'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

  testWidgets('sem badge quando variante normal', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CardTile(
          item: (card: _card, owned: false, variant: CardVariant.normal),
          onTap: () {},
        ),
      ),
    ));
    expect(find.byIcon(Icons.auto_awesome), findsNothing);
    expect(find.byIcon(Icons.flip), findsNothing);
  });
}
