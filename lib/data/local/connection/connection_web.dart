import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

/// Ligação web: SQLite compilado para WebAssembly, persistido pelo browser.
///
/// Requer dois ficheiros em `web/` (ver README):
///   - `sqlite3.wasm`         (corresponde à versão do pacote sqlite3)
///   - `drift_worker.dart.js` (corresponde à versão do pacote drift)
DatabaseConnection openConnection() {
  return DatabaseConnection.delayed(Future(() async {
    final result = await WasmDatabase.open(
      databaseName: 'pokedex',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.dart.js'),
    );
    return result.resolvedExecutor;
  }));
}
