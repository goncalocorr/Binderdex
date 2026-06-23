import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../local/database.dart';

/// Sincronização da coleção entre o Drift (local) e o Cloud Firestore.
///
/// - **Offline-first:** todas as edições escrevem primeiro no Drift (`dirty`).
/// - **Push:** entradas `dirty` são enviadas com `serverTimestamp()`.
/// - **Pull:** um listener aplica documentos remotos mais recentes ao Drift.
/// - **Conflitos:** última escrita vence pelo **updatedAt do servidor**.
///
/// Estrutura remota: `users/{uid}/cards/{cardId}`.
class SyncService {
  final AppDatabase db;
  final FirebaseFirestore fs;
  SyncService(this.db, {FirebaseFirestore? firestore})
      : fs = firestore ?? FirebaseFirestore.instance;

  StreamSubscription? _remoteSub;
  StreamSubscription? _localSub;
  String? _uid;

  CollectionReference<Map<String, dynamic>> _cards(String uid) =>
      fs.collection('users').doc(uid).collection('cards');

  /// Começa a sincronizar para um utilizador. Idempotente.
  void start(String uid) {
    if (_uid == uid) return;
    stop();
    _uid = uid;
    final col = _cards(uid);

    // Remoto → local (inclui a carga inicial de todos os documentos).
    _remoteSub = col.snapshots().listen((snap) async {
      for (final change in snap.docChanges) {
        final doc = change.doc;
        // Ignora os ecos das nossas próprias escritas ainda por confirmar.
        if (doc.metadata.hasPendingWrites) continue;
        await _applyRemote(doc.id, doc.data());
      }
    });

    // Local (dirty) → remoto.
    _localSub = db.watchDirtyEntries().listen((rows) {
      for (final e in rows) {
        _push(col, e);
      }
    });
  }

  Future<void> _applyRemote(String cardId, Map<String, dynamic>? data) async {
    if (data == null) return;
    final ts = data['updatedAt'];
    if (ts is! Timestamp) return; // serverTimestamp ainda pendente
    final remoteUpdated = ts.toDate();

    final local = await db.entryOnce(cardId);
    // Local igual ou mais recente → mantém (last-write-wins).
    if (local != null && !local.updatedAt.isBefore(remoteUpdated)) return;

    await db.applyRemoteEntry(UserCardEntriesCompanion(
      cardId: Value(cardId),
      ownedNormal: Value(data['ownedNormal'] as bool? ?? false),
      ownedHolo: Value(data['ownedHolo'] as bool? ?? false),
      ownedReverse: Value(data['ownedReverse'] as bool? ?? false),
      qtyNormal: Value((data['qtyNormal'] as num?)?.toInt() ?? 0),
      qtyHolo: Value((data['qtyHolo'] as num?)?.toInt() ?? 0),
      qtyReverse: Value((data['qtyReverse'] as num?)?.toInt() ?? 0),
      notes: Value(data['notes'] as String? ?? ''),
      wishlisted: Value(data['wishlisted'] as bool? ?? false),
      updatedAt: Value(remoteUpdated),
      dirty: const Value(false),
    ));
  }

  void _push(
      CollectionReference<Map<String, dynamic>> col, UserCardEntryRow e) {
    // Não esperamos pela confirmação do servidor (offline-first): o SDK
    // persiste localmente e sincroniza quando houver rede.
    col.doc(e.cardId).set({
      'ownedNormal': e.ownedNormal,
      'ownedHolo': e.ownedHolo,
      'ownedReverse': e.ownedReverse,
      'qtyNormal': e.qtyNormal,
      'qtyHolo': e.qtyHolo,
      'qtyReverse': e.qtyReverse,
      'notes': e.notes,
      'wishlisted': e.wishlisted,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // Marca como enviada; o updatedAt do servidor chega pelo listener remoto.
    db.markPushed(e.cardId);
  }

  /// Apaga todos os dados remotos do utilizador (ao eliminar a conta).
  /// Sem `recursiveDelete` no SDK cliente — apaga em lotes.
  Future<void> deleteRemoteData(String uid) async {
    final col = _cards(uid);
    final snap = await col.get();
    final docs = snap.docs;
    for (var i = 0; i < docs.length; i += 400) {
      final batch = fs.batch();
      for (final d in docs.skip(i).take(400)) {
        batch.delete(d.reference);
      }
      await batch.commit();
    }
    // O documento-pai users/{uid} é virtual (sem campos) e não tem regra de
    // escrita própria — não há nada para apagar nele.
  }

  void stop() {
    _remoteSub?.cancel();
    _localSub?.cancel();
    _remoteSub = null;
    _localSub = null;
    _uid = null;
  }
}
