import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing.dart';
import '../../domain/entities/market_tier.dart';

/// Um utilizador bloqueado (com nome/avatar desnormalizados).
typedef BlockedUser = ({String uid, String name, String avatar});

class SlotLimitException implements Exception {
  final int limit;
  SlotLimitException(this.limit);
  @override
  String toString() => 'SlotLimitException(limit: $limit)';
}

/// Acesso ao marketplace público (`listings/`) e à moderação (reports/blocks).
class MarketService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _db.collection('listings');

  List<Listing> _map(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map((d) => Listing.fromMap(d.id, d.data())).toList();

  Stream<List<Listing>> watchForCard(String cardId) => _listings
      .where('status', isEqualTo: 'active')
      .where('cardId', isEqualTo: cardId)
      .snapshots()
      .map(_map);

  /// Anúncios ativos de qualquer carta da lista (para notificações de wishlist).
  /// Limitado a 30 cartas (limite do `whereIn` do Firestore).
  Stream<List<Listing>> watchListingsForCards(List<String> cardIds) {
    if (cardIds.isEmpty) return Stream.value(const []);
    return _listings
        .where('status', isEqualTo: 'active')
        .where('cardId', whereIn: cardIds.take(30).toList())
        .snapshots()
        .map(_map);
  }

  /// Como [watchListingsForCards] mas SEM o limite de 30 — faz a busca em
  /// lotes de 30 (limite do `whereIn`) e junta. Usado nas trocas perfeitas.
  Future<List<Listing>> fetchListingsForCards(List<String> cardIds) async {
    final ids = cardIds.toSet().toList(); // sem repetidos
    if (ids.isEmpty) return const [];
    final out = <Listing>[];
    for (var i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, (i + 30 > ids.length) ? ids.length : i + 30);
      final snap = await _listings
          .where('status', isEqualTo: 'active')
          .where('cardId', whereIn: chunk)
          .get();
      out.addAll(_map(snap));
    }
    return out;
  }

  Stream<List<Listing>> watchMine(String uid) => _listings
      .where('ownerUid', isEqualTo: uid)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map(_map);

  Stream<Set<String>> watchBlocked(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('blocks')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());

  /// Utilizadores bloqueados (com nome/avatar) — para o ecrã de bloqueados.
  Stream<List<BlockedUser>> watchBlockedUsers(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('blocks')
      .snapshots()
      .map((s) => s.docs
          .map((d) => (
                uid: d.id,
                name: (d.data()['name'] ?? '') as String,
                avatar: (d.data()['avatar'] ?? '') as String,
              ))
          .toList());

  Future<void> publish({
    required List<CardRef> cards,
    required String ownerUid,
    required String ownerName,
    required String ownerAvatar,
    required int tier,
    required int activeCount,
    required TradeMode mode,
    required CardCondition condition,
    String? wantText,
    String? note,
    List<CardRef> wantCards = const [],
  }) async {
    if (!MarketTier.canPublish(
        activeCount: activeCount, tier: tier, selectedCount: cards.length)) {
      throw SlotLimitException(MarketTier.slotsFor(tier));
    }
    final wanted = wantCards.map((c) => c.toMap()).toList();
    final batch = _db.batch();
    for (final c in cards) {
      final doc = _listings.doc();
      batch.set(doc, {
        'ownerUid': ownerUid,
        'ownerName': ownerName,
        'ownerAvatar': ownerAvatar,
        'cardId': c.cardId,
        'cardName': c.cardName,
        'cardImage': c.cardImage,
        'setId': c.setId,
        'mode': mode.id,
        'condition': condition.id,
        if (wantText != null && wantText.isNotEmpty) 'wantText': wantText,
        if (note != null && note.isNotEmpty) 'note': note,
        if (wanted.isNotEmpty) 'wantCards': wanted,
        if (tier > 0) 'ownerTier': tier,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    batch.set(
      _db.collection('users').doc(ownerUid),
      {'activeListings': FieldValue.increment(cards.length)},
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  /// Edita os campos de um anúncio existente. Atualiza sempre os 4 campos
  /// (vazio = guarda ''), por isso é possível apagar a nota / o que quero.
  Future<void> editListing({
    required String id,
    required TradeMode mode,
    required CardCondition condition,
    String? wantText,
    String? note,
    List<CardRef> wantCards = const [],
    int ownerTier = 0,
  }) =>
      _listings.doc(id).update({
        'mode': mode.id,
        'condition': condition.id,
        'wantText': wantText?.trim() ?? '',
        'note': note?.trim() ?? '',
        'wantCards': wantCards.map((c) => c.toMap()).toList(),
        'ownerTier': ownerTier,
      });

  Future<void> deleteListing(String id, String ownerUid) async {
    final batch = _db.batch();
    batch.delete(_listings.doc(id));
    batch.set(
      _db.collection('users').doc(ownerUid),
      {'activeListings': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> report({
    required String listingId,
    required String reporterUid,
    required String reportedUid,
    required String reportedName,
    required String reason,
  }) =>
      _db.collection('reports').add({
        'listingId': listingId,
        'reporterUid': reporterUid,
        'reportedUid': reportedUid,
        'reportedName': reportedName,
        'reason': reason,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> block(String uid, String blockedUid,
          {String name = '', String avatar = ''}) =>
      _db.collection('users').doc(uid).collection('blocks').doc(blockedUid).set({
        'name': name,
        'avatar': avatar,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> unblock(String uid, String blockedUid) => _db
      .collection('users')
      .doc(uid)
      .collection('blocks')
      .doc(blockedUid)
      .delete();

  Future<void> setTier(String uid, int tier) => _db
      .collection('users')
      .doc(uid)
      .set({'marketTier': tier}, SetOptions(merge: true));
}
