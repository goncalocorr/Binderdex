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

  /// Segue/deixa de seguir uma carta (sino). Guarda em `users/{uid}.notifyCards`
  /// para o servidor (Cloud Functions) saber a quem enviar push quando essa
  /// carta for posta à venda/troca.
  Future<void> setCardWatch(String uid, String cardId, bool on) async {
    if (cardId.isEmpty) return;
    try {
      await _doc(uid).set({
        'notifyCards': on
            ? FieldValue.arrayUnion([cardId])
            : FieldValue.arrayRemove([cardId]),
      }, SetOptions(merge: true));
    } catch (_) {
      // Sem rede / sem permissão — o estado local (prefs) fica na mesma.
    }
  }

  Future<void> delete(String uid) => _doc(uid).delete();
}
