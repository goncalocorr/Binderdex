import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/links.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Início de sessão (Etapa 2): Google + email/password, com modo entrar/criar.
/// A app continua local-first — isto serve para sincronizar entre dispositivos.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _obscure = true;
  late final TapGestureRecognizer _privacyTap =
      TapGestureRecognizer()..onTap = () => _open(kPrivacyPolicyUrl);
  late final TapGestureRecognizer _termsTap =
      TapGestureRecognizer()..onTap = () => _open(kTermsUrl);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _privacyTap.dispose();
    _termsTap.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      // Entrou com conta: sai do modo convidado e passa o gate. O popup do
      // nome é mostrado pela app já montada (ensureDisplayName no shell).
      ref.read(guestModeProvider.notifier).state = false;
      context.go('/');
    } on FirebaseAuthException catch (e) {
      _error(e.message);
    } catch (_) {
      _error(null);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _error(String? message) {
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message ?? t.authFailed)));
  }

  /// Convidado: entra em modo só-leitura. Faz login anónimo no Firebase para
  /// poder LER a Comunidade (regras exigem `request.auth != null`); se falhar
  /// (ex.: sem rede), mantém o comportamento de convidado offline.
  Future<void> _enterAsGuest() async {
    setState(() => _busy = true);
    try {
      await ref.read(authServiceProvider).signInAnonymously();
    } catch (_) {
      // Sem rede ou anónimo desativado — segue em modo convidado offline.
    }
    if (!mounted) return;
    ref.read(guestModeProvider.notifier).state = true;
    context.go('/');
  }

  Future<void> _emailAuth() async {
    final email = _email.text.trim();
    final pass = _password.text;
    // Valida campos vazios para não disparar um erro técnico do Firebase.
    if (email.isEmpty || pass.isEmpty) {
      _error(AppLocalizations.of(context)!.fillFields);
      return;
    }
    final auth = ref.read(authServiceProvider);
    await _run(() => _register
        ? auth.registerWithEmail(email, pass)
        : auth.signInWithEmail(email, pass));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _busy,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
            children: [
              Image.asset('assets/logo.png', width: 56, height: 56),
              const SizedBox(height: 14),
              Text(
                _register ? t.createAccount : t.loginTitle,
                style: TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.loginSubtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 22),

              _SocialButton(
                icon: SvgPicture.asset('assets/google_g.svg',
                    width: 20, height: 20),
                label: t.continueGoogle,
                onTap: () =>
                    _run(() => ref.read(authServiceProvider).signInWithGoogle()),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(child: Divider(color: cs.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t.orLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant)),
                  ),
                  Expanded(child: Divider(color: cs.outlineVariant)),
                ],
              ),
              const SizedBox(height: 18),

              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: t.emailLabel,
                  prefixIcon: const Icon(Icons.mail_outline),
                  hintText: 'you@example.com',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: t.passwordLabel,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  hintText: '••••••••',
                ),
              ),
              const SizedBox(height: 22),

              FilledButton(
                onPressed: _busy ? null : _emailAuth,
                style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52)),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5))
                    : Text(_register ? t.createAccount : t.logIn),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _register = !_register),
                  child: Text(_register ? t.switchToLogin : t.switchToRegister),
                ),
              ),
              Center(
                child: TextButton(
                  onPressed: _busy ? null : _enterAsGuest,
                  child: Text(t.guestEnter),
                ),
              ),
              const SizedBox(height: 8),
              // Consentimento: ao continuar, aceita a Política de Privacidade.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text.rich(
                  TextSpan(children: [
                    TextSpan(text: t.consentPrefix),
                    TextSpan(
                      text: t.termsOfUse,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _termsTap,
                    ),
                    TextSpan(text: t.consentAnd),
                    TextSpan(
                      text: t.privacyPolicy,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: _privacyTap,
                    ),
                    const TextSpan(text: '.'),
                  ]),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback onTap;
  const _SocialButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: icon,
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: cs.onSurface,
        side: BorderSide(color: cs.outlineVariant, width: 1.5),
        textStyle: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontWeight: FontWeight.w600,
            fontSize: 15),
      ),
    );
  }
}
