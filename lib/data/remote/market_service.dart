import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing.dart';
import '../../domain/entities/market_tier.dart';

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

  Stream<List<Listing>> watchRecent({int limit = 30}) => _listings
      .where('status', isEqualTo: 'active')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(_map);

  Stream<List<Listing>> watchForCard(String cardId) => _listings
      .where('status', isEqualTo: 'active')
      .where('cardId', isEqualTo: cardId)
      .snapshots()
      .map(_map);

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
  }) async {
    if (!MarketTier.canPublish(
        activeCount: activeCount, tier: tier, selectedCount: cards.length)) {
      throw SlotLimitException(MarketTier.slotsFor(tier));
    }
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

  Future<void> updateListing(Listing l) =>
      _listings.doc(l.id).update(l.toMap());

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
    required String reason,
  }) =>
      _db.collection('reports').add({
        'listingId': listingId,
        'reporterUid': reporterUid,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> block(String uid, String blockedUid) => _db
      .collection('users')
      .doc(uid)
      .collection('blocks')
      .doc(blockedUid)
      .set({'createdAt': FieldValue.serverTimestamp()});

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
