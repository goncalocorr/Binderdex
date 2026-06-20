import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../presentation/screens/card_detail_screen.dart';
import '../../presentation/screens/missing_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../presentation/screens/progress_screen.dart';
import '../../presentation/screens/search_screen.dart';
import '../../presentation/screens/set_cards_screen.dart';
import '../../presentation/screens/sets_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/splash_screen.dart';

/// Casca com navegação inferior (Coleções, Progresso, Em falta, Definições).
class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  static const _tabs = [
    SetsScreen(),
    ProgressScreen(),
    MissingScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titles = [t.tabSets, t.tabProgress, t.tabMissing, t.tabSettings];

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 52,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Image.asset('assets/logo.png', width: 32, height: 32),
        ),
        title: Text(titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: t.tabSearch,
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.style), label: t.tabSets),
          NavigationDestination(
              icon: const Icon(Icons.donut_large), label: t.tabProgress),
          NavigationDestination(
              icon: const Icon(Icons.search_off), label: t.tabMissing),
          NavigationDestination(
              icon: const Icon(Icons.settings), label: t.tabSettings),
        ],
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(
        path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    GoRoute(path: '/', builder: (_, __) => const _Shell()),
    GoRoute(
      path: '/set/:id',
      builder: (_, s) => SetCardsScreen(
        setId: s.pathParameters['id']!,
        initialStatus: s.uri.queryParameters['status'],
      ),
    ),
    GoRoute(
      path: '/card/:id',
      builder: (_, s) => CardDetailScreen(id: s.pathParameters['id']!),
    ),
    GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
  ],
);
