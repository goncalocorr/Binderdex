# Play Billing para o premium — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transformar o premium num conjunto de subscrições mensais reais via Google Play Billing, com verificação no servidor e notificações em tempo real (RTDN).

**Architecture:** Cliente (`in_app_purchase`) compra na Play; uma Cloud Function callable (`verifyPurchase`) valida o token com a Google Play Developer API e escreve `marketTier`+validade no Firestore; uma função Pub/Sub (`playRtdn`) reage a renovações/cancelamentos. A app nunca escreve `marketTier`.

**Tech Stack:** Flutter (`in_app_purchase`, `cloud_functions`), Firebase Cloud Functions v2 (Node 22, `googleapis`), Firestore, Pub/Sub.

Spec: [docs/superpowers/specs/2026-06-30-play-billing-premium-design.md](../specs/2026-06-30-play-billing-premium-design.md)

## Global Constraints

- Só **Android**. iOS fora de âmbito.
- A app **nunca** escreve `marketTier`/`sub`; só as Cloud Functions (admin SDK) e o admin.
- Produto de subscrição: `binderdex_premium`. Base plans → tier: `treinador`→1, `mestre`→2, `lendario`→3.
- Funções na região `europe-west1` (consistente com as existentes).
- Não commitar segredos (service account key fica no Secret Manager / conta de serviço da função).
- Português europeu nos comentários e copy.
- `flutter test` e `flutter analyze` correm localmente; o **build da app e o deploy das funções são feitos pelo utilizador**. O teste fim‑a‑fim do Billing exige a app num track de teste da Play (não automatizável).

---

## Task 1: Setup de Play Console + GCP (ações manuais do utilizador)

Esta tarefa não tem código nem testes automatizados — é a base sem a qual nada funciona. Marca cada item ao concluir na consola.

**Files:** nenhum (documentação operacional).

- [ ] **Play Console → Monetize → Subscriptions:** criar produto `binderdex_premium`.
- [ ] Adicionar 3 **base plans** auto-renováveis, mensais:
  - `treinador` — 1,99 €/mês
  - `mestre` — 3,99 €/mês
  - `lendario` — 6,99 €/mês
  - Ativar cada base plan.
- [ ] **GCP Console (projeto `binderdex-b1908`) → APIs & Services:** ativar **Google Play Android Developer API**.
- [ ] Criar uma **service account** dedicada; em **Play Console → Users and permissions**, convidar o email da service account com permissão de **View financial data / Manage orders and subscriptions** (acesso à API de compras).
- [ ] **GCP → Pub/Sub:** criar tópico `play-rtdn`. Dar ao publicador da Google Play (`google-play-developer-notifications@system.gserviceaccount.com`) o papel **Pub/Sub Publisher** nesse tópico.
- [ ] **Play Console → Monetization setup → Real-time developer notifications:** colar o nome completo do tópico (`projects/binderdex-b1908/topics/play-rtdn`) e enviar uma **test notification** (confirma a ligação).
- [ ] **Play Console → Setup → License testing:** adicionar a tua conta Google como testador de licença (compras de teste sem cobrança; renovações aceleradas).

**Nota:** a função usa a conta de serviço da própria função (App Engine default service account) com acesso concedido na Play, ou uma chave em Secret Manager. Decidir na Task 6 (preferir a conta de serviço da função sem chave exportada).

---

## Task 2: Dependências e harness de teste das functions

**Files:**
- Modify: `functions/package.json`
- Create: `functions/.gitignore` (se não cobrir já `node_modules`) — verificar primeiro

**Interfaces:**
- Produces: comando `npm test` (em `functions/`) a correr ficheiros `*.test.js` com o runner nativo do Node.

- [ ] **Step 1: Adicionar `googleapis` e o script de teste**

Em `functions/package.json`, na secção `dependencies` adicionar `"googleapis": "^144.0.0"` e em `scripts` adicionar `"test": "node --test"`.

```json
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "deploy": "firebase deploy --only functions",
    "logs": "firebase functions:log",
    "test": "node --test"
  },
  "dependencies": {
    "firebase-admin": "^13.0.0",
    "firebase-functions": "^6.1.0",
    "googleapis": "^144.0.0"
  }
```

- [ ] **Step 2: Instalar**

Run: `cd functions && npm install`
Expected: instala `googleapis`; `node_modules` atualizado.

- [ ] **Step 3: Smoke test do runner**

Criar `functions/sanity.test.js`:
```js
const { test } = require("node:test");
const assert = require("node:assert");
test("runner ok", () => assert.equal(1 + 1, 2));
```

Run: `cd functions && npm test`
Expected: 1 test passed.

- [ ] **Step 4: Remover o smoke test e commit**

```bash
rm functions/sanity.test.js
git add functions/package.json functions/package-lock.json
git commit -m "build(functions): googleapis + node:test runner"
```

---

## Task 3: Helper puro `tierForBasePlan` (+ test)

**Files:**
- Create: `functions/billing.js`
- Test: `functions/billing.test.js`

**Interfaces:**
- Produces: `tierForBasePlan(basePlanId): number` — `'treinador'→1`, `'mestre'→2`, `'lendario'→3`, desconhecido→`0`.

- [ ] **Step 1: Escrever o teste a falhar**

`functions/billing.test.js`:
```js
const { test } = require("node:test");
const assert = require("node:assert");
const { tierForBasePlan } = require("./billing");

test("tierForBasePlan mapeia os base plans", () => {
  assert.equal(tierForBasePlan("treinador"), 1);
  assert.equal(tierForBasePlan("mestre"), 2);
  assert.equal(tierForBasePlan("lendario"), 3);
});

test("tierForBasePlan desconhecido devolve 0", () => {
  assert.equal(tierForBasePlan("xpto"), 0);
  assert.equal(tierForBasePlan(undefined), 0);
});
```

- [ ] **Step 2: Correr — deve falhar**

Run: `cd functions && npm test`
Expected: FAIL (`Cannot find module './billing'`).

- [ ] **Step 3: Implementar**

`functions/billing.js`:
```js
/** Mapeia o base plan da subscrição para o nível (marketTier). */
const BASE_PLAN_TIER = { treinador: 1, mestre: 2, lendario: 3 };

function tierForBasePlan(basePlanId) {
  return BASE_PLAN_TIER[basePlanId] || 0;
}

module.exports = { tierForBasePlan, BASE_PLAN_TIER };
```

- [ ] **Step 4: Correr — deve passar**

Run: `cd functions && npm test`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add functions/billing.js functions/billing.test.js
git commit -m "feat(functions): tierForBasePlan + teste"
```

---

## Task 4: Helper puro `decodeRtdn` (+ test)

**Files:**
- Modify: `functions/billing.js`
- Test: `functions/billing.test.js`

**Interfaces:**
- Produces: `decodeRtdn(messageDataBase64): object|null` — descodifica o `message.data` (base64) do Pub/Sub para o JSON da `DeveloperNotification`. Devolve `null` se inválido.

- [ ] **Step 1: Adicionar testes**

Acrescentar a `functions/billing.test.js`:
```js
const { decodeRtdn } = require("./billing");

test("decodeRtdn descodifica subscriptionNotification", () => {
  const payload = {
    version: "1.0",
    packageName: "com.example.binderdex",
    eventTimeMillis: "123",
    subscriptionNotification: {
      version: "1.0",
      notificationType: 2,
      purchaseToken: "tok_abc",
      subscriptionId: "binderdex_premium",
    },
  };
  const b64 = Buffer.from(JSON.stringify(payload)).toString("base64");
  const out = decodeRtdn(b64);
  assert.equal(out.subscriptionNotification.purchaseToken, "tok_abc");
});

test("decodeRtdn devolve null para base64 invalido", () => {
  assert.equal(decodeRtdn("@@nao-base64@@"), null);
  assert.equal(decodeRtdn(undefined), null);
});
```

- [ ] **Step 2: Correr — deve falhar**

Run: `cd functions && npm test`
Expected: FAIL (`decodeRtdn is not a function`).

- [ ] **Step 3: Implementar**

Acrescentar a `functions/billing.js` (antes do `module.exports`):
```js
/** Descodifica o message.data (base64) do Pub/Sub para a DeveloperNotification. */
function decodeRtdn(dataBase64) {
  if (typeof dataBase64 !== "string" || dataBase64.length === 0) return null;
  try {
    const json = Buffer.from(dataBase64, "base64").toString("utf8");
    const obj = JSON.parse(json);
    return obj && typeof obj === "object" ? obj : null;
  } catch (_) {
    return null;
  }
}
```
E acrescentar `decodeRtdn` ao `module.exports`.

- [ ] **Step 4: Correr — deve passar**

Run: `cd functions && npm test`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add functions/billing.js functions/billing.test.js
git commit -m "feat(functions): decodeRtdn (RTDN payload) + teste"
```

---

## Task 5: Helper puro `subStateFromV2` (+ test)

Transforma a resposta da Play Developer API (`purchases.subscriptionsv2.get`) no estado que gravamos.

**Files:**
- Modify: `functions/billing.js`
- Test: `functions/billing.test.js`

**Interfaces:**
- Produces: `subStateFromV2(resp): { basePlanId, tier, expiryMs, state, autoRenewing, uid }`
  - `state`: `'active' | 'grace' | 'canceled' | 'on_hold' | 'paused' | 'expired' | 'unknown'`.
  - `tier`: `0` se não ativo/grace; senão `tierForBasePlan(basePlanId)`.
  - `uid`: de `resp.externalAccountIdentifiers.obfuscatedExternalAccountId` (ou `''`).
  - Lê o 1.º `lineItems[]` para `basePlanId`/`expiryTime`.
  - **Nota ao implementador:** confirmar os nomes dos campos contra a doc atual de `SubscriptionPurchaseV2` (subscriptionState, lineItems[].offerDetails.basePlanId, lineItems[].expiryTime, externalAccountIdentifiers.obfuscatedExternalAccountId, linkedPurchaseToken).

- [ ] **Step 1: Adicionar testes**

Acrescentar a `functions/billing.test.js`:
```js
const { subStateFromV2 } = require("./billing");

function v2(state, basePlanId, expiry, uid) {
  return {
    subscriptionState: state,
    externalAccountIdentifiers: { obfuscatedExternalAccountId: uid },
    lineItems: [
      { offerDetails: { basePlanId }, expiryTime: expiry },
    ],
  };
}

test("subStateFromV2 ativo concede o tier", () => {
  const r = subStateFromV2(
    v2("SUBSCRIPTION_STATE_ACTIVE", "mestre", "2026-08-01T00:00:00Z", "uid1")
  );
  assert.equal(r.tier, 2);
  assert.equal(r.state, "active");
  assert.equal(r.basePlanId, "mestre");
  assert.equal(r.uid, "uid1");
  assert.equal(r.expiryMs, Date.parse("2026-08-01T00:00:00Z"));
});

test("subStateFromV2 em graca mantem o tier", () => {
  const r = subStateFromV2(
    v2("SUBSCRIPTION_STATE_IN_GRACE_PERIOD", "treinador", "2026-08-01T00:00:00Z", "u")
  );
  assert.equal(r.tier, 1);
  assert.equal(r.state, "grace");
});

test("subStateFromV2 expirado zera o tier", () => {
  const r = subStateFromV2(
    v2("SUBSCRIPTION_STATE_EXPIRED", "lendario", "2026-01-01T00:00:00Z", "u")
  );
  assert.equal(r.tier, 0);
  assert.equal(r.state, "expired");
});
```

- [ ] **Step 2: Correr — deve falhar**

Run: `cd functions && npm test`
Expected: FAIL (`subStateFromV2 is not a function`).

- [ ] **Step 3: Implementar**

Acrescentar a `functions/billing.js`:
```js
const _STATE = {
  SUBSCRIPTION_STATE_ACTIVE: "active",
  SUBSCRIPTION_STATE_IN_GRACE_PERIOD: "grace",
  SUBSCRIPTION_STATE_CANCELED: "canceled",
  SUBSCRIPTION_STATE_ON_HOLD: "on_hold",
  SUBSCRIPTION_STATE_PAUSED: "paused",
  SUBSCRIPTION_STATE_EXPIRED: "expired",
};

/** Estados que mantêm o premium ativo. */
const _ACTIVE = new Set(["active", "grace"]);

function subStateFromV2(resp) {
  const state = _STATE[resp && resp.subscriptionState] || "unknown";
  const line = (resp && resp.lineItems && resp.lineItems[0]) || {};
  const basePlanId = (line.offerDetails && line.offerDetails.basePlanId) || "";
  const expiryMs = line.expiryTime ? Date.parse(line.expiryTime) : 0;
  const uid =
    (resp &&
      resp.externalAccountIdentifiers &&
      resp.externalAccountIdentifiers.obfuscatedExternalAccountId) ||
    "";
  const tier = _ACTIVE.has(state) ? tierForBasePlan(basePlanId) : 0;
  return { basePlanId, tier, expiryMs, state, autoRenewing: state === "active", uid };
}
```
E acrescentar `subStateFromV2` ao `module.exports`.

- [ ] **Step 4: Correr — deve passar**

Run: `cd functions && npm test`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add functions/billing.js functions/billing.test.js
git commit -m "feat(functions): subStateFromV2 (resposta Play -> estado) + teste"
```

---

## Task 6: Cloud Function `verifyPurchase` (callable)

**Files:**
- Create: `functions/verify_purchase.js`
- Modify: `functions/index.js` (registar)

**Interfaces:**
- Consumes: `tierForBasePlan`, `subStateFromV2` (de `billing.js`); `googleapis` androidpublisher.
- Produces: callable `verifyPurchase({ purchaseToken, basePlanId }) -> { tier, expiryMs, state }`.
  - Escreve `users/{uid}` (merge): `marketTier`, `sub{ productId, basePlanId, state, expiryMs, autoRenewing, purchaseToken, updatedAt }`.
  - Escreve `purchaseTokens/{token}` = `{ uid, basePlanId }`.
  - Se `resp.linkedPurchaseToken` existir, apaga `purchaseTokens/{linkedPurchaseToken}`.

Esta tarefa não tem teste automatizado (depende da Play API real). A lógica pura já está coberta nas Tasks 3–5. Verificação: deploy + teste manual com testador de licença (Task 10/handoff).

- [ ] **Step 1: Implementar a função**

`functions/verify_purchase.js`:
```js
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { google } = require("googleapis");
const { subStateFromV2 } = require("./billing");

const PACKAGE = "com.example.binderdex"; // confirmar com android/app/build.gradle (applicationId)
const PRODUCT_ID = "binderdex_premium";

let _publisher;
async function publisher() {
  if (_publisher) return _publisher;
  // Usa a conta de serviço da função (ADC). Conceder-lhe acesso na Play Console.
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  _publisher = google.androidpublisher({ version: "v3", auth });
  return _publisher;
}

exports.verifyPurchase = onCall(async (request) => {
  const uid = request.auth && request.auth.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sessao necessaria.");
  const token = request.data && request.data.purchaseToken;
  if (!token) throw new HttpsError("invalid-argument", "purchaseToken em falta.");

  const ap = await publisher();
  let resp;
  try {
    const r = await ap.purchases.subscriptionsv2.get({
      packageName: PACKAGE,
      token,
    });
    resp = r.data;
  } catch (e) {
    throw new HttpsError("not-found", "Compra invalida ou nao encontrada.");
  }

  const s = subStateFromV2(resp);
  const db = admin.firestore();
  await db.collection("users").doc(uid).set(
    {
      marketTier: s.tier,
      sub: {
        productId: PRODUCT_ID,
        basePlanId: s.basePlanId,
        state: s.state,
        expiryMs: s.expiryMs,
        autoRenewing: s.autoRenewing,
        purchaseToken: token,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    },
    { merge: true }
  );
  await db
    .collection("purchaseTokens")
    .doc(token)
    .set({ uid, basePlanId: s.basePlanId });

  // Upgrade/downgrade: limpa o mapeamento do token antigo substituido.
  if (resp.linkedPurchaseToken) {
    await db
      .collection("purchaseTokens")
      .doc(resp.linkedPurchaseToken)
      .delete()
      .catch(() => {});
  }

  return { tier: s.tier, expiryMs: s.expiryMs, state: s.state };
});
```

- [ ] **Step 2: Registar no index.js**

Em `functions/index.js`, antes da linha final `require("./announce_new_set")(exports);`, acrescentar:
```js
// 4) Verificacao de compra (callable) + 5) RTDN (Pub/Sub) — Play Billing.
Object.assign(exports, require("./verify_purchase"));
```

- [ ] **Step 3: Confirmar o `PACKAGE`**

Abrir `android/app/build.gradle` (ou `.kts`) e copiar o `applicationId` real para a constante `PACKAGE` em `verify_purchase.js`. (Tem de bater certo, senão a Play API rejeita.)

- [ ] **Step 4: Lint local**

Run: `cd functions && npm test`
Expected: PASS (não há novos testes, mas garante que os módulos carregam sem erro de sintaxe; `node --test` carrega `billing.js`).

- [ ] **Step 5: Commit**

```bash
git add functions/verify_purchase.js functions/index.js
git commit -m "feat(functions): verifyPurchase (valida compra na Play + grava tier)"
```

---

## Task 7: Cloud Function `playRtdn` (Pub/Sub) com guarda de staleness

**Files:**
- Create: `functions/play_rtdn.js`
- Modify: `functions/index.js`

**Interfaces:**
- Consumes: `decodeRtdn`, `subStateFromV2` (de `billing.js`); androidpublisher.
- Produces: função `onMessagePublished("play-rtdn", ...)` que atualiza `users/{uid}` **só** se o token for o autoritativo (`users/{uid}.sub.purchaseToken`).

- [ ] **Step 1: Implementar**

`functions/play_rtdn.js`:
```js
const { onMessagePublished } = require("firebase-functions/v2/pubsub");
const admin = require("firebase-admin");
const { google } = require("googleapis");
const { decodeRtdn, subStateFromV2 } = require("./billing");

const PACKAGE = "com.example.binderdex"; // mesmo applicationId do verify_purchase.js

let _ap;
async function publisher() {
  if (_ap) return _ap;
  const auth = new google.auth.GoogleAuth({
    scopes: ["https://www.googleapis.com/auth/androidpublisher"],
  });
  _ap = google.androidpublisher({ version: "v3", auth });
  return _ap;
}

/** Resolve o uid: pela Play (obfuscated id) ou pelo mapeamento purchaseTokens. */
async function resolveUid(db, state, token) {
  if (state.uid) return state.uid;
  const map = await db.collection("purchaseTokens").doc(token).get();
  return map.exists ? map.data().uid : null;
}

exports.playRtdn = onMessagePublished("play-rtdn", async (event) => {
  const note = decodeRtdn(event.data.message.data);
  const sub = note && note.subscriptionNotification;
  if (!sub || !sub.purchaseToken) return; // ignora outros tipos (voided/test)
  const token = sub.purchaseToken;

  const ap = await publisher();
  let resp;
  try {
    const r = await ap.purchases.subscriptionsv2.get({ packageName: PACKAGE, token });
    resp = r.data;
  } catch (_) {
    return; // token desconhecido/invalido — nada a fazer
  }

  const s = subStateFromV2(resp);
  const db = admin.firestore();
  const uid = await resolveUid(db, s, token);
  if (!uid) return; // sem dono resolúvel — ignora

  const userRef = db.collection("users").doc(uid);
  const snap = await userRef.get();
  const current = (snap.data() && snap.data().sub) || {};

  // GUARDA DE STALENESS: só age se for o token autoritativo do utilizador.
  if (current.purchaseToken && current.purchaseToken !== token) {
    // Token antigo (resubscricao/upgrade) — limpa o mapeamento, nao toca no tier.
    await db.collection("purchaseTokens").doc(token).delete().catch(() => {});
    return;
  }

  await userRef.set(
    {
      marketTier: s.tier,
      sub: {
        productId: (current.productId) || "binderdex_premium",
        basePlanId: s.basePlanId,
        state: s.state,
        expiryMs: s.expiryMs,
        autoRenewing: s.autoRenewing,
        purchaseToken: token,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
    },
    { merge: true }
  );
});
```

- [ ] **Step 2: Registar no index.js**

Em `functions/index.js`, alterar a linha da Task 6 para incluir também o RTDN:
```js
// 4) Verificacao de compra (callable) + 5) RTDN (Pub/Sub) — Play Billing.
Object.assign(exports, require("./verify_purchase"));
Object.assign(exports, require("./play_rtdn"));
```

- [ ] **Step 3: Lint local**

Run: `cd functions && npm test`
Expected: PASS (módulos carregam sem erro).

- [ ] **Step 4: Commit**

```bash
git add functions/play_rtdn.js functions/index.js
git commit -m "feat(functions): playRtdn (RTDN) com guarda de staleness"
```

---

## Task 8: Regras do Firestore — bloquear escrita de `marketTier`/`sub`

**Files:**
- Modify: `firestore.rules` (bloco `match /users/{userId}`)

**Interfaces:**
- Produces: o próprio utilizador deixa de poder escrever `marketTier`/`sub`; admin e functions continuam.

- [ ] **Step 1: Substituir a regra de `users/{userId}`**

Localizar:
```
    match /users/{userId} {
      allow read, write: if (request.auth != null && request.auth.uid == userId)
                         || isAdmin();
```
Substituir por (mantendo o `read` aberto, dividindo o `write`):
```
    match /users/{userId} {
      allow read: if (request.auth != null && request.auth.uid == userId)
                  || isAdmin();

      // Campos que o PRÓPRIO utilizador pode escrever. marketTier/sub ficam de
      // fora — só as Cloud Functions (admin SDK) e o admin os alteram.
      function selfWritableKeys() {
        return ['name', 'avatar', 'fcmTokens', 'notifyCards',
                'acceptedTerms', 'acceptedTermsAt', 'appealed', 'warning'].toSet();
      }

      // Criar o próprio doc: permitido (campos legítimos; sem marketTier/sub).
      allow create: if isAdmin()
        || (request.auth != null && request.auth.uid == userId
            && !request.resource.data.keys().hasAny(['marketTier', 'sub']));

      // Atualizar: admin tudo; o próprio só os campos da whitelist.
      allow update: if isAdmin()
        || (request.auth != null && request.auth.uid == userId
            && request.resource.data.diff(resource.data).affectedKeys()
                 .hasOnly(selfWritableKeys()));

      allow delete: if (request.auth != null && request.auth.uid == userId)
                    || isAdmin();
```
(O resto do bloco `users` — subcoleções `cards`, `blocks` — fica igual.)

- [ ] **Step 2: Adicionar regra para `purchaseTokens` (sem acesso ao cliente)**

No mesmo ficheiro, ao nível das outras coleções de topo, acrescentar:
```
    // Mapeamento token->uid: só as Cloud Functions (admin SDK) lê/escreve.
    match /purchaseTokens/{token} {
      allow read, write: if false;
    }
```

- [ ] **Step 3: Verificação manual (não há harness de rules)**

Rever mentalmente contra as escritas existentes do cliente:
- `profile_service.save` (name/avatar) ✅ na whitelist
- `addFcmToken`/`removeFcmToken` (fcmTokens) ✅
- `setNotifyCards` (notifyCards) ✅
- `setAcceptedTerms` (acceptedTerms/acceptedTermsAt) — **escrito pela função?** Não: é escrito pelo cliente em `auth_guard.ensureTermsAccepted`. ✅ na whitelist
- `markAppealed` (appealed) ✅
- `clearWarning` (warning delete) ✅
- `setTier` (marketTier) — vai ser **removido** na Task 14. ✅ deixa de existir

- [ ] **Step 4: Commit (deploy é do utilizador)**

```bash
git add firestore.rules
git commit -m "fix(rules): bloquear escrita de marketTier/sub pelo cliente"
```
> ⚠️ O utilizador faz `firebase deploy --only firestore:rules` **só depois** da Task 14 (remover o `setTier`), senão o premium_screen antigo parte.

---

## Task 9: Cliente — dependências `in_app_purchase` + `cloud_functions`

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Adicionar as dependências**

Em `pubspec.yaml`, na secção `dependencies`, acrescentar depois de `firebase_analytics`:
```yaml
  # Play Billing (subscrições premium) + chamada à Cloud Function de verificação
  in_app_purchase: ^3.2.0
  cloud_functions: ^6.0.0
```

- [ ] **Step 2: Resolver**

Run: `flutter pub get`
Expected: resolve sem conflitos.

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "build: in_app_purchase + cloud_functions"
```

---

## Task 10: Mapeamento `basePlanId -> tier` no cliente (+ test)

**Files:**
- Create: `lib/data/remote/billing_ids.dart`
- Test: `test/billing_ids_test.dart`

**Interfaces:**
- Produces: `const kPremiumProductId = 'binderdex_premium';`
  `const Map<String,int> kBasePlanTier = {'treinador':1,'mestre':2,'lendario':3};`
  `int tierForBasePlan(String? id)` e `String? basePlanForTier(int tier)`.

- [ ] **Step 1: Escrever o teste**

`test/billing_ids_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/remote/billing_ids.dart';

void main() {
  test('tierForBasePlan mapeia e faz fallback a 0', () {
    expect(tierForBasePlan('treinador'), 1);
    expect(tierForBasePlan('mestre'), 2);
    expect(tierForBasePlan('lendario'), 3);
    expect(tierForBasePlan('x'), 0);
    expect(tierForBasePlan(null), 0);
  });

  test('basePlanForTier inverte o mapa', () {
    expect(basePlanForTier(1), 'treinador');
    expect(basePlanForTier(2), 'mestre');
    expect(basePlanForTier(3), 'lendario');
    expect(basePlanForTier(0), isNull);
  });
}
```
> Confirmar o nome do package (`pokedex`) em `pubspec.yaml` (campo `name:`) e ajustar o import se for diferente.

- [ ] **Step 2: Correr — deve falhar**

Run: `flutter test test/billing_ids_test.dart`
Expected: FAIL (target of URI doesn't exist).

- [ ] **Step 3: Implementar**

`lib/data/remote/billing_ids.dart`:
```dart
/// Identificadores do Play Billing e mapeamento base plan <-> nível.
const String kPremiumProductId = 'binderdex_premium';

const Map<String, int> kBasePlanTier = {
  'treinador': 1,
  'mestre': 2,
  'lendario': 3,
};

int tierForBasePlan(String? basePlanId) => kBasePlanTier[basePlanId] ?? 0;

String? basePlanForTier(int tier) {
  for (final e in kBasePlanTier.entries) {
    if (e.value == tier) return e.key;
  }
  return null;
}
```

- [ ] **Step 4: Correr — deve passar**

Run: `flutter test test/billing_ids_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/data/remote/billing_ids.dart test/billing_ids_test.dart
git commit -m "feat(billing): mapeamento basePlanId<->tier no cliente + teste"
```

---

## Task 11: `BillingService` (compra + verificação)

**Files:**
- Create: `lib/data/remote/billing_service.dart`

**Interfaces:**
- Consumes: `in_app_purchase`, `cloud_functions`, `billing_ids.dart`, `firebase_auth`.
- Produces:
  - `BillingService` com:
    - `Future<bool> isAvailable()`
    - `Future<List<ProductDetails>> loadOffers()` (offers/base plans do `kPremiumProductId`)
    - `Stream<List<PurchaseDetails>> get purchaseStream`
    - `Future<void> buy(ProductDetails offer)` (com `applicationUserName = uid`)
    - `Future<void> restore()`
    - `Future<void> handlePurchase(PurchaseDetails p)` — chama a callable `verifyPurchase` e faz `completePurchase`.
  - Sem testes automatizados (depende da loja/rede). Verificação manual no handoff.

- [ ] **Step 1: Implementar**

`lib/data/remote/billing_service.dart`:
```dart
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import 'billing_ids.dart';

/// Liga o Play Billing à Cloud Function de verificação. A app nunca escreve
/// marketTier — só envia o token para `verifyPurchase`, que valida e grava.
class BillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final FirebaseFunctions _fns =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  Future<bool> isAvailable() => _iap.isAvailable();

  Stream<List<PurchaseDetails>> get purchaseStream => _iap.purchaseStream;

  /// Offers/base plans disponíveis para o produto premium.
  Future<List<ProductDetails>> loadOffers() async {
    final resp = await _iap.queryProductDetails({kPremiumProductId});
    return resp.productDetails;
  }

  /// Lança a compra/troca de um offer, marcando o uid (obfuscatedAccountId).
  Future<void> buy(ProductDetails offer) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final param = GooglePlayPurchaseParam(
      productDetails: offer,
      applicationUserName: uid,
    );
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() => _iap.restorePurchases();

  /// Valida no servidor e finaliza a compra. Devolve o tier concedido (ou 0).
  Future<int> handlePurchase(PurchaseDetails p) async {
    int tier = 0;
    if (p.status == PurchaseStatus.purchased ||
        p.status == PurchaseStatus.restored) {
      final token = p.verificationData.serverVerificationData;
      try {
        final res = await _fns.httpsCallable('verifyPurchase').call({
          'purchaseToken': token,
          'basePlanId': p.productID, // informativo; a função recalcula pela Play
        });
        tier = (res.data?['tier'] as int?) ?? 0;
      } catch (_) {
        // Falha de verificação — não concede nada; a app fica como está.
      }
    }
    if (p.pendingCompletePurchase) {
      await _iap.completePurchase(p);
    }
    return tier;
  }
}
```
> Nota: no Android, `serverVerificationData` é o `purchaseToken`. Para múltiplos base plans num produto, cada offer vem como um `ProductDetails` distinto; o ecrã (Task 13) mapeia offer→tier por `GooglePlayProductDetails.subscriptionOfferDetails` / `basePlanId`.

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/data/remote/billing_service.dart`
Expected: No issues found.

- [ ] **Step 3: Commit**

```bash
git add lib/data/remote/billing_service.dart
git commit -m "feat(billing): BillingService (compra + verifyPurchase)"
```

---

## Task 12: Provider do BillingService + listener global de compras

**Files:**
- Modify: `lib/presentation/providers/app_providers.dart` (novo provider)
- Modify: `lib/app.dart` (ativar o listener de compras)

**Interfaces:**
- Consumes: `BillingService`.
- Produces: `billingServiceProvider`; um listener que, ao receber compras no stream, chama `handlePurchase` (concede o tier via função). Cobre compras feitas fora do ecrã premium (ex.: restauros, renovações pendentes ao abrir a app).

- [ ] **Step 1: Adicionar o provider**

Em `lib/presentation/providers/app_providers.dart` (junto aos outros service providers), acrescentar o import e:
```dart
final billingServiceProvider = Provider<BillingService>((ref) => BillingService());
```
(import: `import '../../data/remote/billing_service.dart';`)

- [ ] **Step 2: Ativar o listener no arranque autenticado**

Em `lib/app.dart`, onde os outros serviços são ativados (syncService, pushService, etc.), acrescentar a subscrição ao stream de compras:
```dart
// Play Billing: processa compras/restauros/renovações pendentes.
ref.listen(authStateProvider, (_, next) {
  if (next.valueOrNull == null) return;
  final billing = ref.read(billingServiceProvider);
  billing.purchaseStream.listen((purchases) {
    for (final p in purchases) {
      billing.handlePurchase(p);
    }
  });
});
```
> Seguir o padrão exato de ativação já usado em `app.dart` (StatefulWidget/initState ou ref.listen). Garantir uma única subscrição (guardar a `StreamSubscription` e cancelar no dispose, como os outros listeners do ficheiro).

- [ ] **Step 3: Analyze**

Run: `flutter analyze lib/`
Expected: No issues found.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/providers/app_providers.dart lib/app.dart
git commit -m "feat(billing): provider + listener global de compras"
```

---

## Task 13: `PremiumScreen` — comprar a sério

**Files:**
- Modify: `lib/presentation/screens/premium_screen.dart`

**Interfaces:**
- Consumes: `billingServiceProvider`, `marketTierProvider`, offers (`ProductDetails`).
- Produces: ecrã que lista os base plans com **preço da loja**; botão por nível: "Subscrever"/"Mudar para"/"Plano atual"; botão "Restaurar compras". Remove o caminho `setTier`.

- [ ] **Step 1: Carregar offers e religar os botões**

Substituir o corpo do `PremiumScreen.build` para:
1. Obter `offers` via `FutureProvider`/`ref.watch` de `billingServiceProvider.loadOffers()`.
2. Para cada `tier` (1..3), encontrar o offer cujo `basePlanId` mapeia para esse tier (via `GooglePlayProductDetails.subscriptionOfferDetails` → `basePlanId`, comparando com `basePlanForTier(tier)`), e mostrar o `offer.price`.
3. O botão chama `ref.read(billingServiceProvider).buy(offer)`. O resultado chega pelo listener global (Task 12) e o `marketTierProvider` (stream do Firestore) atualiza a UI.

Detalhe da localização do basePlanId (Android):
```dart
String? basePlanIdOf(ProductDetails pd) {
  if (pd is GooglePlayProductDetails) {
    return pd.subscriptionOfferDetails?.basePlanId;
  }
  return null;
}
```
> `GooglePlayProductDetails` vem de `package:in_app_purchase_android/in_app_purchase_android.dart`. Confirmar o getter exato do basePlanId na versão instalada (`subscriptionOfferDetails`/`basePlanId`); ajustar se a API diferir.

- [ ] **Step 2: Adicionar "Restaurar compras"**

No topo ou rodapé do ListView, um `TextButton`/`OutlinedButton`:
```dart
TextButton.icon(
  onPressed: () => ref.read(billingServiceProvider).restore(),
  icon: const Icon(Icons.restore),
  label: Text(t.restorePurchases),
),
```
(`restorePurchases` é uma string l10n nova — adicionar em `app_en.arb` e `app_pt.arb`: EN `"Restore purchases"`, PT `"Restaurar compras"`, depois `flutter gen-l10n`.)

- [ ] **Step 3: Remover o caminho client-trusted**

Apagar a chamada `ref.read(marketServiceProvider).setTier(...)` do `onPressed`; o desbloqueio passa a vir da compra verificada.

- [ ] **Step 4: Analyze**

Run: `flutter analyze lib/presentation/screens/premium_screen.dart`
Expected: No issues found.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/screens/premium_screen.dart lib/l10n/
git commit -m "feat(billing): PremiumScreen compra via Play (precos da loja + restaurar)"
```

---

## Task 14: Remover `MarketService.setTier` e usos órfãos

**Files:**
- Modify: `lib/data/remote/market_service.dart` (remover `setTier`)
- Verificar: nenhum uso restante além do admin (que usa `adminService.setUserTier`, separado e mantido).

**Interfaces:**
- O admin continua a conceder premium via `AdminService.setUserTier` (escrita direta permitida pela regra `isAdmin()`). Só se remove o `setTier` do `MarketService` (usado pelo premium_screen, já religado).

- [ ] **Step 1: Procurar usos**

Run: `grep -rn "setTier(" lib/`
Expected: nenhum uso de `marketServiceProvider...setTier` (o premium_screen já não chama; `adminService.setUserTier` é outro método).

- [ ] **Step 2: Remover o método**

Em `lib/data/remote/market_service.dart`, apagar:
```dart
  Future<void> setTier(String uid, int tier) => _db
      .collection('users')
      .doc(uid)
      .set({'marketTier': tier}, SetOptions(merge: true));
```

- [ ] **Step 3: Analyze + testes**

Run: `flutter analyze lib/ && flutter test`
Expected: No issues found; todos os testes passam.

- [ ] **Step 4: Commit**

```bash
git add lib/data/remote/market_service.dart
git commit -m "refactor(billing): remove setTier client-trusted (substituido por Play Billing)"
```

---

## Task 15: Deploy e teste fim-a-fim (handoff ao utilizador)

Sem código. Ordem de deploy importa para não partir nada.

- [ ] **Step 1:** `cd functions && firebase deploy --only functions` (publica `verifyPurchase` + `playRtdn`). Confirmar que o trigger Pub/Sub ligou ao tópico `play-rtdn`.
- [ ] **Step 2:** `firebase deploy --only firestore:rules` (só **depois** das Tasks 13/14 e do build novo da app instalado — senão o premium_screen antigo, com `setTier`, deixa de funcionar).
- [ ] **Step 3:** `flutter build appbundle --release` e subir ao **Internal testing** na Play Console.
- [ ] **Step 4:** Com a conta testadora de licença: abrir o ecrã premium, confirmar que aparecem os **3 preços da loja**, subscrever um nível.
- [ ] **Step 5:** Confirmar no Firestore que `users/{uid}.marketTier` e `sub` ficaram corretos (escritos pela função, não pelo cliente).
- [ ] **Step 6:** Esperar a renovação acelerada (teste) e confirmar nos logs que o `playRtdn` disparou e manteve o tier.
- [ ] **Step 7:** Cancelar a subscrição de teste e confirmar que, no fim do período, `playRtdn` repõe `marketTier = 0`.
- [ ] **Step 8:** Testar **restaurar compras** numa reinstalação.

---

## Self-Review (cobertura da spec)

- Produtos/base plans → Task 1. ✅
- Cliente BillingService/compra/restore/verify → Tasks 9–13. ✅
- Reverificação no arranque → Task 12 (listener global processa compras/renovações pendentes do stream). ✅
- `verifyPurchase` → Task 6. ✅
- `playRtdn` + guarda de staleness + linkedPurchaseToken + obfuscatedAccountId → Tasks 5–7, 11. ✅
- Modelo de dados (`sub`, `purchaseTokens`) → Tasks 6–7. ✅
- Regras Firestore (bloquear marketTier/sub; purchaseTokens fechado) → Task 8. ✅
- Remoção do setTier client-trusted → Task 14. ✅
- Setup console/GCP → Task 1; deploy/e2e → Task 15. ✅
- iOS fora de âmbito → respeitado (sem tarefas iOS). ✅
