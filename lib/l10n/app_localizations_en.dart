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
  String get checkCommunityOffers => 'Check community offers';

  @override
  String get noListings => 'No listings yet.';

  @override
  String get noListingsBody =>
      'When new listings are published, they\'ll show up here.';

  @override
  String get editListingTitle => 'Edit listing';

  @override
  String get save => 'Save';

  @override
  String get wantCardsLimit => 'You\'ve reached the card limit.';

  @override
  String get wantedCards => 'Cards I want';

  @override
  String get wishlistEmpty =>
      'Your wishlist is empty. Search for a card above.';

  @override
  String get deleteListingAction => 'Delete listing';

  @override
  String get deleteListingConfirm => 'Delete this listing for good?';

  @override
  String get messages => 'Messages';

  @override
  String get noConversations => 'No conversations yet.';

  @override
  String get noConversationsBody =>
      'Contact someone from a listing to get started.';

  @override
  String get typeMessage => 'Type a message…';

  @override
  String get contact => 'Contact';

  @override
  String get contactWarning =>
      'You\'re about to share your own contact (email or phone). Binderdex isn\'t responsible for trades, payments or scams.';

  @override
  String get sendAnyway => 'Send anyway';

  @override
  String blockConfirm(Object name) {
    return 'Block $name? You\'ll stop seeing this person\'s listings and messages.';
  }

  @override
  String get userBlocked => 'User blocked.';

  @override
  String premiumYourPlan(Object name) {
    return 'Your plan: $name';
  }

  @override
  String get unlock => 'Unlock';

  @override
  String get currentPlanTag => 'Current';

  @override
  String perkSlots(Object n) {
    return '$n listing slots';
  }

  @override
  String get perkBadge => 'Premium badge';

  @override
  String get perkAvatars => 'Exclusive avatars';

  @override
  String perkTradeMatchesCount(Object n) {
    return 'See $n perfect trades';
  }

  @override
  String get perkTradeMatchesUnlimited => 'Unlimited perfect trades';

  @override
  String get tradeMatches => 'Perfect trades';

  @override
  String tradeMatchesFound(Object count) {
    return '$count perfect trades';
  }

  @override
  String get noTradeMatches =>
      'No perfect trades yet. Add cards to your wishlist and mark your duplicates!';

  @override
  String get tradeReceive => 'You get';

  @override
  String get tradeGive => 'You give';

  @override
  String get tradeMatchesLockedBody =>
      'Unlock Premium to see your perfect trades.';

  @override
  String tradeMatchesSeeMore(Object shown, Object total) {
    return 'Showing $shown of $total · upgrade to see them all';
  }

  @override
  String get seePlans => 'See Premium plans';

  @override
  String get collectionValue => 'Collection value';

  @override
  String get value => 'Value';

  @override
  String get valueLockedBody =>
      'Unlock Premium to see your collection\'s value.';

  @override
  String valueCoverage(Object priced, Object total) {
    return 'Based on $priced of $total cards';
  }

  @override
  String get updatePrices => 'Update prices';

  @override
  String get pricesUpdated => 'Prices updated';

  @override
  String get mostValuable => 'Most valuable';

  @override
  String get showValue => 'Show value';

  @override
  String get hideValue => 'Hide value';

  @override
  String setsAdded(Object count) {
    return '$count new collections!';
  }

  @override
  String get setsUpToDate => 'Catalogue up to date';

  @override
  String get refreshFailed => 'Couldn\'t update';

  @override
  String get admin => 'Admin';

  @override
  String get adminReports => 'Reports';

  @override
  String get adminSuggestions => 'Suggestions';

  @override
  String get noReports => 'No reports.';

  @override
  String get noSuggestions => 'No suggestions.';

  @override
  String get warnUser => 'Warn';

  @override
  String get banUser => 'Ban';

  @override
  String get markHandled => 'Mark handled';

  @override
  String get warnTitle => 'Warn user';

  @override
  String get warnHint => 'Warning message';

  @override
  String get banConfirm =>
      'Ban this user? They won\'t be able to post or message.';

  @override
  String get userWarned => 'Warning sent';

  @override
  String get userBanned => 'User banned';

  @override
  String get send => 'Send';

  @override
  String get sendSuggestion => 'Send a suggestion';

  @override
  String get suggestionHint => 'Your suggestion…';

  @override
  String get suggestionSent => 'Suggestion sent. Thanks!';

  @override
  String get warningTitle => 'Notice';

  @override
  String get accountSuspended => 'Your account has been suspended.';

  @override
  String get chatUnavailable => 'Couldn\'t load this conversation.';

  @override
  String get reportReasonTitle => 'Why are you reporting?';

  @override
  String get reportScam => 'Fraud / scam';

  @override
  String get reportAbuse => 'Abusive messages';

  @override
  String get reportInappropriate => 'Inappropriate content';

  @override
  String get reportFake => 'Fake / not as described';

  @override
  String get reportSpam => 'Spam';

  @override
  String get reportOther => 'Other';

  @override
  String get reportAll => 'All';

  @override
  String get reportSent => 'Report sent';

  @override
  String get reporterLabel => 'Reporter';

  @override
  String get reportedLabel => 'Reported';

  @override
  String get noConversation => 'No conversation between these users.';

  @override
  String get adminBanned => 'Banned users';

  @override
  String get adminPremium => 'Premium users';

  @override
  String get adminBroadcast => 'Broadcast';

  @override
  String get noBanned => 'No banned users.';

  @override
  String get unban => 'Unban';

  @override
  String get noPremiumUsers => 'No premium users.';

  @override
  String get grantPremium => 'Grant premium (uid)';

  @override
  String get uidHint => 'User uid';

  @override
  String get grant => 'Grant';

  @override
  String get change => 'Change';

  @override
  String get premiumUpdated => 'Premium updated';

  @override
  String get broadcastTitle => 'Title';

  @override
  String get broadcastBody => 'Message';

  @override
  String get broadcastSend => 'Send to everyone';

  @override
  String get broadcastSent => 'Broadcast sent';

  @override
  String get listingDeleted => 'Listing deleted';

  @override
  String get deleteListing => 'Delete listing';

  @override
  String get notifBroadcast => 'Announcement';

  @override
  String get statListings => 'Active listings';

  @override
  String get statReports => 'Reports';

  @override
  String get bannedLabel => 'Banned';

  @override
  String get resolved => 'Resolved';

  @override
  String get resolvedWarn => 'Resolved · Warned';

  @override
  String get resolvedBan => 'Resolved · Banned';

  @override
  String get resolvedDelete => 'Resolved · Listing deleted';

  @override
  String get perMonth => '/month';

  @override
  String get premiumOnly => 'Premium only';

  @override
  String premiumUnlocked(Object name) {
    return '$name unlocked!';
  }

  @override
  String get youUnlocked => 'You unlocked:';

  @override
  String get subscriptionNotRenewed => 'Subscription not renewed';

  @override
  String get backToFreeBody =>
      'You\'re back on the Free plan — you lost the extra slots, the badge and premium avatars.';

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get archivedTitle => 'Archived';

  @override
  String get deleteConversation => 'Delete chat';

  @override
  String get deleteConversationConfirm =>
      'Delete this chat? It comes back if you get a new message.';

  @override
  String get noArchived => 'No archived chats.';

  @override
  String get tabBinderShort => 'Binder';

  @override
  String get blockedUsers => 'Blocked people';

  @override
  String get noBlockedUsers => 'No blocked people.';

  @override
  String get noNotifications => 'No notifications.';

  @override
  String get notifCleared => 'Notification cleared';

  @override
  String get notifNewMessage => 'New message';

  @override
  String get notifWishlistAvailable => 'Tracked card available';

  @override
  String get notifNewCollection => 'New collection';
}
