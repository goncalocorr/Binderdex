import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Ligação nativa: ficheiro SQLite na pasta de documentos da app.
DatabaseConnection openConnection() {
  return DatabaseConnection(LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'pokedex.sqlite'));
    return NativeDatabase.createInBackground(file);
  }));
}
