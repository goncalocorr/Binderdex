import 'pokemon.dart';

/// Estado de filtro por estado de coleção.
enum StatusFilter { all, caught, missing, shiny }

/// Conjunto imutável de filtros aplicados à grelha da Pokédex.
///
/// É traduzido diretamente para SQL no Drift (ver AppDatabase.watchFiltered),
/// para que a filtragem nunca aconteça em memória sobre os ~1025 Pokémon.
class PokedexFilter {
  final String query; // nome ou número
  final int? generation; // null = todas as gerações
  final PokemonType? type; // null = todos os tipos
  final StatusFilter status;

  const PokedexFilter({
    this.query = '',
    this.generation,
    this.type,
    this.status = StatusFilter.all,
  });

  PokedexFilter copyWith({
    String? query,
    int? generation,
    bool clearGeneration = false,
    PokemonType? type,
    bool clearType = false,
    StatusFilter? status,
  }) =>
      PokedexFilter(
        query: query ?? this.query,
        generation: clearGeneration ? null : (generation ?? this.generation),
        type: clearType ? null : (type ?? this.type),
        status: status ?? this.status,
      );
}
