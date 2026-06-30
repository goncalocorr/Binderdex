# Play Billing para o premium — Design

Data: 2026-06-30
Estado: aprovado (brainstorming)

## Objetivo

Transformar o premium (hoje um marcador `marketTier` escrito pelo cliente) em
**subscrições reais** via Google Play Billing, com **verificação no servidor** e
**notificações em tempo real (RTDN)** para renovações/cancelamentos.

Só **Android** nesta fase. iOS fica fora de âmbito.

## Decisões (do brainstorming)

- **Modelo:** subscrição mensal (auto-renovável).
- **Níveis:** mantêm-se os 3 pagos — Treinador (1), Mestre (2), Lendário (3) —
  modelados como **1 produto de subscrição com 3 base plans**.
- **Verificação:** no servidor (Cloud Function + Google Play Developer API).
- **Estado da subscrição:** RTDN via Pub/Sub (renova/cancela em tempo real),
  com reverificação no arranque como rede de segurança.

## Princípio central

A app **nunca** escreve `marketTier`. Só as Cloud Functions (admin SDK, que
ignoram as regras) e o admin (concessões manuais) o fazem. O
`marketTierProvider` continua a ler `users/{uid}.marketTier` exatamente como
hoje — **nenhum ecrã/consumidor de premium muda** (PremiumScreen é a exceção,
que passa a comprar a sério).

## Arquitetura

```
App (in_app_purchase)  ──compra──>  Google Play
        │                              │
        │ purchaseToken                │ RTDN (renova/cancela)
        ▼                              ▼
 verifyPurchase (callable) ◄─── Play Developer API
        │                              ▲
        ▼                              │
   Firestore users/{uid}        playRtdn (Pub/Sub trigger)
   (marketTier + validade)  ◄────────┘
```

## Produtos (Play Console)

Subscrição `binderdex_premium` com 3 base plans auto-renováveis mensais:

| Base plan id | Tier | Preço |
|---|---|---|
| `treinador` | 1 | 1,99 €/mês |
| `mestre` | 2 | 3,99 €/mês |
| `lendario` | 3 | 6,99 €/mês |

- Upgrade/downgrade entre base plans usa o *replacement mode* da Play
  (proporção/charge prorated).
- Os preços apresentados na app vêm da **loja** (`ProductDetails`), não
  hardcoded. As constantes em `MarketTier.prices` ficam só como reserva/teaser.

## Cliente (Flutter)

### Dependências
- `in_app_purchase` (+ `in_app_purchase_android` transitivo).

### `BillingService` (novo, `lib/data/remote/billing_service.dart`)
- `init()`: verifica `InAppPurchase.isAvailable()`, subscreve `purchaseStream`.
- `loadOffers()`: `queryProductDetails({'binderdex_premium'})` → devolve os base
  plans disponíveis (no Android, um `ProductDetails`/offer por base plan).
- Mapeamento `basePlanId → tier`: `{ treinador: 1, mestre: 2, lendario: 3 }`.
- `buy(tier)`: lança `buyNonConsumable` com o `GooglePlayPurchaseParam` do offer
  certo; para troca de plano usa `changeSubscriptionParam` (upgrade/downgrade).
- `restore()`: `restorePurchases()` (botão exigido pela Play).
- No `purchaseStream`, para `purchased`/`restored`:
  1. chama a callable `verifyPurchase` com `{ purchaseToken, basePlanId }`;
  2. `completePurchase(purchase)`.
  Para `error`/`canceled`: mostra mensagem; não concede nada.
- O `marketTier` **não** é escrito pelo cliente — vem do Firestore depois da
  função validar.

### `PremiumScreen` (religado)
- Lê os offers via `BillingService.loadOffers()`; mostra preços da loja.
- Botão por nível: se não tens nada → "Subscrever"; se tens outro → "Mudar para";
  o atual → "Plano atual".
- Botão **"Restaurar compras"**.
- Remove o caminho `marketServiceProvider.setTier(...)` (client-trusted).

### Reverificação no arranque
- No arranque (ou ao abrir o PremiumScreen), se houver `purchaseToken` guardado,
  chama `verifyPurchase` para reconfirmar (rede de segurança além do RTDN).

## Cloud Functions

### `verifyPurchase` (callable `onCall`, região europe-west1)
- Input: `{ purchaseToken, basePlanId }`. `context.auth.uid` obrigatório.
- Valida o token com a Play Developer API
  (`androidpublisher.purchases.subscriptionsv2.get`).
- Confirma que a subscrição está ativa e qual o base plan → calcula `tier` e
  `expiryMs`.
- Escreve `users/{uid}`: `marketTier`, `sub{...}`, `updatedAt`.
- Grava `purchaseTokens/{token}` → `{ uid, basePlanId }` (para o RTDN resolver o
  dono).
- Devolve `{ tier, expiryMs, state }`.

### `playRtdn` (trigger Pub/Sub no tópico de RTDN)
- Descodifica a `SubscriptionNotification` (base64 → JSON).
- Resolve o `uid` por `purchaseTokens/{token}`.
- Reconsulta a Play Developer API com o token (fonte de verdade).
- Atualiza `users/{uid}`: renovou/em-período-de-graça → mantém tier + nova
  validade; expirou/cancelou/revogado/em-espera → `marketTier = 0` + estado.
- A lógica já existente em `app_router` (repor avatar premium quando o tier
  deixa de ser premium) trata do efeito colateral no cliente.

### Credenciais
- Service account com a Play Developer API; chave acessível à função (Secret
  Manager ou conta de serviço da função com o papel certo na Play Console).

## Modelo de dados (Firestore)

`users/{uid}` (campos novos):
```
marketTier: int               // escrito só por functions/admin
sub: {
  productId: string,          // 'binderdex_premium'
  basePlanId: string,         // 'treinador' | 'mestre' | 'lendario'
  state: string,              // 'active' | 'grace' | 'expired' | 'canceled' | ...
  expiryMs: int,
  autoRenewing: bool,
  purchaseToken: string,
  updatedAt: timestamp
}
```

`purchaseTokens/{token}` (só functions):
```
{ uid: string, basePlanId: string }
```

## Regras do Firestore (alteração de segurança)

Hoje: `users/{uid}` permite escrita livre do próprio (logo, `marketTier`
falsificável). Mudança:

- O **próprio** utilizador pode escrever só os campos legítimos:
  `name`, `avatar`, `fcmTokens`, `notifyCards`, `acceptedTerms`,
  `acceptedTermsAt`, `appealed`, `warning` (limpar).
- O próprio **não** pode escrever `marketTier` nem `sub`.
- O **admin** (`isAdmin()`) continua a poder escrever tudo (concessões manuais
  via painel admin).
- As **Cloud Functions** (admin SDK) ignoram as regras.
- `purchaseTokens/**`: sem acesso ao cliente.

Implementação: validar no `allow update` que as chaves alteradas
(`request.resource.data.diff(resource.data).affectedKeys()`) são um subconjunto
da lista permitida, exceto quando `isAdmin()`.

## Fluxos

- **Subscrever:** escolher nível → compra Play → `verifyPurchase` → `marketTier`
  atualizado → UI reflete (stream).
- **Upgrade/downgrade:** `changeSubscriptionParam` com replacement mode → nova
  compra → `verifyPurchase` recalcula o tier.
- **Restaurar:** `restorePurchases()` → reentra no stream → `verifyPurchase`.
- **Renovação:** RTDN → `playRtdn` mantém o tier e estende a validade.
- **Expiração/cancelamento:** RTDN → `playRtdn` põe `marketTier = 0`.

## O que o utilizador cria (console/GCP)

1. Subscrição `binderdex_premium` + base plans `treinador`/`mestre`/`lendario`
   (preços acima), na Play Console.
2. Ativar a **Google Play Developer API** no GCP e criar **service account**;
   conceder acesso na Play Console (Users & permissions / API access).
3. Criar **tópico Pub/Sub** e ligá-lo em *Monetization setup → Real-time
   developer notifications* na Play Console.
4. Adicionar **testadores de licença** (Play Console → License testing) para
   compras de teste sem cobrança (renovações aceleradas em teste).
5. Após o 1.º upload: o SHA-1 do *Play App Signing* já está na checklist de
   lançamento (necessário para o login Google; não bloqueia o Billing).

## Testes

- **Lógica pura (unit):** mapeamento `basePlanId → tier`; cálculo de tier/estado
  a partir da resposta da Play Developer API (com fixtures); descodificação da
  notificação RTDN. Estas correm sem rede.
- **Fim-a-fim:** só possível com a app num *track* de teste da Play + testador de
  licença (compra de teste, renovação acelerada). Documentar passos.
- As funções: testar a transformação resposta-Play → escrita Firestore com
  mocks; não chamar a Play real nos testes.

## Fora de âmbito

- **iOS / App Store.**
- Promoções, trials, ofertas introdutórias (podem vir depois; a estrutura de
  offers já as suporta).
- Reembolsos manuais (a Play trata; o RTDN reflete via `playRtdn`).

## Riscos / notas

- Não dá para validar o fluxo completo sem a app na Play Console — o código fica
  pronto, mas o teste fim-a-fim depende do upload (internal testing).
- A mudança às regras do Firestore tem de ser cuidadosa para não bloquear
  escritas legítimas existentes (avatar, fcmTokens, consentimento, etc.).
- Migração: utilizadores a quem o admin deu premium manualmente continuam com
  `marketTier` definido; não têm `sub` (sem token) — o `playRtdn`/reverificação
  ignora-os (só atua sobre tokens conhecidos).
