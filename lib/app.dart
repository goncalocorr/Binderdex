import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/router/root_navigator.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/app_providers.dart';

/// Evita mostrar o aviso duas vezes enquanto o diálogo está aberto.
bool _warningShowing = false;

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
    // Aviso de moderação: mostra o aviso deixado pelo admin (e limpa-o).
    ref.listen(selfModerationProvider, (_, next) {
      final w = next.valueOrNull?.warning;
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
