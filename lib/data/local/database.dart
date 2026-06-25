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
  IntColumn get hp => integer().nullable()();
  IntColumn get atk => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Coleção do utilizador (por carta), com posse independente por variante.
/// Ter a mesma carta em normal, holo e reverse NÃO conta como duplicado;
/// duplicado = 2+ cópias da MESMA variante.
@DataClassName('UserCardEntryRow')
class UserCardEntries extends Table {
  TextColumn get cardId => text()();
  BoolColumn get ownedNormal => boolean().withDefault(const Constant(false))();
  BoolColumn get ownedHolo => boolean().withDefault(const Constant(false))();
  BoolColumn get ownedReverse => boolean().withDefault(const Constant(false))();
  IntColumn get qtyNormal => integer().withDefault(const Constant(0))();
  IntColumn get qtyHolo => integer().withDefault(const Constant(0))();
  IntColumn get qtyReverse => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  BoolColumn get wishlisted => boolean().withDefault(const Constant(false))();
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

/// Carta possuída + indicação de duplicado (para a grelha "As minhas cartas").
class OwnedCard {
  final TcgCardRow card;
  final bool isDuplicate;
  const OwnedCard(this.card, this.isDuplicate);
}

@DriftDatabase(tables: [CardSets, TcgCards, UserCardEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(tcgCards, tcgCards.hp);
            await m.addColumn(tcgCards, tcgCards.atk);
            await (update(cardSets))
                .write(const CardSetsCompanion(cardsSynced: Value(false)));
          }
          if (from < 3) {
            // Posse por variante (substitui owned/variant/quantity).
            await m.addColumn(userCardEntries, userCardEntries.ownedNormal);
            await m.addColumn(userCardEntries, userCardEntries.ownedHolo);
            await m.addColumn(userCardEntries, userCardEntries.ownedReverse);
            await m.addColumn(userCardEntries, userCardEntries.qtyNormal);
            await m.addColumn(userCardEntries, userCardEntries.qtyHolo);
            await m.addColumn(userCardEntries, userCardEntries.qtyReverse);
            await customStatement(
              "UPDATE user_card_entries SET "
              "owned_normal = (owned = 1 AND variant = 'normal'), "
              "owned_holo = (owned = 1 AND variant = 'holo'), "
              "owned_reverse = (owned = 1 AND variant = 'reverseHolo'), "
              "qty_normal = CASE WHEN variant = 'normal' THEN quantity ELSE 0 END, "
              "qty_holo = CASE WHEN variant = 'holo' THEN quantity ELSE 0 END, "
              "qty_reverse = CASE WHEN variant = 'reverseHolo' THEN quantity ELSE 0 END",
            );
            // Remove as colunas antigas (SQLite recente suporta DROP COLUMN).
            for (final col in ['owned', 'variant', 'quantity']) {
              await customStatement(
                  'ALTER TABLE user_card_entries DROP COLUMN $col');
            }
          }
          if (from < 4) {
            // Lista de desejos (wishlist).
            await m.addColumn(userCardEntries, userCardEntries.wishlisted);
          }
        },
      );

  // Expressão "possui pelo menos uma variante" (para joins).
  Expression<bool> _anyOwned() =>
      userCardEntries.ownedNormal.equals(true) |
      userCardEntries.ownedHolo.equals(true) |
      userCardEntries.ownedReverse.equals(true);

  // --- Sets ---

  Future<int> setCount() async {
    final row = await (selectOnly(cardSets)
          ..addColumns([cardSets.id.count()]))
        .getSingle();
    return row.read(cardSets.id.count()) ?? 0;
  }

  Future<void> bulkInsertSets(List<CardSetsCompanion> rows) async {
    await batch(
        (b) => b.insertAll(cardSets, rows, mode: InsertMode.insertOrReplace));
  }

  Future<CardSetRow?> setById(String id) =>
      (select(cardSets)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<List<SetWithProgress>> watchSetsWithProgress() {
    return customSelect(
      'SELECT s.*, ('
      '  SELECT COUNT(*) FROM tcg_cards c '
      '  JOIN user_card_entries e ON e.card_id = c.id '
      '  WHERE c.set_id = s.id AND '
      '  (e.owned_normal = 1 OR e.owned_holo = 1 OR e.owned_reverse = 1)'
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

  Future<List<String>> raritiesInSet(String setId) async {
    final rows = await (selectOnly(tcgCards, distinct: true)
          ..addColumns([tcgCards.rarity])
          ..where(tcgCards.setId.equals(setId) & tcgCards.rarity.isNotNull()))
        .get();
    return rows.map((r) => r.read(tcgCards.rarity)).whereType<String>().toList()
      ..sort();
  }

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
        q.where(_anyOwned());
        break;
      case 'missing':
        q.where(userCardEntries.cardId.isNull() |
            (userCardEntries.ownedNormal.equals(false) &
                userCardEntries.ownedHolo.equals(false) &
                userCardEntries.ownedReverse.equals(false)));
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

  // --- Sincronização (Etapa 2) ---

  /// Entradas por enviar para a nuvem (alteradas localmente).
  Stream<List<UserCardEntryRow>> watchDirtyEntries() =>
      (select(userCardEntries)..where((t) => t.dirty.equals(true))).watch();

  Future<UserCardEntryRow?> entryOnce(String cardId) =>
      (select(userCardEntries)..where((t) => t.cardId.equals(cardId)))
          .getSingleOrNull();

  /// Aplica valores vindos do servidor (already-won pelo chamador), dirty=false.
  Future<void> applyRemoteEntry(UserCardEntriesCompanion entry) async {
    await into(userCardEntries).insertOnConflictUpdate(entry);
  }

  /// Marca como enviada (dirty=false) sem mexer nos valores; o updatedAt do
  /// servidor chega depois pelo listener remoto.
  Future<void> markPushed(String cardId) async {
    await (update(userCardEntries)..where((t) => t.cardId.equals(cardId)))
        .write(const UserCardEntriesCompanion(dirty: Value(false)));
  }

  /// Apaga toda a coleção local (ex.: ao eliminar a conta).
  Future<void> clearCollection() => delete(userCardEntries).go();

  // --- Wishlist (lista de desejos) ---

  /// Marca/desmarca uma carta na wishlist sem tocar na posse.
  Future<void> setWishlisted(String cardId, bool wanted) async {
    final n = await (update(userCardEntries)
          ..where((t) => t.cardId.equals(cardId)))
        .write(UserCardEntriesCompanion(
      wishlisted: Value(wanted),
      updatedAt: Value(DateTime.now()),
      dirty: const Value(true),
    ));
    if (n == 0) {
      await into(userCardEntries).insert(UserCardEntriesCompanion.insert(
        cardId: cardId,
        wishlisted: Value(wanted),
        updatedAt: DateTime.now(),
        dirty: const Value(true),
      ));
    }
  }

  /// Cartas desejadas que ainda NÃO possuo (como no design).
  Stream<List<CardRow>> watchWishlist() {
    final q = select(tcgCards).join([
      innerJoin(
          userCardEntries, userCardEntries.cardId.equalsExp(tcgCards.id)),
    ])
      ..where(userCardEntries.wishlisted.equals(true) & _anyOwned().not())
      ..orderBy([OrderingTerm(expression: tcgCards.numberSort)]);
    return q.watch().map((rows) => rows
        .map((r) =>
            CardRow(r.readTable(tcgCards), r.readTable(userCardEntries)))
        .toList());
  }

  /// Contagem de cartas desejadas (não possuídas).
  Stream<int> watchWishlistCount() {
    final c = countAll();
    final q = selectOnly(userCardEntries)
      ..addColumns([c])
      ..where(userCardEntries.wishlisted.equals(true) & _anyOwned().not());
    return q.watchSingle().map((r) => r.read(c) ?? 0);
  }

  // --- Progresso / estatísticas ---

  Future<int> totalOwned() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS c FROM user_card_entries '
      'WHERE owned_normal = 1 OR owned_holo = 1 OR owned_reverse = 1',
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

  Stream<({int total, int owned})> watchSetCounts(String setId) {
    return customSelect(
      'SELECT COUNT(*) AS total, '
      'SUM(CASE WHEN (e.owned_normal = 1 OR e.owned_holo = 1 '
      '  OR e.owned_reverse = 1) THEN 1 ELSE 0 END) AS owned '
      'FROM tcg_cards c LEFT JOIN user_card_entries e ON e.card_id = c.id '
      'WHERE c.set_id = ?',
      variables: [Variable<String>(setId)],
      readsFrom: {tcgCards, userCardEntries},
    ).watchSingle().map((r) =>
        (total: r.read<int>('total'), owned: r.read<int?>('owned') ?? 0));
  }

  /// Cartas possuídas em variante holo ou reverse.
  Future<int> holoCount() async {
    final r = await customSelect(
      'SELECT COUNT(*) AS c FROM user_card_entries '
      'WHERE owned_holo = 1 OR owned_reverse = 1',
      readsFrom: {userCardEntries},
    ).getSingle();
    return r.read<int>('c');
  }

  /// Cartas com 2+ cópias da MESMA variante (duplicados reais).
  Future<int> duplicatesCount() async {
    final r = await customSelect(
      'SELECT COUNT(*) AS c FROM user_card_entries '
      'WHERE qty_normal > 1 OR qty_holo > 1 OR qty_reverse > 1',
      readsFrom: {userCardEntries},
    ).getSingle();
    return r.read<int>('c');
  }

  Future<int> setsDoneCount() async {
    final r = await customSelect(
      'SELECT COUNT(*) AS c FROM card_sets s WHERE s.total > 0 AND '
      '(SELECT COUNT(*) FROM tcg_cards c JOIN user_card_entries e '
      ' ON e.card_id = c.id WHERE c.set_id = s.id AND '
      ' (e.owned_normal = 1 OR e.owned_holo = 1 OR e.owned_reverse = 1)'
      ') >= s.total',
      readsFrom: {cardSets, tcgCards, userCardEntries},
    ).getSingle();
    return r.read<int>('c');
  }

  Future<List<({String type, int owned})>> ownedByTypeInSet(
      String setId) async {
    final rows = await customSelect(
      "SELECT COALESCE(c.type, 'Colorless') AS t, COUNT(*) AS n "
      'FROM tcg_cards c JOIN user_card_entries e ON e.card_id = c.id '
      'WHERE c.set_id = ? AND '
      '(e.owned_normal = 1 OR e.owned_holo = 1 OR e.owned_reverse = 1) '
      'GROUP BY t ORDER BY n DESC',
      variables: [Variable<String>(setId)],
      readsFrom: {tcgCards, userCardEntries},
    ).get();
    return rows
        .map((r) => (type: r.read<String>('t'), owned: r.read<int>('n')))
        .toList();
  }

  /// Todas as cartas com ≥1 variante possuída. `onlyDuplicates` limita às que
  /// têm 2+ cópias da mesma variante.
  Future<List<OwnedCard>> ownedCards({bool onlyDuplicates = false}) async {
    const dupeExpr =
        '(e.qty_normal > 1 OR e.qty_holo > 1 OR e.qty_reverse > 1)';
    final rows = await customSelect(
      'SELECT c.*, $dupeExpr AS is_dupe '
      'FROM tcg_cards c JOIN user_card_entries e ON e.card_id = c.id '
      'WHERE (e.owned_normal = 1 OR e.owned_holo = 1 OR e.owned_reverse = 1) '
      '${onlyDuplicates ? 'AND $dupeExpr ' : ''}'
      'ORDER BY c.set_id, c.number_sort',
      readsFrom: {tcgCards, userCardEntries},
    ).get();
    return rows
        .map((r) => OwnedCard(tcgCards.map(r.data), r.read<int>('is_dupe') == 1))
        .toList();
  }

  Stream<List<CardRow>> watchAllCards({
    required String query,
    required List<String> types,
    required String status, // 'all' | 'owned' | 'missing'
    int limit = 60,
  }) {
    final q = select(tcgCards).join([
      leftOuterJoin(
          userCardEntries, userCardEntries.cardId.equalsExp(tcgCards.id)),
    ]);
    if (query.isNotEmpty) {
      final like = '%${query.toLowerCase()}%';
      q.where(tcgCards.name.lower().like(like) |
          tcgCards.number.lower().like(like));
    }
    if (types.isNotEmpty) {
      q.where(tcgCards.type.isIn(types));
    }
    switch (status) {
      case 'owned':
        q.where(_anyOwned());
        break;
      case 'missing':
        q.where(userCardEntries.cardId.isNull() |
            (userCardEntries.ownedNormal.equals(false) &
                userCardEntries.ownedHolo.equals(false) &
                userCardEntries.ownedReverse.equals(false)));
        break;
    }
    q.orderBy([OrderingTerm.asc(tcgCards.name)]);
    q.limit(limit);
    return q.watch().map((rows) => rows
        .map((r) => CardRow(
              r.readTable(tcgCards),
              r.readTableOrNull(userCardEntries),
            ))
        .toList());
  }
}
