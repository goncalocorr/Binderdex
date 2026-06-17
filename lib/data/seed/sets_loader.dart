import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../local/database.dart';

/// Carrega a lista de sets incluída (assets/data/tcg_sets.json) para o Drift,
/// para que o ecrã inicial abra offline. As cartas são buscadas on-demand.
class SetsLoader {
  final AppDatabase db;
  SetsLoader(this.db);

  Future<void> ensureSeeded() async {
    if (await db.setCount() > 0) return;

    final raw = await rootBundle.loadString('assets/data/tcg_sets.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final list = (data['sets'] as List).cast<Map<String, dynamic>>();

    final rows = list
        .map((m) => CardSetsCompanion.insert(
              id: m['id'] as String,
              name: m['name'] as String? ?? '',
              series: m['series'] as String? ?? '',
              printedTotal: m['printedTotal'] as int? ?? 0,
              total: m['total'] as int? ?? 0,
              releaseDate: m['releaseDate'] as String? ?? '',
              symbolUrl: m['symbolUrl'] as String? ?? '',
              logoUrl: m['logoUrl'] as String? ?? '',
            ))
        .toList();

    await db.bulkInsertSets(rows);
  }
}
