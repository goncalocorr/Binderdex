import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/chat.dart';
import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/auth_guard.dart';

class ListingDetailScreen extends ConsumerWidget {
  final Listing listing;
  const ListingDetailScreen({super.key, required this.listing});

  String _modeLabel(AppLocalizations t) => switch (listing.mode) {
        TradeMode.trade => t.modeTrade,
        TradeMode.sell => t.modeSell,
        TradeMode.both => t.modeBoth,
      };

  Future<void> _contact(BuildContext context, WidgetRef ref) async {
    if (!requireSignIn(context, ref)) return;
    final meUid = ref.read(authStateProvider).valueOrNull?.uid;
    if (meUid == null) return;
    final convId = await ref.read(chatServiceProvider).openConversation(
          meUid: meUid,
          meName: ref.read(displayNameProvider),
          meAvatar: ref.read(avatarProvider),
          otherUid: listing.ownerUid,
          otherName: listing.ownerName,
          otherAvatar: listing.ownerAvatar,
        );
    if (!context.mounted) return;
    context.push(
      '/chat',
      extra: Conversation(
        id: convId,
        otherUid: listing.ownerUid,
        otherName: listing.ownerName,
        otherAvatar: listing.ownerAvatar,
        lastMessage: '',
        lastSenderUid: '',
        unread: 0,
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(listing.cardName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) async {
              final uid = ref.read(authStateProvider).valueOrNull?.uid;
              if (uid == null) {
                requireSignIn(context, ref);
                return;
              }
              final svc = ref.read(marketServiceProvider);
              if (v == 'report') {
                await svc.report(
                    listingId: listing.id, reporterUid: uid, reason: 'user');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(t.report)));
                }
              } else if (v == 'block') {
                await svc.block(uid, listing.ownerUid);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'report', child: Text(t.report)),
              PopupMenuItem(value: 'block', child: Text(t.block)),
            ],
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (listing.cardImage.isNotEmpty)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                  imageUrl: listing.cardImage, height: 320, fit: BoxFit.contain),
            ),
          ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.person),
          title: Text(listing.ownerName),
          subtitle: Text(_modeLabel(t)),
        ),
        if (listing.wantCards.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(t.whatIWant,
                style: Theme.of(context).textTheme.titleMedium),
          ),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: listing.wantCards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = listing.wantCards[i];
                return GestureDetector(
                  onTap: () => context.push('/card/${c.cardId}'),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: c.cardImage.isEmpty
                        ? Container(width: 78, color: Colors.grey)
                        : CachedNetworkImage(
                            imageUrl: c.cardImage,
                            width: 78,
                            fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
        if (listing.wantText != null && listing.wantText!.isNotEmpty)
          ListTile(title: Text(t.whatIWant), subtitle: Text(listing.wantText!)),
        if (listing.note != null && listing.note!.isNotEmpty)
          ListTile(title: Text(t.noteOptional), subtitle: Text(listing.note!)),
        const SizedBox(height: 16),
        if (listing.ownerUid != ref.watch(authStateProvider).valueOrNull?.uid)
          FilledButton.icon(
            onPressed: () => _contact(context, ref),
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(t.contact),
          ),
      ]),
    );
  }
}
