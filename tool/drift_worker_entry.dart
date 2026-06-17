// Ponto de entrada do worker do Drift para a web.
// Compilado para web/drift_worker.dart.js com:
//   dart compile js -O4 -o web/drift_worker.dart.js tool/drift_worker_entry.dart
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
