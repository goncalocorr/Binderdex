const { test } = require("node:test");
const assert = require("node:assert");
const { tierForBasePlan, decodeRtdn } = require("./billing");

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
