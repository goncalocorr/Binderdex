import 'package:cloud_firestore/cloud_firestore.dart';

/// Id determinístico de uma conversa entre dois utilizadores (1 por par).
/// Simétrico: `conversationIdFor(a,b) == conversationIdFor(b,a)`.
String conversationIdFor(String a, String b) {
  final pair = [a, b]..sort();
  return '${pair[0]}_${pair[1]}';
}

final _emailRe = RegExp(r'[\w.+\-]+@[\w\-]+\.[\w.\-]+');
// 9+ dígitos seguidos, tolerando espaços/+/- entre eles (nº de telemóvel).
final _phoneRe = RegExp(r'(?:\+?\d[\s\-]?){9,}');

/// Verdadeiro se o texto parece partilhar um contacto (email ou telemóvel).
/// Usado para o aviso de burla nas mensagens recebidas.
bool messageHasContact(String text) =>
    _emailRe.hasMatch(text) || _phoneRe.hasMatch(text);

DateTime _ts(dynamic v) =>
    v is Timestamp ? v.toDate() : DateTime.fromMillisecondsSinceEpoch(0);

/// Uma conversa, já resolvida na perspetiva do utilizador atual (o "outro").
/// `card*` = carta em negociação (vinda do anúncio que originou o contacto).
class Conversation {
  final String id, otherUid, otherName, otherAvatar, lastMessage, lastSenderUid;
  final String cardId, cardName, cardImage;
  final int unread;
  final DateTime updatedAt;

  const Conversation({
    required this.id,
    required this.otherUid,
    required this.otherName,
    required this.otherAvatar,
    required this.lastMessage,
    required this.lastSenderUid,
    required this.unread,
    required this.updatedAt,
    this.cardId = '',
    this.cardName = '',
    this.cardImage = '',
  });

  factory Conversation.fromMap(String id, Map<String, dynamic> m, String meUid) {
    final parts = List<String>.from((m['participants'] ?? const []) as List);
    final other = parts.firstWhere((u) => u != meUid, orElse: () => '');
    final names = Map<String, dynamic>.from((m['names'] ?? const {}) as Map);
    final avatars = Map<String, dynamic>.from((m['avatars'] ?? const {}) as Map);
    final unread = Map<String, dynamic>.from((m['unread'] ?? const {}) as Map);
    return Conversation(
      id: id,
      otherUid: other,
      otherName: (names[other] ?? '') as String,
      otherAvatar: (avatars[other] ?? '') as String,
      lastMessage: (m['lastMessage'] ?? '') as String,
      lastSenderUid: (m['lastSenderUid'] ?? '') as String,
      cardId: (m['cardId'] ?? '') as String,
      cardName: (m['cardName'] ?? '') as String,
      cardImage: (m['cardImage'] ?? '') as String,
      unread: (unread[meUid] ?? 0) as int,
      updatedAt: _ts(m['updatedAt']),
    );
  }
}

class ChatMessage {
  final String id, senderUid, text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderUid,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(String id, Map<String, dynamic> m) => ChatMessage(
        id: id,
        senderUid: (m['senderUid'] ?? '') as String,
        text: (m['text'] ?? '') as String,
        createdAt: _ts(m['createdAt']),
      );
}
