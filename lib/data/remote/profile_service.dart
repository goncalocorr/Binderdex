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

  Future<void> delete(String uid) => _doc(uid).delete();
}
