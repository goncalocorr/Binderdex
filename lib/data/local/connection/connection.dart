// Seleciona a implementação de ligação à base de dados conforme a plataforma:
// - dart.library.io  -> nativo (SQLite via FFI), usado em Android/desktop/testes.
// - dart.library.js_interop -> WASM (sqlite3.wasm + drift worker), usado na web.
export 'connection_unsupported.dart'
    if (dart.library.io) 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';
