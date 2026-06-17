import '../../domain/entities/card_set.dart';
import '../../domain/entities/progress.dart';
import '../local/database.dart';

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
  SetsRepository(this.db);

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
