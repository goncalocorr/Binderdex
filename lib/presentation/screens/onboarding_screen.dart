import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Ecrã de boas-vindas (primeiro arranque): logo, frase, e CTA para começar.
/// O "Já tenho conta" fica desativado até à Etapa 2 (login/Firebase).
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  void _start(BuildContext context, WidgetRef ref) {
    ref.read(onboardingDoneProvider.notifier).state = true;
    ref.read(prefsProvider).setBool('onboardingDone', true);
    context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.6),
            radius: 1.1,
            colors: [
              cs.primaryContainer,
              Theme.of(context).scaffoldBackgroundColor,
            ],
            stops: const [0.0, 0.55],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/logo.png', width: 104, height: 104),
                      const SizedBox(height: 14),
                      Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: 'Binder',
                              style: TextStyle(color: cs.primary)),
                          TextSpan(
                              text: 'dex',
                              style: TextStyle(color: cs.onSurface)),
                        ]),
                        style: TextStyle(
                          fontFamily: AppTheme.displayFont,
                          fontWeight: FontWeight.w700,
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t.onboardingTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant, height: 1.5),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(t.startCollection),
                  style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52)),
                  onPressed: () => _start(context, ref),
                ),
                const SizedBox(height: 10),
                // Mostra o ecrã de login (visual; auth real na Etapa 2).
                TextButton(
                  onPressed: () => context.push('/login'),
                  child: Text(t.haveAccount),
                ),
                const SizedBox(height: 6),
                Text(
                  t.fanMadeDisclaimer,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
