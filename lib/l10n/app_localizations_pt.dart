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

  @override
  String get tabProfile => 'Perfil';

  @override
  String profileSummary(int cards, int sets) {
    return '$cards cartas · $sets sets';
  }

  @override
  String get signIn => 'Iniciar sessão';

  @override
  String get signInSync => 'Inicia sessão para sincronizar entre dispositivos';

  @override
  String get backupSync => 'Backup e sincronização';

  @override
  String get notifications => 'Notificações';

  @override
  String get helpFeedback => 'Ajuda e feedback';

  @override
  String get aboutApp => 'Sobre o Binderdex';

  @override
  String get loginTitle => 'Bem-vindo de volta';

  @override
  String get loginSubtitle =>
      'Inicia sessão para sincronizar o teu binder entre dispositivos.';

  @override
  String get continueGoogle => 'Continuar com Google';

  @override
  String get continueApple => 'Continuar com Apple';

  @override
  String get orLabel => 'ou';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Palavra-passe';

  @override
  String get logIn => 'Iniciar sessão';

  @override
  String get skipForNow => 'Saltar por agora';

  @override
  String get authComingSoon =>
      'O início de sessão chega com a sincronização na nuvem — em breve.';

  @override
  String get wishlist => 'Lista de desejos';

  @override
  String cardsWanted(int n) {
    return '$n cartas desejadas';
  }

  @override
  String get wishlistEmptyTitle => 'A lista de desejos está vazia';

  @override
  String get wishlistEmptyBody =>
      'Marca com ♥ as cartas que procuras e aparecem aqui.';

  @override
  String addedToWishlist(String name) {
    return 'Adicionada $name à lista de desejos';
  }

  @override
  String get removedFromWishlist => 'Removida da lista de desejos';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get switchToRegister => 'Novo por aqui? Cria uma conta';

  @override
  String get switchToLogin => 'Já tens conta? Inicia sessão';

  @override
  String get authFailed =>
      'Não foi possível iniciar sessão. Verifica os dados e tenta de novo.';

  @override
  String signedInAs(String email) {
    return 'Sessão iniciada como $email';
  }

  @override
  String get signOut => 'Terminar sessão';

  @override
  String get deleteAccount => 'Eliminar conta';

  @override
  String get deleteAccountConfirm => 'Eliminar conta?';

  @override
  String get deleteAccountBody =>
      'Isto elimina permanentemente a tua conta e a tua coleção — na nuvem e neste dispositivo. Não pode ser anulado.';

  @override
  String get delete => 'Eliminar';

  @override
  String get reauthNeeded =>
      'Por segurança, inicia sessão de novo e tenta eliminar a conta outra vez.';

  @override
  String get accountDeleted => 'Conta eliminada.';

  @override
  String get deleteFailed =>
      'Não foi possível eliminar a conta. Tenta de novo.';

  @override
  String get guestEnter => 'Entrar como convidado';

  @override
  String get loginRequiredTitle => 'Inicia sessão para adicionar';

  @override
  String get loginRequiredBody =>
      'Cria uma conta (ou inicia sessão) para começares a registar a tua coleção. Como convidado só podes ver.';

  @override
  String get loginOrCreate => 'Iniciar sessão ou criar conta';

  @override
  String get tabHome => 'Início';

  @override
  String homeGreeting(String name) {
    return 'Olá, $name';
  }

  @override
  String get homeGreetingGuest => 'Bem-vindo';

  @override
  String get homeAlmostThere => 'Quase lá';

  @override
  String get homeDiscover => 'Descobrir';

  @override
  String homeToGo(int n) {
    return 'faltam $n';
  }

  @override
  String get homeSignInCta => 'Inicia sessão para começares a tua coleção';

  @override
  String get openMyBinder => 'Abrir o meu binder';

  @override
  String get askNameTitle => 'Como te queres chamar?';

  @override
  String get askNameBody =>
      'Escolhe um nome de colecionador — aparece no início e no perfil.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get chooseAvatar => 'Escolhe o teu avatar';

  @override
  String get fillFields => 'Escreve o email e a palavra-passe.';

  @override
  String get tabCommunity => 'Comunidade';

  @override
  String get communityDisclaimerTitle => 'Antes de começares';

  @override
  String get communityDisclaimerBody =>
      'A Comunidade liga colecionadores para trocar e vender cartas. Os negócios são entre utilizadores — a Binderdex não é parte nem se responsabiliza por trocas, pagamentos ou eventuais burlas. Tem cuidado, confirma com quem negoceias e nunca partilhes dados sensíveis.';

  @override
  String get communityDisclaimerOk => 'Compreendo';

  @override
  String get sellOrTrade => 'Vender ou trocar cartas';

  @override
  String addToCommunity(Object n) {
    return 'Adicionar à comunidade ($n)';
  }

  @override
  String get onlyDuplicates => 'Só repetidas';

  @override
  String get myListings => 'Os meus anúncios';

  @override
  String get publish => 'Publicar';

  @override
  String get modeTrade => 'Trocar';

  @override
  String get modeSell => 'Vender';

  @override
  String get modeBoth => 'Ambos';

  @override
  String get condMint => 'Nova';

  @override
  String get condGood => 'Boa';

  @override
  String get condUsed => 'Usada';

  @override
  String get condDamaged => 'Danificada';

  @override
  String get whatIWant => 'O que quero em troca';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get contactSoon => 'Contactar (em breve)';

  @override
  String get report => 'Denunciar';

  @override
  String get block => 'Bloquear';

  @override
  String get unblock => 'Desbloquear';

  @override
  String slotsUsed(Object used, Object limit) {
    return '$used/$limit slots usados';
  }

  @override
  String get slotLimitReached =>
      'Atingiste o limite de slots. Desbloqueia mais com Premium.';

  @override
  String get premiumSlots => 'Slots e Premium';

  @override
  String get recentListings => 'Anúncios recentes';

  @override
  String get searchCardHint => 'Procurar uma carta…';

  @override
  String get communitySearchPrompt =>
      'Procura uma carta para veres quem a vende ou troca.';

  @override
  String get noListings => 'Ainda não há anúncios.';
}
