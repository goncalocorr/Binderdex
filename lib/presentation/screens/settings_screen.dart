import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/dex_tokens.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/avatar.dart';

/// Definições: perfil, tema e idioma. Sincronização e Premium ficam preparados
/// aqui mas só ganham função nas Etapas 2 e 3.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final controller =
        TextEditingController(text: ref.read(displayNameProvider));
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(hintText: t.guest),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
    if (result != null) {
      ref.read(displayNameProvider.notifier).state = result;
      await ref.read(prefsProvider).setString('displayName', result);
    }
  }

  void _setTheme(WidgetRef ref, int i) {
    ref.read(themeModeProvider.notifier).state = i;
    ref.read(prefsProvider).setInt('themeMode', i);
  }

  void _setLocale(WidgetRef ref, String? code) {
    ref.read(localeProvider.notifier).state = code;
    final prefs = ref.read(prefsProvider);
    if (code == null) {
      prefs.remove('locale');
    } else {
      prefs.setString('locale', code);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final theme = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final name = ref.watch(displayNameProvider);

    final themeLabels = [t.themeSystem, t.themeLight, t.themeDark];

    return ListView(
      children: [
        // --- Perfil ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(DexRadii.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                      alpha: Theme.of(context).brightness == Brightness.dark
                          ? 0.35
                          : 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Avatar(name: name, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name.isEmpty ? t.guest : name,
                          style: Theme.of(context).textTheme.titleLarge),
                      Text(t.localCollection,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: t.editName,
                  onPressed: () => _editName(context, ref),
                ),
              ],
            ),
          ),
        ),
        // ☁️ Etapa 2: aqui entrará "Iniciar sessão / Sincronizar".

        const Divider(),
        // --- Tema ---
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
                onSelected: (_) => _setTheme(ref, i),
              ),
            ),
          ),
        ),
        const Divider(),
        // --- Idioma ---
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
                onSelected: (_) => _setLocale(ref, null),
              ),
              ChoiceChip(
                label: const Text('Português'),
                selected: locale == 'pt',
                onSelected: (_) => _setLocale(ref, 'pt'),
              ),
              ChoiceChip(
                label: const Text('English'),
                selected: locale == 'en',
                onSelected: (_) => _setLocale(ref, 'en'),
              ),
            ],
          ),
        ),
        const Divider(),

        // ⭐ PREMIUM: secção de subscrição — preparada para a Etapa 3.
        ListTile(
          leading: const Icon(Icons.workspace_premium),
          title: Text(t.premium),
          subtitle: Text(t.comingSoon),
          enabled: false,
        ),
      ],
    );
  }
}
