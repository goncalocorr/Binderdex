import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/avatar.dart';

/// Perfil: cabeçalho com avatar + resumo, atalhos (Iniciar sessão, Wishlist),
/// tema e idioma. Sincronização e Premium ficam preparados aqui mas só ganham
/// função nas Etapas 2 e 3.
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

  /// Limpa o estado local da sessão (coleção, nome, modo convidado).
  Future<void> _clearLocalProfile(WidgetRef ref) async {
    await ref.read(databaseProvider).clearCollection();
    ref.read(displayNameProvider.notifier).state = '';
    await ref.read(prefsProvider).remove('displayName');
    ref.read(guestModeProvider.notifier).state = false;
  }

  Future<void> _signOut(WidgetRef ref) async {
    // Limpa a coleção e o nome ao sair (ficam seguros na nuvem na conta).
    ref.read(syncServiceProvider).stop();
    await ref.read(authServiceProvider).signOut();
    await _clearLocalProfile(ref);
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteAccountConfirm),
        content: Text(t.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final sync = ref.read(syncServiceProvider);
    final auth = ref.read(authServiceProvider);
    try {
      sync.stop(); // pára os listeners antes de apagar
      await sync.deleteRemoteData(user.uid); // ainda autenticado (regras)
      await auth.deleteAccount();
      await _clearLocalProfile(ref); // limpa coleção + nome locais
      messenger.showSnackBar(SnackBar(content: Text(t.accountDeleted)));
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(e.code == 'requires-recent-login'
              ? t.reauthNeeded
              : (e.message ?? t.authFailed))));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.deleteFailed)));
    }
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
    final user = ref.watch(authStateProvider).valueOrNull;
    final signedIn = user != null && !user.isAnonymous;
    final owned = ref.watch(globalProgressProvider).valueOrNull?.owned ?? 0;
    final mySets = ref
            .watch(setsListProvider)
            .valueOrNull
            ?.where((s) => s.progress.owned > 0)
            .length ??
        0;

    final themeLabels = [t.themeSystem, t.themeLight, t.themeDark];

    return ListView(
      children: [
        // --- Cabeçalho de perfil ---
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
          child: Row(
            children: [
              Avatar(name: name, size: 64),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name.isEmpty ? t.guest : name,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(t.profileSummary(owned, mySets),
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

        // --- Atalhos ---
        if (signedIn)
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(t.signedInAs(user.email ?? '')),
            trailing: TextButton(
              onPressed: () => _signOut(ref),
              child: Text(t.signOut),
            ),
          )
        else
          ListTile(
            leading: const Icon(Icons.login),
            title: Text(t.signIn),
            subtitle: Text(t.signInSync),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/login'),
          ),
        ListTile(
          leading: const Icon(Icons.favorite_border),
          title: Text(t.wishlist),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/wishlist'),
        ),
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

        // Zona de perigo — só com sessão iniciada (RGPD: direito ao esquecimento).
        if (signedIn) ...[
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever, color: cs.error),
            title: Text(t.deleteAccount, style: TextStyle(color: cs.error)),
            onTap: () => _deleteAccount(context, ref),
          ),
        ],
      ],
    );
  }
}
