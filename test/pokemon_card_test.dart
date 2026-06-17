import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/pokemon.dart';
import 'package:pokedex/presentation/widgets/pokemon_card.dart';

const _bulba = Pokemon(
  id: 1,
  name: 'Bulbasaur',
  nameEn: 'Bulbasaur',
  type1: PokemonType.grass,
  type2: PokemonType.poison,
  generation: 1,
  hp: 45,
  attack: 49,
  defense: 49,
  spAttack: 65,
  spDefense: 65,
  speed: 45,
  description: '',
);

void main() {
  testWidgets('mostra a estrela shiny quando shiny=true', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PokemonCard(
            pokemon: _bulba, caught: true, shiny: true, onTap: () {}),
      ),
    ));
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('Bulbasaur'), findsOneWidget);
  });

  testWidgets('não mostra estrela quando shiny=false', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: PokemonCard(
            pokemon: _bulba, caught: false, shiny: false, onTap: () {}),
      ),
    ));
    expect(find.byIcon(Icons.star), findsNothing);
  });
}
