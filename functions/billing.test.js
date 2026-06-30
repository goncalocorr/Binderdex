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
