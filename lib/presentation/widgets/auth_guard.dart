import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/links.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Verdadeiro se há sessão iniciada com conta real (pode editar a coleção).
/// Utilizadores anónimos (convidados que entraram para poder ler a
/// Comunidade) contam como NÃO autenticados — continuam só-leitura.
bool isSignedIn(WidgetRef ref) {
  final u = ref.read(authStateProvider).valueOrNull;
  return u != null && !u.isAnonymous;
}

/// Restaura o perfil (nome + avatar) da conta a partir da nuvem, ao iniciar
/// sessão. Se a conta já tinha nome, evita que o popup reapareça.
Future<void> syncProfileFromCloud(WidgetRef ref) async {
  final uid = ref.read(authStateProvider).valueOrNull?.uid;
  if (uid == null) return;
  final p = await ref.read(profileServiceProvider).fetch(uid);
  if (p == null) return;
  final prefs = ref.read(prefsProvider);
  if (p.name.isNotEmpty) {
    ref.read(displayNameProvider.notifier).state = p.name;
    await prefs.setString('displayName', p.name);
  }
  if (p.avatar.isNotEmpty) {
    ref.read(avatarProvider.notifier).state = p.avatar;
    await prefs.setString('avatar', p.avatar);
  }
}

/// Garante o consentimento de Termos+Privacidade **por conta** (não por
/// dispositivo): uma conta nova tem sempre de aceitar. Aplica-se a qualquer
/// sessão, incluindo convidado. Deve ser chamado da app já montada, após o
/// login. Se já aceitou (neste dispositivo ou na conta), não faz nada.
Future<void> ensureTermsAccepted(BuildContext context, WidgetRef ref) async {
  final uid = ref.read(authStateProvider).valueOrNull?.uid;
  if (uid == null) return; // sem sessão
  final prefs = ref.read(prefsProvider);
  // 1. Cache local desta conta neste dispositivo (rápido, funciona offline).
  if (prefs.getBool('acceptedTerms_$uid') ?? false) return;
  // 2. Já aceitou na conta (ex.: aceitou noutro dispositivo)?
  if (await ref.read(profileServiceProvider).hasAcceptedTerms(uid)) {
    await prefs.setBool('acceptedTerms_$uid', true);
    return;
  }
  // 3. Ainda não aceitou → gate bloqueante (só sai ao aceitar).
  if (!context.mounted) return;
  final accepted = await _showConsentGate(context);
  if (accepted != true) return; // não aceitou — repete no próximo arranque
  await prefs.setBool('acceptedTerms_$uid', true);
  try {
    await ref.read(profileServiceProvider).setAcceptedTerms(uid);
  } catch (_) {/* offline / regras — fica local, sincroniza depois */}
}

Future<void> _openLegal(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Diálogo de consentimento. Não é dispensável: o único botão ("Aceitar e
/// continuar") só fica ativo com a checkbox marcada.
Future<bool?> _showConsentGate(BuildContext context) {
  final t = AppLocalizations.of(context)!;
  bool checked = false;
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => PopScope(
      canPop: false,
      child: StatefulBuilder(
        builder: (ctx, setState) {
          final cs = Theme.of(ctx).colorScheme;
          return AlertDialog(
            title: Text(t.consentGateTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.consentGateBody,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setState(() => checked = !checked),
                  child: Row(children: [
                    Checkbox(
                      value: checked,
                      onChanged: (v) => setState(() => checked = v ?? false),
                    ),
                    Expanded(
                      child: Text(
                        '${t.acceptPrefix}${t.termsOfUse}${t.consentAnd}${t.privacyPolicy}.',
                        style: Theme.of(ctx).textTheme.bodySmall,
                      ),
                    ),
                  ]),
                ),
                Row(children: [
                  TextButton(
                    onPressed: () => _openLegal(kTermsUrl),
                    child: Text(t.termsOfUse),
                  ),
                  TextButton(
                    onPressed: () => _openLegal(kPrivacyPolicyUrl),
                    child: Text(t.privacyPolicy),
                  ),
                ]),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: checked ? () => Navigator.pop(ctx, true) : null,
                child: Text(t.consentAccept),
              ),
            ],
          );
        },
      ),
    ),
  );
}

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
    // Guarda também na conta (nuvem) para restaurar noutro login/dispositivo.
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      try {
        await ref.read(profileServiceProvider).save(uid, name: name);
      } catch (_) {/* offline ou regras por publicar — fica local */}
    }
  }
}

/// Verdadeiro se a conta NÃO está banida. Se estiver, mostra um aviso e devolve
/// `false` (bloqueia publicar/contactar; as regras também o impedem no servidor).
bool requireNotBanned(BuildContext context, WidgetRef ref) {
  if (!ref.read(isBannedProvider)) return true;
  final t = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(t.accountSuspended)));
  return false;
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
