import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/router/root_navigator.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/appeal.dart';
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
  final appealed =
      ref.read(selfModerationProvider).valueOrNull?.appealed ?? false;
  showDialog<void>(
    context: ctx,
    builder: (dctx) => AlertDialog(
      icon: const Icon(Icons.block, color: Colors.red, size: 36),
      title: Text(t.accountSuspendedTitle, textAlign: TextAlign.center),
      content: Text(t.accountSuspended),
      actions: [
        if (!appealed)
          TextButton(
            onPressed: () {
              Navigator.of(dctx).pop();
              showAppealSheet(ctx, ref);
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

/// Aviso de que a conta foi reativada (desbanida). Adiado para depois do frame
/// (a Comunidade reconstrói ao deixar de estar banido) e mostrado só uma vez.
bool _unbanShown = false;
void _showUnban(WidgetRef ref) {
  if (_unbanShown) return;
  _unbanShown = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
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
  });
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
    ref.watch(billingListenerProvider); // processa compras/restauros/renovações Play
    // Moderação: aviso de conta suspensa (banido) ou aviso deixado pelo admin.
    ref.listen(selfModerationProvider, (prev, next) {
      final mod = next.valueOrNull;
      if (mod == null) return;
      // Sem sessão → terminar sessão NÃO é desban; não mexer.
      final uid = ref.read(authStateProvider).valueOrNull?.uid;
      if (uid == null) return;
      final prefs = ref.read(prefsProvider);
      if (mod.banned) {
        _showBan(ref);
        prefs.setString('bannedUid', uid); // ligado a esta conta
        _unbanShown = false; // permite o aviso de reativação no próximo desban
        return;
      }
      // Reativada se: transitou de banido→não-banido (app aberta) OU esta conta
      // estava marcada como banida (reabertura). NÃO em logout (uid já guardado).
      final justUnbanned = prev?.valueOrNull?.banned ?? false;
      if (justUnbanned || prefs.getString('bannedUid') == uid) {
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
