// Gera a lista de sets (coleções) incluída na app.
//
// Corre na máquina de build (precisa de internet), uma vez por versão:
//   dart run tool/generate_tcg_sets.dart
//
// As cartas de cada set NÃO vão no dataset — são buscadas on-demand à API e
// cacheadas no Drift quando o set é aberto.
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

final Dio _dio = Dio(BaseOptions(baseUrl: 'https://api.pokemontcg.io/v2'));

Future<void> main() async {
  final all = <Map<String, dynamic>>[];
  var page = 1;
  while (true) {
    final res = await _dio.get('/sets', queryParameters: {
      'page': page,
      'pageSize': 250,
      'orderBy': 'releaseDate',
    });
    final data = (res.data['data'] as List).cast<Map<String, dynamic>>();
    for (final j in data) {
      all.add({
        'id': j['id'],
        'name': j['name'] ?? '',
        'series': j['series'] ?? '',
        'printedTotal': j['printedTotal'] ?? 0,
        'total': j['total'] ?? 0,
        'releaseDate': j['releaseDate'] ?? '',
        'symbolUrl': j['images']?['symbol'] ?? '',
        'logoUrl': j['images']?['logo'] ?? '',
      });
    }
    stdout.writeln('página $page: ${data.length} sets');
    if (data.length < 250) break;
    page++;
  }

  final out = {
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'sets': all,
  };
  await Directory('assets/data').create(recursive: true);
  await File('assets/data/tcg_sets.json')
      .writeAsString(const JsonEncoder().convert(out));
  stdout.writeln('OK: ${all.length} sets -> assets/data/tcg_sets.json');
}
