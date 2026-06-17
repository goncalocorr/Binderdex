import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Catálogo estático (preenchido a partir do dataset incluído).
class PokemonTable extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get nameEn => text()();
  TextColumn get type1 => text()();
  TextColumn get type2 => text().nullable()();
  IntColumn get generation => integer()();
  IntColumn get hp => integer()();
  IntColumn get attack => integer()();
  IntColumn get defense => integer()();
  IntColumn get spAttack => integer()();
  IntColumn get spDefense => integer()();
  IntColumn get speed => integer()();
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Coleção do utilizador.
///
/// O Drift singulariza "UserEntries" para "UserEntry", o que colidiria com a
/// nossa entidade de domínio. Damos um nome distinto à classe gerada.
@DataClassName('UserEntryRow')
class UserEntries extends Table {
  IntColumn get pokemonId => integer()();
  BoolColumn get caught => boolean().withDefault(const Constant(false))();
  BoolColumn get shiny => boolean().withDefault(const Constant(false))();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();

  /// Marcado quando há alterações por sincronizar. Usado na Etapa 2.
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {pokemonId};
}

/// Resultado de uma linha da grelha: o Pokémon e (opcionalmente) o seu registo.
class PokemonRow {
  final PokemonTableData pokemon;
  final UserEntryRow? entry;
  PokemonRow(this.pokemon, this.entry);
}

/// Contagem agregada por geração (para o ecrã de progresso).
class GenCount {
  final int generation;
  final int total;
  final int caught;
  GenCount(this.generation, this.total, this.caught);
}

@DriftDatabase(tables: [PokemonTable, UserEntries])
class AppDatabase extends _$AppDatabase {
  /// Construtor de produção (ficheiro). Para testes, passar NativeDatabase.memory().
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  Future<int> pokemonCount() async {
    final row = await (selectOnly(pokemonTable)
          ..addColumns([pokemonTable.id.count()]))
        .getSingle();
    return row.read(pokemonTable.id.count()) ?? 0;
  }

  Future<void> bulkInsertPokemon(List<PokemonTableCompanion> rows) async {
    await batch((b) => b.insertAll(pokemonTable, rows,
        mode: InsertMode.insertOrReplace));
  }

  /// Query reativa com TODOS os filtros aplicados em SQL.
  Stream<List<PokemonRow>> watchFiltered({
    required String query,
    int? generation,
    String? type,
    required String status, // 'all' | 'caught' | 'missing' | 'shiny'
  }) {
    final q = select(pokemonTable).join([
      leftOuterJoin(userEntries, userEntries.pokemonId.equalsExp(pokemonTable.id)),
    ]);

    if (query.isNotEmpty) {
      final asNum = int.tryParse(query);
      if (asNum != null) {
        q.where(pokemonTable.id.equals(asNum));
      } else {
        final like = '%${query.toLowerCase()}%';
        q.where(pokemonTable.name.lower().like(like) |
            pokemonTable.nameEn.lower().like(like));
      }
    }
    if (generation != null) {
      q.where(pokemonTable.generation.equals(generation));
    }
    if (type != null) {
      q.where(pokemonTable.type1.equals(type) | pokemonTable.type2.equals(type));
    }
    switch (status) {
      case 'caught':
        q.where(userEntries.caught.equals(true));
        break;
      case 'shiny':
        q.where(userEntries.shiny.equals(true));
        break;
      case 'missing':
        // Sem registo (isNull) OU registo com caught = false.
        q.where(userEntries.caught.isNull() | userEntries.caught.equals(false));
        break;
    }

    q.orderBy([OrderingTerm.asc(pokemonTable.id)]);

    return q.watch().map((rows) => rows
        .map((r) => PokemonRow(
              r.readTable(pokemonTable),
              r.readTableOrNull(userEntries),
            ))
        .toList());
  }

  Stream<UserEntryRow?> watchEntry(int pokemonId) =>
      (select(userEntries)..where((t) => t.pokemonId.equals(pokemonId)))
          .watchSingleOrNull();

  Future<void> upsertEntry(UserEntriesCompanion entry) async {
    await into(userEntries).insertOnConflictUpdate(entry);
  }

  /// Contagens por geração (total e apanhados), calculadas em SQL.
  Future<List<GenCount>> caughtByGeneration() async {
    final rows = await customSelect(
      'SELECT p.generation AS g, COUNT(*) AS total, '
      'SUM(CASE WHEN e.caught = 1 THEN 1 ELSE 0 END) AS caught '
      'FROM pokemon_table p '
      'LEFT JOIN user_entries e ON e.pokemon_id = p.id '
      'GROUP BY p.generation ORDER BY p.generation',
      readsFrom: {pokemonTable, userEntries},
    ).get();
    return rows
        .map((r) => GenCount(
              r.read<int>('g'),
              r.read<int>('total'),
              r.read<int>('caught'),
            ))
        .toList();
  }
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'pokedex.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
