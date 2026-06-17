import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../presentation/screens/detail_screen.dart';
import '../../presentation/screens/missing_screen.dart';
import '../../presentation/screens/pokedex_screen.dart';
import '../../presentation/screens/progress_screen.dart';
import '../../presentation/screens/settings_screen.dart';

/// Casca com navegação inferior (4 abas) + rota de detalhe.
class _Shell extends StatefulWidget {
  const _Shell();
  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> {
  int _index = 0;

  static const _tabs = [
    PokedexScreen(),
    ProgressScreen(),
    MissingScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final titles = [t.tabPokedex, t.tabProgress, t.tabMissing, t.tabSettings];

    return Scaffold(
      appBar: AppBar(title: Text(titles[_index])),
      body: _tabs[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
              icon: const Icon(Icons.catching_pokemon), label: t.tabPokedex),
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
  routes: [
    GoRoute(path: '/', builder: (_, __) => const _Shell()),
    GoRoute(
      path: '/pokemon/:id',
      builder: (_, s) =>
          DetailScreen(id: int.parse(s.pathParameters['id']!)),
    ),
  ],
);
