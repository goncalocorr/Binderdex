import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/tcg_card.dart';
import 'package:pokedex/presentation/widgets/card_tile.dart';

const _card = TcgCard(
  id: 'base1-4',
  setId: 'base1',
  name: 'Emberwyrm',
  number: '4',
  numberSort: 4,
  rarity: 'Rare Holo',
  type: 'Fire',
  imageSmall: 'https://example.com/4.png',
  imageLarge: 'https://example.com/4_hires.png',
);

void main() {
  testWidgets('carta possuída mostra número e check', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CardTile(
          item: (card: _card, owned: true, variant: CardVariant.holo, quantity: 2),
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('#4'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('carta em falta mostra "???" e ícone de adicionar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: CardTile(
          item: (card: _card, owned: false, variant: CardVariant.normal, quantity: 0),
          onTap: () {},
        ),
      ),
    ));
    expect(find.text('???'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });
}
