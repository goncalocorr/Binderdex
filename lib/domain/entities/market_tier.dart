/// Níveis premium do marketplace. Premium = só marcador (sem pagamento ainda;
/// futuro Play Billing). Nível 0 = grátis. Preços provisórios (mudam depois /
/// virão do Google na integração de pagamento).
class MarketTier {
  static const List<int> slots = [20, 100, 200, 500];
  static const List<String> names = ['Grátis', 'Treinador', 'Mestre', 'Lendário'];
  static const List<String> prices = ['', '1,99 €', '3,99 €', '6,99 €'];

  static int slotsFor(int tier) => slots[_clamp(tier)];
  static String nameFor(int tier) => names[_clamp(tier)];
  static String priceFor(int tier) => prices[_clamp(tier)];

  /// Verdadeiro se é um nível pago (≥1) — desbloqueia selo + avatares premium.
  static bool isPremium(int tier) => tier >= 1;

  static int _clamp(int tier) => tier.clamp(0, slots.length - 1);

  static bool canPublish({
    required int activeCount,
    required int tier,
    required int selectedCount,
  }) =>
      activeCount + selectedCount <= slotsFor(tier);

  static int remaining({required int activeCount, required int tier}) {
    final r = slotsFor(tier) - activeCount;
    return r < 0 ? 0 : r;
  }
}
