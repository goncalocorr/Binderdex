# Comunidade — Marketplace (Fase 1) — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir o marketplace da Comunidade (Fase 1): publicar cartas possuídas para trocar/vender, pesquisar/ver anúncios num feed, gerir os meus anúncios com limites de slots por nível premium (marcadores), e denunciar/bloquear.

**Architecture:** Camadas existentes — `domain/` (entidades puras) → `data/` (Drift local + `MarketService` Firestore) → `presentation/` (screens/widgets/providers Riverpod) → `core/` (router). Anúncios vivem numa coleção de topo `listings/` no Firestore, com dados da carta e do dono desnormalizados. Slots validados no cliente (e reforçados por contador no perfil).

**Tech Stack:** Flutter, Riverpod, Drift (SQLite), Firebase (cloud_firestore, firebase_auth), GoRouter, flutter_test.

## Global Constraints

- App-facing name: **Binderdex**. Idioma principal: **Português europeu** (strings em `l10n`).
- Sem campo de **preço** estruturado (preço combina-se na nota/chat).
- Premium = **só marcadores** (`marketTier` 0..3 → slots **[20, 100, 200, 500]**). Sem Play Billing nesta fase.
- "Contactar" = **desativado / "em breve"** (chat é a Fase 2).
- Cartas publicáveis: **só as que o utilizador possui**.
- Campos do anúncio: **condição**, **o que quero**, **nota**. Modo ∈ {`trade`,`sell`,`both`}. Condição ∈ {`mint`,`good`,`used`,`damaged`}.
- Convidados (modo só-leitura) veem feed/pesquisa; escrita chama `requireSignIn(context, ref)` (em `lib/presentation/widgets/auth_guard.dart`).
- Verificação: o agente corre `C:\src\flutter\bin\flutter.bat analyze` e `... test` (sem Android/Firebase reais). Passos de Firestore são verificados pelo utilizador em dispositivo.
- Drift: alterações são queries `customSelect` manuais → **não** é preciso `build_runner`. Schema **mantém-se v4**.
- Cada commit usa `--no-verify` não é necessário; usar mensagens `feat:`/`test:`/`chore:`.

---

### Task 1: Domínio — níveis e regra de slots

**Files:**
- Create: `lib/domain/entities/market_tier.dart`
- Test: `test/market_tier_test.dart`

**Interfaces:**
- Produces:
  - `class MarketTier` com `static const List<int> slots = [20, 100, 200, 500];`
  - `static int slotsFor(int tier)` → limite do nível (tier "clamped" a 0..3).
  - `static bool canPublish({required int activeCount, required int tier, required int selectedCount})` → `activeCount + selectedCount <= slotsFor(tier)`.
  - `static int remaining({required int activeCount, required int tier})` → `slotsFor(tier) - activeCount` (mínimo 0).

- [ ] **Step 1: Write the failing test**

`test/market_tier_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/market_tier.dart';

void main() {
  test('slotsFor devolve o limite de cada nível', () {
    expect(MarketTier.slotsFor(0), 20);
    expect(MarketTier.slotsFor(1), 100);
    expect(MarketTier.slotsFor(2), 200);
    expect(MarketTier.slotsFor(3), 500);
  });

  test('slotsFor faz clamp de níveis inválidos', () {
    expect(MarketTier.slotsFor(-1), 20);
    expect(MarketTier.slotsFor(99), 500);
  });

  test('canPublish permite até ao limite e bloqueia acima', () {
    expect(MarketTier.canPublish(activeCount: 18, tier: 0, selectedCount: 2), true);
    expect(MarketTier.canPublish(activeCount: 19, tier: 0, selectedCount: 2), false);
    expect(MarketTier.canPublish(activeCount: 0, tier: 0, selectedCount: 20), true);
  });

  test('remaining nunca é negativo', () {
    expect(MarketTier.remaining(activeCount: 5, tier: 0), 15);
    expect(MarketTier.remaining(activeCount: 25, tier: 0), 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/market_tier_test.dart`
Expected: FAIL ("Target of URI doesn't exist: market_tier.dart").

- [ ] **Step 3: Write minimal implementation**

`lib/domain/entities/market_tier.dart`:
```dart
/// Níveis de slots de anúncios. Premium = só marcador (sem pagamento ainda).
class MarketTier {
  static const List<int> slots = [20, 100, 200, 500];

  static int slotsFor(int tier) => slots[tier.clamp(0, slots.length - 1)];

  static bool canPublish({
    required int activeCount,
    required int tier,
    required int selectedCount,
  }) =>
      activeCount + selectedCount <= slotsFor(tier);

  static int remaining({required int activeCount, required int tier}) {
    final r = slotsFor(tier) - activeCount;
    return r < 0 ? 0 : r;
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/market_tier_test.dart`
Expected: PASS (4 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entities/market_tier.dart test/market_tier_test.dart
git commit -m "feat(comunidade): niveis e regra de slots (MarketTier)"
```

---

### Task 2: Domínio — entidade `Listing`

**Files:**
- Create: `lib/domain/entities/listing.dart`
- Test: `test/listing_test.dart`

**Interfaces:**
- Produces:
  - `enum TradeMode { trade, sell, both }` com `String get id` (`'trade'|'sell'|'both'`) e `static TradeMode fromId(String)`.
  - `enum CardCondition { mint, good, used, damaged }` com `String get id` e `static CardCondition fromId(String)`.
  - `class CardRef { final String cardId, cardName, cardImage, setId; }` (carta a publicar).
  - `class Listing { final String id, ownerUid, ownerName, ownerAvatar, cardId, cardName, cardImage, setId; final TradeMode mode; final CardCondition condition; final String? wantText, note; final DateTime createdAt; }`
  - `Map<String, dynamic> Listing.toMap()` (sem `id`; `createdAt` omitido → preenchido por `serverTimestamp` no serviço).
  - `factory Listing.fromMap(String id, Map<String, dynamic> m)` (lê `createdAt` de `Timestamp` ou usa epoch 0 se nulo).

- [ ] **Step 1: Write the failing test**

`test/listing_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/listing.dart';

void main() {
  test('TradeMode/CardCondition convertem id ida-e-volta', () {
    for (final m in TradeMode.values) {
      expect(TradeMode.fromId(m.id), m);
    }
    for (final c in CardCondition.values) {
      expect(CardCondition.fromId(c.id), c);
    }
  });

  test('toMap inclui os campos esperados e omite createdAt', () {
    final l = Listing(
      id: 'x', ownerUid: 'u1', ownerName: 'Ana', ownerAvatar: 'a1',
      cardId: 'base1-4', cardName: 'Charizard', cardImage: 'img', setId: 'base1',
      mode: TradeMode.both, condition: CardCondition.good,
      wantText: 'Pikachu', note: 'tenho 3',
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    final m = l.toMap();
    expect(m['ownerUid'], 'u1');
    expect(m['cardId'], 'base1-4');
    expect(m['mode'], 'both');
    expect(m['condition'], 'good');
    expect(m['wantText'], 'Pikachu');
    expect(m.containsKey('createdAt'), false);
    expect(m['status'], 'active');
  });

  test('fromMap lê os campos e tolera createdAt nulo', () {
    final l = Listing.fromMap('doc1', {
      'ownerUid': 'u1', 'ownerName': 'Ana', 'ownerAvatar': 'a1',
      'cardId': 'base1-4', 'cardName': 'Charizard', 'cardImage': 'img',
      'setId': 'base1', 'mode': 'sell', 'condition': 'mint',
      'wantText': null, 'note': null, 'status': 'active', 'createdAt': null,
    });
    expect(l.id, 'doc1');
    expect(l.mode, TradeMode.sell);
    expect(l.condition, CardCondition.mint);
    expect(l.createdAt.millisecondsSinceEpoch, 0);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/listing_test.dart`
Expected: FAIL ("Target of URI doesn't exist: listing.dart").

- [ ] **Step 3: Write minimal implementation**

`lib/domain/entities/listing.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum TradeMode {
  trade, sell, both;

  String get id => name;
  static TradeMode fromId(String s) =>
      TradeMode.values.firstWhere((e) => e.name == s, orElse: () => TradeMode.trade);
}

enum CardCondition {
  mint, good, used, damaged;

  String get id => name;
  static CardCondition fromId(String s) => CardCondition.values
      .firstWhere((e) => e.name == s, orElse: () => CardCondition.good);
}

/// Identidade mínima de uma carta a publicar.
class CardRef {
  final String cardId, cardName, cardImage, setId;
  const CardRef({
    required this.cardId,
    required this.cardName,
    required this.cardImage,
    required this.setId,
  });
}

class Listing {
  final String id, ownerUid, ownerName, ownerAvatar;
  final String cardId, cardName, cardImage, setId;
  final TradeMode mode;
  final CardCondition condition;
  final String? wantText, note;
  final DateTime createdAt;

  const Listing({
    required this.id,
    required this.ownerUid,
    required this.ownerName,
    required this.ownerAvatar,
    required this.cardId,
    required this.cardName,
    required this.cardImage,
    required this.setId,
    required this.mode,
    required this.condition,
    required this.wantText,
    required this.note,
    required this.createdAt,
  });

  /// Mapa para o Firestore. `createdAt` é omitido aqui — o serviço acrescenta
  /// `FieldValue.serverTimestamp()` na escrita.
  Map<String, dynamic> toMap() => {
        'ownerUid': ownerUid,
        'ownerName': ownerName,
        'ownerAvatar': ownerAvatar,
        'cardId': cardId,
        'cardName': cardName,
        'cardImage': cardImage,
        'setId': setId,
        'mode': mode.id,
        'condition': condition.id,
        if (wantText != null && wantText!.isNotEmpty) 'wantText': wantText,
        if (note != null && note!.isNotEmpty) 'note': note,
        'status': 'active',
      };

  factory Listing.fromMap(String id, Map<String, dynamic> m) {
    final ts = m['createdAt'];
    return Listing(
      id: id,
      ownerUid: (m['ownerUid'] ?? '') as String,
      ownerName: (m['ownerName'] ?? '') as String,
      ownerAvatar: (m['ownerAvatar'] ?? '') as String,
      cardId: (m['cardId'] ?? '') as String,
      cardName: (m['cardName'] ?? '') as String,
      cardImage: (m['cardImage'] ?? '') as String,
      setId: (m['setId'] ?? '') as String,
      mode: TradeMode.fromId((m['mode'] ?? 'trade') as String),
      condition: CardCondition.fromId((m['condition'] ?? 'good') as String),
      wantText: m['wantText'] as String?,
      note: m['note'] as String?,
      createdAt: ts is Timestamp
          ? ts.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/listing_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/domain/entities/listing.dart test/listing_test.dart
git commit -m "feat(comunidade): entidade Listing + enums (toMap/fromMap)"
```

---

### Task 3: Drift — query `ownedCards`

**Files:**
- Modify: `lib/data/local/database.dart` (acrescentar classe `OwnedCard` perto de `CardRow` na linha ~77, e o método `ownedCards` junto às outras queries)
- Test: `test/owned_cards_test.dart`

**Interfaces:**
- Produces:
  - `class OwnedCard { final TcgCardRow card; final bool isDuplicate; }`
  - `Future<List<OwnedCard>> AppDatabase.ownedCards({bool onlyDuplicates = false})` — cartas com ≥1 variante possuída, ordenadas por `set_id, number_sort`; `isDuplicate` = alguma `qty_* > 1`.

- [ ] **Step 1: Write the failing test**

`test/owned_cards_test.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/local/database.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.bulkInsertSets([
      CardSetsCompanion.insert(
        id: 'base1', name: 'Base', series: 'Base',
        printedTotal: 102, total: 102, releaseDate: '1999',
        symbolUrl: '', logoUrl: '',
      ),
    ]);
    await db.bulkInsertCards([
      TcgCardsCompanion.insert(
        id: 'base1-4', setId: 'base1', name: 'Charizard',
        number: '4', numberSort: 4, imageSmall: '', imageLarge: ''),
      TcgCardsCompanion.insert(
        id: 'base1-58', setId: 'base1', name: 'Pikachu',
        number: '58', numberSort: 58, imageSmall: '', imageLarge: ''),
    ]);
  });

  tearDown(() => db.close());

  test('ownedCards devolve só as possuídas', () async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-4', ownedNormal: const Value(true),
      updatedAt: DateTime.now()));
    final res = await db.ownedCards();
    expect(res.length, 1);
    expect(res.single.card.id, 'base1-4');
    expect(res.single.isDuplicate, false);
  });

  test('isDuplicate é true quando qty > 1', () async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-4', ownedNormal: const Value(true),
      qtyNormal: const Value(3), updatedAt: DateTime.now()));
    final res = await db.ownedCards();
    expect(res.single.isDuplicate, true);
  });

  test('onlyDuplicates filtra só as repetidas', () async {
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-4', ownedNormal: const Value(true),
      qtyNormal: const Value(2), updatedAt: DateTime.now()));
    await db.upsertEntry(UserCardEntriesCompanion.insert(
      cardId: 'base1-58', ownedNormal: const Value(true),
      updatedAt: DateTime.now()));
    final all = await db.ownedCards();
    final dupes = await db.ownedCards(onlyDuplicates: true);
    expect(all.length, 2);
    expect(dupes.length, 1);
    expect(dupes.single.card.id, 'base1-4');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/owned_cards_test.dart`
Expected: FAIL ("The method 'ownedCards' isn't defined").

- [ ] **Step 3: Write minimal implementation**

Em `lib/data/local/database.dart`, a seguir à classe `CardRow` (≈ linha 77) acrescentar:
```dart
/// Carta possuída + indicação de duplicado (para a grelha "As minhas cartas").
class OwnedCard {
  final TcgCardRow card;
  final bool isDuplicate;
  OwnedCard(this.card, this.isDuplicate);
}
```

E dentro da classe `AppDatabase` (junto às outras queries, p.ex. a seguir a `ownedByTypeInSet`):
```dart
  /// Todas as cartas com ≥1 variante possuída. `onlyDuplicates` limita às que
  /// têm 2+ cópias da mesma variante.
  Future<List<OwnedCard>> ownedCards({bool onlyDuplicates = false}) async {
    final dupeExpr =
        '(e.qty_normal > 1 OR e.qty_holo > 1 OR e.qty_reverse > 1)';
    final rows = await customSelect(
      'SELECT c.*, $dupeExpr AS is_dupe '
      'FROM tcg_cards c JOIN user_card_entries e ON e.card_id = c.id '
      'WHERE (e.owned_normal = 1 OR e.owned_holo = 1 OR e.owned_reverse = 1) '
      '${onlyDuplicates ? 'AND $dupeExpr ' : ''}'
      'ORDER BY c.set_id, c.number_sort',
      readsFrom: {tcgCards, userCardEntries},
    ).get();
    return rows
        .map((r) => OwnedCard(tcgCards.map(r.data), r.read<int>('is_dupe') == 1))
        .toList();
  }
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/owned_cards_test.dart`
Expected: PASS (3 testes).

- [ ] **Step 5: Commit**

```bash
git add lib/data/local/database.dart test/owned_cards_test.dart
git commit -m "feat(comunidade): query ownedCards (todas/repetidas)"
```

---

### Task 4: `MarketService` (Firestore)

**Files:**
- Create: `lib/data/remote/market_service.dart`

**Interfaces:**
- Consumes: `Listing`, `CardRef`, `TradeMode`, `CardCondition` (Task 2), `MarketTier` (Task 1).
- Produces (`class MarketService`):
  - `Stream<List<Listing>> watchRecent({int limit = 30})`
  - `Stream<List<Listing>> watchForCard(String cardId)`
  - `Stream<List<Listing>> watchMine(String uid)`
  - `Stream<Set<String>> watchBlocked(String uid)`
  - `Future<void> publish({required List<CardRef> cards, required String ownerUid, required String ownerName, required String ownerAvatar, required int tier, required int activeCount, required TradeMode mode, required CardCondition condition, String? wantText, String? note})` — lança `SlotLimitException` se exceder; cria N docs + incrementa `activeListings` numa `WriteBatch`/transação.
  - `Future<void> updateListing(Listing l)`
  - `Future<void> deleteListing(String id, String ownerUid)`
  - `Future<void> report({required String listingId, required String reporterUid, required String reason})`
  - `Future<void> block(String uid, String blockedUid)` / `Future<void> unblock(String uid, String blockedUid)`
  - `Future<void> setTier(String uid, int tier)`
  - `class SlotLimitException implements Exception {}`

> **Nota de verificação:** este serviço depende do Firestore real e **não tem teste automático** (o agente não tem credenciais). A lógica de slots já está testada em Task 1; aqui garante-se só que compila (`analyze`). Verificação funcional é em dispositivo (Task 11/12).

- [ ] **Step 1: Write the implementation**

`lib/data/remote/market_service.dart`:
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/listing.dart';
import '../../domain/entities/market_tier.dart';

class SlotLimitException implements Exception {
  final int limit;
  SlotLimitException(this.limit);
  @override
  String toString() => 'SlotLimitException(limit: $limit)';
}

/// Acesso ao marketplace público (`listings/`) e à moderação (reports/blocks).
class MarketService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _listings =>
      _db.collection('listings');

  List<Listing> _map(QuerySnapshot<Map<String, dynamic>> s) =>
      s.docs.map((d) => Listing.fromMap(d.id, d.data())).toList();

  Stream<List<Listing>> watchRecent({int limit = 30}) => _listings
      .where('status', isEqualTo: 'active')
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .snapshots()
      .map(_map);

  Stream<List<Listing>> watchForCard(String cardId) => _listings
      .where('status', isEqualTo: 'active')
      .where('cardId', isEqualTo: cardId)
      .snapshots()
      .map(_map);

  Stream<List<Listing>> watchMine(String uid) => _listings
      .where('ownerUid', isEqualTo: uid)
      .where('status', isEqualTo: 'active')
      .snapshots()
      .map(_map);

  Stream<Set<String>> watchBlocked(String uid) => _db
      .collection('users')
      .doc(uid)
      .collection('blocks')
      .snapshots()
      .map((s) => s.docs.map((d) => d.id).toSet());

  Future<void> publish({
    required List<CardRef> cards,
    required String ownerUid,
    required String ownerName,
    required String ownerAvatar,
    required int tier,
    required int activeCount,
    required TradeMode mode,
    required CardCondition condition,
    String? wantText,
    String? note,
  }) async {
    if (!MarketTier.canPublish(
        activeCount: activeCount, tier: tier, selectedCount: cards.length)) {
      throw SlotLimitException(MarketTier.slotsFor(tier));
    }
    final batch = _db.batch();
    for (final c in cards) {
      final doc = _listings.doc();
      batch.set(doc, {
        'ownerUid': ownerUid,
        'ownerName': ownerName,
        'ownerAvatar': ownerAvatar,
        'cardId': c.cardId,
        'cardName': c.cardName,
        'cardImage': c.cardImage,
        'setId': c.setId,
        'mode': mode.id,
        'condition': condition.id,
        if (wantText != null && wantText.isNotEmpty) 'wantText': wantText,
        if (note != null && note.isNotEmpty) 'note': note,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    batch.set(
      _db.collection('users').doc(ownerUid),
      {'activeListings': FieldValue.increment(cards.length)},
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> updateListing(Listing l) =>
      _listings.doc(l.id).update(l.toMap());

  Future<void> deleteListing(String id, String ownerUid) async {
    final batch = _db.batch();
    batch.delete(_listings.doc(id));
    batch.set(
      _db.collection('users').doc(ownerUid),
      {'activeListings': FieldValue.increment(-1)},
      SetOptions(merge: true),
    );
    await batch.commit();
  }

  Future<void> report({
    required String listingId,
    required String reporterUid,
    required String reason,
  }) =>
      _db.collection('reports').add({
        'listingId': listingId,
        'reporterUid': reporterUid,
        'reason': reason,
        'createdAt': FieldValue.serverTimestamp(),
      });

  Future<void> block(String uid, String blockedUid) => _db
      .collection('users')
      .doc(uid)
      .collection('blocks')
      .doc(blockedUid)
      .set({'createdAt': FieldValue.serverTimestamp()});

  Future<void> unblock(String uid, String blockedUid) => _db
      .collection('users')
      .doc(uid)
      .collection('blocks')
      .doc(blockedUid)
      .delete();

  Future<void> setTier(String uid, int tier) => _db
      .collection('users')
      .doc(uid)
      .set({'marketTier': tier}, SetOptions(merge: true));
}
```

- [ ] **Step 2: Verify it compiles**

Run: `C:\src\flutter\bin\flutter.bat analyze lib/data/remote/market_service.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/data/remote/market_service.dart
git commit -m "feat(comunidade): MarketService (Firestore listings/reports/blocks)"
```

---

### Task 5: Strings (l10n)

**Files:**
- Modify: `lib/l10n/app_pt.arb`, `lib/l10n/app_en.arb`

**Interfaces:**
- Produces (chaves usadas nos ecrãs): `tabCommunity`, `communityDisclaimerTitle`, `communityDisclaimerBody`, `communityDisclaimerOk`, `sellOrTrade`, `addToCommunity`, `onlyDuplicates`, `myListings`, `publish`, `modeTrade`, `modeSell`, `modeBoth`, `condMint`, `condGood`, `condUsed`, `condDamaged`, `whatIWant`, `noteOptional`, `contactSoon`, `report`, `block`, `unblock`, `slotsUsed` (placeholder `{used}`/`{limit}`), `slotLimitReached`, `premiumSlots`, `recentListings`, `searchCardHint`, `noListings`.

- [ ] **Step 1: Add keys to `lib/l10n/app_pt.arb`**

Acrescentar (antes da última `}`):
```json
  "tabCommunity": "Comunidade",
  "communityDisclaimerTitle": "Antes de começares",
  "communityDisclaimerBody": "A Comunidade liga colecionadores para trocar e vender cartas. Os negócios são entre utilizadores — a Binderdex não é parte nem se responsabiliza por trocas, pagamentos ou eventuais burlas. Tem cuidado, confirma com quem negoceias e nunca partilhes dados sensíveis.",
  "communityDisclaimerOk": "Compreendo",
  "sellOrTrade": "Vender ou trocar cartas",
  "addToCommunity": "Adicionar à comunidade ({n})",
  "@addToCommunity": { "placeholders": { "n": {} } },
  "onlyDuplicates": "Só repetidas",
  "myListings": "Os meus anúncios",
  "publish": "Publicar",
  "modeTrade": "Trocar",
  "modeSell": "Vender",
  "modeBoth": "Ambos",
  "condMint": "Nova",
  "condGood": "Boa",
  "condUsed": "Usada",
  "condDamaged": "Danificada",
  "whatIWant": "O que quero em troca",
  "noteOptional": "Nota (opcional)",
  "contactSoon": "Contactar (em breve)",
  "report": "Denunciar",
  "block": "Bloquear",
  "unblock": "Desbloquear",
  "slotsUsed": "{used}/{limit} slots usados",
  "@slotsUsed": { "placeholders": { "used": {}, "limit": {} } },
  "slotLimitReached": "Atingiste o limite de slots. Desbloqueia mais com Premium.",
  "premiumSlots": "Slots e Premium",
  "recentListings": "Anúncios recentes",
  "searchCardHint": "Procurar uma carta…",
  "noListings": "Ainda não há anúncios."
```

- [ ] **Step 2: Add the same keys to `lib/l10n/app_en.arb`** (traduções em inglês, mesmas chaves; ex.: `"tabCommunity": "Community"`, `"onlyDuplicates": "Duplicates only"`, etc.)

- [ ] **Step 3: Regenerate + analyze**

Run: `C:\src\flutter\bin\flutter.bat gen-l10n` depois `C:\src\flutter\bin\flutter.bat analyze`
Expected: gera `app_localizations*.dart`; "No issues found!"

- [ ] **Step 4: Commit**

```bash
git add lib/l10n/
git commit -m "feat(comunidade): strings l10n (pt/en)"
```

---

### Task 6: Regras Firestore

**Files:**
- Modify: `firestore.rules`

**Interfaces:**
- Produces: regras para `listings/`, `reports/`, `users/{uid}/blocks/{blockedUid}`.

> **Verificação:** regras são aplicadas pelo Firebase; o agente só edita o ficheiro. O utilizador faz `firebase deploy --only firestore:rules`.

- [ ] **Step 1: Add the rules**

Em `firestore.rules`, dentro de `match /databases/{database}/documents {`, antes do comentário final, acrescentar:
```
    // Marketplace público — leitura por autenticados; escrita só do dono.
    match /listings/{id} {
      allow read: if request.auth != null;
      allow create: if request.auth != null
        && request.resource.data.ownerUid == request.auth.uid
        && request.resource.data.mode in ['trade','sell','both']
        && request.resource.data.condition in ['mint','good','used','damaged']
        && (!('wantText' in request.resource.data)
            || request.resource.data.wantText.size() <= 280)
        && (!('note' in request.resource.data)
            || request.resource.data.note.size() <= 280);
      allow update, delete: if request.auth != null
        && resource.data.ownerUid == request.auth.uid;
    }

    // Denúncias — criar por autenticados; sem leitura no cliente.
    match /reports/{id} {
      allow create: if request.auth != null
        && request.resource.data.reporterUid == request.auth.uid;
      allow read, update, delete: if false;
    }
```

E dentro de `match /users/{userId} {` (a par do `match /cards/...`):
```
      // Utilizadores bloqueados por este user.
      match /blocks/{blockedUid} {
        allow read, write: if request.auth != null
                           && request.auth.uid == userId;
      }
```

- [ ] **Step 2: Commit**

```bash
git add firestore.rules
git commit -m "feat(comunidade): regras Firestore (listings/reports/blocks)"
```

---

### Task 7: Providers

**Files:**
- Modify: `lib/presentation/providers/app_providers.dart`

**Interfaces:**
- Consumes: `MarketService` (Task 4), `authStateProvider`, `displayNameProvider`, `avatarProvider`, `prefsProvider` (existentes).
- Produces:
  - `marketServiceProvider` → `Provider<MarketService>`
  - `recentListingsProvider` → `StreamProvider<List<Listing>>` (já filtrado por bloqueados)
  - `listingsForCardProvider` → `StreamProvider.family<List<Listing>, String>`
  - `myListingsProvider` → `StreamProvider<List<Listing>>`
  - `blockedUidsProvider` → `StreamProvider<Set<String>>`
  - `marketTierProvider` → `StreamProvider<int>` (lê `users/{uid}.marketTier`)
  - `activeListingsCountProvider` → deriva de `myListingsProvider` (length)
  - `communityDisclaimerSeenProvider` → `StateProvider<bool>` (semeado de `prefs.getBool('communityDisclaimerSeen')`)

- [ ] **Step 1: Add the providers**

No fim de `lib/presentation/providers/app_providers.dart` (e import no topo de `../../data/remote/market_service.dart` e `../../domain/entities/listing.dart`):
```dart
// --- Comunidade / marketplace ---
final marketServiceProvider = Provider<MarketService>((ref) => MarketService());

String? _uid(Ref ref) => ref.watch(authStateProvider).valueOrNull?.uid;

final blockedUidsProvider = StreamProvider<Set<String>>((ref) {
  final uid = _uid(ref);
  if (uid == null) return Stream.value(<String>{});
  return ref.watch(marketServiceProvider).watchBlocked(uid);
});

final recentListingsProvider = StreamProvider<List<Listing>>((ref) {
  final blocked = ref.watch(blockedUidsProvider).valueOrNull ?? const <String>{};
  return ref
      .watch(marketServiceProvider)
      .watchRecent()
      .map((list) => list.where((l) => !blocked.contains(l.ownerUid)).toList());
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
```
(Acrescentar no topo o import `import 'package:cloud_firestore/cloud_firestore.dart';` se ainda não existir.)

- [ ] **Step 2: Analyze**

Run: `C:\src\flutter\bin\flutter.bat analyze`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/providers/app_providers.dart
git commit -m "feat(comunidade): providers (feed/mine/blocked/tier/disclaimer)"
```

---

### Task 8: Widget `ListingTile`

**Files:**
- Create: `lib/presentation/widgets/listing_tile.dart`
- Test: `test/listing_tile_test.dart`

**Interfaces:**
- Consumes: `Listing`, `TradeMode`, `CardCondition`.
- Produces: `class ListingTile extends StatelessWidget { final Listing listing; final VoidCallback? onTap; }` — mostra nome da carta, dono, e um chip com o rótulo do modo (`Trocar`/`Vender`/`Ambos`).

- [ ] **Step 1: Write the failing test**

`test/listing_tile_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/listing.dart';
import 'package:pokedex/l10n/app_localizations.dart';
import 'package:pokedex/presentation/widgets/listing_tile.dart';

Listing _sample(TradeMode mode) => Listing(
      id: 'x', ownerUid: 'u1', ownerName: 'Ana', ownerAvatar: '',
      cardId: 'base1-4', cardName: 'Charizard', cardImage: '', setId: 'base1',
      mode: mode, condition: CardCondition.good, wantText: null, note: null,
      createdAt: DateTime.now());

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt'), Locale('en')],
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('mostra a carta, o dono e o modo', (tester) async {
    await tester.pumpWidget(_wrap(ListingTile(listing: _sample(TradeMode.sell))));
    await tester.pumpAndSettle();
    expect(find.text('Charizard'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Vender'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/listing_tile_test.dart`
Expected: FAIL ("Target of URI doesn't exist: listing_tile.dart").

- [ ] **Step 3: Write minimal implementation**

`lib/presentation/widgets/listing_tile.dart`:
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';

class ListingTile extends StatelessWidget {
  final Listing listing;
  final VoidCallback? onTap;
  const ListingTile({super.key, required this.listing, this.onTap});

  String _modeLabel(AppLocalizations t) => switch (listing.mode) {
        TradeMode.trade => t.modeTrade,
        TradeMode.sell => t.modeSell,
        TradeMode.both => t.modeBoth,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 40,
        child: listing.cardImage.isEmpty
            ? const Icon(Icons.style)
            : CachedNetworkImage(
                imageUrl: listing.cardImage,
                fit: BoxFit.contain,
                errorWidget: (_, __, ___) => const Icon(Icons.style),
              ),
      ),
      title: Text(listing.cardName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(listing.ownerName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Chip(
        label: Text(_modeLabel(t)),
        backgroundColor: cs.primaryContainer,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/listing_tile_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/widgets/listing_tile.dart test/listing_tile_test.dart
git commit -m "feat(comunidade): widget ListingTile"
```

---

### Task 9: Grelha "As minhas cartas" (seleção múltipla)

**Files:**
- Create: `lib/presentation/screens/my_cards_screen.dart`
- Test: `test/my_cards_selection_test.dart`

**Interfaces:**
- Consumes: `ownedCards` (via novo provider), `CardRef` (Task 2).
- Produces:
  - `ownedCardsProvider` → `FutureProvider.family<List<OwnedCard>, bool>` (param = `onlyDuplicates`) — adicionar em `app_providers.dart`.
  - `class MyCardsScreen extends ConsumerStatefulWidget { final bool startDuplicates; }` — grelha com checkboxes; botão inferior `addToCommunity(n)`; abre o `PublishSheet` (Task 10) com a lista de `CardRef` selecionados.
  - Função pura testável: `List<CardRef> cardRefsFrom(List<OwnedCard> all, Set<String> selectedIds)` (top-level no mesmo ficheiro).

- [ ] **Step 1: Write the failing test** (testa a função pura de seleção)

`test/my_cards_selection_test.dart`:
```dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/local/database.dart';
import 'package:pokedex/presentation/screens/my_cards_screen.dart';

void main() {
  test('cardRefsFrom devolve só as cartas selecionadas', () {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final all = [
      OwnedCard(
          TcgCardRow(
              id: 'a', setId: 's', name: 'A', number: '1', numberSort: 1,
              imageSmall: '', imageLarge: 'imgA'),
          false),
      OwnedCard(
          TcgCardRow(
              id: 'b', setId: 's', name: 'B', number: '2', numberSort: 2,
              imageSmall: '', imageLarge: 'imgB'),
          true),
    ];
    final refs = cardRefsFrom(all, {'b'});
    expect(refs.length, 1);
    expect(refs.single.cardId, 'b');
    expect(refs.single.cardImage, 'imgB');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `C:\src\flutter\bin\flutter.bat test test/my_cards_selection_test.dart`
Expected: FAIL ("Target of URI doesn't exist: my_cards_screen.dart").

- [ ] **Step 3: Write implementation**

Primeiro, em `app_providers.dart` acrescentar:
```dart
final ownedCardsProvider =
    FutureProvider.family<List<OwnedCard>, bool>((ref, onlyDuplicates) {
  ref.watch(setsListProvider); // recalcula quando a coleção muda
  return ref.watch(databaseProvider).ownedCards(onlyDuplicates: onlyDuplicates);
});
```

`lib/presentation/screens/my_cards_screen.dart`:
```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/database.dart';
import '../../domain/entities/listing.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/publish_sheet.dart';

/// Converte a seleção (ids) em CardRef para publicar. Top-level p/ ser testável.
List<CardRef> cardRefsFrom(List<OwnedCard> all, Set<String> selectedIds) => all
    .where((o) => selectedIds.contains(o.card.id))
    .map((o) => CardRef(
          cardId: o.card.id,
          cardName: o.card.name,
          cardImage: o.card.imageLarge,
          setId: o.card.setId,
        ))
    .toList();

class MyCardsScreen extends ConsumerStatefulWidget {
  final bool startDuplicates;
  const MyCardsScreen({super.key, this.startDuplicates = false});

  @override
  ConsumerState<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends ConsumerState<MyCardsScreen> {
  late bool _onlyDupes = widget.startDuplicates;
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cardsAsync = ref.watch(ownedCardsProvider(_onlyDupes));

    return Scaffold(
      appBar: AppBar(
        title: Text(t.sellOrTrade),
        actions: [
          Row(children: [
            Text(t.onlyDuplicates),
            Switch(
              value: _onlyDupes,
              onChanged: (v) => setState(() {
                _onlyDupes = v;
                _selected.clear();
              }),
            ),
          ]),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (cards) => GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 0.72, mainAxisSpacing: 8,
              crossAxisSpacing: 8),
          itemCount: cards.length,
          itemBuilder: (_, i) {
            final o = cards[i];
            final sel = _selected.contains(o.card.id);
            return GestureDetector(
              onTap: () => setState(() =>
                  sel ? _selected.remove(o.card.id) : _selected.add(o.card.id)),
              child: Stack(fit: StackFit.expand, children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: o.card.imageLarge.isEmpty
                      ? Container(color: Theme.of(context).colorScheme.surfaceContainerHigh)
                      : CachedNetworkImage(
                          imageUrl: o.card.imageLarge, fit: BoxFit.cover),
                ),
                if (sel)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary, width: 3),
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
                    ),
                    alignment: Alignment.topRight,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.check_circle, color: Colors.white),
                    ),
                  ),
              ]),
            );
          },
        ),
      ),
      bottomNavigationBar: _selected.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  icon: const Icon(Icons.storefront),
                  label: Text(t.addToCommunity(_selected.length)),
                  onPressed: () async {
                    final all = ref.read(ownedCardsProvider(_onlyDupes)).valueOrNull ?? [];
                    final refs = cardRefsFrom(all, _selected);
                    final ok = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => PublishSheet(cards: refs),
                    );
                    if (ok == true && mounted) {
                      setState(() => _selected.clear());
                    }
                  },
                ),
              ),
            ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `C:\src\flutter\bin\flutter.bat test test/my_cards_selection_test.dart`
Expected: PASS. (Nota: o ecrã importa `PublishSheet` da Task 10 — implementar Task 10 antes de `analyze` global; o teste da função pura compila na mesma porque só usa `cardRefsFrom`.)

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/my_cards_screen.dart lib/presentation/providers/app_providers.dart test/my_cards_selection_test.dart
git commit -m "feat(comunidade): grelha As minhas cartas + selecao multipla"
```

---

### Task 10: `PublishSheet`

**Files:**
- Create: `lib/presentation/widgets/publish_sheet.dart`

**Interfaces:**
- Consumes: `CardRef`, `TradeMode`, `CardCondition`, `MarketTier`, `MarketService`, `marketTierProvider`, `activeListingsCountProvider`, `displayNameProvider`, `avatarProvider`, `authStateProvider`, `SlotLimitException`.
- Produces: `class PublishSheet extends ConsumerStatefulWidget { final List<CardRef> cards; }` — formulário (modo/condição/o-que-quero/nota), mostra `slotsUsed`, bloqueia se exceder, publica via `MarketService.publish`, faz `Navigator.pop(true)` no sucesso.

> Sem teste automático (depende do Firestore na submissão). A regra de slots já está testada (Task 1). Verificação: compila + dispositivo.

- [ ] **Step 1: Write implementation**

`lib/presentation/widgets/publish_sheet.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/listing.dart';
import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

class PublishSheet extends ConsumerStatefulWidget {
  final List<CardRef> cards;
  const PublishSheet({super.key, required this.cards});

  @override
  ConsumerState<PublishSheet> createState() => _PublishSheetState();
}

class _PublishSheetState extends ConsumerState<PublishSheet> {
  TradeMode _mode = TradeMode.trade;
  CardCondition _cond = CardCondition.good;
  final _want = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _want.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final t = AppLocalizations.of(context)!;
    final uid = ref.read(authStateProvider).valueOrNull?.uid;
    if (uid == null) return;
    final tier = ref.read(marketTierProvider).valueOrNull ?? 0;
    final active = ref.read(activeListingsCountProvider);
    if (!MarketTier.canPublish(
        activeCount: active, tier: tier, selectedCount: widget.cards.length)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.slotLimitReached)));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(marketServiceProvider).publish(
            cards: widget.cards,
            ownerUid: uid,
            ownerName: ref.read(displayNameProvider),
            ownerAvatar: ref.read(avatarProvider),
            tier: tier,
            activeCount: active,
            mode: _mode,
            condition: _cond,
            wantText: _want.text.trim(),
            note: _note.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } on SlotLimitException {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(t.slotLimitReached)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final tier = ref.watch(marketTierProvider).valueOrNull ?? 0;
    final active = ref.watch(activeListingsCountProvider);
    return Padding(
      padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(t.slotsUsed(active, MarketTier.slotsFor(tier)),
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 12),
        SegmentedButton<TradeMode>(
          segments: [
            ButtonSegment(value: TradeMode.trade, label: Text(t.modeTrade)),
            ButtonSegment(value: TradeMode.sell, label: Text(t.modeSell)),
            ButtonSegment(value: TradeMode.both, label: Text(t.modeBoth)),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<CardCondition>(
          initialValue: _cond,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            DropdownMenuItem(value: CardCondition.mint, child: Text(t.condMint)),
            DropdownMenuItem(value: CardCondition.good, child: Text(t.condGood)),
            DropdownMenuItem(value: CardCondition.used, child: Text(t.condUsed)),
            DropdownMenuItem(value: CardCondition.damaged, child: Text(t.condDamaged)),
          ],
          onChanged: (v) => setState(() => _cond = v ?? CardCondition.good),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _want,
          maxLength: 280,
          decoration: InputDecoration(
              labelText: t.whatIWant, border: const OutlineInputBorder()),
        ),
        TextField(
          controller: _note,
          maxLength: 280,
          decoration: InputDecoration(
              labelText: t.noteOptional, border: const OutlineInputBorder()),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _busy ? null : _publish,
          child: _busy
              ? const SizedBox(
                  height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : Text('${t.publish} (${widget.cards.length})'),
        ),
      ]),
    );
  }
}
```

- [ ] **Step 2: Analyze** (agora Task 9 e 10 compilam juntas)

Run: `C:\src\flutter\bin\flutter.bat analyze`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/widgets/publish_sheet.dart
git commit -m "feat(comunidade): PublishSheet (formulario + guarda de slots)"
```

---

### Task 11: Ecrã Comunidade + 5.º tab + disclaimer + rotas

**Files:**
- Create: `lib/presentation/screens/community_screen.dart`
- Modify: `lib/core/router/app_router.dart` (`_Shell`: `_tabs`, `titles`, `destinations`; e novas `GoRoute`)

**Interfaces:**
- Consumes: `recentListingsProvider`, `communityDisclaimerSeenProvider`, `prefsProvider`, `listingsForCardProvider`, `ListingTile`, `MyCardsScreen`, `requireSignIn`.
- Produces: `class CommunityScreen extends ConsumerStatefulWidget` (feed + pesquisa + FAB "+ Vender/Trocar" + ação "Os meus anúncios" + disclaimer na 1ª vez). Novas rotas: `/community/card/:id`, `/listing/:id`, `/my-cards`, `/my-listings`.

> Verificação automática: `analyze`. Feed real e disclaimer = dispositivo.

- [ ] **Step 1: Write `community_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/auth_guard.dart';
import '../widgets/listing_tile.dart';
import 'my_cards_screen.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});
  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeDisclaimer());
  }

  Future<void> _maybeDisclaimer() async {
    if (ref.read(communityDisclaimerSeenProvider)) return;
    final t = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(t.communityDisclaimerTitle),
        content: Text(t.communityDisclaimerBody),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t.communityDisclaimerOk),
          ),
        ],
      ),
    );
    await ref.read(prefsProvider).setBool('communityDisclaimerSeen', true);
    ref.read(communityDisclaimerSeenProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final recent = ref.watch(recentListingsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: Text(t.sellOrTrade),
        onPressed: () {
          if (!requireSignIn(context, ref)) return;
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const MyCardsScreen(startDuplicates: true)));
        },
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            readOnly: true,
            onTap: () => context.push('/search'),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: t.searchCardHint,
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextButton.icon(
              icon: const Icon(Icons.sell),
              label: Text(t.myListings),
              onPressed: () {
                if (!requireSignIn(context, ref)) return;
                context.push('/my-listings');
              },
            ),
          ),
        ),
        Expanded(
          child: recent.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noListings))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => ListingTile(
                      listing: list[i],
                      onTap: () => context.push('/listing/${list[i].id}',
                          extra: list[i]),
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}
```

> **Nota:** `requireSignIn(BuildContext, WidgetRef)` devolve `bool` (`true` = autenticado; `false` = mostrou o diálogo de login). O padrão `if (!requireSignIn(context, ref)) return;` está correto.

- [ ] **Step 2: Wire the 5th tab + routes in `app_router.dart`**

No `_Shell.build`:
- `titles`: `[t.tabHome, t.tabSets, t.tabBinder, t.tabCommunity, t.tabProfile]`
- `_tabs` (onde estiver definido): inserir `const CommunityScreen()` na 4ª posição (antes do Perfil).
- `destinations`: inserir antes do Perfil:
```dart
          NavigationDestination(
              icon: const Icon(Icons.storefront), label: t.tabCommunity),
```
Nas `routes:` da `GoRouter`, acrescentar:
```dart
    GoRoute(path: '/my-cards', builder: (_, __) => const MyCardsScreen()),
    GoRoute(path: '/my-listings', builder: (_, __) => const MyListingsScreen()),
    GoRoute(
      path: '/listing/:id',
      builder: (_, s) => ListingDetailScreen(listing: s.extra as Listing),
    ),
    GoRoute(
      path: '/community/card/:id',
      builder: (_, s) => CardListingsScreen(cardId: s.pathParameters['id']!),
    ),
```
(Importar `community_screen.dart`, `my_cards_screen.dart`, `my_listings_screen.dart`, `listing_detail_screen.dart`, `card_listings_screen.dart`, e `domain/entities/listing.dart`. `MyListingsScreen`, `ListingDetailScreen`, `CardListingsScreen` chegam na Task 12 — implementar Task 12 antes do `analyze` global.)

- [ ] **Step 3: Commit**

```bash
git add lib/presentation/screens/community_screen.dart lib/core/router/app_router.dart
git commit -m "feat(comunidade): ecra Comunidade + 5o tab + disclaimer + rotas"
```

---

### Task 12: Detalhe do anúncio, anúncios por carta, Os meus anúncios, Slots/Premium, entrada no Binder

**Files:**
- Create: `lib/presentation/screens/listing_detail_screen.dart`
- Create: `lib/presentation/screens/card_listings_screen.dart`
- Create: `lib/presentation/screens/my_listings_screen.dart`
- Modify: `lib/presentation/screens/my_binder_screen.dart` (botão "Vender ou trocar cartas")
- Modify: `lib/presentation/screens/settings_screen.dart` (linha "Slots e Premium")

**Interfaces:**
- Consumes: `Listing`, `listingsForCardProvider`, `myListingsProvider`, `marketTierProvider`, `marketServiceProvider`, `MarketTier`, `requireSignIn`, `ListingTile`.
- Produces: `ListingDetailScreen({required Listing listing})`, `CardListingsScreen({required String cardId})`, `MyListingsScreen()`, e secção de Slots/Premium (com interruptor DEV `setTier`).

> Verificação automática: `analyze` + `flutter test` (toda a suite). Fluxos Firestore (denunciar/bloquear/apagar/feed) = dispositivo.

- [ ] **Step 1: `listing_detail_screen.dart`**

```dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        if (listing.wantText != null && listing.wantText!.isNotEmpty)
          ListTile(title: Text(t.whatIWant), subtitle: Text(listing.wantText!)),
        if (listing.note != null && listing.note!.isNotEmpty)
          ListTile(title: Text(t.noteOptional), subtitle: Text(listing.note!)),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: null, // Fase 2: chat
          icon: const Icon(Icons.chat_bubble_outline),
          label: Text(t.contactSoon),
        ),
      ]),
    );
  }
}
```

- [ ] **Step 2: `card_listings_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/listing_tile.dart';

class CardListingsScreen extends ConsumerWidget {
  final String cardId;
  const CardListingsScreen({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final listings = ref.watch(listingsForCardProvider(cardId));
    return Scaffold(
      appBar: AppBar(title: Text(t.recentListings)),
      body: listings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) => list.isEmpty
            ? Center(child: Text(t.noListings))
            : ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => ListingTile(
                  listing: list[i],
                  onTap: () =>
                      context.push('/listing/${list[i].id}', extra: list[i]),
                ),
              ),
      ),
    );
  }
}
```

- [ ] **Step 3: `my_listings_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/market_tier.dart';
import '../../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../widgets/listing_tile.dart';

class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final mine = ref.watch(myListingsProvider);
    final tier = ref.watch(marketTierProvider).valueOrNull ?? 0;
    final active = ref.watch(activeListingsCountProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t.myListings)),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(t.slotsUsed(active, MarketTier.slotsFor(tier)),
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Expanded(
          child: mine.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (list) => list.isEmpty
                ? Center(child: Text(t.noListings))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final l = list[i];
                      return Dismissible(
                        key: ValueKey(l.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) => ref
                            .read(marketServiceProvider)
                            .deleteListing(l.id, l.ownerUid),
                        child: ListingTile(listing: l),
                      );
                    },
                  ),
          ),
        ),
      ]),
    );
  }
}
```

- [ ] **Step 4: Botão no `my_binder_screen.dart`**

No topo do `ListView` (a seguir ao subtítulo "N sets seguidos", ≈ linha 60), inserir:
```dart
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.storefront),
                label: Text(AppLocalizations.of(context)!.sellOrTrade),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const MyCardsScreen())),
              ),
            ),
```
(Importar `import 'my_cards_screen.dart';` no topo do ficheiro.)

- [ ] **Step 5: Secção Slots/Premium no `settings_screen.dart`**

Acrescentar uma `ListTile` (perto da Wishlist) que abre um diálogo simples com os 4 níveis e um botão por nível que chama `setTier` (interruptor DEV):
```dart
          ListTile(
            leading: const Icon(Icons.workspace_premium),
            title: Text(AppLocalizations.of(context)!.premiumSlots),
            subtitle: Text('${MarketTier.slotsFor(ref.watch(marketTierProvider).valueOrNull ?? 0)} slots'),
            onTap: () async {
              final uid = ref.read(authStateProvider).valueOrNull?.uid;
              if (uid == null) return;
              final svc = ref.read(marketServiceProvider);
              await showDialog<void>(
                context: context,
                builder: (_) => SimpleDialog(
                  title: Text(AppLocalizations.of(context)!.premiumSlots),
                  children: [
                    for (var i = 0; i < MarketTier.slots.length; i++)
                      SimpleDialogOption(
                        onPressed: () {
                          svc.setTier(uid, i);
                          Navigator.of(context).pop();
                        },
                        child: Text('Nível $i — ${MarketTier.slots[i]} slots'),
                      ),
                  ],
                ),
              );
            },
          ),
```
(Importar `market_tier.dart` e garantir que `marketServiceProvider`/`marketTierProvider`/`authStateProvider` estão acessíveis.)

- [ ] **Step 6: Run analyze + full test suite**

Run: `C:\src\flutter\bin\flutter.bat analyze`
Expected: "No issues found!"
Run: `C:\src\flutter\bin\flutter.bat test`
Expected: todos os testes passam (10 antigos + novos das Tasks 1,2,3,8,9).

- [ ] **Step 7: Commit**

```bash
git add lib/presentation/screens/listing_detail_screen.dart lib/presentation/screens/card_listings_screen.dart lib/presentation/screens/my_listings_screen.dart lib/presentation/screens/my_binder_screen.dart lib/presentation/screens/settings_screen.dart lib/core/router/app_router.dart
git commit -m "feat(comunidade): detalhe, anuncios por carta, os meus anuncios, slots/premium, entrada no binder"
```

---

## Verificação final (utilizador, em dispositivo)

Depois das 12 tarefas, o utilizador valida no telemóvel:
1. `firebase deploy --only firestore:rules`.
2. `flutter run` → separador **Comunidade** aparece; 1ª entrada mostra o **disclaimer**.
3. **O meu binder → Vender ou trocar cartas** → selecionar várias → **Publicar** → confirmar que aparecem no feed.
4. Pesquisar a carta → ver o anúncio; **Denunciar**/**Bloquear** funcionam.
5. **Os meus anúncios** → apagar liberta slot. Mudar nível em **Slots e Premium** muda o limite.
6. Tentar exceder os 20 slots no nível grátis → bloqueia com aviso.

## Fora de âmbito (Fase 2+)
Chat/mensagens, pagamento real (Play Billing), painel de moderação, preço estruturado, propostas/contra-propostas, filtros por região.
```

