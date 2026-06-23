import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Verdadeiro se há sessão iniciada (pode editar a coleção).
bool isSignedIn(WidgetRef ref) =>
    ref.read(authStateProvider).valueOrNull != null;

/// Mostra o popup do nome se houver sessão e ainda não houver nome. Deve ser
/// chamado da app já montada (não do login, que o gate desmonta ao autenticar).
Future<void> ensureDisplayName(BuildContext context, WidgetRef ref) async {
  if (!isSignedIn(ref)) return;
  if (ref.read(displayNameProvider).trim().isNotEmpty) return;
  final t = AppLocalizations.of(context)!;
  final controller = TextEditingController(
    text: FirebaseAuth.instance.currentUser?.displayName ?? '',
  );
  final name = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: Text(t.askNameTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.askNameBody,
              style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 14),
          TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(hintText: t.guest),
            onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          child: Text(t.continueLabel),
        ),
      ],
    ),
  );
  if (name != null && name.isNotEmpty) {
    ref.read(displayNameProvider.notifier).state = name;
    await ref.read(prefsProvider).setString('displayName', name);
  }
}

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
