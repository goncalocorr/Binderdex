import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/local/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.bulkInsertSets([
      CardSetsCompanion.insert(
        id: 'base1', name: 'Base', series: 'Base',
        printedTotal: 102, total: 102, releaseDate: '1999',
        symbolUrl: '', logoUrl: '',
      ),
    ]);
    await db.bulkInsertCards([
      TcgCardsCompanion.insert(
        id: 'base1-4', setId: 'base1', name: 'Charizard',
        number: '4', numberSort: 4, imageSmall: '', imageLarge: ''),
      TcgCardsCompanion.insert(
        id: 'base1-58', setId: 'base1', name: 'Pikachu',
        number: '58', numberSort: 58, imageSmall: '', imageLarge: ''),
    ]);
  });

  tearDown(() => db.close());

  test('ownedCards devolve só as possuídas', () async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-4', ownedNormal: const Value(true),
      updatedAt: DateTime.now()));
    final res = await db.ownedCards();
    expect(res.length, 1);
    expect(res.single.card.id, 'base1-4');
    expect(res.single.isDuplicate, false);
  });

  test('isDuplicate é true quando qty > 1', () async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-4', ownedNormal: const Value(true),
      qtyNormal: const Value(3), updatedAt: DateTime.now()));
    final res = await db.ownedCards();
    expect(res.single.isDuplicate, true);
  });

  test('onlyDuplicates filtra só as repetidas', () async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-4', ownedNormal: const Value(true),
      qtyNormal: const Value(2), updatedAt: DateTime.now()));
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-58', ownedNormal: const Value(true),
      updatedAt: DateTime.now()));
    final all = await db.ownedCards();
    final dupes = await db.ownedCards(onlyDuplicates: true);
    expect(all.length, 2);
    expect(dupes.length, 1);
    expect(dupes.single.card.id, 'base1-4');
  });
}
