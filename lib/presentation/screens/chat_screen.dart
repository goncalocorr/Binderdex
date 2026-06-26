import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Conversation conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  bool _sending = false;

  String get _convId => widget.conversation.id;

  @override
  void initState() {
    super.initState();
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid != null) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => ref.read(chatServiceProvider).markRead(_convId, uid));
    }
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    final text = _input.text.trim();
    if (uid == null || text.isEmpty) return;
    // Aviso a QUEM ENVIA quando vai partilhar um contacto seu (email/telemóvel).
    if (messageHasContact(text)) {
      final t = AppLocalizations.of(context)!;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.warning_amber_rounded),
          content: Text(t.contactWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(t.sendAnyway),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    setState(() => _sending = true);
    _input.clear();
    try {
      await ref.read(chatServiceProvider).sendMessage(
            convId: _convId,
            senderUid: uid,
            otherUid: widget.conversation.otherUid,
            text: text,
          );
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$err')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _block() async {
    final t = AppLocalizations.of(context)!;
    final meUid = ref.read(authStateProvider).valueOrNull?.uid;
    if (meUid == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(t.blockConfirm(widget.conversation.otherName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(t.block),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref
          .read(marketServiceProvider)
          .block(meUid, widget.conversation.otherUid);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.userBlocked)));
        Navigator.of(context).pop();
      }
    } catch (err) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$err')));
      }
    }
  }

  /// Cabeçalho com a carta em negociação (do anúncio que originou o contacto).
  Widget _cardHeader(BuildContext context) {
    final c = widget.conversation;
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHigh,
      child: InkWell(
        onTap: c.cardId.isEmpty ? null : () => context.push('/card/${c.cardId}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            if (c.cardImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                    imageUrl: c.cardImage,
                    width: 34,
                    height: 48,
                    fit: BoxFit.cover,
                    memCacheWidth: 120),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(c.cardName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final meUid = ref.watch(authStateProvider).valueOrNull?.uid;
    final messages = ref.watch(messagesProvider(_convId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.otherName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'block') _block();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'block', child: Text(t.block)),
            ],
          ),
        ],
      ),
      body: Column(children: [
        if (widget.conversation.cardName.isNotEmpty) _cardHeader(context),
        Expanded(
          child: messages.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final m = list[list.length - 1 - i];
                return _Bubble(message: m, mine: m.senderUid == meUid);
              },
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 8, 8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: t.typeMessage,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sending ? null : _send,
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Bubble extends StatelessWidget {
  final ChatMessage message;
  final bool mine;
  const _Bubble({required this.message, required this.mine});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: mine ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message.text,
            style: TextStyle(color: mine ? cs.onPrimary : cs.onSurface)),
      ),
    );
  }
}
