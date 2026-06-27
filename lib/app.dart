import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/app_providers.dart';

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
