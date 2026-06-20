import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/seed/sets_loader.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Container partilhado para hidratar os sets e injetar as preferências.
  final container = ProviderContainer(
    overrides: [prefsProvider.overrideWithValue(prefs)],
  );
  await SetsLoader(container.read(databaseProvider)).ensureSeeded();

  // Estado inicial a partir das preferências guardadas.
  container.read(themeModeProvider.notifier).state =
      prefs.getInt('themeMode') ?? 0;
  container.read(localeProvider.notifier).state = prefs.getString('locale');
  container.read(displayNameProvider.notifier).state =
      prefs.getString('displayName') ?? '';

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PokedexApp(),
    ),
  );
}
