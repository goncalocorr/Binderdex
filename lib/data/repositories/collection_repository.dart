import 'package:drift/drift.dart';

import '../../domain/entities/progress.dart';
import '../../domain/entities/tcg_card.dart';
import '../../domain/entities/user_card_entry.dart';
import '../local/database.dart';

/// Leitura/escrita da coleção do utilizador (por carta).
class CollectionRepository {
  final AppDatabase db;
  CollectionRepository(this.db);

  /// Observa o registo de uma carta. Se não existir, devolve um registo vazio
  /// (época 0) para a UI poder editar sem casos especiais.
  Stream<UserCardEntry> watchEntry(String cardId) =>
      db.watchEntry(cardId).map((e) => e == null
          ? UserCardEntry(
              cardId: cardId,
              updatedAt: DateTime.fromMillisecondsSinceEpoch(0))
          : UserCardEntry(
              cardId: e.cardId,
              owned: e.owned,
              quantity: e.quantity,
              variant: CardVariant.fromName(e.variant),
              notes: e.notes,
              updatedAt: e.updatedAt,
            ));

  Future<void> save(UserCardEntry entry) async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: entry.cardId,
      owned: Value(entry.owned),
      quantity: Value(entry.quantity),
      variant: Value(entry.variant.name),
      notes: Value(entry.notes),
      updatedAt: DateTime.now(), // Etapa 2: server timestamp no sync
      dirty: const Value(true),
    ));
  }

  Future<ProgressStats> globalProgress() async {
    final total = await db.totalCards();
    final owned = await db.totalOwned();
    return ProgressStats(total: total, owned: owned);
  }
}
