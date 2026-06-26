import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final meUid = ref.watch(authStateProvider).valueOrNull?.uid;
    final messages = ref.watch(messagesProvider(_convId));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.otherName),
        actions: [
          IconButton(
            tooltip: t.block,
            icon: const Icon(Icons.block),
            onPressed: () async {
              if (meUid == null) return;
              await ref
                  .read(marketServiceProvider)
                  .block(meUid, widget.conversation.otherUid);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Column(children: [
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
                return _Bubble(message: m, mine: m.senderUid == meUid, t: t);
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
  final AppLocalizations t;
  const _Bubble({required this.message, required this.mine, required this.t});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Aviso de burla só nas mensagens RECEBIDAS com contacto.
    final warn = !mine && messageHasContact(message.text);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: mine ? cs.primary : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(message.text,
                style: TextStyle(color: mine ? cs.onPrimary : cs.onSurface)),
          ),
          if (warn)
            Container(
              margin: const EdgeInsets.only(bottom: 6, right: 24),
              padding: const EdgeInsets.all(8),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.warning_amber_rounded,
                    size: 18, color: cs.onErrorContainer),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(t.contactWarning,
                      style: TextStyle(
                          fontSize: 12, color: cs.onErrorContainer)),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
