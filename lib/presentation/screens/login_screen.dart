import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      if (!mounted) return;
      // Entrou com conta: sai do modo convidado e passa o gate.
      ref.read(guestModeProvider.notifier).state = false;
      // 1ª vez (sem nome ainda): pede o nome antes de explorar a app.
      if (ref.read(displayNameProvider).trim().isEmpty) {
        await _askName();
      }
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      _error(e.message);
    } catch (_) {
      _error(null);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Popup (obrigatório passar) para escolher o nome de colecionador.
  Future<void> _askName() async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: ref.read(displayNameProvider).isNotEmpty
          ? ref.read(displayNameProvider)
          : (FirebaseAuth.instance.currentUser?.displayName ?? ''),
    );
    final name = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(t.askNameTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.askNameBody,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(hintText: t.guest),
              onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(t.continueLabel),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      ref.read(displayNameProvider.notifier).state = name;
      await ref.read(prefsProvider).setString('displayName', name);
    }
  }

  void _error(String? message) {
    if (!mounted) return;
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message ?? t.authFailed)));
  }

  Future<void> _emailAuth() {
    final auth = ref.read(authServiceProvider);
    final email = _email.text;
    final pass = _password.text;
    return _run(() => _register
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
                icon: Icons.g_mobiledata,
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
                  onPressed: () {
                    ref.read(guestModeProvider.notifier).state = true;
                    context.go('/');
                  },
                  child: Text(t.guestEnter),
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
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SocialButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 22),
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
