/** Mapeia o base plan da subscrição para o nível (marketTier). */
const BASE_PLAN_TIER = { treinador: 1, mestre: 2, lendario: 3 };

function tierForBasePlan(basePlanId) {
  return BASE_PLAN_TIER[basePlanId] || 0;
}

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

module.exports = { tierForBasePlan, BASE_PLAN_TIER, decodeRtdn, subStateFromV2 };
