/// Níveis de slots de anúncios. Premium = só marcador (sem pagamento ainda).
class MarketTier {
  static const List<int> slots = [20, 100, 200, 500];

  static int slotsFor(int tier) => slots[tier.clamp(0, slots.length - 1)];

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
