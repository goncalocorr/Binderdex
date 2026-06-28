import 'package:cloud_firestore/cloud_firestore.dart';

/// Email da conta de administração (vê denúncias/sugestões, avisa/bane).
/// Reforçado nas regras do Firestore — não basta o cliente.
const String kAdminEmail = 'hivecode.comercial@gmail.com';

/// Uma denúncia recebida (vista pelo admin).
typedef Report = ({
  String id,
  String listingId,
  String reporterUid,
  String reportedUid,
  String reportedName,
  String cardId,
  String reason,
  String status,
  String resolution,
  DateTime at,
});

/// Uma sugestão enviada por um utilizador premium (vista pelo admin).
typedef Suggestion = ({
  String id,
  String uid,
  String name,
  String text,
  DateTime at,
});

/// Um utilizador, na perspetiva do admin (banidos / premium).
typedef AdminUser = ({
  String uid,
  String name,
  String avatar,
  int tier,
  bool banned,
});

/// Um anúncio global (do admin para todos).
typedef Broadcast = ({String id, String title, String body, DateTime at});

DateTime _ts(dynamic v) =>
    v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);

/// Operações de moderação (admin) + envio de sugestões (premium).
class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Denúncias (admin) ---
  /// Todas as denúncias (abertas primeiro, depois resolvidas), mais recentes
  /// primeiro dentro de cada grupo. Sem `orderBy`/`where` → sem índice.
  Stream<List<Report>> watchReports() =>
      _db.collection('reports').snapshots().map((s) {
        final list = s.docs.map(_report).toList();
        list.sort((a, b) {
          final ao = a.status == 'open' ? 0 : 1;
          final bo = b.status == 'open' ? 0 : 1;
          return ao != bo ? ao - bo : b.at.compareTo(a.at);
        });
        return list;
      });

  /// Resolve uma denúncia — fica na lista marcada com a resolução
  /// (`warn` / `ban` / `delete` / `done`).
  Future<void> resolveReport(String id, String resolution) =>
      _db.collection('reports').doc(id).set({
        'status': 'resolved',
        'resolution': resolution,
        'resolvedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

  // --- Ações sobre um utilizador (admin) ---
  /// Deixa um aviso que o utilizador vê ao abrir a app (privado).
  Future<void> warnUser(String uid, String text) =>
      _db.collection('users').doc(uid).set({
        'warning': {'text': text.trim(), 'at': FieldValue.serverTimestamp()},
      }, SetOptions(merge: true));

  /// Bane/desbane o utilizador (bloqueia publicar/contactar nas regras). Ao
  /// banir, apaga também todos os anúncios dele.
  Future<void> banUser(String uid, bool banned) async {
    await _db
        .collection('users')
        .doc(uid)
        .set({'banned': banned}, SetOptions(merge: true));
    if (!banned) return;
    final snap =
        await _db.collection('listings').where('ownerUid', isEqualTo: uid).get();
    if (snap.docs.isEmpty) return;
    final batch = _db.batch(); // anúncios por user ≤ 500 (limite de slots)
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  /// Apaga um anúncio (moderação — regras permitem ao admin). Ignora id vazio
  /// (denúncias feitas a partir da conversa não têm anúncio).
  Future<void> deleteListing(String id) async {
    if (id.isEmpty) return;
    await _db.collection('listings').doc(id).delete();
  }

  /// Define o nível premium de uma conta (dar/tirar premium).
  Future<void> setUserTier(String uid, int tier) => _db
      .collection('users')
      .doc(uid)
      .set({'marketTier': tier}, SetOptions(merge: true));

  /// Utilizadores banidos (para a lista de gestão).
  Stream<List<AdminUser>> watchBannedUsers() => _db
      .collection('users')
      .where('banned', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(_user).toList());

  /// Utilizadores premium (marketTier >= 1).
  Stream<List<AdminUser>> watchPremiumUsers() => _db
      .collection('users')
      .where('marketTier', isGreaterThanOrEqualTo: 1)
      .snapshots()
      .map((s) => s.docs.map(_user).toList());

  /// Estado de um utilizador (para o ecrã de stats do admin).
  Stream<AdminUser> watchUser(String uid) =>
      _db.collection('users').doc(uid).snapshots().map((d) {
        final m = d.data() ?? const {};
        return (
          uid: uid,
          name: (m['name'] ?? '') as String,
          avatar: (m['avatar'] ?? '') as String,
          tier: (m['marketTier'] ?? 0) as int,
          banned: (m['banned'] ?? false) as bool,
        );
      });

  /// Todas as denúncias contra um utilizador (para os stats dele).
  Stream<List<Report>> watchReportsAgainst(String uid) => _db
      .collection('reports')
      .where('reportedUid', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map(_report).toList()
        ..sort((a, b) => b.at.compareTo(a.at)));

  /// Publica um anúncio global (todos os utilizadores veem nas notificações).
  Future<void> postBroadcast(String title, String body) =>
      _db.collection('broadcasts').add({
        'title': title.trim(),
        'body': body.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// Anúncios globais (qualquer utilizador lê), mais recentes primeiro.
  Stream<List<Broadcast>> watchBroadcasts() =>
      _db.collection('broadcasts').snapshots().map((s) => s.docs
          .map((d) => (
                id: d.id,
                title: (d.data()['title'] ?? '') as String,
                body: (d.data()['body'] ?? '') as String,
                at: _ts(d.data()['createdAt']),
              ))
          .toList()
        ..sort((a, b) => b.at.compareTo(a.at)));

  AdminUser _user(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return (
      uid: d.id,
      name: (m['name'] ?? '') as String,
      avatar: (m['avatar'] ?? '') as String,
      tier: (m['marketTier'] ?? 0) as int,
      banned: (m['banned'] ?? false) as bool,
    );
  }

  // --- Sugestões ---
  /// Sugestões (admin lê todas, mais recentes primeiro).
  Stream<List<Suggestion>> watchSuggestions() =>
      _db.collection('suggestions').snapshots().map((s) =>
          s.docs.map(_suggestion).toList()
            ..sort((a, b) => b.at.compareTo(a.at)));

  /// Envia uma sugestão (só premium — reforçado nas regras).
  Future<void> addSuggestion({
    required String uid,
    required String name,
    required String text,
  }) =>
      _db.collection('suggestions').add({
        'uid': uid,
        'name': name,
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

  Report _report(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return (
      id: d.id,
      listingId: (m['listingId'] ?? '') as String,
      reporterUid: (m['reporterUid'] ?? '') as String,
      reportedUid: (m['reportedUid'] ?? '') as String,
      reportedName: (m['reportedName'] ?? '') as String,
      cardId: (m['cardId'] ?? '') as String,
      reason: (m['reason'] ?? '') as String,
      status: (m['status'] ?? 'open') as String,
      resolution: (m['resolution'] ?? '') as String,
      at: _ts(m['createdAt']),
    );
  }

  Suggestion _suggestion(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final m = d.data();
    return (
      id: d.id,
      uid: (m['uid'] ?? '') as String,
      name: (m['name'] ?? '') as String,
      text: (m['text'] ?? '') as String,
      at: _ts(m['createdAt']),
    );
  }
}
