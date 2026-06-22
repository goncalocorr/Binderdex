// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Binderdex';

  @override
  String get tabSets => 'Coleções';

  @override
  String get tabProgress => 'Progresso';

  @override
  String get tabMissing => 'Em falta';

  @override
  String get tabSettings => 'Definições';

  @override
  String get tabBinder => 'O meu binder';

  @override
  String setsFollowed(int n) {
    return '$n sets seguidos';
  }

  @override
  String get keepCompleting => 'Continua a completar os teus sets';

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

  @override
  String get cardsCollected => 'cartas reunidas em todas as coleções';

  @override
  String get statsSetsDone => 'Sets feitos';

  @override
  String get statsHolos => 'Holos';

  @override
  String get statsDuplicates => 'Duplicados';

  @override
  String get statsByType => 'Coleção por tipo';

  @override
  String percentComplete(int n) {
    return '$n% completo';
  }

  @override
  String get allCollected => 'Tudo apanhado!';

  @override
  String get emptyOwned => 'Ainda não tens cartas';

  @override
  String get emptyOwnedBody => 'Adiciona uma carta para começar este set.';

  @override
  String get noMatch => 'Nada por aqui';

  @override
  String get quickAddTitle => 'Adicionar carta';

  @override
  String addedToBinder(String name) {
    return 'Adicionada $name';
  }

  @override
  String get undo => 'Anular';

  @override
  String get tabSearch => 'Pesquisa';

  @override
  String get searchAllHint => 'Pesquisar todas as cartas…';

  @override
  String get missingOnly => 'Só em falta';

  @override
  String get searchEmptyBody => 'Tenta outro nome ou filtro de tipo.';

  @override
  String cardsCountLabel(int n) {
    return '$n cartas';
  }

  @override
  String get myCollection => 'A minha coleção';

  @override
  String get myCollections => 'As minhas coleções';

  @override
  String get missingTotal => 'Em falta no total';

  @override
  String get noStartedCollections => 'Sem coleções começadas';

  @override
  String get noStartedCollectionsBody =>
      'Abre um set e marca uma carta para começares a colecionar.';

  @override
  String get allCards => 'Todas as cartas';

  @override
  String get viewMissingCards => 'Ver cartas em falta';

  @override
  String get guest => 'Colecionador';

  @override
  String get localCollection => 'Coleção local';

  @override
  String get editName => 'Editar nome';

  @override
  String get onboardingTagline =>
      'Segue todas as cartas que tens, vê o que falta e completa cada coleção.';

  @override
  String get startCollection => 'Começar a minha coleção';

  @override
  String get haveAccount => 'Já tenho conta';

  @override
  String get fanMadeDisclaimer =>
      'Registo de coleção feito por fãs · sem afiliação a qualquer editora de cartas.';
}
