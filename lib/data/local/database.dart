import 'package:drift/drift.dart';

import 'connection/connection.dart';

part 'database.g.dart';

/// Sets/expansões (incluídos via dataset + atualizados da API).
@DataClassName('CardSetRow')
class CardSets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get series => text()();
  IntColumn get printedTotal => integer()();
  IntColumn get total => integer()();
  TextColumn get releaseDate => text()();
  TextColumn get symbolUrl => text()();
  TextColumn get logoUrl => text()();

  /// True quando as cartas deste set já foram buscadas e cacheadas.
  BoolColumn get cardsSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cartas (cacheadas por set, à medida que os sets são abertos).
@DataClassName('TcgCardRow')
class TcgCards extends Table {
  TextColumn get id => text()();
  TextColumn get setId => text()();
  TextColumn get name => text()();
  TextColumn get number => text()();
  IntColumn get numberSort => integer()();
  TextColumn get rarity => text().nullable()();
  TextColumn get supertype => text().nullable()();
  TextColumn get type => text().nullable()();
  TextColumn get imageSmall => text()();
  TextColumn get imageLarge => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Coleção do utilizador (por carta).
@DataClassName('UserCardEntryRow')
class UserCardEntries extends Table {
  TextColumn get cardId => text()();
  BoolColumn get owned => boolean().withDefault(const Constant(false))();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get variant => text().withDefault(const Constant('normal'))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {cardId};
}

/// Set + nº de cartas possuídas (para a lista de coleções e progresso).
class SetWithProgress {
  final CardSetRow set;
  final int owned;
  SetWithProgress(this.set, this.owned);
}

/// Carta + (opcional) registo de coleção.
class CardRow {
  final TcgCardRow card;
  final UserCardEntryRow? entry;
  CardRow(this.card, this.entry);
}

@DriftDatabase(tables: [CardSets, TcgCards, UserCardEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 1;

  // --- Sets ---

  Future<int> setCount() async {
    final row =
        await (selectOnly(cardSets)..addColumns([cardSets.id.count()]))
            .getSingle();
    return row.read(cardSets.id.count()) ?? 0;
  }

  Future<void> bulkInsertSets(List<CardSetsCompanion> rows) async {
    await batch(
        (b) => b.insertAll(cardSets, rows, mode: InsertMode.insertOrReplace));
  }

  Future<CardSetRow?> setById(String id) =>
      (select(cardSets)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Sets com o nº de cartas possuídas, ordenados por data (mais recentes primeiro).
  /// As datas estão em "YYYY/MM/DD", por isso a ordenação lexical funciona.
  Stream<List<SetWithProgress>> watchSetsWithProgress() {
    return customSelect(
      'SELECT s.*, ('
      '  SELECT COUNT(*) FROM tcg_cards c '
      '  JOIN user_card_entries e ON e.card_id = c.id '
      '  WHERE c.set_id = s.id AND e.owned = 1'
      ') AS owned_count '
      'FROM card_sets s ORDER BY s.release_date DESC',
      readsFrom: {cardSets, tcgCards, userCardEntries},
    ).watch().map((rows) => rows
        .map((r) => SetWithProgress(
              cardSets.map(r.data),
              r.read<int>('owned_count'),
            ))
        .toList());
  }

  Future<bool> isSetSynced(String setId) async {
    final s = await setById(setId);
    return s?.cardsSynced ?? false;
  }

  Future<void> markSetSynced(String setId) async {
    await (update(cardSets)..where((t) => t.id.equals(setId)))
        .write(const CardSetsCompanion(cardsSynced: Value(true)));
  }

  // --- Cartas ---

  Future<void> bulkInsertCards(List<TcgCardsCompanion> rows) async {
    await batch(
        (b) => b.insertAll(tcgCards, rows, mode: InsertMode.insertOrReplace));
  }

  Future<TcgCardRow?> cardById(String id) =>
      (select(tcgCards)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Raridades distintas presentes num set (para os chips de filtro).
  Future<List<String>> raritiesInSet(String setId) async {
    final rows = await (selectOnly(tcgCards, distinct: true)
          ..addColumns([tcgCards.rarity])
          ..where(tcgCards.setId.equals(setId) & tcgCards.rarity.isNotNull()))
        .get();
    return rows.map((r) => r.read(tcgCards.rarity)).whereType<String>().toList()
      ..sort();
  }

  /// Cartas de um set, com filtros aplicados em SQL.
  Stream<List<CardRow>> watchCardsInSet({
    required String setId,
    required String query,
    String? rarity,
    required String status, // 'all' | 'owned' | 'missing'
  }) {
    final q = select(tcgCards).join([
      leftOuterJoin(
          userCardEntries, userCardEntries.cardId.equalsExp(tcgCards.id)),
    ]);
    q.where(tcgCards.setId.equals(setId));
    if (query.isNotEmpty) {
      final like = '%${query.toLowerCase()}%';
      q.where(tcgCards.name.lower().like(like) |
          tcgCards.number.lower().like(like));
    }
    if (rarity != null) q.where(tcgCards.rarity.equals(rarity));
    switch (status) {
      case 'owned':
        q.where(userCardEntries.owned.equals(true));
        break;
      case 'missing':
        q.where(
            userCardEntries.owned.isNull() | userCardEntries.owned.equals(false));
        break;
    }
    q.orderBy([
      OrderingTerm.asc(tcgCards.numberSort),
      OrderingTerm.asc(tcgCards.number),
    ]);
    return q.watch().map((rows) => rows
        .map((r) => CardRow(
              r.readTable(tcgCards),
              r.readTableOrNull(userCardEntries),
            ))
        .toList());
  }

  // --- Coleção ---

  Stream<UserCardEntryRow?> watchEntry(String cardId) =>
      (select(userCardEntries)..where((t) => t.cardId.equals(cardId)))
          .watchSingleOrNull();

  Future<void> upsertEntry(UserCardEntriesCompanion entry) async {
    await into(userCardEntries).insertOnConflictUpdate(entry);
  }

  // --- Progresso ---

  Future<int> totalOwned() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM user_card_entries WHERE owned = 1',
      readsFrom: {userCardEntries},
    ).getSingle();
    return row.read<int>('c');
  }

  Future<int> totalCards() async {
    final row =
        await (selectOnly(cardSets)..addColumns([cardSets.total.sum()]))
            .getSingle();
    return row.read(cardSets.total.sum()) ?? 0;
  }
}
