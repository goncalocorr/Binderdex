import 'package:cloud_firestore/cloud_firestore.dart';

/// Perfil do utilizador na nuvem (nome + avatar), em `users/{uid}`.
/// Permite restaurar o perfil ao iniciar sessão noutro dispositivo / após sair.
class ProfileService {
  final FirebaseFirestore fs;
  ProfileService({FirebaseFirestore? firestore})
      : fs = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      fs.collection('users').doc(uid);

  /// Lê o perfil. Devolve null se não existir ou em caso de erro (ex.: offline).
  Future<({String name, String avatar})?> fetch(String uid) async {
    try {
      final snap = await _doc(uid).get();
      final data = snap.data();
      if (data == null) return null;
      return (
        name: (data['name'] as String?) ?? '',
        avatar: (data['avatar'] as String?) ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  /// Grava nome e/ou avatar (merge).
  Future<void> save(String uid, {String? name, String? avatar}) async {
    final m = <String, dynamic>{};
    if (name != null) m['name'] = name;
    if (avatar != null) m['avatar'] = avatar;
    if (m.isEmpty) return;
    await _doc(uid).set(m, SetOptions(merge: true));
  }

  /// Regista o token FCM deste dispositivo na conta (para push). Vários
  /// dispositivos → vários tokens, por isso é uma lista (arrayUnion).
  Future<void> addFcmToken(String uid, String token) async {
    if (token.isEmpty) return;
    await _doc(uid).set(
      {'fcmTokens': FieldValue.arrayUnion([token])},
      SetOptions(merge: true),
    );
  }

  /// Remove o token deste dispositivo (ex.: ao terminar sessão).
  Future<void> removeFcmToken(String uid, String token) async {
    if (token.isEmpty) return;
    try {
      await _doc(uid).set(
        {'fcmTokens': FieldValue.arrayRemove([token])},
        SetOptions(merge: true),
      );
    } catch (_) {
      // Sem rede / sem permissão — ignora.
    }
  }

  /// Espelha a wishlist (ids das cartas desejadas) em `users/{uid}.notifyCards`,
  /// que a Cloud Function `onNewListing` lê para enviar push quando uma dessas
  /// cartas é anunciada. Substitui o array inteiro (= wishlist atual).
  Future<void> setNotifyCards(String uid, Set<String> cardIds) async {
    try {
      await _doc(uid)
          .set({'notifyCards': cardIds.toList()}, SetOptions(merge: true));
    } catch (_) {
      // Sem rede / sem permissão — tenta de novo na próxima alteração.
    }
  }

  /// Estado de moderação do próprio utilizador: aviso pendente, se está banido,
  /// e se já apelou (só pode apelar 1x por ban).
  Stream<({String? warning, bool banned, bool appealed})> watchSelf(
          String uid) =>
      _doc(uid).snapshots().map((s) {
        final d = s.data() ?? const {};
        final w = d['warning'];
        return (
          warning: w is Map ? (w['text'] as String?) : null,
          banned: (d['banned'] as bool?) ?? false,
          appealed: (d['appealed'] as bool?) ?? false,
        );
      });

  /// Marca que o utilizador já apelou (não pode apelar de novo até novo ban).
  Future<void> markAppealed(String uid) =>
      _doc(uid).set({'appealed': true}, SetOptions(merge: true));

  /// Limpa o aviso depois de o utilizador o ver.
  Future<void> clearWarning(String uid) =>
      _doc(uid).set({'warning': FieldValue.delete()}, SetOptions(merge: true));

  Future<void> delete(String uid) => _doc(uid).delete();
}
