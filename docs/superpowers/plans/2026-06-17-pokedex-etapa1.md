# Plano de Implementação — Etapa 1: Pokédex Offline

> **Para workers agênticos:** SUB-SKILL OBRIGATÓRIA: usar superpowers:subagent-driven-development (recomendado) ou superpowers:executing-plans para implementar tarefa-a-tarefa. Os passos usam checkboxes (`- [ ]`).

**Goal:** Entregar uma app Flutter funcional e 100% offline que lista todos os Pokémon (todas as gerações) a partir de um dataset incluído, com pesquisa, filtros, detalhe, progresso e lista de "em falta", guardando a coleção no Drift — **sem Firebase**.

**Architecture:** Arquitetura limpa por camadas (data/domain/presentation). Catálogo estático gerado por um script Dart a partir da PokéAPI e incluído em `assets/`, hidratado para Drift no primeiro arranque. Filtros e pesquisa executados em SQL no Drift (queries reativas). Estado e injeção via Riverpod. UI Material 3 com tema claro/escuro e i18n PT/EN.

**Tech Stack:** Flutter, Dart, Riverpod (flutter_riverpod), Drift (+ sqlite3_flutter_libs), GoRouter, cached_network_image, intl/flutter_localizations, dio (só no script gerador).

**Nota de execução:** O ambiente do agente não tem Flutter instalado — os comandos `flutter`/`dart`/`pytest`→`flutter test` correm na máquina do utilizador. O agente escreve o código; o utilizador (ou o agente após instalação do SDK) corre os testes e reporta resultados.

---

## Estrutura de Ficheiros (Etapa 1)

```
pubspec.yaml                                   # dependências
analysis_options.yaml                          # lints
l10n.yaml                                       # config de geração intl
.gitignore
tool/generate_dataset.dart                     # PokéAPI -> assets/data/pokedex.json
assets/data/pokedex.json                       # dataset gerado (catálogo)
lib/
├── main.dart                                  # bootstrap + ProviderScope
├── app.dart                                   # MaterialApp.router, tema, l10n
├── l10n/app_en.arb, app_pt.arb                # strings
├── core/
│   ├── theme/app_theme.dart                   # temas claro/escuro M3
│   ├── theme/type_colors.dart                 # cor por tipo
│   ├── router/app_router.dart                 # GoRouter + shell de navegação
│   └── utils/sprites.dart                     # URL determinístico de arte oficial
├── domain/
│   ├── entities/pokemon.dart                  # Pokemon, PokemonType
│   ├── entities/user_entry.dart               # UserEntry, CollectionStatus
│   ├── entities/progress.dart                 # ProgressStats
│   └── entities/pokedex_filter.dart           # PokedexFilter (estado de filtros)
├── data/
│   ├── local/database.dart                    # Drift: tabelas + AppDatabase + DAO/queries
│   ├── seed/dataset_loader.dart               # lê pokedex.json -> hidrata Drift
│   └── repositories/
│       ├── pokemon_repository.dart            # interface + impl (catálogo + queries)
│       └── collection_repository.dart         # interface + impl (user_entries)
└── presentation/
    ├── providers/app_providers.dart           # db, repos, filtros, listas, progresso
    ├── screens/pokedex_screen.dart            # grelha + pesquisa + filtros
    ├── screens/detail_screen.dart             # detalhe + edição de coleção
    ├── screens/progress_screen.dart           # progresso global e por geração
    ├── screens/missing_screen.dart            # lista de em falta
    ├── screens/settings_screen.dart           # idioma + tema
    └── widgets/
        ├── pokemon_card.dart                  # cartão (silhueta/cor, badge shiny, placeholder)
        ├── type_chip.dart                     # chip de tipo colorido
        └── filter_sheet.dart                  # bottom sheet de filtros
test/
├── progress_test.dart                         # cálculo de progresso
├── filter_query_test.dart                     # filtros/pesquisa no Drift
└── pokemon_card_test.dart                     # estados visuais do cartão
```

---

## Task 1: Scaffold do projeto Flutter

**Files:**
- Create: projeto Flutter base, `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`

- [ ] **Step 1: Criar o projeto**

Run:
```bash
flutter create --org com.example --project-name pokedex --platforms=android,web .
```
Expected: cria `lib/`, `android/`, `web/`, `pubspec.yaml`.

- [ ] **Step 2: Definir dependências em `pubspec.yaml`**

Substituir a secção `dependencies`/`dev_dependencies` por:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  drift: ^2.18.0
  sqlite3_flutter_libs: ^0.5.24
  path_provider: ^2.1.3
  path: ^1.9.0
  go_router: ^14.2.0
  cached_network_image: ^3.3.1
  intl: any

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  drift_dev: ^2.18.0
  build_runner: ^2.4.11
  dio: ^5.4.3+1            # usado só pelo tool/generate_dataset.dart

flutter:
  uses-material-design: true
  generate: true          # ativa geração de l10n
  assets:
    - assets/data/pokedex.json
```

- [ ] **Step 3: Instalar e confirmar que compila**

Run: `flutter pub get`
Expected: "Got dependencies".

- [ ] **Step 4: Garantir minSdk 26**

Em `android/app/build.gradle` (ou `build.gradle.kts`), definir `minSdkVersion 26`.

- [ ] **Step 5: Commit**

```bash
git add -A
git commit -m "chore: scaffold do projeto Flutter com dependências da Etapa 1"
```

---

## Task 2: Script gerador do dataset

**Files:**
- Create: `tool/generate_dataset.dart`

- [ ] **Step 1: Escrever o gerador**

```dart
// tool/generate_dataset.dart
// Corre com: dart run tool/generate_dataset.dart
// Percorre a PokéAPI e escreve assets/data/pokedex.json.
// Nome/lore em PT quando existir; fallback EN.
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';

const datasetVersion = 1; // incrementar a cada regeneração com Pokémon novos
final dio = Dio(BaseOptions(baseUrl: 'https://pokeapi.co/api/v2/'));

String _pick(List entries, String langField, String textField) {
  Map? pt = entries.cast<Map>().firstWhere(
      (e) => e[langField]['name'] == 'pt', orElse: () => {});
  if (pt.isNotEmpty) return (pt[textField] as String);
  Map? en = entries.cast<Map>().firstWhere(
      (e) => e[langField]['name'] == 'en', orElse: () => {});
  return en.isNotEmpty ? (en[textField] as String) : '';
}

int _genFromUrl(String url) {
  // .../generation/3/ -> 3
  final parts = url.split('/').where((p) => p.isNotEmpty).toList();
  return int.parse(parts.last);
}

Future<Map<String, dynamic>> _build(int id) async {
  final p = (await dio.get('pokemon/$id')).data;
  final s = (await dio.get('pokemon-species/$id')).data;
  final types = (p['types'] as List)..sort((a, b) => a['slot'].compareTo(b['slot']));
  final stats = {for (final st in p['stats']) st['stat']['name']: st['base_stat']};
  final namePt = _pick(s['names'], 'language', 'name');
  final lore = _pick(s['flavor_text_entries'], 'language', 'flavor_text')
      .replaceAll('\n', ' ').replaceAll('\f', ' ');
  return {
    'id': id,
    'name': namePt.isNotEmpty ? namePt : (p['name'] as String),
    'nameEn': p['name'],
    'type1': types[0]['type']['name'],
    'type2': types.length > 1 ? types[1]['type']['name'] : null,
    'gen': _genFromUrl(s['generation']['url']),
    'hp': stats['hp'], 'attack': stats['attack'], 'defense': stats['defense'],
    'spAttack': stats['special-attack'], 'spDefense': stats['special-defense'],
    'speed': stats['speed'],
    'description': lore,
  };
}

Future<void> main() async {
  final list = (await dio.get('pokemon?limit=100000')).data['results'] as List;
  final total = list.length;
  final out = <Map<String, dynamic>>[];
  for (var i = 0; i < total; i++) {
    final id = i + 1;
    try {
      out.add(await _build(id));
    } catch (e) {
      stderr.writeln('Falhou #$id: $e');
    }
    if (id % 50 == 0) stdout.writeln('$id/$total');
    await Future.delayed(const Duration(milliseconds: 40)); // throttle gentil
  }
  final json = {
    'datasetVersion': datasetVersion,
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'pokemon': out,
  };
  await Directory('assets/data').create(recursive: true);
  await File('assets/data/pokedex.json')
      .writeAsString(const JsonEncoder().convert(json));
  stdout.writeln('OK: ${out.length} Pokémon -> assets/data/pokedex.json');
}
```

- [ ] **Step 2: Commit**

```bash
git add tool/generate_dataset.dart
git commit -m "feat: script gerador do dataset a partir da PokeAPI"
```

---

## Task 3: Gerar o dataset

**Files:**
- Create: `assets/data/pokedex.json` (artefacto gerado)

- [ ] **Step 1: Correr o gerador** (requer internet; ~poucos minutos)

Run: `dart run tool/generate_dataset.dart`
Expected: imprime progresso e "OK: N Pokémon ...". `N` deve ser ~1025+.

- [ ] **Step 2: Validação rápida do ficheiro**

Run: `dart -e "import 'dart:io';import 'dart:convert';void main(){final j=jsonDecode(File('assets/data/pokedex.json').readAsStringSync());print('total=' + (j['pokemon'] as List).length.toString());}"`
Expected: `total=1025` (ou superior).

- [ ] **Step 3: Commit**

```bash
git add assets/data/pokedex.json
git commit -m "data: dataset incluído gerado (todas as gerações)"
```

---

## Task 4: Entidades de domínio

**Files:**
- Create: `lib/domain/entities/pokemon.dart`, `user_entry.dart`, `progress.dart`, `pokedex_filter.dart`

- [ ] **Step 1: Escrever o teste de progresso primeiro** (ver Task 12). Aqui definem-se as entidades de que ele depende.

- [ ] **Step 2: `pokemon.dart`**

```dart
enum PokemonType {
  normal, fire, water, electric, grass, ice, fighting, poison, ground,
  flying, psychic, bug, rock, ghost, dragon, dark, steel, fairy;

  static PokemonType fromApi(String s) =>
      PokemonType.values.firstWhere((t) => t.name == s);
}

class Pokemon {
  final int id;
  final String name;
  final String nameEn;
  final PokemonType type1;
  final PokemonType? type2;
  final int generation;
  final int hp, attack, defense, spAttack, spDefense, speed;
  final String description;

  const Pokemon({
    required this.id, required this.name, required this.nameEn,
    required this.type1, this.type2, required this.generation,
    required this.hp, required this.attack, required this.defense,
    required this.spAttack, required this.spDefense, required this.speed,
    required this.description,
  });

  List<PokemonType> get types => [type1, if (type2 != null) type2!];
}
```

- [ ] **Step 3: `user_entry.dart`**

```dart
class UserEntry {
  final int pokemonId;
  final bool caught;
  final bool shiny;
  final int quantity;
  final String notes;
  final DateTime updatedAt;

  const UserEntry({
    required this.pokemonId,
    this.caught = false,
    this.shiny = false,
    this.quantity = 0,
    this.notes = '',
    required this.updatedAt,
  });

  UserEntry copyWith({bool? caught, bool? shiny, int? quantity, String? notes, DateTime? updatedAt}) =>
      UserEntry(
        pokemonId: pokemonId,
        caught: caught ?? this.caught,
        shiny: shiny ?? this.shiny,
        quantity: quantity ?? this.quantity,
        notes: notes ?? this.notes,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
```

- [ ] **Step 4: `progress.dart`**

```dart
class ProgressStats {
  final int total;
  final int caught;
  const ProgressStats({required this.total, required this.caught});

  int get missing => total - caught;
  double get percent => total == 0 ? 0 : caught / total;
}
```

- [ ] **Step 5: `pokedex_filter.dart`**

```dart
import 'pokemon.dart';

enum StatusFilter { all, caught, missing, shiny }

class PokedexFilter {
  final String query;            // nome ou número
  final int? generation;         // null = todas
  final PokemonType? type;       // null = todos
  final StatusFilter status;

  const PokedexFilter({
    this.query = '',
    this.generation,
    this.type,
    this.status = StatusFilter.all,
  });

  PokedexFilter copyWith({
    String? query, int? generation, bool clearGeneration = false,
    PokemonType? type, bool clearType = false, StatusFilter? status,
  }) =>
      PokedexFilter(
        query: query ?? this.query,
        generation: clearGeneration ? null : (generation ?? this.generation),
        type: clearType ? null : (type ?? this.type),
        status: status ?? this.status,
      );
}
```

- [ ] **Step 6: Commit**

```bash
git add lib/domain/entities
git commit -m "feat: entidades de domínio (Pokemon, UserEntry, Progress, Filter)"
```

---

## Task 5: Base de dados Drift

**Files:**
- Create: `lib/data/local/database.dart`
- Test: `test/filter_query_test.dart` (Task 11)

- [ ] **Step 1: Definir tabelas e queries**

```dart
// lib/data/local/database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

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

class UserEntries extends Table {
  IntColumn get pokemonId => integer()();
  BoolColumn get caught => boolean().withDefault(const Constant(false))();
  BoolColumn get shiny => boolean().withDefault(const Constant(false))();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))(); // para Etapa 2 (sync)
  @override
  Set<Column> get primaryKey => {pokemonId};
}

@DriftDatabase(tables: [PokemonTable, UserEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _open());

  @override
  int get schemaVersion => 1;

  Future<int> pokemonCount() async =>
      (await select(pokemonTable).get()).length;

  Future<void> bulkInsertPokemon(List<PokemonTableCompanion> rows) async {
    await batch((b) => b.insertAll(pokemonTable, rows, mode: InsertMode.insertOrReplace));
  }

  // Query reativa com filtros aplicados em SQL.
  Stream<List<PokemonRow>> watchFiltered({
    required String query,
    int? generation,
    String? type,
    required String status, // 'all'|'caught'|'missing'|'shiny'
  }) {
    final q = select(pokemonTable).join([
      leftOuterJoin(userEntries, userEntries.pokemonId.equalsExp(pokemonTable.id)),
    ]);
    if (query.isNotEmpty) {
      final asNum = int.tryParse(query);
      if (asNum != null) {
        q.where(pokemonTable.id.equals(asNum));
      } else {
        q.where(pokemonTable.name.lower().like('%${query.toLowerCase()}%') |
            pokemonTable.nameEn.lower().like('%${query.toLowerCase()}%'));
      }
    }
    if (generation != null) q.where(pokemonTable.generation.equals(generation));
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
        q.where(userEntries.caught.equals(true).not() | userEntries.caught.isNull());
        break;
    }
    q.orderBy([OrderingTerm.asc(pokemonTable.id)]);
    return q.watch().map((rows) => rows.map((r) => PokemonRow(
          r.readTable(pokemonTable),
          r.readTableOrNull(userEntries),
        )).toList());
  }

  Stream<UserEntrie?> watchEntry(int pokemonId) =>
      (select(userEntries)..where((t) => t.pokemonId.equals(pokemonId)))
          .watchSingleOrNull();

  Future<void> upsertEntry(UserEntriesCompanion entry) async {
    await into(userEntries).insertOnConflictUpdate(entry);
  }

  // Para o ecrã de progresso (contagens por geração feitas em SQL).
  Future<List<GenCount>> caughtByGeneration() async {
    final caught = await customSelect(
      'SELECT p.generation AS g, COUNT(*) AS total, '
      'SUM(CASE WHEN e.caught = 1 THEN 1 ELSE 0 END) AS caught '
      'FROM pokemon_table p LEFT JOIN user_entries e ON e.pokemon_id = p.id '
      'GROUP BY p.generation ORDER BY p.generation',
      readsFrom: {pokemonTable, userEntries},
    ).get();
    return caught
        .map((r) => GenCount(r.read<int>('g'), r.read<int>('total'),
            r.read<int>('caught')))
        .toList();
  }
}

class PokemonRow {
  final PokemonTableData pokemon;
  final UserEntrie? entry;
  PokemonRow(this.pokemon, this.entry);
}

class GenCount {
  final int generation, total, caught;
  GenCount(this.generation, this.total, this.caught);
}

LazyDatabase _open() => LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      return NativeDatabase.createInBackground(File(p.join(dir.path, 'pokedex.sqlite')));
    });
```

- [ ] **Step 2: Gerar o código Drift**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: cria `lib/data/local/database.g.dart` sem erros.

- [ ] **Step 3: Commit**

```bash
git add lib/data/local/database.dart lib/data/local/database.g.dart
git commit -m "feat: base de dados Drift (tabelas, queries de filtro e progresso)"
```

---

## Task 6: Carregador do dataset (hidratação)

**Files:**
- Create: `lib/data/seed/dataset_loader.dart`

- [ ] **Step 1: Implementar**

```dart
// lib/data/seed/dataset_loader.dart
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../local/database.dart';
import 'package:drift/drift.dart';

class DatasetLoader {
  final AppDatabase db;
  DatasetLoader(this.db);

  /// Hidrata o Drift a partir do asset, apenas se ainda estiver vazio.
  Future<void> ensureSeeded() async {
    if (await db.pokemonCount() > 0) return;
    final raw = await rootBundle.loadString('assets/data/pokedex.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = (data['pokemon'] as List).cast<Map<String, dynamic>>();
    final rows = list.map((m) => PokemonTableCompanion.insert(
          id: Value(m['id'] as int),
          name: m['name'] as String,
          nameEn: m['nameEn'] as String,
          type1: m['type1'] as String,
          type2: Value(m['type2'] as String?),
          generation: m['gen'] as int,
          hp: m['hp'] as int, attack: m['attack'] as int, defense: m['defense'] as int,
          spAttack: m['spAttack'] as int, spDefense: m['spDefense'] as int,
          speed: m['speed'] as int,
          description: m['description'] as String,
        )).toList();
    await db.bulkInsertPokemon(rows);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/seed/dataset_loader.dart
git commit -m "feat: hidratação do Drift a partir do dataset incluído"
```

---

## Task 7: Repositórios

**Files:**
- Create: `lib/data/repositories/pokemon_repository.dart`, `collection_repository.dart`

- [ ] **Step 1: `pokemon_repository.dart`**

```dart
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokedex_filter.dart';
import '../local/database.dart';

Pokemon _toEntity(PokemonTableData p) => Pokemon(
      id: p.id, name: p.name, nameEn: p.nameEn,
      type1: PokemonType.fromApi(p.type1),
      type2: p.type2 == null ? null : PokemonType.fromApi(p.type2!),
      generation: p.generation,
      hp: p.hp, attack: p.attack, defense: p.defense,
      spAttack: p.spAttack, spDefense: p.spDefense, speed: p.speed,
      description: p.description,
    );

class PokemonRepository {
  final AppDatabase db;
  PokemonRepository(this.db);

  Stream<List<({Pokemon pokemon, bool caught, bool shiny})>> watchFiltered(PokedexFilter f) {
    return db
        .watchFiltered(
          query: f.query,
          generation: f.generation,
          type: f.type?.name,
          status: f.status.name,
        )
        .map((rows) => rows
            .map((r) => (
                  pokemon: _toEntity(r.pokemon),
                  caught: r.entry?.caught ?? false,
                  shiny: r.entry?.shiny ?? false,
                ))
            .toList());
  }

  Future<Pokemon?> byId(int id) async {
    final row = await (db.select(db.pokemonTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }
}
```

- [ ] **Step 2: `collection_repository.dart`**

```dart
import 'package:drift/drift.dart';
import '../../domain/entities/user_entry.dart';
import '../../domain/entities/progress.dart';
import '../local/database.dart';

class CollectionRepository {
  final AppDatabase db;
  CollectionRepository(this.db);

  Stream<UserEntry> watchEntry(int pokemonId) => db.watchEntry(pokemonId).map((e) =>
      e == null
          ? UserEntry(pokemonId: pokemonId, updatedAt: DateTime.fromMillisecondsSinceEpoch(0))
          : UserEntry(
              pokemonId: e.pokemonId, caught: e.caught, shiny: e.shiny,
              quantity: e.quantity, notes: e.notes, updatedAt: e.updatedAt));

  Future<void> save(UserEntry entry) async {
    await db.upsertEntry(UserEntriesCompanion.insert(
      pokemonId: entry.pokemonId,
      caught: Value(entry.caught),
      shiny: Value(entry.shiny),
      quantity: Value(entry.quantity),
      notes: Value(entry.notes),
      updatedAt: DateTime.now(), // Etapa 2 troca para server timestamp no sync
      dirty: const Value(true),
    ));
  }

  Future<ProgressStats> globalProgress() async {
    final gens = await db.caughtByGeneration();
    final total = gens.fold<int>(0, (a, g) => a + g.total);
    final caught = gens.fold<int>(0, (a, g) => a + g.caught);
    return ProgressStats(total: total, caught: caught);
  }

  Future<Map<int, ProgressStats>> progressByGeneration() async {
    final gens = await db.caughtByGeneration();
    return {for (final g in gens) g.generation: ProgressStats(total: g.total, caught: g.caught)};
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/repositories
git commit -m "feat: repositórios de catálogo e coleção"
```

---

## Task 8: Providers Riverpod

**Files:**
- Create: `lib/presentation/providers/app_providers.dart`

- [ ] **Step 1: Implementar**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/database.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../../data/repositories/collection_repository.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokedex_filter.dart';
import '../../domain/entities/progress.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final pokemonRepositoryProvider =
    Provider((ref) => PokemonRepository(ref.watch(databaseProvider)));
final collectionRepositoryProvider =
    Provider((ref) => CollectionRepository(ref.watch(databaseProvider)));

final filterProvider = StateProvider<PokedexFilter>((_) => const PokedexFilter());

final pokedexListProvider =
    StreamProvider<List<({Pokemon pokemon, bool caught, bool shiny})>>((ref) {
  final filter = ref.watch(filterProvider);
  return ref.watch(pokemonRepositoryProvider).watchFiltered(filter);
});

// Lista de "em falta" = filtro com status missing, independente do filtro principal.
final missingListProvider =
    StreamProvider<List<({Pokemon pokemon, bool caught, bool shiny})>>((ref) {
  return ref
      .watch(pokemonRepositoryProvider)
      .watchFiltered(const PokedexFilter(status: StatusFilter.missing));
});

final globalProgressProvider = FutureProvider<ProgressStats>((ref) {
  ref.watch(pokedexListProvider); // re-calcula quando a coleção muda
  return ref.watch(collectionRepositoryProvider).globalProgress();
});

final progressByGenProvider = FutureProvider<Map<int, ProgressStats>>((ref) {
  ref.watch(pokedexListProvider);
  return ref.watch(collectionRepositoryProvider).progressByGeneration();
});

final entryProvider = StreamProvider.family((ref, int id) =>
    ref.watch(collectionRepositoryProvider).watchEntry(id));

// Preferências simples de UI (Etapa 1): tema e idioma em memória.
final themeModeProvider = StateProvider((_) => 0);   // 0=sistema,1=claro,2=escuro
final localeProvider = StateProvider<String?>((_) => null); // null=sistema
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/providers/app_providers.dart
git commit -m "feat: providers Riverpod (db, repos, filtros, listas, progresso)"
```

---

## Task 9: Tema, cores de tipo e utilitário de sprites

**Files:**
- Create: `lib/core/theme/type_colors.dart`, `lib/core/theme/app_theme.dart`, `lib/core/utils/sprites.dart`

- [ ] **Step 1: `type_colors.dart`**

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/pokemon.dart';

const Map<PokemonType, Color> typeColors = {
  PokemonType.normal: Color(0xFFA8A77A), PokemonType.fire: Color(0xFFEE8130),
  PokemonType.water: Color(0xFF6390F0), PokemonType.electric: Color(0xFFF7D02C),
  PokemonType.grass: Color(0xFF7AC74C), PokemonType.ice: Color(0xFF96D9D6),
  PokemonType.fighting: Color(0xFFC22E28), PokemonType.poison: Color(0xFFA33EA1),
  PokemonType.ground: Color(0xFFE2BF65), PokemonType.flying: Color(0xFFA98FF3),
  PokemonType.psychic: Color(0xFFF95587), PokemonType.bug: Color(0xFFA6B91A),
  PokemonType.rock: Color(0xFFB6A136), PokemonType.ghost: Color(0xFF735797),
  PokemonType.dragon: Color(0xFF6F35FC), PokemonType.dark: Color(0xFF705746),
  PokemonType.steel: Color(0xFFB7B7CE), PokemonType.fairy: Color(0xFFD685AD),
};
```

- [ ] **Step 2: `sprites.dart`**

```dart
class Sprites {
  static const _base =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';
  static String artwork(int id, {bool shiny = false}) =>
      shiny ? '$_base/shiny/$id.png' : '$_base/$id.png';
}
```

- [ ] **Step 3: `app_theme.dart`**

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE3350D), // vermelho Pokébola
        brightness: Brightness.light,
      );
  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE3350D),
        brightness: Brightness.dark,
      );
}
```

- [ ] **Step 4: Commit**

```bash
git add lib/core
git commit -m "feat: tema M3, cores por tipo e URLs de sprites"
```

---

## Task 10: i18n (PT/EN)

**Files:**
- Create: `l10n.yaml`, `lib/l10n/app_en.arb`, `lib/l10n/app_pt.arb`

- [ ] **Step 1: `l10n.yaml`**

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

- [ ] **Step 2: `app_en.arb`**

```json
{
  "appTitle": "Pokédex",
  "searchHint": "Search by name or number",
  "tabPokedex": "Pokédex",
  "tabProgress": "Progress",
  "tabMissing": "Missing",
  "tabSettings": "Settings",
  "caught": "Caught",
  "shiny": "Shiny",
  "quantity": "Quantity",
  "notes": "Notes",
  "filterGeneration": "Generation",
  "filterType": "Type",
  "filterStatus": "Status",
  "statusAll": "All",
  "statusMissing": "Missing",
  "progressGlobal": "Global progress",
  "theme": "Theme",
  "language": "Language"
}
```

- [ ] **Step 3: `app_pt.arb`** (mesmas chaves, valores PT)

```json
{
  "appTitle": "Pokédex",
  "searchHint": "Pesquisar por nome ou número",
  "tabPokedex": "Pokédex",
  "tabProgress": "Progresso",
  "tabMissing": "Em falta",
  "tabSettings": "Definições",
  "caught": "Tenho",
  "shiny": "Shiny",
  "quantity": "Quantidade",
  "notes": "Notas",
  "filterGeneration": "Geração",
  "filterType": "Tipo",
  "filterStatus": "Estado",
  "statusAll": "Todos",
  "statusMissing": "Em falta",
  "progressGlobal": "Progresso global",
  "theme": "Tema",
  "language": "Idioma"
}
```

- [ ] **Step 4: Gerar localizações**

Run: `flutter gen-l10n`
Expected: gera `app_localizations.dart` sem erros.

- [ ] **Step 5: Commit**

```bash
git add l10n.yaml lib/l10n
git commit -m "feat: i18n PT/EN com ficheiros .arb"
```

---

## Task 11: Teste de filtros (Drift em memória)

**Files:**
- Test: `test/filter_query_test.dart`

- [ ] **Step 1: Escrever o teste**

```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:pokedex/data/local/database.dart';

void main() {
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.bulkInsertPokemon([
      PokemonTableCompanion.insert(id: const Value(1), name: 'Bulbasaur', nameEn: 'Bulbasaur',
          type1: 'grass', type2: const Value('poison'), generation: 1,
          hp: 45, attack: 49, defense: 49, spAttack: 65, spDefense: 65, speed: 45, description: ''),
      PokemonTableCompanion.insert(id: const Value(4), name: 'Charmander', nameEn: 'Charmander',
          type1: 'fire', generation: 1,
          hp: 39, attack: 52, defense: 43, spAttack: 60, spDefense: 50, speed: 65, description: ''),
    ]);
  });
  tearDown(() => db.close());

  test('filtra por tipo via SQL', () async {
    final res = await db.watchFiltered(query: '', generation: null, type: 'fire', status: 'all').first;
    expect(res.length, 1);
    expect(res.first.pokemon.id, 4);
  });

  test('pesquisa por número', () async {
    final res = await db.watchFiltered(query: '1', generation: null, type: null, status: 'all').first;
    expect(res.single.pokemon.name, 'Bulbasaur');
  });

  test('status missing inclui quem não tem entrada', () async {
    final res = await db.watchFiltered(query: '', generation: null, type: null, status: 'missing').first;
    expect(res.length, 2);
  });
}
```

- [ ] **Step 2: Correr (deve falhar se a API divergir; ajustar)**

Run: `flutter test test/filter_query_test.dart`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add test/filter_query_test.dart
git commit -m "test: filtros e pesquisa no Drift"
```

---

## Task 12: Teste de progresso

**Files:**
- Test: `test/progress_test.dart`

- [ ] **Step 1: Escrever o teste**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/progress.dart';

void main() {
  test('percent e missing calculados', () {
    const p = ProgressStats(total: 151, caught: 30);
    expect(p.missing, 121);
    expect((p.percent * 100).round(), 20);
  });
  test('total zero não rebenta', () {
    const p = ProgressStats(total: 0, caught: 0);
    expect(p.percent, 0);
  });
}
```

- [ ] **Step 2: Correr**

Run: `flutter test test/progress_test.dart`
Expected: PASS.

- [ ] **Step 3: Commit**

```bash
git add test/progress_test.dart
git commit -m "test: cálculo de progresso"
```

---

## Task 13: Widgets — cartão, chip de tipo

**Files:**
- Create: `lib/presentation/widgets/type_chip.dart`, `pokemon_card.dart`
- Test: `test/pokemon_card_test.dart`

- [ ] **Step 1: `type_chip.dart`**

```dart
import 'package:flutter/material.dart';
import '../../domain/entities/pokemon.dart';
import '../../core/theme/type_colors.dart';

class TypeChip extends StatelessWidget {
  final PokemonType type;
  const TypeChip(this.type, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: typeColors[type], borderRadius: BorderRadius.circular(12)),
        child: Text(type.name, style: const TextStyle(color: Colors.white, fontSize: 11)),
      );
}
```

- [ ] **Step 2: `pokemon_card.dart`** (silhueta vs cor, badge shiny, placeholder)

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/utils/sprites.dart';
import '../../domain/entities/pokemon.dart';
import 'type_chip.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final bool caught;
  final bool shiny;
  final VoidCallback onTap;
  const PokemonCard({
    super.key, required this.pokemon, required this.caught,
    required this.shiny, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = CachedNetworkImage(
      imageUrl: Sprites.artwork(pokemon.id, shiny: shiny),
      placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) => const Icon(Icons.catching_pokemon, size: 48),
      // Não apanhado = silhueta apagada.
      color: caught ? null : Colors.black,
      colorBlendMode: caught ? BlendMode.dst : BlendMode.srcIn,
      fit: BoxFit.contain,
    );
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: Column(children: [
              Text('#${pokemon.id}', style: const TextStyle(fontSize: 11)),
              Expanded(child: Opacity(opacity: caught ? 1 : 0.55, child: image)),
              Text(pokemon.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              Wrap(spacing: 4, children: pokemon.types.map((t) => TypeChip(t)).toList()),
            ]),
          ),
          if (shiny)
            const Positioned(top: 4, right: 4, child: Icon(Icons.star, color: Colors.amber, size: 18)),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 3: Teste de widget**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/pokemon.dart';
import 'package:pokedex/presentation/widgets/pokemon_card.dart';

const _bulba = Pokemon(id: 1, name: 'Bulbasaur', nameEn: 'Bulbasaur',
    type1: PokemonType.grass, type2: PokemonType.poison, generation: 1,
    hp: 45, attack: 49, defense: 49, spAttack: 65, spDefense: 65, speed: 45, description: '');

void main() {
  testWidgets('mostra badge shiny quando shiny=true', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PokemonCard(pokemon: _bulba, caught: true, shiny: true, onTap: () {})),
    ));
    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
  });

  testWidgets('sem badge shiny quando shiny=false', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: PokemonCard(pokemon: _bulba, caught: false, shiny: false, onTap: () {})),
    ));
    expect(find.byIcon(Icons.star), findsNothing);
  });
}
```

- [ ] **Step 4: Correr**

Run: `flutter test test/pokemon_card_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets test/pokemon_card_test.dart
git commit -m "feat: cartão de Pokémon (silhueta/cor, shiny, placeholder) + teste"
```

---

## Task 14: Ecrã Pokédex (grelha + pesquisa + filtros)

**Files:**
- Create: `lib/presentation/widgets/filter_sheet.dart`, `lib/presentation/screens/pokedex_screen.dart`

- [ ] **Step 1: `filter_sheet.dart`** — bottom sheet que edita o `filterProvider`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokedex_filter.dart';
import '../providers/app_providers.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final f = ref.watch(filterProvider);
    final notifier = ref.read(filterProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Estado'),
        Wrap(spacing: 8, children: StatusFilter.values.map((s) => ChoiceChip(
          label: Text(s.name), selected: f.status == s,
          onSelected: (_) => notifier.state = f.copyWith(status: s),
        )).toList()),
        const SizedBox(height: 12),
        const Text('Geração'),
        Wrap(spacing: 8, children: List.generate(9, (i) => i + 1).map((g) => ChoiceChip(
          label: Text('$g'), selected: f.generation == g,
          onSelected: (sel) => notifier.state =
              sel ? f.copyWith(generation: g) : f.copyWith(clearGeneration: true),
        )).toList()),
        const SizedBox(height: 12),
        const Text('Tipo'),
        Wrap(spacing: 6, children: PokemonType.values.map((t) => ChoiceChip(
          label: Text(t.name), selected: f.type == t,
          onSelected: (sel) => notifier.state =
              sel ? f.copyWith(type: t) : f.copyWith(clearType: true),
        )).toList()),
      ]),
    );
  }
}
```

- [ ] **Step 2: `pokedex_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/filter_sheet.dart';

class PokedexScreen extends ConsumerWidget {
  const PokedexScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(pokedexListProvider);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Expanded(child: TextField(
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Pesquisar'),
            onChanged: (v) => ref.read(filterProvider.notifier).state =
                ref.read(filterProvider).copyWith(query: v),
          )),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => showModalBottomSheet(
                context: context, showDragHandle: true, builder: (_) => const FilterSheet()),
          ),
        ]),
      ),
      Expanded(child: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (items) => GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.72),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final it = items[i];
            return PokemonCard(
              pokemon: it.pokemon, caught: it.caught, shiny: it.shiny,
              onTap: () => context.push('/pokemon/${it.pokemon.id}'),
            );
          },
        ),
      )),
    ]);
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/pokedex_screen.dart lib/presentation/widgets/filter_sheet.dart
git commit -m "feat: ecrã Pokédex com grelha, pesquisa e filtros"
```

---

## Task 15: Ecrã de detalhe + edição de coleção

**Files:**
- Create: `lib/presentation/screens/detail_screen.dart`

- [ ] **Step 1: Implementar**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/sprites.dart';
import '../../domain/entities/user_entry.dart';
import '../providers/app_providers.dart';
import '../widgets/type_chip.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final int id;
  const DetailScreen({super.key, required this.id});
  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  bool showShiny = false;

  @override
  Widget build(BuildContext context) {
    final pokeFuture = ref.watch(pokemonRepositoryProvider).byId(widget.id);
    final entryAsync = ref.watch(entryProvider(widget.id));
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(showShiny ? Icons.star : Icons.star_border, color: Colors.amber),
          onPressed: () => setState(() => showShiny = !showShiny),
        ),
      ]),
      body: FutureBuilder(
        future: pokeFuture,
        builder: (context, snap) {
          final p = snap.data;
          if (p == null) return const Center(child: CircularProgressIndicator());
          return entryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Erro: $e')),
            data: (entry) {
              final repo = ref.read(collectionRepositoryProvider);
              void save(UserEntry e) => repo.save(e.copyWith(updatedAt: DateTime.now()));
              return ListView(padding: const EdgeInsets.all(16), children: [
                CachedNetworkImage(
                    imageUrl: Sprites.artwork(p.id, shiny: showShiny), height: 200),
                Text('#${p.id}  ${p.name}', style: Theme.of(context).textTheme.headlineSmall),
                Wrap(spacing: 6, children: p.types.map((t) => TypeChip(t)).toList()),
                const SizedBox(height: 12),
                Text(p.description),
                const Divider(),
                Text('Stats base', style: Theme.of(context).textTheme.titleMedium),
                _stat('HP', p.hp), _stat('Ataque', p.attack), _stat('Defesa', p.defense),
                _stat('At. Esp.', p.spAttack), _stat('Def. Esp.', p.spDefense), _stat('Velocidade', p.speed),
                const Divider(),
                SwitchListTile(
                  title: const Text('Tenho'),
                  value: entry.caught,
                  onChanged: (v) => save(entry.copyWith(caught: v)),
                ),
                SwitchListTile(
                  title: const Text('Shiny'),
                  value: entry.shiny,
                  onChanged: (v) => save(entry.copyWith(shiny: v)),
                ),
                Row(children: [
                  const Text('Quantidade'),
                  const Spacer(),
                  IconButton(onPressed: entry.quantity > 0
                      ? () => save(entry.copyWith(quantity: entry.quantity - 1)) : null,
                      icon: const Icon(Icons.remove)),
                  Text('${entry.quantity}'),
                  IconButton(onPressed: () => save(entry.copyWith(quantity: entry.quantity + 1)),
                      icon: const Icon(Icons.add)),
                ]),
                TextFormField(
                  initialValue: entry.notes,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 3,
                  onFieldSubmitted: (v) => save(entry.copyWith(notes: v)),
                  // ⭐ PREMIUM: limite de notas / notas longas poderá ser bloqueado no futuro.
                ),
              ]);
            },
          );
        },
      ),
    );
  }

  Widget _stat(String label, int value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(children: [
          SizedBox(width: 90, child: Text(label)),
          Expanded(child: LinearProgressIndicator(value: value / 255)),
          SizedBox(width: 36, child: Text(' $value', textAlign: TextAlign.right)),
        ]),
      );
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/detail_screen.dart
git commit -m "feat: ecrã de detalhe com stats e edição de coleção"
```

---

## Task 16: Ecrã de progresso

**Files:**
- Create: `lib/presentation/screens/progress_screen.dart`

- [ ] **Step 1: Implementar**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final global = ref.watch(globalProgressProvider);
    final byGen = ref.watch(progressByGenProvider);
    return ListView(padding: const EdgeInsets.all(16), children: [
      global.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text('Erro: $e'),
        data: (p) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Progresso global', style: Theme.of(context).textTheme.titleLarge),
          Text('${p.caught} / ${p.total}  (${(p.percent * 100).toStringAsFixed(1)}%)'),
          const SizedBox(height: 4),
          LinearProgressIndicator(value: p.percent, minHeight: 10),
          Text('Em falta: ${p.missing}'),
        ]),
      ),
      const Divider(height: 32),
      byGen.when(
        loading: () => const SizedBox.shrink(),
        error: (e, _) => Text('Erro: $e'),
        data: (map) => Column(children: (map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)))
            .map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Geração ${e.key} — ${e.value.caught}/${e.value.total}'),
                    LinearProgressIndicator(value: e.value.percent),
                  ]),
                ))
            .toList()),
      ),
    ]);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/progress_screen.dart
git commit -m "feat: ecrã de progresso global e por geração"
```

---

## Task 17: Ecrã "Em falta"

**Files:**
- Create: `lib/presentation/screens/missing_screen.dart`

- [ ] **Step 1: Implementar**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/sprites.dart';
import '../providers/app_providers.dart';

class MissingScreen extends ConsumerWidget {
  const MissingScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missing = ref.watch(missingListProvider);
    return missing.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Erro: $e')),
      data: (items) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) {
          final p = items[i].pokemon;
          return ListTile(
            leading: CachedNetworkImage(imageUrl: Sprites.artwork(p.id), width: 40, height: 40),
            title: Text(p.name),
            subtitle: Text('#${p.id} • Gen ${p.generation}'),
            onTap: () => context.push('/pokemon/${p.id}'),
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/missing_screen.dart
git commit -m "feat: ecrã de Pokémon em falta"
```

---

## Task 18: Ecrã de definições (idioma + tema)

**Files:**
- Create: `lib/presentation/screens/settings_screen.dart`

- [ ] **Step 1: Implementar**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return ListView(children: [
      ListTile(title: const Text('Tema'), subtitle: Text(['Sistema', 'Claro', 'Escuro'][theme])),
      Wrap(spacing: 8, children: List.generate(3, (i) => ChoiceChip(
        label: Text(['Sistema', 'Claro', 'Escuro'][i]),
        selected: theme == i,
        onSelected: (_) => ref.read(themeModeProvider.notifier).state = i,
      ))),
      const Divider(),
      ListTile(title: const Text('Idioma'), subtitle: Text(locale ?? 'Sistema')),
      Wrap(spacing: 8, children: [
        ChoiceChip(label: const Text('Sistema'), selected: locale == null,
            onSelected: (_) => ref.read(localeProvider.notifier).state = null),
        ChoiceChip(label: const Text('Português'), selected: locale == 'pt',
            onSelected: (_) => ref.read(localeProvider.notifier).state = 'pt'),
        ChoiceChip(label: const Text('English'), selected: locale == 'en',
            onSelected: (_) => ref.read(localeProvider.notifier).state = 'en'),
      ]),
      const Divider(),
      // ⭐ PREMIUM: secção de subscrição (preparada para Etapa 3 — sem pagamentos agora).
      const ListTile(
        leading: Icon(Icons.workspace_premium),
        title: Text('Premium'),
        subtitle: Text('Em breve'),
        enabled: false,
      ),
      // Sincronização na nuvem: ativada na Etapa 2 (Firebase).
    ]);
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/settings_screen.dart
git commit -m "feat: ecrã de definições (tema, idioma, placeholders premium/sync)"
```

---

## Task 19: Router, shell de navegação e bootstrap

**Files:**
- Create: `lib/core/router/app_router.dart`, `lib/app.dart`, `lib/main.dart`

- [ ] **Step 1: `app_router.dart`** — bottom nav com 4 abas + rota de detalhe

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/pokedex_screen.dart';
import '../../presentation/screens/progress_screen.dart';
import '../../presentation/screens/missing_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/detail_screen.dart';

final _tabs = const [PokedexScreen(), ProgressScreen(), MissingScreen(), SettingsScreen()];

class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int index = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Pokédex')),
        body: _tabs[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => setState(() => index = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.catching_pokemon), label: 'Pokédex'),
            NavigationDestination(icon: Icon(Icons.donut_large), label: 'Progresso'),
            NavigationDestination(icon: Icon(Icons.search_off), label: 'Em falta'),
            NavigationDestination(icon: Icon(Icons.settings), label: 'Definições'),
          ],
        ),
      );
}

final appRouter = GoRouter(routes: [
  GoRoute(path: '/', builder: (_, __) => const _Shell()),
  GoRoute(path: '/pokemon/:id', builder: (_, s) =>
      DetailScreen(id: int.parse(s.pathParameters['id']!))),
]);
```

- [ ] **Step 2: `app.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/app_providers.dart';

class PokedexApp extends ConsumerWidget {
  const PokedexApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIdx = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: [ThemeMode.system, ThemeMode.light, ThemeMode.dark][themeIdx],
      locale: locale == null ? null : Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 3: `main.dart`** — hidrata o dataset antes de arrancar a UI

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'data/seed/dataset_loader.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  await DatasetLoader(container.read(databaseProvider)).ensureSeeded();
  runApp(UncontrolledProviderScope(container: container, child: const PokedexApp()));
}
```

- [ ] **Step 4: Verificar análise estática**

Run: `flutter analyze`
Expected: "No issues found!" (corrigir importações/typos que apareçam).

- [ ] **Step 5: Correr todos os testes**

Run: `flutter test`
Expected: todos PASS.

- [ ] **Step 6: Verificação manual no browser**

Run: `flutter run -d chrome`
Expected: abre a Pokédex; grelha carrega ~1025 com silhuetas; pesquisa, filtros, detalhe (marcar "Tenho"/"Shiny" muda o cartão), progresso e "em falta" funcionam. **Utilizador tira capturas.**

- [ ] **Step 7: Commit**

```bash
git add lib/main.dart lib/app.dart lib/core/router/app_router.dart
git commit -m "feat: router, shell de navegação e bootstrap com hidratação do dataset"
```

---

## Self-Review (cobertura vs spec)

- §3 estrutura de pastas → Tasks 4–19 ✓
- §4 dataset incluído + hidratação → Tasks 2,3,6 ✓ (verificador de versão remoto fica para Etapa 2/3, pois depende do Firebase Hosting)
- §4.4 filtros/pesquisa em SQL no Drift → Task 5 + Task 11 ✓
- §7 ecrãs (Pokédex, detalhe, progresso, em falta, definições) → Tasks 14–18 ✓
- §9 i18n + tema → Tasks 9,10 ✓
- UI silhueta/cor + badge shiny + placeholder → Task 13 ✓
- §8 marcação premium (`// ⭐ PREMIUM:`) → Tasks 15,18 ✓
- §10 testes (filtros, progresso, widget) → Tasks 11,12,13 ✓
- **Fora da Etapa 1 (intencional):** Firebase/Auth/sync/conflitos (§5), regras (§6.1), privacidade/eliminação/Data Safety (§6.2-6.4) → **Etapa 2**; ícone/splash/.aab (§11), gates premium reais → **Etapa 3**.

---

## Roteiro das próximas etapas (planos próprios quando lá chegarmos)

**Etapa 2 — Nuvem e conformidade:**
1. Configurar Firebase (projeto do utilizador, `flutterfire configure`, `google-services.json`).
2. Anonymous Auth no arranque; `AuthRepository` com Google/email + `linkWithCredential`.
3. `SyncService`: push de `dirty`→Firestore, pull→Drift, conflitos por `serverUpdatedAt`.
4. `firestore.rules` por utilizador + testes de regras (emulador Firebase).
5. Eliminação de conta (reautenticação → `recursiveDelete`/WriteBatch → `user.delete()` → limpar Drift).
6. Verificador de versão do dataset contra Firebase Hosting.
7. Páginas web legais (privacidade + pedido de eliminação) e mapa de Data Safety.

**Etapa 3 — Monetização e publicação:**
1. `PremiumGate` + `entitlementProvider` (tudo desbloqueado) ligados aos pontos `// ⭐ PREMIUM:`.
2. `flutter_launcher_icons` + `flutter_native_splash` (ícone, nome, splash).
3. Assinatura: keystore + `key.properties` + `build.gradle` release.
4. `flutter build appbundle` → `.aab` + instruções de publicação na Play Store.
