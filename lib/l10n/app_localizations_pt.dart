// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Caderneta de Cartas';

  @override
  String get tabSets => 'Coleções';

  @override
  String get tabProgress => 'Progresso';

  @override
  String get tabMissing => 'Em falta';

  @override
  String get tabSettings => 'Definições';

  @override
  String get searchSetsHint => 'Pesquisar coleções';

  @override
  String get searchCardsHint => 'Pesquisar por nome ou número';

  @override
  String get owned => 'Tenho';

  @override
  String get quantity => 'Quantidade';

  @override
  String get notes => 'Notas';

  @override
  String get variant => 'Variante';

  @override
  String get variantNormal => 'Normal';

  @override
  String get variantHolo => 'Holo';

  @override
  String get variantReverse => 'Reverse holo';

  @override
  String get rarity => 'Raridade';

  @override
  String get statusAll => 'Todas';

  @override
  String get statusOwned => 'Tenho';

  @override
  String get statusMissing => 'Em falta';

  @override
  String get progressGlobal => 'Progresso global';

  @override
  String ownedOfTotal(int owned, int total) {
    return '$owned/$total';
  }

  @override
  String missingCount(int n) {
    return 'Em falta: $n';
  }

  @override
  String get loadingCards => 'A carregar cartas…';

  @override
  String get cardsLoadError =>
      'Não foi possível carregar as cartas. Verifica a ligação.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get noCards => 'Sem cartas';

  @override
  String get noSets => 'Sem coleções';

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
