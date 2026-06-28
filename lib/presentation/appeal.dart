import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'providers/app_providers.dart';

/// Folha para o utilizador banido apelar (explicar-se). Escreve em `appeals/` e
/// marca a conta como já-apelou (só pode apelar 1x por ban).
Future<void> showAppealSheet(BuildContext context, WidgetRef ref) {
  final ctrl = TextEditingController();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sctx) {
      final t = AppLocalizations.of(sctx)!;
      return Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(sctx).viewInsets.bottom + 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.appeal, style: Theme.of(sctx).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 5,
              maxLength: 1000,
              decoration: InputDecoration(
                  hintText: t.appealHint, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () async {
                final text = ctrl.text.trim();
                final user = ref.read(authStateProvider).valueOrNull;
                if (text.isEmpty || user == null) return;
                final messenger = ScaffoldMessenger.of(sctx);
                await ref.read(adminServiceProvider).addAppeal(
                    uid: user.uid,
                    name: ref.read(displayNameProvider),
                    text: text);
                await ref.read(profileServiceProvider).markAppealed(user.uid);
                if (sctx.mounted) Navigator.of(sctx).pop();
                messenger.showSnackBar(SnackBar(content: Text(t.appealSent)));
              },
              child: Text(t.send),
            ),
          ],
        ),
      );
    },
  );
}
