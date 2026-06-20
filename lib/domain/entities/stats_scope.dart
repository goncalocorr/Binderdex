/// Âmbito das estatísticas/progresso.
/// - `setId != null` → focado numa coleção específica.
/// - senão `all == true` → todas as cartas; `all == false` → as minhas coleções.
class StatsScope {
  final bool all;
  final String? setId;
  final String? setName;

  const StatsScope({this.all = false, this.setId, this.setName});

  bool get isSet => setId != null;

  StatsScope get clearedToMine => const StatsScope(all: false);
}
