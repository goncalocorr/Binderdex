import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/local/database.dart';
import '../../data/remote/auth_service.dart';
import '../../data/remote/profile_service.dart';
import '../../data/remote/sync_service.dart';
import '../../data/remote/tcg_api.dart';
import '../../data/repositories/cards_repository.dart';
import '../../data/repositories/collection_repository.dart';
import '../../data/repositories/sets_repository.dart';
import '../../domain/entities/card_filter.dart';
import '../../domain/entities/card_set.dart';
import '../../domain/entities/progress.dart';
import '../../domain/entities/tcg_card.dart';
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
    if (user != null) {
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
