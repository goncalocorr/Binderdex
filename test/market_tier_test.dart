import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/market_tier.dart';

void main() {
  test('slotsFor devolve o limite de cada nível', () {
    expect(MarketTier.slotsFor(0), 20);
    expect(MarketTier.slotsFor(1), 100);
    expect(MarketTier.slotsFor(2), 200);
    expect(MarketTier.slotsFor(3), 500);
  });

  test('slotsFor faz clamp de níveis inválidos', () {
    expect(MarketTier.slotsFor(-1), 20);
    expect(MarketTier.slotsFor(99), 500);
  });

  test('canPublish permite até ao limite e bloqueia acima', () {
    expect(MarketTier.canPublish(activeCount: 18, tier: 0, selectedCount: 2), true);
    expect(MarketTier.canPublish(activeCount: 19, tier: 0, selectedCount: 2), false);
    expect(MarketTier.canPublish(activeCount: 0, tier: 0, selectedCount: 20), true);
  });

  test('remaining nunca é negativo', () {
    expect(MarketTier.remaining(activeCount: 5, tier: 0), 15);
    expect(MarketTier.remaining(activeCount: 25, tier: 0), 0);
  });
}
