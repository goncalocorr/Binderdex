import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/market_tier.dart';
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

  /// Limpa o estado local da sessão (coleção, nome, avatar, modo convidado).
  /// As mutações de estado vêm PRIMEIRO; deve ser chamado ANTES do signOut/
  /// delete, senão o redirect do gate desmonta o ecrã a meio.
  Future<void> _clearLocalProfile(WidgetRef ref) async {
    ref.read(displayNameProvider.notifier).state = '';
    ref.read(avatarProvider.notifier).state = '';
    ref.read(guestModeProvider.notifier).state = false;
    final prefs = ref.read(prefsProvider);
    await prefs.remove('displayName');
    await prefs.remove('avatar');
    await ref.read(databaseProvider).clearCollection();
  }

  /// Folha para escolher um dos avatares incluídos.
  void _pickAvatar(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final current = ref.read(avatarProvider);
    final ids = kAvatarIds;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 4),
                child: Text(t.chooseAvatar,
                    style: Theme.of(ctx).textTheme.titleMedium),
              ),
              Expanded(
                child: GridView.count(
                  controller: scroll,
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: ids.map((id) {
                final selected = id == current;
                return GestureDetector(
                  onTap: () async {
                    ref.read(avatarProvider.notifier).state = id;
                    await ref.read(prefsProvider).setString('avatar', id);
                    final uid = ref.read(authStateProvider).valueOrNull?.uid;
                    if (uid != null) {
                      try {
                        await ref
                            .read(profileServiceProvider)
                            .save(uid, avatar: id);
                      } catch (_) {/* offline/regras — fica local */}
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: cs.primary, width: 3)
                          : null,
                    ),
                    child: ClipOval(
                      child: Image.asset('assets/avatars/$id.png',
                          fit: BoxFit.cover),
                    ),
                  ),
                );
                }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signOut(WidgetRef ref) async {
    // Limpa a coleção e o nome ANTES de sair (enquanto o ecrã está montado).
    ref.read(syncServiceProvider).stop();
    await _clearLocalProfile(ref);
    await ref.read(authServiceProvider).signOut();
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
      try {
        await ref.read(profileServiceProvider).delete(user.uid); // perfil
      } catch (_) {/* sem doc de perfil ou regras por publicar */}
      await _clearLocalProfile(ref); // limpa local ANTES de sair (ecrã montado)
      await auth.deleteAccount();
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
    final avatar = ref.watch(avatarProvider);
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
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _pickAvatar(context, ref),
                child: Stack(
                  children: [
                    Avatar(name: name, size: 64, avatarId: avatar),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: cs.surface, width: 2),
                        ),
                        child: const Icon(Icons.edit,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
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
        ListTile(
          leading: const Icon(Icons.chat_bubble_outline),
          title: Text(t.messages),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/messages'),
        ),
        ListTile(
          leading: const Icon(Icons.workspace_premium),
          title: Text(t.premiumSlots),
          subtitle: Text(
              '${MarketTier.slotsFor(ref.watch(marketTierProvider).valueOrNull ?? 0)} slots'),
          onTap: () async {
            final uid = ref.read(authStateProvider).valueOrNull?.uid;
            if (uid == null) return;
            final svc = ref.read(marketServiceProvider);
            await showDialog<void>(
              context: context,
              builder: (_) => SimpleDialog(
                title: Text(t.premiumSlots),
                children: [
                  for (var i = 0; i < MarketTier.slots.length; i++)
                    SimpleDialogOption(
                      onPressed: () {
                        svc.setTier(uid, i);
                        Navigator.of(context).pop();
                      },
                      child: Text('Nível $i — ${MarketTier.slots[i]} slots'),
                    ),
                ],
              ),
            );
          },
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
