import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat.dart';

/// Mensagens privadas entre utilizadores (1 conversa por par).
class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _convos =>
      _db.collection('conversations');

  Stream<List<Conversation>> watchConversations(String uid) => _convos
      .where('participants', arrayContains: uid)
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) => Conversation.fromMap(d.id, d.data(), uid))
          .toList());

  Stream<List<ChatMessage>> watchMessages(String convId) => _convos
      .doc(convId)
      .collection('messages')
      .orderBy('createdAt')
      .snapshots()
      .map((s) =>
          s.docs.map((d) => ChatMessage.fromMap(d.id, d.data())).toList());

  /// Abre (ou cria) a conversa entre os dois utilizadores. Devolve o convId.
  /// Usa `set(merge)` sem ler primeiro — ler um doc inexistente seria negado
  /// pelas regras (que testam os participantes). Só define a identidade
  /// (participantes/nomes/avatares); o `lastMessage`/`updatedAt`/`unread`
  /// surgem com a 1ª mensagem (conversas vazias não aparecem na caixa).
  Future<String> openConversation({
    required String meUid,
    required String meName,
    required String meAvatar,
    required String otherUid,
    required String otherName,
    required String otherAvatar,
    String? cardId,
    String? cardName,
    String? cardImage,
  }) async {
    final id = conversationIdFor(meUid, otherUid);
    await _convos.doc(id).set({
      'participants': [meUid, otherUid],
      'names': {meUid: meName, otherUid: otherName},
      'avatars': {meUid: meAvatar, otherUid: otherAvatar},
      // Carta em negociação (do anúncio que originou o contacto).
      if (cardId != null && cardId.isNotEmpty) 'cardId': cardId,
      if (cardName != null && cardName.isNotEmpty) 'cardName': cardName,
      if (cardImage != null && cardImage.isNotEmpty) 'cardImage': cardImage,
    }, SetOptions(merge: true));
    return id;
  }

  Future<void> sendMessage({
    required String convId,
    required String senderUid,
    required String otherUid,
    required String text,
  }) async {
    final t = text.trim();
    if (t.isEmpty) return;
    final batch = _db.batch();
    final msg = _convos.doc(convId).collection('messages').doc();
    batch.set(msg, {
      'senderUid': senderUid,
      'text': t,
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      _convos.doc(convId),
      {
        'lastMessage': t,
        'lastSenderUid': senderUid,
        'updatedAt': FieldValue.serverTimestamp(),
        'unread': {otherUid: FieldValue.increment(1)},
      },
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  /// Zera as não-lidas do utilizador nesta conversa (ao abrir o chat).
  Future<void> markRead(String convId, String uid) => _convos.doc(convId).set(
        {
          'unread': {uid: 0}
        },
        SetOptions(merge: true),
      );

  /// Arquiva/desarquiva a conversa só para este utilizador.
  Future<void> setArchived(String convId, String uid, bool archived) =>
      _convos.doc(convId).set({
        'archived': {uid: archived}
      }, SetOptions(merge: true));

  /// "Apaga" a conversa só para este utilizador (esconde-a até chegar uma
  /// mensagem mais recente). Não destrói a conversa do outro participante.
  Future<void> clearConversation(String convId, String uid) =>
      _convos.doc(convId).set({
        'clearedAt': {uid: FieldValue.serverTimestamp()},
        'archived': {uid: false},
      }, SetOptions(merge: true));
}
