import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokedex/data/local/database.dart';
import 'package:pokedex/presentation/screens/my_cards_screen.dart';

void main() {
  test('cardRefsFrom devolve só as cartas selecionadas', () {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final all = [
      const OwnedCard(
          TcgCardRow(
              id: 'a', setId: 's', name: 'A', number: '1', numberSort: 1,
              imageSmall: '', imageLarge: 'imgA'),
          false),
      const OwnedCard(
          TcgCardRow(
              id: 'b', setId: 's', name: 'B', number: '2', numberSort: 2,
              imageSmall: '', imageLarge: 'imgB'),
          true),
    ];
    final refs = cardRefsFrom(all, {'b'});
    expect(refs.length, 1);
    expect(refs.single.cardId, 'b');
    expect(refs.single.cardImage, 'imgB');
  });
}
