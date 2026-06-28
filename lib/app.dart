import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/router/root_navigator.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/app_providers.dart';

/// Evita mostrar o aviso duas vezes enquanto o diálogo está aberto.
bool _warningShowing = false;
bool _banShown = false;

void _showBan(WidgetRef ref) {
  if (_banShown) return;
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  _banShown = true;
  final t = AppLocalizations.of(ctx)!;
  showDialog<void>(
    context: ctx,
    builder: (dctx) => AlertDialog(
      icon: const Icon(Icons.block, color: Colors.red, size: 36),
      title: Text(t.accountSuspendedTitle, textAlign: TextAlign.center),
      content: Text(t.accountSuspended),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dctx).pop();
            _appealSheet(ref);
          },
          child: Text(t.appeal),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dctx).pop(),
          child: Text(t.continueLabel),
        ),
      ],
    ),
  );
}

/// Folha para o utilizador banido apelar (explicar-se). Vai para `appeals/`.
void _appealSheet(WidgetRef ref) {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  final ctrl = TextEditingController();
  showModalBottomSheet<void>(
    context: ctx,
    isScrollControlled: true,
    builder: (sctx) {
      final t = AppLocalizations.of(sctx)!;
      return Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(sctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.appeal, style: Theme.of(sctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 5,
              maxLength: 1000,
              decoration: InputDecoration(
                  hintText: t.appealHint, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final text = ctrl.text.trim();
                final user = ref.read(authStateProvider).valueOrNull;
                if (text.isEmpty || user == null) return;
                final messenger = ScaffoldMessenger.of(sctx);
                await ref.read(adminServiceProvider).addAppeal(
                    uid: user.uid,
                    name: ref.read(displayNameProvider),
                    text: text);
                if (sctx.mounted) Navigator.of(sctx).pop();
                messenger.showSnackBar(SnackBar(content: Text(t.appealSent)));
              },
              child: Text(t.send),
            ),
          ],
        ),
      );
    },
  );
}

/// Aviso de que a conta foi reativada (desbanida).
void _showUnban(WidgetRef ref) {
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  final t = AppLocalizations.of(ctx)!;
  showDialog<void>(
    context: ctx,
    builder: (dctx) => AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 36),
      title: Text(t.accountReactivatedTitle, textAlign: TextAlign.center),
      content: Text(t.accountReactivated),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(dctx).pop(),
          child: Text(t.continueLabel),
        ),
      ],
    ),
  );
}

void _showWarning(WidgetRef ref, String text) {
  if (_warningShowing) return;
  final ctx = rootNavigatorKey.currentContext;
  if (ctx == null) return;
  _warningShowing = true;
  showDialog<void>(
    context: ctx,
    builder: (dctx) {
      final t = AppLocalizations.of(dctx)!;
      return AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded,
            color: Colors.orange, size: 36),
        title: Text(t.warningTitle, textAlign: TextAlign.center),
        content: Text(text),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dctx).pop();
              final uid = ref.read(authStateProvider).valueOrNull?.uid;
              if (uid != null) {
                ref.read(profileServiceProvider).clearWarning(uid);
              }
            },
            child: Text(t.continueLabel),
          ),
        ],
      );
    },
  ).then((_) => _warningShowing = false);
}

class PokedexApp extends ConsumerWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeIdx = ref.watch(themeModeProvider);
    final localeCode = ref.watch(localeProvider);
    // Liga a sincronização e o push ao ciclo de vida da sessão.
    ref.watch(syncServiceProvider);
    ref.watch(pushServiceProvider);
    ref.watch(wishlistWatchSyncProvider); // wishlist → notifyCards (push)
    ref.watch(ensureOwnedSetsSyncedProvider); // sets possuídos → cache (binder)
    ref.watch(setsRefreshProvider); // apanha coleções novas da API (6h)
    // Moderação: aviso de conta suspensa (banido) ou aviso deixado pelo admin.
    ref.listen(selfModerationProvider, (_, next) {
      final mod = next.valueOrNull;
      if (mod == null) return;
      // Sem sessão → terminar sessão NÃO é desban; não mexer.
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      if (uid == null) return;
      final prefs = ref.read(prefsProvider);
      if (mod.banned) {
        _showBan(ref);
        prefs.setString('bannedUid', uid); // ligado a esta conta
        return;
      }
      // Não banido: só avisa "reativada" se ERA esta conta que estava banida.
      if (prefs.getString('bannedUid') == uid) {
        prefs.remove('bannedUid');
        _banShown = false;
        _showUnban(ref);
      }
      final w = mod.warning;
      if (w != null && w.trim().isNotEmpty) _showWarning(ref, w);
    });
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Binderdex',
      onGenerateTitle: (ctx) => AppLocalizations.of(ctx)!.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark][themeIdx],
      locale: localeCode == null ? null : Locale(localeCode),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
