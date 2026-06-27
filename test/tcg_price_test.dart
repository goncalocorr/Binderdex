import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/remote/tcg_api.dart';

Map<String, dynamic> _card(Map<String, dynamic> extra) => {
      'id': 'base1-4',
      'name': 'Charizard',
      'number': '4',
      'set': {'id': 'base1'},
      'images': {'small': 's', 'large': 'l'},
      ...extra,
    };

void main() {
  group('cardFromJson — preço Cardmarket (€)', () {
    test('usa trendPrice quando existe', () {
      final c = TcgApi.cardFromJson(_card({
        'cardmarket': {
          'prices': {'trendPrice': 12.5, 'averageSellPrice': 9.9, 'lowPrice': 1.0}
        }
      }));
      expect(c.price, 12.5);
    });

    test('cai para averageSellPrice e depois lowPrice', () {
      expect(
          TcgApi.cardFromJson(_card({
            'cardmarket': {
              'prices': {'averageSellPrice': 9.9}
            }
          })).price,
          9.9);
      expect(
          TcgApi.cardFromJson(_card({
            'cardmarket': {
              'prices': {'lowPrice': 1.0}
            }
          })).price,
          1.0);
    });

    test('null quando não há cardmarket', () {
      expect(TcgApi.cardFromJson(_card({})).price, isNull);
    });
  });
}
