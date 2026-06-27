import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/remote/push_service.dart';

void main() {
  group('routeForData (toque na notificação → rota)', () {
    test('mensagem → caixa de mensagens', () {
      expect(routeForData({'type': 'message'}), '/messages');
    });

    test('anúncio com carta → ofertas dessa carta', () {
      expect(routeForData({'type': 'listing', 'cardId': 'me4-9'}),
          '/community/card/me4-9');
    });

    test('anúncio sem carta → centro de notificações', () {
      expect(routeForData({'type': 'listing'}), '/notifications');
    });

    test('coleção nova → centro de notificações', () {
      expect(routeForData({'type': 'newSet', 'setId': 'sv8'}), '/notifications');
    });

    test('tipo desconhecido / vazio → centro de notificações', () {
      expect(routeForData({}), '/notifications');
      expect(routeForData({'type': 'qualquer'}), '/notifications');
    });
  });
}
