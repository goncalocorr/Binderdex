import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/listing.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/presentation/widgets/listing_tile.dart';

Listing _sample(TradeMode mode) => Listing(
      id: 'x', ownerUid: 'u1', ownerName: 'Ana', ownerAvatar: '',
      cardId: 'base1-4', cardName: 'Charizard', cardImage: '', setId: 'base1',
      mode: mode, condition: CardCondition.good, wantText: null, note: null,
      createdAt: DateTime.now());

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt'), Locale('en')],
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('mostra a carta, o dono e o modo', (tester) async {
    await tester.pumpWidget(_wrap(ListingTile(listing: _sample(TradeMode.sell))));
    await tester.pumpAndSettle();
    expect(find.text('Charizard'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Vender'), findsOneWidget);
  });
}
