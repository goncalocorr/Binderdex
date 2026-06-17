// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get searchHint => 'Pesquisar por nome ou número';

  @override
  String get tabPokedex => 'Pokédex';

  @override
  String get tabProgress => 'Progresso';

  @override
  String get tabMissing => 'Em falta';

  @override
  String get tabSettings => 'Definições';

  @override
  String get caught => 'Tenho';

  @override
  String get shiny => 'Shiny';

  @override
  String get quantity => 'Quantidade';

  @override
  String get notes => 'Notas';

  @override
  String get baseStats => 'Estatísticas base';

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Ataque';

  @override
  String get statDefense => 'Defesa';

  @override
  String get statSpAttack => 'At. Esp.';

  @override
  String get statSpDefense => 'Def. Esp.';

  @override
  String get statSpeed => 'Velocidade';

  @override
  String get filterStatus => 'Estado';

  @override
  String get filterGeneration => 'Geração';

  @override
  String get filterType => 'Tipo';

  @override
  String get statusAll => 'Todos';

  @override
  String get statusCaught => 'Tenho';

  @override
  String get statusMissing => 'Em falta';

  @override
  String get statusShiny => 'Shiny';

  @override
  String get progressGlobal => 'Progresso global';

  @override
  String progressGeneration(int n) {
    return 'Geração $n';
  }

  @override
  String missingCount(int n) {
    return 'Em falta: $n';
  }

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get language => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get premium => 'Premium';

  @override
  String get comingSoon => 'Em breve';
}
