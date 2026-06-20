import 'package:drift/drift.dart';

import '../../domain/entities/progress.dart';
import '../../domain/entities/user_card_entry.dart';
import '../local/database.dart';

/// Leitura/escrita da coleção do utilizador (posse por variante).
class CollectionRepository {
  final AppDatabase db;
  CollectionRepository(this.db);

  /// Observa o registo de uma carta. Se não existir, devolve um registo vazio.
  Stream<UserCardEntry> watchEntry(String cardId) =>
      db.watchEntry(cardId).map((e) => e == null
          ? UserCardEntry(
              cardId: cardId,
              updatedAt: DateTime.fromMillisecondsSinceEpoch(0))
          : UserCardEntry(
              cardId: e.cardId,
              ownedNormal: e.ownedNormal,
              ownedHolo: e.ownedHolo,
              ownedReverse: e.ownedReverse,
              qtyNormal: e.qtyNormal,
              qtyHolo: e.qtyHolo,
              qtyReverse: e.qtyReverse,
              notes: e.notes,
              updatedAt: e.updatedAt,
            ));

  Future<void> save(UserCardEntry entry) async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: entry.cardId,
      ownedNormal: Value(entry.ownedNormal),
      ownedHolo: Value(entry.ownedHolo),
      ownedReverse: Value(entry.ownedReverse),
      qtyNormal: Value(entry.qtyNormal),
      qtyHolo: Value(entry.qtyHolo),
      qtyReverse: Value(entry.qtyReverse),
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

  Future<({int setsDone, int holos, int dupes})> counts() async => (
        setsDone: await db.setsDoneCount(),
        holos: await db.holoCount(),
        dupes: await db.duplicatesCount(),
      );

  Future<List<({String type, int owned})>> ownedByType() => db.ownedByType();
}
