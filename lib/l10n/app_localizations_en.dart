// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Binderdex';

  @override
  String get tabSets => 'Collections';

  @override
  String get tabProgress => 'Progress';

  @override
  String get tabMissing => 'Missing';

  @override
  String get tabSettings => 'Settings';

  @override
  String get tabBinder => 'My Binder';

  @override
  String setsFollowed(int n) {
    return '$n sets followed';
  }

  @override
  String get keepCompleting => 'Keep completing your sets';

  @override
  String get searchSetsHint => 'Search collections';

  @override
  String get searchCardsHint => 'Search by name or number';

  @override
  String get owned => 'Owned';

  @override
  String get quantity => 'Quantity';

  @override
  String get notes => 'Notes';

  @override
  String get variant => 'Variant';

  @override
  String get variantNormal => 'Normal';

  @override
  String get variantHolo => 'Holo';

  @override
  String get variantReverse => 'Reverse holo';

  @override
  String get rarity => 'Rarity';

  @override
  String get statusAll => 'All';

  @override
  String get statusOwned => 'Owned';

  @override
  String get statusMissing => 'Missing';

  @override
  String get progressGlobal => 'Global progress';

  @override
  String ownedOfTotal(int owned, int total) {
    return '$owned/$total';
  }

  @override
  String missingCount(int n) {
    return 'Missing: $n';
  }

  @override
  String get loadingCards => 'Loading cards…';

  @override
  String get cardsLoadError => 'Couldn\'t load cards. Check your connection.';

  @override
  String get retry => 'Retry';

  @override
  String get noCards => 'No cards';

  @override
  String get noSets => 'No collections';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get premium => 'Premium';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get cardsCollected => 'cards collected across all sets';

  @override
  String get statsSetsDone => 'Sets done';

  @override
  String get statsHolos => 'Holos';

  @override
  String get statsDuplicates => 'Duplicates';

  @override
  String get statsByType => 'Collection by type';

  @override
  String percentComplete(int n) {
    return '$n% complete';
  }

  @override
  String get allCollected => 'All collected!';

  @override
  String get emptyOwned => 'No cards owned yet';

  @override
  String get emptyOwnedBody => 'Add a card to start this set.';

  @override
  String get noMatch => 'Nothing here';

  @override
  String get quickAddTitle => 'Add a card';

  @override
  String addedToBinder(String name) {
    return 'Added $name';
  }

  @override
  String get undo => 'Undo';

  @override
  String get tabSearch => 'Search';

  @override
  String get searchAllHint => 'Search all cards…';

  @override
  String get missingOnly => 'Missing only';

  @override
  String get searchEmptyBody => 'Try a different name or type filter.';

  @override
  String cardsCountLabel(int n) {
    return '$n cards';
  }

  @override
  String get myCollection => 'My collection';

  @override
  String get myCollections => 'My collections';

  @override
  String get missingTotal => 'Missing in total';

  @override
  String get noStartedCollections => 'No collections started';

  @override
  String get noStartedCollectionsBody =>
      'Open a set and mark a card to start collecting.';

  @override
  String get allCards => 'All cards';

  @override
  String get viewMissingCards => 'View missing cards';

  @override
  String get guest => 'Collector';

  @override
  String get localCollection => 'Local collection';

  @override
  String get editName => 'Edit name';

  @override
  String get onboardingTagline =>
      'Track every card you own, see what\'s missing, and complete every set.';

  @override
  String get startCollection => 'Start my collection';

  @override
  String get haveAccount => 'I already have an account';

  @override
  String get fanMadeDisclaimer =>
      'A fan-made collection tracker · not affiliated with any card publisher.';

  @override
  String get tabProfile => 'Profile';

  @override
  String profileSummary(int cards, int sets) {
    return '$cards cards · $sets sets';
  }

  @override
  String get signIn => 'Sign in';

  @override
  String get signInSync => 'Sign in to sync across devices';

  @override
  String get backupSync => 'Backup & sync';

  @override
  String get notifications => 'Notifications';

  @override
  String get helpFeedback => 'Help & feedback';

  @override
  String get aboutApp => 'About Binderdex';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to sync your binder across devices.';

  @override
  String get continueGoogle => 'Continue with Google';

  @override
  String get continueApple => 'Continue with Apple';

  @override
  String get orLabel => 'or';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get logIn => 'Log in';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get authComingSoon => 'Sign-in arrives with cloud sync — coming soon.';

  @override
  String get wishlist => 'Wishlist';

  @override
  String cardsWanted(int n) {
    return '$n cards wanted';
  }

  @override
  String get wishlistEmptyTitle => 'Wishlist is empty';

  @override
  String get wishlistEmptyBody =>
      'Heart the cards you\'re hunting for and they\'ll show up here.';

  @override
  String addedToWishlist(String name) {
    return 'Added $name to wishlist';
  }

  @override
  String get removedFromWishlist => 'Removed from wishlist';

  @override
  String get createAccount => 'Create account';

  @override
  String get switchToRegister => 'New here? Create an account';

  @override
  String get switchToLogin => 'Already have an account? Log in';

  @override
  String get authFailed =>
      'Couldn\'t sign in. Check your details and try again.';

  @override
  String signedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm => 'Delete account?';

  @override
  String get deleteAccountBody =>
      'This permanently deletes your account and your collection — from the cloud and this device. This can\'t be undone.';

  @override
  String get delete => 'Delete';

  @override
  String get reauthNeeded =>
      'For security, sign in again and then retry deleting your account.';

  @override
  String get accountDeleted => 'Account deleted.';

  @override
  String get deleteFailed => 'Couldn\'t delete your account. Please try again.';

  @override
  String get guestEnter => 'Browse as guest';

  @override
  String get loginRequiredTitle => 'Sign in to add cards';

  @override
  String get loginRequiredBody =>
      'Create a free account or log in to start tracking your collection. As a guest you can only browse.';

  @override
  String get loginOrCreate => 'Log in or create account';

  @override
  String get tabHome => 'Home';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeGreetingGuest => 'Welcome';

  @override
  String get homeAlmostThere => 'Almost there';

  @override
  String get homeDiscover => 'Discover';

  @override
  String homeToGo(int n) {
    return '$n to go';
  }

  @override
  String get homeSignInCta => 'Sign in to start your collection';

  @override
  String get openMyBinder => 'Open my binder';

  @override
  String get askNameTitle => 'What should we call you?';

  @override
  String get askNameBody =>
      'Pick a collector name — it shows on your home and profile.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get chooseAvatar => 'Choose your avatar';

  @override
  String get fillFields => 'Enter your email and password.';

  @override
  String get tabCommunity => 'Community';

  @override
  String get communityDisclaimerTitle => 'Before you start';

  @override
  String get communityDisclaimerBody =>
      'Community connects collectors to trade and sell cards. Deals are between users — Binderdex is not part of and isn\'t responsible for trades, payments or scams. Be careful, confirm with who you\'re trading with and never share sensitive data.';

  @override
  String get communityDisclaimerOk => 'Got it';

  @override
  String get sellOrTrade => 'Sell or trade cards';

  @override
  String addToCommunity(Object n) {
    return 'Add to community ($n)';
  }

  @override
  String get onlyDuplicates => 'Duplicates only';

  @override
  String get myListings => 'My listings';

  @override
  String get publish => 'Publish';

  @override
  String get modeTrade => 'Trade';

  @override
  String get modeSell => 'Sell';

  @override
  String get modeBoth => 'Both';

  @override
  String get condMint => 'Mint';

  @override
  String get condGood => 'Good';

  @override
  String get condUsed => 'Used';

  @override
  String get condDamaged => 'Damaged';

  @override
  String get whatIWant => 'What I want in exchange';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get contactSoon => 'Contact (coming soon)';

  @override
  String get report => 'Report';

  @override
  String get block => 'Block';

  @override
  String get unblock => 'Unblock';

  @override
  String slotsUsed(Object used, Object limit) {
    return '$used/$limit slots used';
  }

  @override
  String get slotLimitReached =>
      'You\'ve hit your slot limit. Unlock more with Premium.';

  @override
  String get premiumSlots => 'Slots & Premium';

  @override
  String get recentListings => 'Recent listings';

  @override
  String get searchCardHint => 'Search a card…';

  @override
  String get communitySearchPrompt =>
      'Search a card to see who\'s selling or trading it.';

  @override
  String get noListings => 'No listings yet.';
}
