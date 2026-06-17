import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/domain/entities/progress.dart';

void main() {
  test('percent e missing calculados corretamente', () {
    const p = ProgressStats(total: 151, caught: 30);
    expect(p.missing, 121);
    expect((p.percent * 100).round(), 20);
  });

  test('total zero não rebenta (sem divisão por zero)', () {
    const p = ProgressStats(total: 0, caught: 0);
    expect(p.percent, 0);
    expect(p.missing, 0);
  });
}
