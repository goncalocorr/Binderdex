import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/remote/push_service.dart';
import 'data/seed/sets_loader.dart';
import 'firebase_options.dart';
import 'presentation/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (Etapa 2: auth + sincronização). A app continua a funcionar
  // offline; se a inicialização falhar, segue sem nuvem.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Push: handler de 2.º plano + canal de notificações (sem rede aqui).
    await initPushPlatform();
  } catch (_) {
    // Sem Firebase, a app fica em modo local-only.
  }

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
  container.read(avatarProvider.notifier).state =
      prefs.getString('avatar') ?? '';
  container.read(onboardingDoneProvider.notifier).state =
      prefs.getBool('onboardingDone') ?? false;

  // O router (com o gate de login) é criado por provider; ver app_router.dart.
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PokedexApp(),
    ),
  );
}
