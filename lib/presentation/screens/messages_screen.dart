import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/dex_ui.dart';

/// Caixa de mensagens: lista das minhas conversas, mais recentes primeiro.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final convos = ref.watch(conversationsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.messages)),
      body: convos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? EmptyState(
                icon: Icons.forum_outlined,
                title: t.noConversations,
                description: t.noConversationsBody,
              )
            : ListView.separated(
                itemCount: list.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) => _ConvTile(conversation: list[i]),
              ),
      ),
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
      trailing: hasUnread
          ? Badge(label: Text('${c.unread}'))
          : null,
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
