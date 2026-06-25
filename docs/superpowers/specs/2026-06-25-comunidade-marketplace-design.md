# Comunidade — Marketplace de troca/venda de cartas (Fase 1)

**Data:** 2026-06-25
**App:** Binderdex (Flutter, pacote `pokedex`)
**Estado:** Desenho aprovado, pronto para plano de implementação.

---

## 1. Resumo

Nova área **Comunidade**: um marketplace onde os utilizadores publicam cartas que
**possuem** (tipicamente **repetidas**) para **trocar**, **vender** ou **ambos**.
Outros utilizadores **pesquisam** por uma carta e veem quem a oferece, ou navegam
um **feed** de anúncios recentes.

É a **primeira funcionalidade social/multi-utilizador** da app. Até agora todo o
Firestore é privado (`users/{uid}/cards`, só o dono lê/escreve). O marketplace
introduz dados **públicos partilhados** (coleção `listings/`) com **novas regras
de segurança**.

### Decomposição em sub-projetos

- **Fase 1 (este spec): Marketplace.** Anúncios, publicação a partir das cartas
  possuídas, ecrã Comunidade (pesquisa + feed), "Os meus anúncios" + slots,
  níveis premium (apenas marcadores, sem pagamento), denunciar/bloquear, regras
  de segurança, aviso legal na 1.ª entrada.
- **Fase 2 (spec próprio, mais tarde): Chat.** Mensagens entre utilizadores. Na
  Fase 1 o botão **"Contactar"** aparece como **"em breve"** (desativado).

### Decisões fechadas

| Tema | Decisão |
|---|---|
| Contacto comprador/vendedor | Chat na app — **Fase 2** (placeholder "em breve" na Fase 1) |
| Premium/pagamento | **Só a mecânica de slots** (marcadores). Sem Play Billing por agora |
| Origem das cartas | Só cartas que o utilizador **possui** |
| Campos do anúncio | **Condição**, **O que quero em troca**, **Nota livre**. **Sem campo de preço** (preço combinado no chat/nota) |
| Ecrã Comunidade | **Pesquisa + feed recente** |
| Slots por nível | Grátis **20** · Premium 1 **100** · Premium 2 **200** · Premium 3 **500** |
| Moderação | **Denunciar + Bloquear** |
| Seleção para publicar | Nova grelha **"As minhas cartas"** com **seleção múltipla** (de todos os sets) |
| Definições ao publicar várias | **Mesmas opções para todas**; editar cada anúncio depois |
| Entradas para publicar | A partir de **"O meu binder"** (todas as cartas) **e** da **Comunidade** (filtro "Só repetidas" ligado por omissão) |
| Aviso legal | Popup de isenção de responsabilidade na **1.ª entrada** (guardado em `shared_preferences`); texto a afinar depois |

---

## 2. Arquitetura

Mantém a estrutura em camadas existente: `domain/` (entidades) → `data/`
(Drift local + remoto Firestore + repositórios) → `presentation/`
(screens/widgets/providers) → `core/` (theme/router). Estado: Riverpod.

**Modelo de dados Firestore escolhido (Opção A): coleção de topo `listings/`.**
Cada anúncio é um documento independente com os dados da carta e do dono
**desnormalizados** (para mostrar no feed sem 2.ª leitura). Alternativas
rejeitadas: índice agregado por carta (`market/{cardId}` com array — bate nos
limites de tamanho/concorrência de documento) e anúncios aninhados por user
(duplicação sem benefício para esta escala).

---

## 3. Modelo de dados

### 3.1 Firestore

```
listings/{listingId}
  ownerUid: string                       // dono (== quem escreve)
  ownerName: string                      // desnormalizado do perfil
  ownerAvatar: string                    // id/URL do avatar
  cardId: string                         // id da carta (catálogo TCG)
  cardName: string                       // desnormalizado
  cardImage: string                      // URL da imagem
  setId: string
  mode: 'trade' | 'sell' | 'both'
  condition: 'mint' | 'good' | 'used' | 'damaged'
  wantText: string?                      // "o que quero em troca" (máx. 280)
  note: string?                          // nota livre (máx. 280)
  status: 'active'                       // (futuro: 'closed')
  createdAt: serverTimestamp
  updatedAt: serverTimestamp

users/{uid}
  marketTier: 0 | 1 | 2 | 3              // marcador premium (0=grátis). default 0
  activeListings: int                    // contador de anúncios ativos (transação)

users/{uid}/blocks/{blockedUid}
  createdAt: serverTimestamp             // quem este user bloqueou

reports/{reportId}
  listingId: string
  reporterUid: string                    // == quem escreve
  reason: string
  createdAt: serverTimestamp
```

Limites de slots por `marketTier`: `[20, 100, 200, 500]`.

### 3.2 Drift (local) — query nova

Para a grelha **"As minhas cartas"** precisamos de listar **todas as cartas
possuídas** (qualquer variante) entre todos os sets, com indicação de
**duplicado**:

```dart
// AppDatabase
Future<List<OwnedCardRow>> ownedCards({bool onlyDuplicates = false});
// SELECT c.* , (e.qty_normal>1 OR e.qty_holo>1 OR e.qty_reverse>1) AS is_dupe
// FROM tcg_cards c JOIN user_card_entries e ON e.card_id = c.id
// WHERE (e.owned_normal=1 OR e.owned_holo=1 OR e.owned_reverse=1)
// [AND is_dupe quando onlyDuplicates]
// ORDER BY c.set_id, c.number
```

(Reaproveita o padrão `customSelect` já usado em `database.dart`. Sem alterações
de schema → **não** é preciso `build_runner`.)

### 3.3 Entidades de domínio

```dart
// domain/entities/listing.dart
enum TradeMode { trade, sell, both }
enum CardCondition { mint, good, used, damaged }

class Listing {
  final String id, ownerUid, ownerName, ownerAvatar;
  final String cardId, cardName, cardImage, setId;
  final TradeMode mode;
  final CardCondition condition;
  final String? wantText, note;
  final DateTime createdAt;
  // fromMap / toMap para Firestore
}

// domain/entities/market_tier.dart
class MarketTier {
  static const slots = [20, 100, 200, 500];
  static int slotsFor(int tier) => slots[tier.clamp(0, slots.length - 1)];
}
```

---

## 4. Camada de dados (remoto)

```dart
// data/remote/market_service.dart  (novo)
class MarketService {
  // Feed: anúncios recentes (paginado).
  Stream<List<Listing>> watchRecent({int limit = 30});
  // Anúncios de uma carta específica.
  Stream<List<Listing>> watchForCard(String cardId);
  // Os meus anúncios ativos.
  Stream<List<Listing>> watchMine(String uid);

  // Publicar N cartas com as mesmas opções (transação: cria docs + incrementa
  // users/{uid}.activeListings). Lança se exceder o limite de slots.
  Future<void> publish({required List<CardRef> cards, required TradeMode mode,
      required CardCondition condition, String? wantText, String? note});

  Future<void> updateListing(Listing l);
  Future<void> deleteListing(String id); // transação: apaga + decrementa contador
  Future<void> report({required String listingId, required String reason});
  Future<void> block(String uid);
  Future<void> unblock(String uid);
  Stream<Set<String>> watchBlocked(); // ids bloqueados (filtro no cliente)
  Future<void> setTier(int tier);      // DEV/teste; futuro: servidor
}
```

O serviço escreve `ownerName`/`ownerAvatar` a partir do perfil atual
(`ProfileService`/providers de perfil já existentes).

---

## 5. Apresentação (ecrãs e fluxos)

### 5.1 Navegação

Acrescentar **5.º separador** à `NavigationBar` em
`lib/core/router/app_router.dart` (`_Shell`): **Início / Coleções / O meu binder
/ Comunidade / Perfil**. Atualizar `_tabs`, `titles` e `destinations`. Ícone
sugerido: `Icons.storefront`.

### 5.2 Ecrã **Comunidade** (`community_screen.dart`)

- Barra de **pesquisa de carta** (reutiliza o catálogo local para resolver a
  carta pelo nome). Ao escolher uma carta → navega para a **lista de anúncios
  dessa carta**.
- **Feed** dos anúncios recentes (`watchRecent`), com paginação. Cada item =
  `ListingTile` (imagem da carta + nome + dono + chips de modo/condição).
- Botão **"+ Vender/Trocar"** (FAB ou ação no topo) → abre **"As minhas cartas"**
  com o filtro **"Só repetidas" ligado**.
- Ação no topo → **"Os meus anúncios"**.
- Anúncios de utilizadores bloqueados são filtrados no cliente.
- **Convidados:** veem feed/pesquisa; qualquer ação de escrita chama
  `requireSignIn` (padrão existente em `auth_guard.dart`).

### 5.3 **Aviso legal (1.ª entrada)**

Na primeira abertura da Comunidade, `showDialog` com texto-base de isenção de
responsabilidade (negócios entre utilizadores, risco de burla, etc.) + botão
**"Compreendo"**. Persistir flag `communityDisclaimerAccepted` em
`shared_preferences` (novo provider, a par de `onboardingDoneProvider`). Texto
colocado em l10n (`app_pt.arb`/`app_en.arb`) para afinar depois.

### 5.4 **Detalhe do anúncio** (`listing_detail_screen.dart`)

Imagem + info da carta, **dono** (avatar+nome), modo/condição/o-que-quero/nota.
Botão **"Contactar"** desativado com etiqueta **"em breve"**. Menu overflow:
**Denunciar** (sheet com motivo → `report`) e **Bloquear** (confirma → `block`).

### 5.5 **"As minhas cartas"** (`my_cards_screen.dart`)

Grelha de todas as cartas possuídas (`ownedCards`). Filtro **"Só repetidas"**
(chip). **Modo de seleção** com checkboxes; barra inferior persistente
**"Adicionar à comunidade (N)"**. Entradas: botão em "O meu binder" (*"Vender ou
trocar cartas"*, sem filtro) e botão da Comunidade (com filtro de repetidas).

### 5.6 **Formulário de publicação** (`publish_sheet.dart`)

Bottom sheet aplicado às N cartas selecionadas: **modo** (trocar/vender/ambos),
**condição**, **o que quero**, **nota**. Mostra **slots usados (N/limite)**.
**Bloqueia** se `ativos + selecionadas > limite`, com convite a premium.
Confirmar → `MarketService.publish(...)`.

### 5.7 **"Os meus anúncios"** (`my_listings_screen.dart`)

Lista de `watchMine`, contador **N/limite** no topo, **editar** (reabre opções) e
**apagar** cada anúncio. Convite a premium quando perto/acima do limite.

### 5.8 **Slots & Premium** (secção/ecrã)

Mostra os 4 níveis (20/100/200/500). Sem pagamento: o nível muda por um
**interruptor de teste (DEV)** que chama `setTier`. Botão **"Desbloquear"**
preparado para ligar ao Play Billing na fase de monetização.

### 5.9 Rotas (GoRouter)

Adicionar: `/community/card/:id` (anúncios de uma carta), `/listing/:id`,
`/my-cards`, `/my-listings`. O separador Comunidade entra via `_tabs`.

---

## 6. Regras de segurança (`firestore.rules`)

```
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

match /reports/{id} {
  allow create: if request.auth != null
    && request.resource.data.reporterUid == request.auth.uid;
  allow read, update, delete: if false; // só consola/admin
}

match /users/{uid}/blocks/{blockedUid} {
  allow read, write: if request.auth != null && request.auth.uid == uid;
}
```

`users/{uid}` já permite escrita do próprio → cobre `marketTier` e
`activeListings`.

### Slots — aplicação

- **Cliente:** valida antes de publicar (bloqueia se exceder).
- **Servidor (reforço):** contador `users/{uid}.activeListings` mantido em
  **transação** ao criar/apagar anúncios; regra de `create` em `listings` valida
  `activeListings < limite(marketTier)` lendo o doc de perfil via
  `get(/databases/.../users/$(uid))`.

⚠️ **Limitação honesta:** como `marketTier` é escrito pelo próprio cliente nesta
fase, os limites **não são à prova de fraude** até ao pagamento real com
validação no servidor (Cloud Function/Play Billing). Aceitável para MVP/teste.

---

## 7. Privacidade / Play Store

Conteúdo gerado por utilizadores (UGC) público → atualizar a documentação legal
(`docs/legal/`) e o formulário **Data Safety** (recolha de nome/avatar visível a
outros, mecanismos de denúncia/bloqueio). Sem novos dados pessoais sensíveis.

---

## 8. Testes

Como o agente corre `flutter test` mas não compila Android nem acede ao
Firestore real, os testes da Fase 1 cobrem **lógica pura e widgets**, não a rede:

- **Slots:** `MarketTier.slotsFor`, e a função que decide "pode publicar N?"
  dado (ativos, tier) — incluindo limites exatos e excesso.
- **Query Drift:** `ownedCards(onlyDuplicates:)` num DB em memória —
  só possuídas; só repetidas quando pedido.
- **Mapeamento:** `Listing.fromMap/toMap` ida-e-volta.
- **Widget:** modo de seleção de "As minhas cartas" (selecionar/deselecionar
  atualiza o contador) e `ListingTile` (mostra modo/condição corretos).
- **Filtro de bloqueio:** dada uma lista de anúncios + ids bloqueados, o filtro
  remove os certos.

O fluxo Firestore real (publicar/feed/regras) é verificado pelo utilizador em
dispositivo.

---

## 9. Ficheiros (resumo)

**Novos:** `domain/entities/listing.dart`, `domain/entities/market_tier.dart`,
`data/remote/market_service.dart`, `presentation/screens/community_screen.dart`,
`listing_detail_screen.dart`, `my_cards_screen.dart`, `my_listings_screen.dart`,
`presentation/widgets/listing_tile.dart`, `publish_sheet.dart`, providers em
`app_providers.dart`, strings em `app_pt.arb`/`app_en.arb`.

**Alterados:** `core/router/app_router.dart` (5.º tab + rotas),
`data/local/database.dart` (`ownedCards`), `data/repositories/` (delegação),
`firestore.rules`, `my_binder_screen.dart` (botão "Vender ou trocar cartas"),
`docs/legal/` + Data Safety.

---

## 10. Fora de âmbito (Fase 1)

Chat/mensagens (Fase 2), pagamento real/Play Billing, painel de moderação,
preço estruturado, filtros por região/idioma, propostas/contra-propostas,
histórico de negócios.
