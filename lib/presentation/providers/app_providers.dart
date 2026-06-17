import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../../domain/entities/pokedex_filter.dart';
import '../../domain/entities/pokemon.dart';
import '../../domain/entities/progress.dart';
import '../../domain/entities/user_entry.dart';

/// Base de dados (instância única para toda a app).
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final pokemonRepositoryProvider =
    Provider((ref) => PokemonRepository(ref.watch(databaseProvider)));

final collectionRepositoryProvider =
    Provider((ref) => CollectionRepository(ref.watch(databaseProvider)));

/// Estado dos filtros da grelha principal.
final filterProvider = StateProvider<PokedexFilter>((_) => const PokedexFilter());

/// Lista filtrada da Pokédex (reativa ao filtro e à coleção).
final pokedexListProvider = StreamProvider<List<PokedexItem>>((ref) {
  final filter = ref.watch(filterProvider);
  return ref.watch(pokemonRepositoryProvider).watchFiltered(filter);
});

/// Lista dedicada de "em falta" (independente do filtro principal).
final missingListProvider = StreamProvider<List<PokedexItem>>((ref) {
  return ref
      .watch(pokemonRepositoryProvider)
      .watchFiltered(const PokedexFilter(status: StatusFilter.missing));
});

/// Um Pokémon do catálogo por id (cacheado por família).
final pokemonByIdProvider = FutureProvider.family<Pokemon?, int>((ref, id) {
  return ref.watch(pokemonRepositoryProvider).byId(id);
});

/// Registo de coleção de um Pokémon (reativo).
final entryProvider = StreamProvider.family<UserEntry, int>((ref, id) {
  return ref.watch(collectionRepositoryProvider).watchEntry(id);
});

/// Progresso global. Recalcula quando a coleção muda (depende de pokedexList).
final globalProgressProvider = FutureProvider<ProgressStats>((ref) {
  ref.watch(pokedexListProvider);
  return ref.watch(collectionRepositoryProvider).globalProgress();
});

/// Progresso por geração.
final progressByGenProvider = FutureProvider<Map<int, ProgressStats>>((ref) {
  ref.watch(pokedexListProvider);
  return ref.watch(collectionRepositoryProvider).progressByGeneration();
});

/// Preferências de UI (Etapa 1: em memória). 0=sistema, 1=claro, 2=escuro.
final themeModeProvider = StateProvider<int>((_) => 0);

/// Idioma: null = seguir o sistema; 'pt' ou 'en' para forçar.
final localeProvider = StateProvider<String?>((_) => null);
