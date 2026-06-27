import 'package:flutter/widgets.dart';

/// Chave do Navigator raiz, partilhada pelo GoRouter e pelo push (para abrir o
/// ecrã certo ao tocar numa notificação). Em ficheiro próprio para evitar
/// import circular entre o router e os providers.
final rootNavigatorKey = GlobalKey<NavigatorState>();
