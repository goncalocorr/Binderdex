/// Estatísticas de progresso (cartas possuídas vs total), global ou por set.
class ProgressStats {
  final int total;
  final int owned;

  const ProgressStats({required this.total, required this.owned});

  int get missing => total - owned;

  /// Percentagem entre 0.0 e 1.0. Protegido contra divisão por zero.
  double get percent => total == 0 ? 0 : owned / total;
}
