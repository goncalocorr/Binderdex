import 'package:cloud_firestore/cloud_firestore.dart';

/// Id determinístico de uma conversa entre dois utilizadores, por carta
/// (1 chat por par + carta). Simétrico nos utilizadores. Sem carta, recai no
/// id por par (compatibilidade).
String conversationIdFor(String a, String b, [String cardId = '']) {
  final pair = [a, b]..sort();
  final base = '${pair[0]}_${pair[1]}';
  return cardId.isEmpty ? base : '${base}_$cardId';
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

  /// Estado por-utilizador (do utilizador atual). `archived` = movida para
  /// Arquivadas; `clearedAt` = momento em que apaguei a conversa (reaparece se
  /// houver mensagem mais recente).
  final bool archived;
  final DateTime clearedAt;

  Conversation({
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
    this.archived = false,
    DateTime? clearedAt,
  }) : clearedAt = clearedAt ?? _epoch;

  static final DateTime _epoch = DateTime.fromMillisecondsSinceEpoch(0);

  /// Apagada por mim e sem mensagens novas desde então → esconder da caixa.
  bool get isCleared =>
      clearedAt.isAfter(_epoch) && !updatedAt.isAfter(clearedAt);

  factory Conversation.fromMap(String id, Map<String, dynamic> m, String meUid) {
    final parts = List<String>.from((m['participants'] ?? const []) as List);
    final other = parts.firstWhere((u) => u != meUid, orElse: () => '');
    final names = Map<String, dynamic>.from((m['names'] ?? const {}) as Map);
    final avatars = Map<String, dynamic>.from((m['avatars'] ?? const {}) as Map);
    final unread = Map<String, dynamic>.from((m['unread'] ?? const {}) as Map);
    final archived = Map<String, dynamic>.from((m['archived'] ?? const {}) as Map);
    final cleared = Map<String, dynamic>.from((m['clearedAt'] ?? const {}) as Map);
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
      archived: (archived[meUid] ?? false) as bool,
      clearedAt: _ts(cleared[meUid]),
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
