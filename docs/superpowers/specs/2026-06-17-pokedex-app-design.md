# Especificação de Design — App Caderneta de Cartas Pokémon (TCG)

- **Data:** 2026-06-17 (revisto: pivot de Pokédex de criaturas → caderneta de cartas TCG)
- **Estado:** Desenho aprovado; implementação em curso
- **Fonte de dados:** Pokémon TCG API — https://pokemontcg.io (v2)

---

## 1. Visão Geral

App móvel **Flutter/Dart** para a Google Play: uma **caderneta de cartas colecionáveis
Pokémon (TCG)**. O fluxo é:

1. **Coleções (sets oficiais)** — o ecrã inicial lista as expansões (Base Set, 151,
   Scarlet & Violet…), cada uma com progresso (ex.: *37/102*).
2. **Cartas do set** — ao abrir um set, vê-se a grelha de cartas; o utilizador marca
   quais **tem**.
3. **Detalhe da carta** — imagem grande e registo de coleção.

**Local-first / offline-first**, com sincronização opcional na nuvem.

### Princípios

- **Local-first:** utilizável offline e sem conta.
- **Sync opcional:** nuvem só para manter a coleção entre dispositivos.
- **Privacidade primeiro:** dados mínimos, sem tracking, conforme RGPD.
- **Arquitetura limpa por camadas:** data / domain / presentation.
- **Pronta para freemium:** pontos premium marcados, sem pagamentos nesta fase.

---

## 2. Stack Técnica

| Área | Escolha |
|------|---------|
| Framework | Flutter + Dart |
| Estado | Riverpod |
| BD local (offline-first) | Drift (SQLite tipado; web via WASM) |
| Nuvem | Firebase: Auth (Anonymous + Google + email) e Cloud Firestore |
| HTTP | dio (cliente da Pokémon TCG API) |
| Imagens | cached_network_image (URLs das cartas da TCG API) |
| Navegação | GoRouter |
| i18n | flutter_localizations + intl (.arb: PT + EN) |
| UI | Material 3, claro/escuro/sistema |

**Publicação:** minSdk 26, só permissão de Internet, pronto para **.aab** assinado.

---

## 3. Fonte de Dados e Estratégia Offline

**Pokémon TCG API (pokemontcg.io v2):**
- `GET /v2/sets` — todos os sets (~160). Pequeno.
- `GET /v2/cards?q=set.id:"<id>"` — cartas de um set (paginação até 250/página).
- Campos da carta usados: `id`, `name`, `number`, `rarity`, `supertype`, `types`,
  `images.small/large`, `set`.
- **Chave de API opcional** (header `X-Api-Key`): começa-se **sem chave**; há um slot de
  config (`lib/core/config/tcg_config.dart`) para a adicionar (mais pedidos/dia).

**Estratégia:**
- A **lista de sets** é gerada por `tool/generate_tcg_sets.dart` e **incluída** em
  `assets/data/tcg_sets.json` → o ecrã inicial abre offline. Atualiza em segundo plano.
- As **cartas de um set** são buscadas à API **quando o set é aberto** e ficam em cache no
  Drift (`cardsSynced` por set). A partir daí, esse set funciona offline.
- Imagens via `cached_network_image`. **Silhueta/placeholder** enquanto não há cache.

---

## 4. Modelo de Domínio

- **`CardSet`** — id, name, series, printedTotal, total, releaseDate, symbolUrl, logoUrl.
  (Denominador de progresso = `total`.)
- **`TcgCard`** — id, setId, name, number, numberSort, rarity?, supertype?, type?,
  imageSmall, imageLarge.
- **`CardVariant`** — enum: normal, holo, reverseHolo.
- **`UserCardEntry`** — cardId, owned, quantity, variant, notes, updatedAt, dirty.
- **`ProgressStats`** — total, owned (→ missing, percent).
- **`CardFilter`** — query (nome/número), rarity?, status (all/owned/missing).

---

## 5. Base de Dados (Drift) e Queries

Tabelas: `card_sets`, `tcg_cards`, `user_card_entries`.

- **Filtros/pesquisa de cartas em SQL** (WHERE/LIKE/índices), nunca em memória.
- **Sets com progresso:** subquery agregada (owned por setId) — para o ecrã inicial.
- **Progresso global e por set** calculado em SQL.
- Ligação por plataforma já existente (`data/local/connection/`): nativo (FFI) vs WASM.

---

## 6. Autenticação, Sincronização e Conflitos (Etapa 2)

- **Login opcional**: app abre em convidado. Sync opt-in com **Firebase Anonymous Auth** e
  `linkWithCredential` (Google/email) sem perder dados locais.
- **Offline-first:** escreve primeiro no Drift (`dirty=true`); sync envia ao Firestore.
- Estrutura Firestore: `users/{uid}/cards/{cardId}`.
- **Conflitos:** última escrita vence pelo **server timestamp do Firestore**.

---

## 7. Segurança, Privacidade e Publicação (Etapa 2/3 — inalterado)

### 7.1 Regras Firestore (fechadas por omissão)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/cards/{cardId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /{document=**} { allow read, write: if false; }
  }
}
```

### 7.2 Privacidade / RGPD
Política de privacidade estática; minimização (email opcional + coleção); exportar coleção;
direito ao esquecimento; consentimento (sync opt-in).

### 7.3 Eliminação de conta
> Armadilhas: apagar `users/{uid}` não apaga a subcoleção `cards/` (apagar em `WriteBatch`
> ou `recursiveDelete` via Cloud Function); `user.delete()` exige **reautenticação**.

Na app: reautenticar → eliminar dados (Cloud Function recomendada com fallback cliente) →
limpar Drift. Via web: página pública de pedido de eliminação.

### 7.4 Data Safety
Mapa dos dados (email opcional, coleção; não partilhados; encriptados em trânsito;
eliminação disponível).

---

## 8. Ecrãs (Presentation)

1. **Coleções (sets)** — ecrã inicial. Cards com logótipo, nome, série, progresso. Pesquisa.
2. **Cartas do set** — grelha; carta com imagem, número, raridade. Não possuídas em
   silhueta/apagado, possuídas a cores; badge de variante. Pesquisa + filtros (tenho/falta,
   raridade). Indicador de carregamento durante a sincronização do set.
3. **Detalhe da carta** — imagem grande, set, raridade, tipo, e controlos: Tenho,
   Quantidade, Variante (normal/holo/reverse), Notas.
4. **Progresso** — global e por set.
5. **Em falta** — cartas em falta.
6. **Definições** — idioma, tema, (Etapa 2) sync/conta, exportar, eliminar conta, Premium.

---

## 9. Monetização (preparar, não implementar)
`core/premium/` com `PremiumGate`/`entitlementProvider` (tudo desbloqueado). Pontos
candidatos marcados `// ⭐ PREMIUM:` (ex.: notas ilimitadas, temas extra, backup avançado).

## 10. i18n e Tema
intl PT/EN; Material 3 claro/escuro; cores por tipo/raridade.

## 11. Testes e Verificação
Unitários (filtros de cartas, progresso) e widget (carta possuída vs silhueta). Verificação:
`flutter analyze` + `flutter test` + `flutter build web`; capturas pelo utilizador no Chrome.

## 12. Publicação (.aab)
minSdk 26; permissão Internet; ícone/splash; keystore + `key.properties`;
`flutter build appbundle`.

## 13. Fora de Âmbito (YAGNI)
Pagamentos reais; trocas/social; condição da carta (pode vir depois); múltiplas variantes
em simultâneo por carta (MVP: uma variante por registo).
