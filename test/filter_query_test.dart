import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/local/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.bulkInsertPokemon([
      PokemonTableCompanion.insert(
        id: 1,
        name: 'Bulbasaur',
        nameEn: 'Bulbasaur',
        type1: 'grass',
        type2: const Value('poison'),
        generation: 1,
        hp: 45,
        attack: 49,
        defense: 49,
        spAttack: 65,
        spDefense: 65,
        speed: 45,
        description: '',
      ),
      PokemonTableCompanion.insert(
        id: 4,
        name: 'Charmander',
        nameEn: 'Charmander',
        type1: 'fire',
        generation: 1,
        hp: 39,
        attack: 52,
        defense: 43,
        spAttack: 60,
        spDefense: 50,
        speed: 65,
        description: '',
      ),
    ]);
  });

  tearDown(() => db.close());

  test('filtra por tipo via SQL', () async {
    final res = await db
        .watchFiltered(query: '', generation: null, type: 'fire', status: 'all')
        .first;
    expect(res.length, 1);
    expect(res.first.pokemon.id, 4);
  });

  test('pesquisa por número devolve o Pokémon certo', () async {
    final res = await db
        .watchFiltered(query: '1', generation: null, type: null, status: 'all')
        .first;
    expect(res.single.pokemon.name, 'Bulbasaur');
  });

  test('pesquisa por nome é case-insensitive', () async {
    final res = await db
        .watchFiltered(
            query: 'char', generation: null, type: null, status: 'all')
        .first;
    expect(res.single.pokemon.id, 4);
  });

  test('status "missing" inclui quem não tem registo', () async {
    final res = await db
        .watchFiltered(
            query: '', generation: null, type: null, status: 'missing')
        .first;
    expect(res.length, 2);
  });

  test('marcar como apanhado altera os filtros caught/missing', () async {
    await db.upsertEntry(UserEntriesCompanion.insert(
      pokemonId: 1,
      caught: const Value(true),
      updatedAt: DateTime.now(),
    ));

    final caught = await db
        .watchFiltered(
            query: '', generation: null, type: null, status: 'caught')
        .first;
    expect(caught.single.pokemon.id, 1);

    final missing = await db
        .watchFiltered(
            query: '', generation: null, type: null, status: 'missing')
        .first;
    expect(missing.single.pokemon.id, 4);
  });
}
