import 'package:dio/dio.dart';

import '../../core/config/tcg_config.dart';
import '../../domain/entities/card_set.dart';
import '../../domain/entities/tcg_card.dart';

/// Extrai os dígitos de um número de carta para ordenação (ex.: "TG01" -> 1).
int numberSortKey(String number) {
  final m = RegExp(r'\d+').firstMatch(number);
  return m == null ? 99999 : int.parse(m.group(0)!);
}

/// Cliente da Pokémon TCG API (apenas leitura).
class TcgApi {
  final Dio _dio;

  TcgApi([Dio? dio])
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: TcgConfig.baseUrl,
              headers: TcgConfig.apiKey.isEmpty
                  ? null
                  : {'X-Api-Key': TcgConfig.apiKey},
            ));

  Future<List<CardSet>> fetchSets() async {
    final all = <CardSet>[];
    var page = 1;
    while (true) {
      final res = await _dio.get('/sets', queryParameters: {
        'page': page,
        'pageSize': 250,
        'orderBy': 'releaseDate',
      });
      final data = (res.data['data'] as List).cast<Map<String, dynamic>>();
      all.addAll(data.map(setFromJson));
      if (data.length < 250) break;
      page++;
    }
    return all;
  }

  Future<List<TcgCard>> fetchCardsForSet(String setId) async {
    final all = <TcgCard>[];
    var page = 1;
    while (true) {
      final res = await _dio.get('/cards', queryParameters: {
        'q': 'set.id:$setId',
        'page': page,
        'pageSize': 250,
        'select':
            'id,name,number,rarity,supertype,types,images,set,hp,attacks,cardmarket',
        'orderBy': 'number',
      });
      final data = (res.data['data'] as List).cast<Map<String, dynamic>>();
      all.addAll(data.map(cardFromJson));
      if (data.length < 250) break;
      page++;
    }
    return all;
  }

  static CardSet setFromJson(Map<String, dynamic> j) => CardSet(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        series: j['series'] as String? ?? '',
        printedTotal: j['printedTotal'] as int? ?? 0,
        total: j['total'] as int? ?? 0,
        releaseDate: j['releaseDate'] as String? ?? '',
        symbolUrl: (j['images']?['symbol'] as String?) ?? '',
        logoUrl: (j['images']?['logo'] as String?) ?? '',
      );

  static TcgCard cardFromJson(Map<String, dynamic> j) {
    final number = (j['number'] ?? '').toString();
    final types = (j['types'] as List?)?.cast<String>();
    final attacks = (j['attacks'] as List?)?.cast<Map<String, dynamic>>();
    int? atk;
    if (attacks != null && attacks.isNotEmpty) {
      final dmg = (attacks.first['damage'] ?? '').toString();
      final m = RegExp(r'\d+').firstMatch(dmg);
      if (m != null) atk = int.parse(m.group(0)!);
    }
    // Preço Cardmarket (€): tendência → média → mínimo (o que existir).
    final cmPrices = j['cardmarket']?['prices'] as Map<String, dynamic>?;
    final price = _toDouble(cmPrices?['trendPrice']) ??
        _toDouble(cmPrices?['averageSellPrice']) ??
        _toDouble(cmPrices?['lowPrice']);
    return TcgCard(
      id: j['id'] as String,
      setId: (j['set']?['id'] as String?) ?? '',
      name: j['name'] as String? ?? '',
      number: number,
      numberSort: numberSortKey(number),
      rarity: j['rarity'] as String?,
      supertype: j['supertype'] as String?,
      type: (types != null && types.isNotEmpty) ? types.first : null,
      imageSmall: (j['images']?['small'] as String?) ?? '',
      imageLarge: (j['images']?['large'] as String?) ?? '',
      hp: int.tryParse((j['hp'] ?? '').toString()),
      atk: atk,
      price: price,
    );
  }

  static double? _toDouble(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}');
}
