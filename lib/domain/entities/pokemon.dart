/// Tipos de Pokémon. Os nomes correspondem exatamente aos slugs da PokéAPI,
/// o que permite converter de/para a API sem mapeamentos extra.
enum PokemonType {
  normal,
  fire,
  water,
  electric,
  grass,
  ice,
  fighting,
  poison,
  ground,
  flying,
  psychic,
  bug,
  rock,
  ghost,
  dragon,
  dark,
  steel,
  fairy;

  /// Converte um slug da PokéAPI (ex.: "grass") no enum correspondente.
  static PokemonType fromApi(String s) =>
      PokemonType.values.firstWhere((t) => t.name == s);
}

/// Entidade imutável do catálogo (dados estáticos, vindos do dataset incluído).
class Pokemon {
  final int id; // número da Pokédex Nacional
  final String name; // nome a apresentar (PT se existir, senão EN)
  final String nameEn; // nome em inglês (usado também na pesquisa)
  final PokemonType type1;
  final PokemonType? type2;
  final int generation;
  final int hp, attack, defense, spAttack, spDefense, speed;
  final String description; // lore (PT se existir, senão EN)

  const Pokemon({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.type1,
    this.type2,
    required this.generation,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.spAttack,
    required this.spDefense,
    required this.speed,
    required this.description,
  });

  /// Lista de 1 ou 2 tipos (conveniente para construir os chips).
  List<PokemonType> get types => [type1, if (type2 != null) type2!];
}
