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
        id: 'base1',
        name: 'Base',
        series: 'Base',
        printedTotal: 102,
        total: 102,
        releaseDate: '1999/01/09',
        symbolUrl: '',
        logoUrl: '',
      ),
    ]);
    await db.bulkInsertCards([
      TcgCardsCompanion.insert(
        id: 'base1-4',
        setId: 'base1',
        name: 'Charizard',
        number: '4',
        numberSort: 4,
        rarity: const Value('Rare Holo'),
        imageSmall: '',
        imageLarge: '',
      ),
      TcgCardsCompanion.insert(
        id: 'base1-58',
        setId: 'base1',
        name: 'Pikachu',
        number: '58',
        numberSort: 58,
        rarity: const Value('Common'),
        imageSmall: '',
        imageLarge: '',
      ),
    ]);
  });

  tearDown(() => db.close());

  test('filtra por raridade via SQL', () async {
    final res = await db
        .watchCardsInSet(
            setId: 'base1', query: '', rarity: 'Common', status: 'all')
        .first;
    expect(res.length, 1);
    expect(res.single.card.id, 'base1-58');
  });

  test('pesquisa por número', () async {
    final res = await db
        .watchCardsInSet(
            setId: 'base1', query: '58', rarity: null, status: 'all')
        .first;
    expect(res.single.card.name, 'Pikachu');
  });

  test('pesquisa por nome é case-insensitive', () async {
    final res = await db
        .watchCardsInSet(
            setId: 'base1', query: 'char', rarity: null, status: 'all')
        .first;
    expect(res.single.card.id, 'base1-4');
  });

  test('status "missing" inclui cartas sem registo', () async {
    final res = await db
        .watchCardsInSet(
            setId: 'base1', query: '', rarity: null, status: 'missing')
        .first;
    expect(res.length, 2);
  });

  test('marcar como tenho altera os filtros owned/missing e o progresso',
      () async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-4',
      owned: const Value(true),
      updatedAt: DateTime.now(),
    ));

    final owned = await db
        .watchCardsInSet(
            setId: 'base1', query: '', rarity: null, status: 'owned')
        .first;
    expect(owned.single.card.id, 'base1-4');

    final missing = await db
        .watchCardsInSet(
            setId: 'base1', query: '', rarity: null, status: 'missing')
        .first;
    expect(missing.single.card.id, 'base1-58');

    expect(await db.totalOwned(), 1);
    expect(await db.totalCards(), 102);
  });

  test('sets com progresso refletem cartas possuídas', () async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-4',
      owned: const Value(true),
      updatedAt: DateTime.now(),
    ));
    final sets = await db.watchSetsWithProgress().first;
    expect(sets.single.set.id, 'base1');
    expect(sets.single.owned, 1);
  });
}
