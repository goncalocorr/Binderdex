/// Constrói os URLs determinísticos da arte oficial dos Pokémon.
///
/// Não é preciso nenhuma chamada à API para obter a imagem: o caminho deriva
/// diretamente do número da Pokédex. O caching é feito pelo cached_network_image.
class Sprites {
  static const _base =
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork';

  static String artwork(int id, {bool shiny = false}) =>
      shiny ? '$_base/shiny/$id.png' : '$_base/$id.png';
}
