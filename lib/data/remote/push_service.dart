import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'profile_service.dart';

// Notificações push (FCM). Por agora só o LADO DA APP: pede permissão, guarda
// o token na conta e mostra/encaminha as notificações. O ENVIO (quando chega
// uma mensagem, um anúncio de carta seguida ou uma coleção nova) fica para as
// Cloud Functions — ver docs/push_notifications.md.

const _channelId = 'binderdex_default';
const _channelName = 'Binderdex';
const _channelDesc = 'Mensagens, anúncios e novidades';

final FlutterLocalNotificationsPlugin _localNotifs =
    FlutterLocalNotificationsPlugin();

/// Navegação global usada quando o utilizador toca numa notificação mostrada em
/// primeiro plano. Definida pelo provider (liga ao GoRouter).
void Function(String route)? pushNavigate;

/// Converte o `data` da mensagem na rota da app a abrir.
/// Convenção (a respeitar depois nas Cloud Functions):
///   type=message               → caixa de mensagens
///   type=listing, cardId=<id>  → ofertas dessa carta na comunidade
///   type=newSet                → centro de notificações
String routeForData(Map<String, dynamic> data) {
  switch (data['type']) {
    case 'message':
      return '/messages';
    case 'listing':
      final id = data['cardId'];
      return (id is String && id.isNotEmpty)
          ? '/community/card/$id'
          : '/notifications';
    default:
      return '/notifications';
  }
}

/// Handler de segundo plano (tem de ser top-level / vm:entry-point).
/// Mensagens com payload `notification` são mostradas pelo sistema
/// automaticamente — por agora não há nada a fazer aqui.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

/// Inicialização de plataforma. Chamar uma vez no `main`, depois do Firebase.
Future<void> initPushPlatform() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  const init = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );
  await _localNotifs.initialize(
    settings: init,
    onDidReceiveNotificationResponse: (resp) {
      final payload = resp.payload;
      if (payload != null && payload.isNotEmpty) pushNavigate?.call(payload);
    },
  );
  // Canal obrigatório no Android 8+.
  await _localNotifs
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ));
}

/// Liga o push à conta: regista o token e encaminha as notificações.
class PushService {
  final ProfileService profile;
  final void Function(String route) onOpen;
  PushService({required this.profile, required this.onOpen});

  String? _uid;
  String? _token;
  bool _wired = false;

  Future<void> start(String uid) async {
    if (!Platform.isAndroid && !Platform.isIOS) return;
    _uid = uid;
    try {
      final fm = FirebaseMessaging.instance;
      // Android 13+ e iOS pedem permissão ao utilizador (idempotente).
      await fm.requestPermission();

      final token = await fm.getToken();
      if (token != null && token.isNotEmpty) {
        _token = token;
        await profile.addFcmToken(uid, token);
      }
      fm.onTokenRefresh.listen((t) {
        _token = t;
        final u = _uid;
        if (u != null) profile.addFcmToken(u, t);
      });

      // Ligar os handlers só uma vez por sessão.
      if (!_wired) {
        _wired = true;
        // Primeiro plano: o sistema não mostra nada → mostramos nós.
        FirebaseMessaging.onMessage.listen(_showForeground);
        // App em 2.º plano e tocou na notificação.
        FirebaseMessaging.onMessageOpenedApp
            .listen((m) => onOpen(routeForData(m.data)));
        // App estava fechada e foi aberta por uma notificação.
        final initial = await fm.getInitialMessage();
        if (initial != null) onOpen(routeForData(initial.data));
      }
    } catch (_) {
      // Sem rede / sem Google Play Services / sem permissão — segue sem push.
    }
  }

  Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    if (n == null) return;
    await _localNotifs.show(
      id: n.hashCode,
      title: n.title,
      body: n.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: routeForData(m.data),
    );
  }

  /// Ao terminar sessão: tira o token deste dispositivo da conta.
  Future<void> stop() async {
    final uid = _uid, token = _token;
    if (uid != null && token != null) {
      await profile.removeFcmToken(uid, token);
    }
    _uid = null;
    _token = null;
  }
}
