import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';

/// Caixa de mensagens: lista das minhas conversas, mais recentes primeiro.
/// Deslizar → arquivar (direita) / apagar (esquerda). Alternar Arquivadas.
class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final convos = ref.watch(
        _showArchived ? archivedConversationsProvider : conversationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_showArchived ? t.archivedTitle : t.messages),
        actions: [
          IconButton(
            tooltip: _showArchived ? t.messages : t.archivedTitle,
            icon: Icon(_showArchived ? Icons.inbox_outlined : Icons.archive_outlined),
            onPressed: () => setState(() => _showArchived = !_showArchived),
          ),
        ],
      ),
      body: convos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return _showArchived
                ? Center(child: Text(t.noArchived))
                : EmptyState(
                    imageAsset: 'assets/messages_empty.png',
                    icon: Icons.forum_outlined,
                    title: t.noConversations,
                    description: t.noConversationsBody,
                  );
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _DismissibleConv(conversation: list[i]),
          );
        },
      ),
    );
  }
}

class _DismissibleConv extends ConsumerWidget {
  final Conversation conversation;
  const _DismissibleConv({required this.conversation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final c = conversation;
    return Dismissible(
      key: ValueKey(c.id),
      // Deslizar para a direita → arquivar/desarquivar.
      background: Container(
        color: Colors.blueGrey,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.archive, color: Colors.white),
          const SizedBox(width: 8),
          Text(c.archived ? t.unarchive : t.archive,
              style: const TextStyle(color: Colors.white)),
        ]),
      ),
      // Deslizar para a esquerda → apagar.
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(t.deleteConversation,
              style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          const Icon(Icons.delete, color: Colors.white),
        ]),
      ),
      confirmDismiss: (dir) async {
        final uid = ref.read(authStateProvider).valueOrNull?.uid;
        if (uid == null) return false;
        final svc = ref.read(chatServiceProvider);
        if (dir == DismissDirection.endToStart) {
          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              content: Text(t.deleteConversationConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(t.deleteConversation),
                ),
              ],
            ),
          );
          if (ok == true) await svc.clearConversation(c.id, uid);
        } else {
          await svc.setArchived(c.id, uid, !c.archived);
        }
        return false; // a lista atualiza-se sozinha pelo stream
      },
      child: _ConvTile(conversation: c),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final Conversation conversation;
  const _ConvTile({required this.conversation});

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final hasUnread = c.unread > 0;
    return ListTile(
      leading: _Avatar(avatar: c.otherAvatar),
      title: Text(c.otherName.isEmpty ? '—' : c.otherName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(c.lastMessage,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: hasUnread ? Badge(label: Text('${c.unread}')) : null,
      onTap: () => context.push('/chat', extra: c),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String avatar;
  const _Avatar({required this.avatar});
  @override
  Widget build(BuildContext context) => CircleAvatar(
        backgroundImage:
            avatar.isEmpty ? null : AssetImage('assets/avatars/$avatar.png'),
        child: avatar.isEmpty ? const Icon(Icons.person) : null,
      );
}
