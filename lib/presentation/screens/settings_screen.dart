import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Definições: tema e idioma (Etapa 1). Sincronização e Premium são preparados
/// aqui mas só ganham função nas Etapas 2 e 3.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final themeLabels = [t.themeSystem, t.themeLight, t.themeDark];

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.palette_outlined),
          title: Text(t.theme),
          subtitle: Text(themeLabels[theme]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: List.generate(
              3,
              (i) => ChoiceChip(
                label: Text(themeLabels[i]),
                selected: theme == i,
                onSelected: (_) =>
                    ref.read(themeModeProvider.notifier).state = i,
              ),
            ),
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(t.language),
          subtitle: Text(locale == null
              ? t.languageSystem
              : (locale == 'pt' ? 'Português' : 'English')),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: Text(t.languageSystem),
                selected: locale == null,
                onSelected: (_) =>
                    ref.read(localeProvider.notifier).state = null,
              ),
              ChoiceChip(
                label: const Text('Português'),
                selected: locale == 'pt',
                onSelected: (_) =>
                    ref.read(localeProvider.notifier).state = 'pt',
              ),
              ChoiceChip(
                label: const Text('English'),
                selected: locale == 'en',
                onSelected: (_) =>
                    ref.read(localeProvider.notifier).state = 'en',
              ),
            ],
          ),
        ),
        const Divider(),

        // ⭐ PREMIUM: secção de subscrição — preparada para a Etapa 3.
        // Sem pagamentos nesta fase; o PremiumGate dará "tudo desbloqueado".
        ListTile(
          leading: const Icon(Icons.workspace_premium),
          title: Text(t.premium),
          subtitle: Text(t.comingSoon),
          enabled: false,
        ),

        // Sincronização na nuvem (Firebase) — ativada na Etapa 2.
      ],
    );
  }
}
