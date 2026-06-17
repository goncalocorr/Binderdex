import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/seed/dataset_loader.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Container partilhado para podermos hidratar o dataset antes de mostrar a UI.
  final container = ProviderContainer();
  await DatasetLoader(container.read(databaseProvider)).ensureSeeded();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PokedexApp(),
    ),
  );
}
