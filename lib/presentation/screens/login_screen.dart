import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Ecrã de início de sessão — **só visual** nesta fase. A autenticação real
/// (Firebase: Google/Apple/email + sincronização) chega na Etapa 2.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _comingSoon(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(t.authComingSoon)));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
          children: [
            Image.asset('assets/logo.png', width: 56, height: 56),
            const SizedBox(height: 14),
            Text(
              t.loginTitle,
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

            // Botões sociais.
            _SocialButton(
              icon: Icons.g_mobiledata,
              label: t.continueGoogle,
              onTap: () => _comingSoon(context),
            ),
            const SizedBox(height: 10),
            _SocialButton(
              icon: Icons.apple,
              label: t.continueApple,
              onTap: () => _comingSoon(context),
            ),
            const SizedBox(height: 18),

            // Divisor "ou".
            Row(
              children: [
                Expanded(child: Divider(color: cs.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(t.orLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                ),
                Expanded(child: Divider(color: cs.outlineVariant)),
              ],
            ),
            const SizedBox(height: 18),

            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: t.emailLabel,
                prefixIcon: const Icon(Icons.mail_outline),
                hintText: 'you@example.com',
              ),
            ),
            const SizedBox(height: 14),
            const _PasswordField(),
            const SizedBox(height: 22),

            FilledButton(
              onPressed: () => _comingSoon(context),
              style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52)),
              child: Text(t.logIn),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => context.pop(),
                child: Text(t.skipForNow),
              ),
            ),
          ],
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

class _PasswordField extends StatefulWidget {
  const _PasswordField();
  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return TextField(
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: t.passwordLabel,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        hintText: '••••••••',
      ),
    );
  }
}
