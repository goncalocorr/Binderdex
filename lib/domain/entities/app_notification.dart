import 'card_set.dart';
import 'chat.dart';
import 'listing.dart';

enum NotifType { message, wishlist, newSet }

/// Uma notificação no centro no-app. Guarda o objeto-fonte; o ecrã formata o
/// texto (localizado) a partir do tipo.
class AppNotification {
  final NotifType type;
  final DateTime at;
  final Conversation? conversation;
  final Listing? listing;
  final CardSet? set;

  AppNotification.message(Conversation c)
      : type = NotifType.message,
        conversation = c,
        listing = null,
        set = null,
        at = c.updatedAt;

  AppNotification.wishlist(Listing l)
      : type = NotifType.wishlist,
        listing = l,
        conversation = null,
        set = null,
        at = l.createdAt;

  AppNotification.newSet(CardSet s)
      : type = NotifType.newSet,
        set = s,
        conversation = null,
        listing = null,
        at = _parseDate(s.releaseDate);
}

DateTime _parseDate(String s) {
  try {
    return DateTime.parse(s.replaceAll('/', '-'));
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

/// Sets que ainda não foram vistos. `seen == null` (não inicializado) → nenhum
/// é "novo" (evita inundar com todos os sets na primeira vez).
List<CardSet> newSetsFrom(List<CardSet> all, Set<String>? seen) =>
    seen == null ? const [] : all.where((s) => !seen.contains(s.id)).toList();

/// Anúncios da wishlist que valem como notificação: não são meus nem de
/// utilizadores bloqueados.
List<Listing> wishlistMatchesFrom(
        List<Listing> listings, String? meUid, Set<String> blocked) =>
    listings
        .where((l) => l.ownerUid != meUid && !blocked.contains(l.ownerUid))
        .toList();
