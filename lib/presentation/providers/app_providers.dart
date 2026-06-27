import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/router/root_navigator.dart';
import '../../data/local/database.dart';
import '../../data/remote/auth_service.dart';
import '../../data/remote/chat_service.dart';
import '../../data/remote/market_service.dart';
import '../../data/remote/profile_service.dart';
import '../../data/remote/push_service.dart';
import '../../data/remote/sync_service.dart';
import '../../data/remote/tcg_api.dart';
import '../../data/repositories/cards_repository.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/sets_repository.dart';
import '../../domain/entities/card_filter.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/entities/card_set.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/listing.dart';
import '../../domain/entities/progress.dart';
import '../../domain/entities/tcg_card.dart';
import '../../domain/entities/trade_match.dart';
import '../../domain/entities/user_card_entry.dart';

// --- Infra ---
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final tcgApiProvider = Provider<TcgApi>((ref) => TcgApi());

final setsRepositoryProvider =
    Provider((ref) => SetsRepository(ref.watch(databaseProvider)));
final cardsRepositoryProvider = Provider((ref) =>
    CardsRepository(ref.watch(databaseProvider), ref.watch(tcgApiProvider)));
final collectionRepositoryProvider =
    Provider((ref) => CollectionRepository(ref.watch(databaseProvider)));

// --- Autenticação (Etapa 2) ---
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// Perfil na nuvem (nome + avatar).
final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

/// Modo convidado (entrou sem conta para ver o catálogo). Não persiste — cada
/// arranque a frio volta a pedir login. Convidado não pode editar a coleção.
final guestModeProvider = StateProvider<bool>((ref) => false);

/// Separador selecionado na navegação inferior (Início/Coleções/Binder/Perfil).
/// Em provider para o Home poder saltar para outros separadores.
final navIndexProvider = StateProvider<int>((ref) => 0);
final authStateProvider = StreamProvider<User?>(
    (ref) => ref.watch(authServiceProvider).authStateChanges());

/// Sincronização: arranca ao iniciar sessão, pára ao terminar.
final syncServiceProvider = Provider<SyncService>((ref) {
  final svc = SyncService(ref.watch(databaseProvider));
  ref.onDispose(svc.stop);
  ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
    final user = next.valueOrNull;
    // Convidados anónimos não sincronizam — evita criar dados na nuvem
    // para sessões que existem só para poder LER a Comunidade.
    if (user != null && !user.isAnonymous) {
      svc.start(user.uid);
    } else {
      svc.stop();
    }
  }, fireImmediately: true);
  return svc;
});

/// Push (FCM): regista o token e encaminha as notificações. Arranca ao iniciar
/// sessão com conta (convidados anónimos não recebem push). Ver push_service.dart.
final pushServiceProvider = Provider<PushService>((ref) {
  void open(String route) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx != null) {
      try {
        ctx.push(route);
      } catch (_) {/* rota inexistente — ignora */}
    }
  }

  // Liga a navegação global (toque numa notificação de primeiro plano).
  pushNavigate = open;

  final svc = PushService(profile: ref.watch(profileServiceProvider), onOpen: open);
  ref.listen<AsyncValue<User?>>(authStateProvider, (_, next) {
    final user = next.valueOrNull;
    if (user != null && !user.isAnonymous) {
      svc.start(user.uid);
    } else {
      svc.stop();
    }
  }, fireImmediately: true);
  return svc;
});

// --- Sets (ecrã inicial) ---
final setsListProvider =
    StreamProvider<List<SetProgress>>((ref) => ref.watch(setsRepositoryProvider).watchSets());

/// Pesquisa de sets (filtrada em memória — a lista de sets é pequena, ~160).
final setSearchProvider = StateProvider<String>((_) => '');

final setByIdProvider = FutureProvider.family<CardSet?, String>(
    (ref, id) => ref.watch(setsRepositoryProvider).byId(id));

/// Sincroniza as cartas de um set (busca à API se necessário).
final setSyncProvider = FutureProvider.family<void, String>(
    (ref, setId) => ref.watch(cardsRepositoryProvider).ensureSetSynced(setId));

// --- Cartas de um set ---
/// Filtro por set (estado separado para cada set aberto).
final cardFilterProvider =
    StateProvider.family<CardFilter, String>((_, __) => const CardFilter());

final cardsListProvider =
    StreamProvider.family<List<CardItem>, String>((ref, setId) {
  final f = ref.watch(cardFilterProvider(setId));
  return ref.watch(cardsRepositoryProvider).watchCards(setId, f);
});

final raritiesProvider = FutureProvider.family<List<String>, String>(
    (ref, setId) => ref.watch(cardsRepositoryProvider).rarities(setId));

/// Cartas em falta de um set (para a folha de adição rápida).
final missingCardsProvider =
    StreamProvider.family<List<CardItem>, String>((ref, setId) {
  return ref.watch(cardsRepositoryProvider).watchCards(
        setId,
        const CardFilter(status: CardStatusFilter.missing),
      );
});

// --- Carta individual / coleção ---
final cardByIdProvider = FutureProvider.family<TcgCard?, String>(
    (ref, id) => ref.watch(cardsRepositoryProvider).byId(id));

final entryProvider = StreamProvider.family<UserCardEntry, String>(
    (ref, id) => ref.watch(collectionRepositoryProvider).watchEntry(id));

// --- Wishlist (lista de desejos) ---
final wishlistProvider = StreamProvider<List<CardItem>>(
    (ref) => ref.watch(cardsRepositoryProvider).watchWishlist());
final wishlistCountProvider = StreamProvider<int>(
    (ref) => ref.watch(cardsRepositoryProvider).wishlistCount());

// --- Trocas perfeitas (premium, limitadas por nível) ---
/// Ids das minhas cartas repetidas — o que posso DAR numa troca.
final myDuplicateIdsProvider = FutureProvider<Set<String>>((ref) async {
  final dupes = await ref.watch(ownedCardsProvider(true).future);
  return dupes.map((o) => o.card.id).toSet();
});

/// Trocas perfeitas (instantâneo): anúncios que oferecem o que quero (wishlist)
/// e cujo dono quer algo que tenho repetido. Ver [perfectTradesFrom].
final tradeMatchesProvider = FutureProvider<List<TradeMatch>>((ref) async {
  final me = _uid(ref);
  if (me == null) return const [];
  final wishlist = ref.watch(wishlistProvider).valueOrNull ?? const [];
  final wishIds = wishlist.map((c) => c.card.id).toList();
  if (wishIds.isEmpty) return const [];
  final dupes = await ref.watch(myDuplicateIdsProvider.future);
  if (dupes.isEmpty) return const [];
  final blocked =
      ref.watch(blockedUidsProvider).valueOrNull ?? const <String>{};
  final listings =
      await ref.watch(marketServiceProvider).fetchListingsForCards(wishIds);
  return perfectTradesFrom(
    wishlistListings: listings,
    myDuplicateIds: dupes,
    meUid: me,
    blocked: blocked,
  );
});

/// Nº total de trocas perfeitas (teaser/contador — independente do limite).
final tradeMatchCountProvider = Provider<int>((ref) =>
    ref.watch(tradeMatchesProvider).valueOrNull?.length ?? 0);

// --- Progresso / Estatísticas ---
final globalProgressProvider = FutureProvider<ProgressStats>((ref) {
  ref.watch(setsListProvider); // recalcula quando a coleção muda
  return ref.watch(collectionRepositoryProvider).globalProgress();
});

final statsCountsProvider =
    FutureProvider<({int setsDone, int holos, int dupes})>((ref) {
  ref.watch(setsListProvider);
  return ref.watch(collectionRepositoryProvider).counts();
});

/// Contagens (total/possuídas) de um set — para as abas.
final setCountsProvider =
    StreamProvider.family<({int total, int owned}), String>(
        (ref, setId) => ref.watch(cardsRepositoryProvider).setCounts(setId));

/// Cartas possuídas por tipo numa coleção — para os detalhes do set.
/// Recalcula quando a coleção do set muda (via [setCountsProvider]).
final setByTypeProvider =
    FutureProvider.family<List<({String type, int owned})>, String>(
        (ref, setId) {
  ref.watch(setCountsProvider(setId));
  return ref.watch(collectionRepositoryProvider).ownedByTypeInSet(setId);
});

// --- Pesquisa global ---
final searchQueryProvider = StateProvider<String>((_) => '');
final searchTypesProvider = StateProvider<List<String>>((_) => const []);
final searchStatusProvider =
    StateProvider<CardStatusFilter>((_) => CardStatusFilter.all);

final searchResultsProvider = StreamProvider<List<CardItem>>((ref) {
  final q = ref.watch(searchQueryProvider);
  final types = ref.watch(searchTypesProvider);
  final status = ref.watch(searchStatusProvider);
  return ref.watch(cardsRepositoryProvider).searchAll(
        query: q,
        types: types,
        status: status,
      );
});

// --- Preferências de UI (persistidas em shared_preferences) ---
/// Instância de SharedPreferences (substituída no main com a real).
final prefsProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('prefsProvider definido no main'));

final themeModeProvider = StateProvider<int>((_) => 0); // 0=sistema,1=claro,2=escuro
final localeProvider = StateProvider<String?>((_) => null);

/// Nome de apresentação local (perfil). Vazio = convidado.
final displayNameProvider = StateProvider<String>((_) => '');

/// Avatar escolhido (id do ficheiro, ex.: "avatar_03"). Vazio = inicial.
final avatarProvider = StateProvider<String>((_) => '');

/// Se o ecrã de boas-vindas já foi visto (mostra-se só uma vez).
final onboardingDoneProvider = StateProvider<bool>((_) => false);

// --- Comunidade / marketplace ---
final marketServiceProvider = Provider<MarketService>((ref) => MarketService());

String? _uid(Ref ref) => ref.watch(authStateProvider).valueOrNull?.uid;

final blockedUidsProvider = StreamProvider<Set<String>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(<String>{});
  return ref.watch(marketServiceProvider).watchBlocked(uid);
});

/// Lista de utilizadores bloqueados (com nome/avatar) — para o ecrã de gestão.
final blockedUsersProvider = StreamProvider<List<BlockedUser>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const <BlockedUser>[]);
  return ref.watch(marketServiceProvider).watchBlockedUsers(uid);
});

final listingsForCardProvider =
    StreamProvider.family<List<Listing>, String>((ref, cardId) {
  final blocked = ref.watch(blockedUidsProvider).valueOrNull ?? const <String>{};
  return ref
      .watch(marketServiceProvider)
      .watchForCard(cardId)
      .map((list) => list.where((l) => !blocked.contains(l.ownerUid)).toList());
});

final myListingsProvider = StreamProvider<List<Listing>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const <Listing>[]);
  return ref.watch(marketServiceProvider).watchMine(uid);
});

final activeListingsCountProvider = Provider<int>(
    (ref) => ref.watch(myListingsProvider).valueOrNull?.length ?? 0);

final marketTierProvider = StreamProvider<int>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((d) => (d.data()?['marketTier'] ?? 0) as int);
});

final communityDisclaimerSeenProvider = StateProvider<bool>(
    (ref) => ref.read(prefsProvider).getBool('communityDisclaimerSeen') ?? false);

// --- Chat (Fase 2) ---
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

final _allConversationsProvider = StreamProvider<List<Conversation>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(const <Conversation>[]);
  final blocked = ref.watch(blockedUidsProvider).valueOrNull ?? const <String>{};
  return ref.watch(chatServiceProvider).watchConversations(uid).map(
      (list) => list.where((c) => !blocked.contains(c.otherUid)).toList());
});

/// Caixa principal: exclui arquivadas e apagadas (por mim).
final conversationsProvider = Provider<AsyncValue<List<Conversation>>>((ref) =>
    ref.watch(_allConversationsProvider).whenData((list) =>
        list.where((c) => !c.archived && !c.isCleared).toList()));

/// Conversas arquivadas (por mim).
final archivedConversationsProvider =
    Provider<AsyncValue<List<Conversation>>>((ref) =>
        ref.watch(_allConversationsProvider).whenData((list) =>
            list.where((c) => c.archived && !c.isCleared).toList()));

final messagesProvider =
    StreamProvider.family<List<ChatMessage>, String>((ref, convId) =>
        ref.watch(chatServiceProvider).watchMessages(convId));

/// Total de mensagens não-lidas (para o badge na Comunidade).
final unreadTotalProvider = Provider<int>((ref) {
  final convos = ref.watch(conversationsProvider).valueOrNull ?? const [];
  return convos.fold<int>(0, (a, c) => a + c.unread);
});

// --- Notificações (no-app) ---
/// Anúncios ativos das cartas da minha wishlist (para a notificação in-app de
/// "carta disponível"). A wishlist (coração) é a fonte única.
final watchedCardListingsProvider = StreamProvider<List<Listing>>((ref) {
  final wishlist = ref.watch(wishlistProvider).valueOrNull ?? const [];
  final ids = wishlist.map((c) => c.card.id).toList();
  if (ids.isEmpty) return Stream.value(const <Listing>[]);
  return ref.watch(marketServiceProvider).watchListingsForCards(ids);
});

/// Mantém `users/{uid}.notifyCards` igual à wishlist, para o servidor enviar
/// push quando uma carta desejada é anunciada. Espelha sempre que a wishlist
/// muda (e ao arrancar, fazendo o backfill). Só contas (não anónimos).
final wishlistWatchSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<List<CardItem>>>(wishlistProvider, (_, next) {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null || user.isAnonymous) return;
    final ids = (next.valueOrNull ?? const <CardItem>[])
        .map((c) => c.card.id)
        .toSet();
    ref.read(profileServiceProvider).setNotifyCards(user.uid, ids);
  }, fireImmediately: true);
});

/// Sets já vistos (para detetar coleções novas). null = não inicializado.
final seenSetsProvider = StateProvider<Set<String>?>((ref) {
  final l = ref.read(prefsProvider).getStringList('seenSets');
  return l?.toSet();
});

/// Última vez que o utilizador abriu o centro de notificações.
final lastSeenNotifProvider = StateProvider<DateTime>((ref) =>
    DateTime.fromMillisecondsSinceEpoch(
        ref.read(prefsProvider).getInt('lastSeenNotif') ?? 0));

/// Ids de notificações que o utilizador "limpou" (arrastou). Persistido em
/// prefs; filtradas da lista e do badge. Ver AppNotification.id.
final dismissedNotifsProvider = StateProvider<Set<String>>((ref) =>
    (ref.read(prefsProvider).getStringList('dismissedNotifs') ?? const [])
        .toSet());

/// Lista unificada de notificações, mais recentes primeiro (derivada).
final notificationsProvider = Provider<List<AppNotification>>((ref) {
  final me = _uid(ref);
  final blocked = ref.watch(blockedUidsProvider).valueOrNull ?? const <String>{};
  final out = <AppNotification>[];
  for (final c in (ref.watch(conversationsProvider).valueOrNull ?? const [])
      .where((c) => c.unread > 0)) {
    out.add(AppNotification.message(c));
  }
  for (final l in wishlistMatchesFrom(
      ref.watch(watchedCardListingsProvider).valueOrNull ?? const [],
      me,
      blocked)) {
    out.add(AppNotification.wishlist(l));
  }
  final sets = (ref.watch(setsListProvider).valueOrNull ?? const [])
      .map((s) => s.set)
      .toList();
  for (final s in newSetsFrom(sets, ref.watch(seenSetsProvider))) {
    out.add(AppNotification.newSet(s));
  }
  out.sort((a, b) => b.at.compareTo(a.at));
  // Remove as que o utilizador limpou (arrastou).
  final dismissed = ref.watch(dismissedNotifsProvider);
  return dismissed.isEmpty
      ? out
      : out.where((n) => !dismissed.contains(n.id)).toList();
});

/// Nº de notificações ainda não vistas (badge do sino).
final notifUnseenCountProvider = Provider<int>((ref) {
  final lastSeen = ref.watch(lastSeenNotifProvider);
  return ref.watch(notificationsProvider).where((n) {
    return n.type == NotifType.newSet || n.at.isAfter(lastSeen);
  }).length;
});

/// Query de pesquisa de cartas DENTRO da Comunidade (estado local, separado
/// do [searchQueryProvider] do ecrã de pesquisa global). Vazia = mostra o
/// feed de anúncios recentes; com texto = mostra cartas correspondentes.
final communitySearchQueryProvider = StateProvider<String>((_) => '');

/// Resultados da pesquisa de cartas da Comunidade (catálogo local em cache).
final communitySearchResultsProvider = StreamProvider<List<CardItem>>((ref) {
  final q = ref.watch(communitySearchQueryProvider);
  if (q.trim().isEmpty) return Stream.value(const <CardItem>[]);
  return ref.watch(cardsRepositoryProvider).searchAll(
        query: q,
        types: const [],
        status: CardStatusFilter.all,
      );
});

/// Pesquisa de cartas do catálogo para o seletor "o que quero em troca".
/// Estado local (a query é passada como argumento family).
final marketCardSearchProvider =
    StreamProvider.family<List<CardItem>, String>((ref, q) {
  if (q.trim().isEmpty) return Stream.value(const <CardItem>[]);
  return ref.watch(cardsRepositoryProvider).searchAll(
        query: q,
        types: const [],
        status: CardStatusFilter.all,
      );
});

final ownedCardsProvider =
    FutureProvider.family<List<OwnedCard>, bool>((ref, onlyDuplicates) {
  ref.watch(setsListProvider); // recalcula quando a coleção muda
  return ref.watch(databaseProvider).ownedCards(onlyDuplicates: onlyDuplicates);
});

// --- Valor da coleção (premium) ---
/// Valor estimado da coleção (€) + cobertura (priced/total), em tempo real.
final collectionValueProvider =
    StreamProvider<({double value, int priced, int total})>(
        (ref) => ref.watch(databaseProvider).watchCollectionValue());

/// Carta possuída mais valiosa (destaque). Recalcula com a coleção.
final mostValuableCardProvider = FutureProvider((ref) {
  ref.watch(setsListProvider);
  return ref.watch(databaseProvider).mostValuableOwned();
});

/// Garante que os sets onde tenho cartas estão sincronizados localmente. Após
/// login num dispositivo novo, as ENTRADAS chegam por sync mas as cartas do set
/// podem não estar em cache → o binder (que conta possuídas via JOIN com as
/// cartas) fica vazio até abrir cada set. Isto fecha esse buraco e, de caminho,
/// traz os preços. Converge (só busca sets ainda não sincronizados).
final ensureOwnedSetsSyncedProvider = FutureProvider<void>((ref) async {
  ref.watch(setsListProvider); // re-corre quando a coleção/sets mudam
  final db = ref.watch(databaseProvider);
  final repo = ref.read(cardsRepositoryProvider);
  for (final id in await db.ownedSetIdsFromEntries()) {
    if (!await db.isSetSynced(id)) {
      try {
        await repo.ensureSetSynced(id);
      } catch (_) {/* set isolado falhou — continua */}
    }
  }
});
