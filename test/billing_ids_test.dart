import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/remote/billing_ids.dart';

void main() {
  test('tierForBasePlan mapeia e faz fallback a 0', () {
    expect(tierForBasePlan('treinador'), 1);
    expect(tierForBasePlan('mestre'), 2);
    expect(tierForBasePlan('lendario'), 3);
    expect(tierForBasePlan('x'), 0);
    expect(tierForBasePlan(null), 0);
  });

  test('basePlanForTier inverte o mapa', () {
    expect(basePlanForTier(1), 'treinador');
    expect(basePlanForTier(2), 'mestre');
    expect(basePlanForTier(3), 'lendario');
    expect(basePlanForTier(0), isNull);
  });
}
