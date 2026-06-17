import '../../domain/entities/pokedex_filter.dart';
import '../../domain/entities/pokemon.dart';
import '../local/database.dart';

/// Item da grelha: o Pokémon e o seu estado de coleção resumido.
typedef PokedexItem = ({Pokemon pokemon, bool caught, bool shiny});

Pokemon _toEntity(PokemonTableData p) => Pokemon(
      id: p.id,
      name: p.name,
      nameEn: p.nameEn,
      type1: PokemonType.fromApi(p.type1),
      type2: p.type2 == null ? null : PokemonType.fromApi(p.type2!),
      generation: p.generation,
      hp: p.hp,
      attack: p.attack,
      defense: p.defense,
      spAttack: p.spAttack,
      spDefense: p.spDefense,
      speed: p.speed,
      description: p.description,
    );

/// Acesso de leitura ao catálogo (sempre a partir do Drift local).
class PokemonRepository {
  final AppDatabase db;
  PokemonRepository(this.db);

  Stream<List<PokedexItem>> watchFiltered(PokedexFilter f) {
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
