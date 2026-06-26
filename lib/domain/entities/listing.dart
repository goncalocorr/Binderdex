import 'package:cloud_firestore/cloud_firestore.dart';

enum TradeMode {
  trade, sell, both;

  String get id => name;
  static TradeMode fromId(String s) =>
      TradeMode.values.firstWhere((e) => e.name == s, orElse: () => TradeMode.trade);
}

enum CardCondition {
  mint, good, used, damaged;

  String get id => name;
  static CardCondition fromId(String s) => CardCondition.values
      .firstWhere((e) => e.name == s, orElse: () => CardCondition.good);
}

/// Identidade mínima de uma carta (a publicar ou desejada em troca).
class CardRef {
  final String cardId, cardName, cardImage, setId;
  const CardRef({
    required this.cardId,
    required this.cardName,
    required this.cardImage,
    required this.setId,
  });

  Map<String, dynamic> toMap() => {
        'cardId': cardId,
        'cardName': cardName,
        'cardImage': cardImage,
        'setId': setId,
      };

  factory CardRef.fromMap(Map<String, dynamic> m) => CardRef(
        cardId: (m['cardId'] ?? '') as String,
        cardName: (m['cardName'] ?? '') as String,
        cardImage: (m['cardImage'] ?? '') as String,
        setId: (m['setId'] ?? '') as String,
      );
}

class Listing {
  final String id, ownerUid, ownerName, ownerAvatar;
  final String cardId, cardName, cardImage, setId;
  final TradeMode mode;
  final CardCondition condition;
  final String? wantText, note;

  /// Cartas que o dono quer em troca (só relevante em trocar/ambos).
  final List<CardRef> wantCards;
  final DateTime createdAt;

  const Listing({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.ownerAvatar,
    required this.cardId,
    required this.cardName,
    required this.cardImage,
    required this.setId,
    required this.mode,
    required this.condition,
    required this.wantText,
    required this.note,
    required this.createdAt,
    this.wantCards = const [],
  });

  /// Mapa para o Firestore. `createdAt` é omitido aqui — o serviço acrescenta
  /// `FieldValue.serverTimestamp()` na escrita.
  Map<String, dynamic> toMap() => {
        'ownerUid': ownerUid,
        'ownerName': ownerName,
        'ownerAvatar': ownerAvatar,
        'cardId': cardId,
        'cardName': cardName,
        'cardImage': cardImage,
        'setId': setId,
        'mode': mode.id,
        'condition': condition.id,
        if (wantText != null && wantText!.isNotEmpty) 'wantText': wantText,
        if (note != null && note!.isNotEmpty) 'note': note,
        if (wantCards.isNotEmpty)
          'wantCards': wantCards.map((c) => c.toMap()).toList(),
        'status': 'active',
      };

  factory Listing.fromMap(String id, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    return Listing(
      id: id,
      ownerUid: (m['ownerUid'] ?? '') as String,
      ownerName: (m['ownerName'] ?? '') as String,
      ownerAvatar: (m['ownerAvatar'] ?? '') as String,
      cardId: (m['cardId'] ?? '') as String,
      cardName: (m['cardName'] ?? '') as String,
      cardImage: (m['cardImage'] ?? '') as String,
      setId: (m['setId'] ?? '') as String,
      mode: TradeMode.fromId((m['mode'] ?? 'trade') as String),
      condition: CardCondition.fromId((m['condition'] ?? 'good') as String),
      wantText: m['wantText'] as String?,
      note: m['note'] as String?,
      wantCards: ((m['wantCards'] as List?) ?? const [])
          .map((e) => CardRef.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
