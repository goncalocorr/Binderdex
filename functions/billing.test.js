const { test } = require("node:test");
const assert = require("node:assert");
const { tierForBasePlan, decodeRtdn, subStateFromV2 } = require("./billing");

test("tierForBasePlan mapeia os base plans", () => {
  assert.equal(tierForBasePlan("treinador"), 1);
  assert.equal(tierForBasePlan("mestre"), 2);
  assert.equal(tierForBasePlan("lendario"), 3);
});

test("tierForBasePlan desconhecido devolve 0", () => {
  assert.equal(tierForBasePlan("xpto"), 0);
  assert.equal(tierForBasePlan(undefined), 0);
});

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
