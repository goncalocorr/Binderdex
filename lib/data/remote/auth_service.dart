import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Autenticação (Etapa 2). Envolve o Firebase Auth + Google Sign-In.
///
/// Fluxo local-first: a app funciona sem conta; iniciar sessão é opt-in e
/// serve para sincronizar entre dispositivos. Suporta Google e email/password,
/// e o "upgrade" de uma sessão anónima via `link*` sem perder dados.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Sessão anónima (convidado com backup, sem dar email).
  Future<UserCredential> signInAnonymously() => _auth.signInAnonymously();

  // --- Google ---

  /// Credencial Google (web: popup; nativo: google_sign_in 7.x).
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return _auth.signInWithPopup(GoogleAuthProvider());
    }
    final credential = await _googleCredential();
    return _auth.signInWithCredential(credential);
  }

  Future<AuthCredential> _googleCredential() async {
    await GoogleSignIn.instance.initialize();
    final account = await GoogleSignIn.instance.authenticate();
    final idToken = account.authentication.idToken;
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  // --- Email / password ---

  Future<UserCredential> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password);

  Future<UserCredential> registerWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);

  // --- Upgrade de conta anónima (mantém os dados) ---

  Future<UserCredential> linkGoogle() async {
    final user = _auth.currentUser!;
    if (kIsWeb) return user.linkWithPopup(GoogleAuthProvider());
    return user.linkWithCredential(await _googleCredential());
  }

  Future<UserCredential> linkEmail(String email, String password) {
    final cred =
        EmailAuthProvider.credential(email: email.trim(), password: password);
    return _auth.currentUser!.linkWithCredential(cred);
  }

  // --- Sessão ---

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {/* pode não estar inicializado */}
    }
    await _auth.signOut();
  }

  /// Elimina a conta. Pode lançar `requires-recent-login` (tratado na Etapa 2b).
  Future<void> deleteAccount() => _auth.currentUser!.delete();
}
