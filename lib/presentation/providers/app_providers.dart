import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
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

// --- Carta individual / coleção ---
final cardByIdProvider = FutureProvider.family<TcgCard?, String>(
    (ref, id) => ref.watch(cardsRepositoryProvider).byId(id));

final entryProvider = StreamProvider.family<UserCardEntry, String>(
    (ref, id) => ref.watch(collectionRepositoryProvider).watchEntry(id));

// --- Progresso ---
final globalProgressProvider = FutureProvider<ProgressStats>((ref) {
  ref.watch(setsListProvider); // recalcula quando a coleção muda
  return ref.watch(collectionRepositoryProvider).globalProgress();
});

// --- Preferências de UI ---
final themeModeProvider = StateProvider<int>((_) => 0); // 0=sistema,1=claro,2=escuro
final localeProvider = StateProvider<String?>((_) => null);
