import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/admin_service.dart';
import '../../domain/entities/chat.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Conversa entre denunciante e denunciado, **só de leitura** (para o admin
/// diagnosticar a denúncia). Usa a carta da denúncia para achar a conversa exata.
class AdminChatScreen extends ConsumerWidget {
  final Report report;
  const AdminChatScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final convId = conversationIdFor(
        report.reporterUid, report.reportedUid, report.cardId);
    final msgs = ref.watch(messagesProvider(convId));
    final name =
        report.reportedName.isEmpty ? report.reportedUid : report.reportedName;

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: msgs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.noConversation))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: list.length,
                itemBuilder: (_, i) => _Bubble(
                  message: list[i],
                  // Denunciante à direita; denunciado à esquerda.
                  fromReporter: list[i].senderUid == report.reporterUid,
                  label: list[i].senderUid == report.reporterUid
                      ? t.reporterLabel
                      : t.reportedLabel,
                ),
              ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool fromReporter;
  final String label;
  const _Bubble({
    required this.message,
    required this.fromReporter,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final align = fromReporter ? Alignment.centerRight : Alignment.centerLeft;
    final color = fromReporter ? cs.primaryContainer : cs.surfaceContainerHigh;
    return Align(
      alignment: align,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 2),
            Text(message.text),
          ],
        ),
      ),
    );
  }
}
