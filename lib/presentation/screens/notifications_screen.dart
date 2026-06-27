import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

/// Centro de notificações no-app. Tira um "instantâneo" ao abrir (para os itens
/// não desaparecerem ao marcar como vistos) e marca tudo como visto.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<AppNotification>? _items;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _items = ref.read(notificationsProvider));
      _markSeen();
    });
  }

  void _markSeen() {
    final prefs = ref.read(prefsProvider);
    final now = DateTime.now();
    ref.read(lastSeenNotifProvider.notifier).state = now;
    prefs.setInt('lastSeenNotif', now.millisecondsSinceEpoch);
    final ids = (ref.read(setsListProvider).valueOrNull ?? const [])
        .map((s) => s.set.id)
        .toSet();
    if (ids.isNotEmpty) {
      ref.read(seenSetsProvider.notifier).state = ids;
      prefs.setStringList('seenSets', ids.toList());
    }
  }

  String _modeLabel(AppLocalizations t, TradeMode m) => switch (m) {
        TradeMode.trade => t.modeTrade,
        TradeMode.sell => t.modeSell,
        TradeMode.both => t.modeBoth,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = _items;
    return Scaffold(
      appBar: AppBar(title: Text(t.notifications)),
      body: items == null
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? Center(child: Text(t.noNotifications))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = items[i];
                    return Dismissible(
                      key: ValueKey(n.id),
                      direction: DismissDirection.horizontal,
                      background: _swipeBg(Alignment.centerLeft),
                      secondaryBackground: _swipeBg(Alignment.centerRight),
                      onDismissed: (_) => _dismiss(t, n),
                      child: _tile(context, t, n),
                    );
                  },
                ),
    );
  }

  Widget _swipeBg(Alignment a) => Container(
        color: Colors.blueGrey,
        alignment: a,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
      );

  /// "Limpa" (dispensa) uma notificação: guarda o id e tira-a da lista.
  void _dismiss(AppLocalizations t, AppNotification n) {
    final set = {...ref.read(dismissedNotifsProvider), n.id};
    _persistDismissed(set);
    setState(() => _items = [...?_items]..removeWhere((x) => x.id == n.id));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(t.notifCleared),
        action: SnackBarAction(label: t.undo, onPressed: () => _undo(n.id)),
      ));
  }

  void _undo(String id) {
    final set = {...ref.read(dismissedNotifsProvider)}..remove(id);
    _persistDismissed(set);
    // Volta a tirar o instantâneo (a lista ao vivo já a inclui de novo).
    setState(() => _items = ref.read(notificationsProvider));
  }

  void _persistDismissed(Set<String> set) {
    ref.read(dismissedNotifsProvider.notifier).state = set;
    ref.read(prefsProvider).setStringList('dismissedNotifs', set.toList());
  }

  Widget _tile(BuildContext context, AppLocalizations t, AppNotification n) {
    switch (n.type) {
      case NotifType.message:
        final c = n.conversation!;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: c.otherAvatar.isEmpty
                ? null
                : AssetImage('assets/avatars/${c.otherAvatar}.png'),
            child: c.otherAvatar.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(t.notifNewMessage),
          subtitle: Text('${c.otherName}: ${c.lastMessage}',
              maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => context.push('/chat', extra: c),
        );
      case NotifType.wishlist:
        final l = n.listing!;
        return ListTile(
          leading: _thumb(l.cardImage, Icons.style),
          title: Text(t.notifWishlistAvailable),
          subtitle: Text('${l.cardName} · ${l.ownerName} · ${_modeLabel(t, l.mode)}',
              maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => context.push('/community/card/${l.cardId}'),
        );
      case NotifType.newSet:
        final s = n.set!;
        return ListTile(
          leading: _thumb(s.logoUrl, Icons.collections_bookmark, fit: BoxFit.contain),
          title: Text(t.notifNewCollection),
          subtitle: Text(s.name,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () => context.push('/set/${s.id}'),
        );
    }
  }

  Widget _thumb(String url, IconData fallback, {BoxFit fit = BoxFit.cover}) =>
      SizedBox(
        width: 40,
        height: 40,
        child: url.isEmpty
            ? Icon(fallback)
            : ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                    imageUrl: url, fit: fit, memCacheWidth: 120),
              ),
      );
}
