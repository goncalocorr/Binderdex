/** Mapeia o base plan da subscrição para o nível (marketTier). */
const BASE_PLAN_TIER = { treinador: 1, mestre: 2, lendario: 3 };

function tierForBasePlan(basePlanId) {
  return BASE_PLAN_TIER[basePlanId] || 0;
}

module.exports = { tierForBasePlan, BASE_PLAN_TIER };
