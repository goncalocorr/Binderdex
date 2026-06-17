// Gerador do dataset incluído.
//
// Corre na máquina de build (precisa de internet), UMA vez por versão:
//   dart run tool/generate_dataset.dart
//
// Percorre a PokéAPI e escreve assets/data/pokedex.json com todos os Pokémon.
// Nome e lore em PT quando existir; fallback EN.
//
// Ao adicionar Pokémon novos numa futura versão, incrementa [datasetVersion]
// e volta a correr o script (a app usa este número para a atualização leve).

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

const int datasetVersion = 1;

final Dio _dio = Dio(BaseOptions(
  baseUrl: 'https://pokeapi.co/api/v2/',
  connectTimeout: const Duration(seconds: 20),
  receiveTimeout: const Duration(seconds: 20),
));

/// Escolhe o texto na língua 'pt'; se não existir, usa 'en'; senão ''.
String _pickLocalized(List entries, String textField) {
  String find(String lang) {
    for (final e in entries) {
      final m = e as Map;
      if (m['language']?['name'] == lang) return (m[textField] as String);
    }
    return '';
  }

  final pt = find('pt');
  if (pt.isNotEmpty) return pt;
  return find('en');
}

/// .../generation/3/ -> 3
int _genFromUrl(String url) {
  final parts = url.split('/').where((p) => p.isNotEmpty).toList();
  return int.parse(parts.last);
}

Future<Map<String, dynamic>> _build(int id) async {
  final p = (await _dio.get('pokemon/$id')).data as Map<String, dynamic>;
  final s =
      (await _dio.get('pokemon-species/$id')).data as Map<String, dynamic>;

  final types = (p['types'] as List)
    ..sort((a, b) => (a['slot'] as int).compareTo(b['slot'] as int));
  final stats = <String, int>{
    for (final st in (p['stats'] as List))
      st['stat']['name'] as String: st['base_stat'] as int,
  };

  final namePt = _pickLocalized(s['names'] as List, 'name');
  final lore = _pickLocalized(s['flavor_text_entries'] as List, 'flavor_text')
      .replaceAll('\n', ' ')
      .replaceAll('\f', ' ')
      .replaceAll('­', '') // soft hyphen
      .trim();

  return {
    'id': id,
    'name': namePt.isNotEmpty ? namePt : (p['name'] as String),
    'nameEn': p['name'],
    'type1': types[0]['type']['name'],
    'type2': types.length > 1 ? types[1]['type']['name'] : null,
    'gen': _genFromUrl(s['generation']['url'] as String),
    'hp': stats['hp'],
    'attack': stats['attack'],
    'defense': stats['defense'],
    'spAttack': stats['special-attack'],
    'spDefense': stats['special-defense'],
    'speed': stats['speed'],
    'description': lore,
  };
}

Future<void> main() async {
  stdout.writeln('A obter a lista de Pokémon...');
  final list =
      (await _dio.get('pokemon?limit=100000')).data['results'] as List;
  final total = list.length;
  stdout.writeln('Total na PokéAPI: $total. A construir o dataset...');

  final out = <Map<String, dynamic>>[];
  for (var i = 0; i < total; i++) {
    final id = i + 1;
    try {
      out.add(await _build(id));
    } catch (e) {
      stderr.writeln('Falhou #$id: $e');
    }
    if (id % 50 == 0) stdout.writeln('  $id / $total');
    await Future.delayed(const Duration(milliseconds: 40)); // throttle gentil
  }

  final json = {
    'datasetVersion': datasetVersion,
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'pokemon': out,
  };

  await Directory('assets/data').create(recursive: true);
  await File('assets/data/pokedex.json')
      .writeAsString(const JsonEncoder.withIndent('  ').convert(json));

  stdout.writeln('OK: ${out.length} Pokémon -> assets/data/pokedex.json');
}
