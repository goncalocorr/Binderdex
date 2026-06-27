import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/chat.dart';

void main() {
  test('conversationIdFor é determinístico e simétrico (por carta)', () {
    // simétrico nos utilizadores
    expect(conversationIdFor('rui', 'ana', 'base1-4'),
        conversationIdFor('ana', 'rui', 'base1-4'));
    // inclui a carta → 1 chat por carta
    expect(conversationIdFor('ana', 'rui', 'base1-4'), 'ana_rui_base1-4');
    // cartas diferentes → conversas diferentes
    expect(conversationIdFor('ana', 'rui', 'base1-4') !=
        conversationIdFor('ana', 'rui', 'base1-58'), true);
    // sem carta → recai no id por par
    expect(conversationIdFor('ana', 'rui'), 'ana_rui');
  });

  group('messageHasContact', () {
    test('apanha emails', () {
      expect(messageHasContact('escreve para ana@mail.com'), true);
      expect(messageHasContact('o meu mail é rui.silva@gmail.pt!'), true);
    });

    test('apanha números de telemóvel (9+ dígitos)', () {
      expect(messageHasContact('liga 912345678'), true);
      expect(messageHasContact('o meu nº: 91 234 56 78'), true);
      expect(messageHasContact('+351 912345678'), true);
    });

    test('não dá falso-positivo em texto normal', () {
      expect(messageHasContact('tenho 3 cópias desta carta'), false);
      expect(messageHasContact('troco por charizard base 4'), false);
      expect(messageHasContact('quero 2 ou 3 cartas'), false);
    });
  });

  test('ChatMessage.fromMap lê os campos', () {
    final m = ChatMessage.fromMap('m1', {
      'senderUid': 'ana',
      'text': 'olá',
      'createdAt': null,
    });
    expect(m.id, 'm1');
    expect(m.senderUid, 'ana');
    expect(m.text, 'olá');
    expect(m.createdAt.millisecondsSinceEpoch, 0);
  });

  test('Conversation.fromMap resolve o "outro" a partir do meu uid', () {
    final c = Conversation.fromMap(
      'ana_rui',
      {
        'participants': ['ana', 'rui'],
        'names': {'ana': 'Ana', 'rui': 'Rui'},
        'avatars': {'ana': 'a1', 'rui': 'r1'},
        'lastMessage': 'combinado',
        'lastSenderUid': 'ana',
        'unread': {'ana': 0, 'rui': 2},
        'cardId': 'base1-4',
        'cardName': 'Charizard',
        'cardImage': 'img',
        'updatedAt': null,
      },
      'rui',
    );
    expect(c.otherUid, 'ana');
    expect(c.otherName, 'Ana');
    expect(c.unread, 2); // o meu (rui) unread
    expect(c.cardName, 'Charizard'); // carta em negociação
  });
}
