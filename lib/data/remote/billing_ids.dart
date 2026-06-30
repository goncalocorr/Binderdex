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
