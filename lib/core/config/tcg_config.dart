/// Configuração da Pokémon TCG API (https://pokemontcg.io/).
class TcgConfig {
  static const String baseUrl = 'https://api.pokemontcg.io/v2';

  /// Chave de API **opcional**. Sem chave funciona (com limites mais baixos).
  /// Para usar a tua chave gratuita, corre com:
  ///   flutter run --dart-define=TCG_API_KEY=a-tua-chave
  static const String apiKey =
      String.fromEnvironment('TCG_API_KEY', defaultValue: '');
}
