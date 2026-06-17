import 'package:drift/drift.dart';

/// Fallback para plataformas sem dart:io nem js_interop (não deve acontecer).
DatabaseConnection openConnection() =>
    throw UnsupportedError('Plataforma sem implementação de base de dados.');
