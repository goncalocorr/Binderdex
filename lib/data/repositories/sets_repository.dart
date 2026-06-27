import '../../domain/entities/card_set.dart';
import '../../domain/entities/progress.dart';
import '../local/database.dart';
import '../remote/tcg_api.dart';

/// Um set com o respetivo progresso de coleção.
typedef SetProgress = ({CardSet set, ProgressStats progress});

CardSet _toSet(CardSetRow r) => CardSet(
      id: r.id,
      name: r.name,
      series: r.series,
      printedTotal: r.printedTotal,
      total: r.total,
      releaseDate: r.releaseDate,
      symbolUrl: r.symbolUrl,
      logoUrl: r.logoUrl,
    );

class SetsRepository {
  final AppDatabase db;
  final TcgApi api;
  SetsRepository(this.db, this.api);

  /// Vai buscar a lista de sets à API e junta os novos ao catálogo (atualiza os
  /// metadados dos existentes; não mexe nas cartas já sincronizadas). Devolve o
  /// nº de sets novos adicionados. Lança em caso de erro de rede.
  Future<int> refreshSets() async {
    final sets = await api.fetchSets();
    final existing = await db.existingSetIds();
    await db.upsertSetsMeta(sets
        .map((s) => CardSetsCompanion.insert(
              id: s.id,
              name: s.name,
              series: s.series,
              printedTotal: s.printedTotal,
              total: s.total,
              releaseDate: s.releaseDate,
              symbolUrl: s.symbolUrl,
              logoUrl: s.logoUrl,
            ))
        .toList());
    return sets.where((s) => !existing.contains(s.id)).length;
  }

  Stream<List<SetProgress>> watchSets() =>
      db.watchSetsWithProgress().map((rows) => rows
          .map((s) => (
                set: _toSet(s.set),
                progress: ProgressStats(total: s.set.total, owned: s.owned),
              ))
          .toList());

  Future<CardSet?> byId(String id) async {
    final r = await db.setById(id);
    return r == null ? null : _toSet(r);
  }
}
