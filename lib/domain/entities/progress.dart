/// Estatísticas de progresso, usadas tanto no total global como por geração.
class ProgressStats {
  final int total;
  final int caught;

  const ProgressStats({required this.total, required this.caught});

  int get missing => total - caught;

  /// Percentagem entre 0.0 e 1.0. Protegido contra divisão por zero.
  double get percent => total == 0 ? 0 : caught / total;
}
