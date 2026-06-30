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

module.exports = { tierForBasePlan, BASE_PLAN_TIER, decodeRtdn };
