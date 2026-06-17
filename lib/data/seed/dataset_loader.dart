import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../local/database.dart';

/// Lê o dataset incluído (assets/data/pokedex.json) e popula o Drift.
///
/// Na Etapa 2 acrescentamos a verificação leve de versão contra o Firebase
/// Hosting (descarregar dataset mais recente e reidratar).
class DatasetLoader {
  final AppDatabase db;
  DatasetLoader(this.db);

  /// Hidrata o Drift apenas se ainda estiver vazio (primeiro arranque).
  Future<void> ensureSeeded() async {
    if (await db.pokemonCount() > 0) return;

    final raw = await rootBundle.loadString('assets/data/pokedex.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = (data['pokemon'] as List).cast<Map<String, dynamic>>();

    final rows = list
        .map((m) => PokemonTableCompanion.insert(
              id: m['id'] as int,
              name: m['name'] as String,
              nameEn: m['nameEn'] as String,
              type1: m['type1'] as String,
              type2: Value(m['type2'] as String?),
              generation: m['gen'] as int,
              hp: m['hp'] as int,
              attack: m['attack'] as int,
              defense: m['defense'] as int,
              spAttack: m['spAttack'] as int,
              spDefense: m['spDefense'] as int,
              speed: m['speed'] as int,
              description: m['description'] as String,
            ))
        .toList();

    await db.bulkInsertPokemon(rows);
  }
}
