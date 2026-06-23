import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Verdadeiro se há sessão iniciada (pode editar a coleção).
bool isSignedIn(WidgetRef ref) =>
    ref.read(authStateProvider).valueOrNull != null;

/// Garante que o utilizador pode editar. Se for convidado (sem sessão), mostra
/// um aviso com botão para iniciar sessão / criar conta e devolve `false`.
bool requireSignIn(BuildContext context, WidgetRef ref) {
  if (isSignedIn(ref)) return true;
  final t = AppLocalizations.of(context)!;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.lock_outline),
      title: Text(t.loginRequiredTitle),
      content: Text(t.loginRequiredBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/login');
          },
          child: Text(t.loginOrCreate),
        ),
      ],
    ),
  );
  return false;
}
