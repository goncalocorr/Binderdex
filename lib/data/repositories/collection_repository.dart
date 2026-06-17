import 'package:drift/drift.dart';

import '../../domain/entities/progress.dart';
import '../../domain/entities/user_entry.dart';
import '../local/database.dart';

/// Acesso de leitura/escrita à coleção do utilizador (Drift).
class CollectionRepository {
  final AppDatabase db;
  CollectionRepository(this.db);

  /// Observa o registo de um Pokémon. Se não existir, devolve um registo vazio
  /// (com updatedAt na época 0) para a UI poder editar sem casos especiais.
  Stream<UserEntry> watchEntry(int pokemonId) =>
      db.watchEntry(pokemonId).map((e) => e == null
          ? UserEntry(
              pokemonId: pokemonId,
              updatedAt: DateTime.fromMillisecondsSinceEpoch(0))
          : UserEntry(
              pokemonId: e.pokemonId,
              caught: e.caught,
              shiny: e.shiny,
              quantity: e.quantity,
              notes: e.notes,
              updatedAt: e.updatedAt,
            ));

  Future<void> save(UserEntry entry) async {
    await db.upsertEntry(UserEntriesCompanion.insert(
      pokemonId: Value(entry.pokemonId),
      caught: Value(entry.caught),
      shiny: Value(entry.shiny),
      quantity: Value(entry.quantity),
      notes: Value(entry.notes),
      updatedAt: DateTime.now(), // Etapa 2: substituído por server timestamp no sync
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
    return {
      for (final g in gens)
        g.generation: ProgressStats(total: g.total, caught: g.caught)
    };
  }
}
