import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/repositories/cards_repository.dart';
import 'package:pokedex/domain/entities/tcg_card.dart';
import 'package:pokedex/presentation/providers/app_providers.dart';
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
  price: 12.5,
);

/// Envolve o tile num ProviderScope com o nível premium dado (o CardTile lê o
/// marketTier para mostrar/esconder o preço; o override evita tocar no Firebase).
Widget _wrap(CardItem item, {int tier = 0}) => ProviderScope(
      overrides: [
        marketTierProvider.overrideWith((ref) => Stream<int>.value(tier)),
      ],
      child: MaterialApp(
        home: Scaffold(body: CardTile(item: item, onTap: () {})),
      ),
    );

void main() {
  testWidgets('carta possuída mostra número e check', (tester) async {
    await tester.pumpWidget(_wrap((
      card: _card,
      owned: true,
      ownedHolo: true,
      ownedReverse: false,
      dupCount: 2,
    )));
    expect(find.text('#4'), findsOneWidget);
    expect(find.text('×2'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('carta em falta mostra "???" e ícone de adicionar', (tester) async {
    await tester.pumpWidget(_wrap((
      card: _card,
      owned: false,
      ownedHolo: false,
      ownedReverse: false,
      dupCount: 0,
    )));
    expect(find.text('???'), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('grátis (tier 0) não mostra preço na carta', (tester) async {
    await tester.pumpWidget(_wrap((
      card: _card,
      owned: true,
      ownedHolo: false,
      ownedReverse: false,
      dupCount: 1,
    )));
    expect(find.text('12,50 €'), findsNothing);
  });
}
