import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Binderdex'**
  String get appTitle;

  /// No description provided for @tabSets.
  ///
  /// In en, this message translates to:
  /// **'Collections'**
  String get tabSets;

  /// No description provided for @tabProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get tabProgress;

  /// No description provided for @tabMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get tabMissing;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @tabBinder.
  ///
  /// In en, this message translates to:
  /// **'My Binder'**
  String get tabBinder;

  /// No description provided for @setsFollowed.
  ///
  /// In en, this message translates to:
  /// **'{n} sets followed'**
  String setsFollowed(int n);

  /// No description provided for @keepCompleting.
  ///
  /// In en, this message translates to:
  /// **'Keep completing your sets'**
  String get keepCompleting;

  /// No description provided for @searchSetsHint.
  ///
  /// In en, this message translates to:
  /// **'Search collections'**
  String get searchSetsHint;

  /// No description provided for @searchCardsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or number'**
  String get searchCardsHint;

  /// No description provided for @owned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get owned;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @variant.
  ///
  /// In en, this message translates to:
  /// **'Variant'**
  String get variant;

  /// No description provided for @variantNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get variantNormal;

  /// No description provided for @variantHolo.
  ///
  /// In en, this message translates to:
  /// **'Holo'**
  String get variantHolo;

  /// No description provided for @variantReverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse holo'**
  String get variantReverse;

  /// No description provided for @rarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get rarity;

  /// No description provided for @statusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get statusAll;

  /// No description provided for @statusOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get statusOwned;

  /// No description provided for @statusMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get statusMissing;

  /// No description provided for @progressGlobal.
  ///
  /// In en, this message translates to:
  /// **'Global progress'**
  String get progressGlobal;

  /// No description provided for @ownedOfTotal.
  ///
  /// In en, this message translates to:
  /// **'{owned}/{total}'**
  String ownedOfTotal(int owned, int total);

  /// No description provided for @missingCount.
  ///
  /// In en, this message translates to:
  /// **'Missing: {n}'**
  String missingCount(int n);

  /// No description provided for @loadingCards.
  ///
  /// In en, this message translates to:
  /// **'Loading cards…'**
  String get loadingCards;

  /// No description provided for @cardsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load cards. Check your connection.'**
  String get cardsLoadError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noCards.
  ///
  /// In en, this message translates to:
  /// **'No cards'**
  String get noCards;

  /// No description provided for @noSets.
  ///
  /// In en, this message translates to:
  /// **'No collections'**
  String get noSets;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @cardsCollected.
  ///
  /// In en, this message translates to:
  /// **'cards collected across all sets'**
  String get cardsCollected;

  /// No description provided for @statsSetsDone.
  ///
  /// In en, this message translates to:
  /// **'Sets done'**
  String get statsSetsDone;

  /// No description provided for @statsHolos.
  ///
  /// In en, this message translates to:
  /// **'Holos'**
  String get statsHolos;

  /// No description provided for @statsDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get statsDuplicates;

  /// No description provided for @statsByType.
  ///
  /// In en, this message translates to:
  /// **'Collection by type'**
  String get statsByType;

  /// No description provided for @percentComplete.
  ///
  /// In en, this message translates to:
  /// **'{n}% complete'**
  String percentComplete(int n);

  /// No description provided for @allCollected.
  ///
  /// In en, this message translates to:
  /// **'All collected!'**
  String get allCollected;

  /// No description provided for @emptyOwned.
  ///
  /// In en, this message translates to:
  /// **'No cards owned yet'**
  String get emptyOwned;

  /// No description provided for @emptyOwnedBody.
  ///
  /// In en, this message translates to:
  /// **'Add a card to start this set.'**
  String get emptyOwnedBody;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get noMatch;

  /// No description provided for @quickAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a card'**
  String get quickAddTitle;

  /// No description provided for @addedToBinder.
  ///
  /// In en, this message translates to:
  /// **'Added {name}'**
  String addedToBinder(String name);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @tabSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tabSearch;

  /// No description provided for @searchAllHint.
  ///
  /// In en, this message translates to:
  /// **'Search all cards…'**
  String get searchAllHint;

  /// No description provided for @missingOnly.
  ///
  /// In en, this message translates to:
  /// **'Missing only'**
  String get missingOnly;

  /// No description provided for @searchEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Try a different name or type filter.'**
  String get searchEmptyBody;

  /// No description provided for @cardsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{n} cards'**
  String cardsCountLabel(int n);

  /// No description provided for @myCollection.
  ///
  /// In en, this message translates to:
  /// **'My collection'**
  String get myCollection;

  /// No description provided for @myCollections.
  ///
  /// In en, this message translates to:
  /// **'My collections'**
  String get myCollections;

  /// No description provided for @missingTotal.
  ///
  /// In en, this message translates to:
  /// **'Missing in total'**
  String get missingTotal;

  /// No description provided for @noStartedCollections.
  ///
  /// In en, this message translates to:
  /// **'No collections started'**
  String get noStartedCollections;

  /// No description provided for @noStartedCollectionsBody.
  ///
  /// In en, this message translates to:
  /// **'Open a set and mark a card to start collecting.'**
  String get noStartedCollectionsBody;

  /// No description provided for @allCards.
  ///
  /// In en, this message translates to:
  /// **'All cards'**
  String get allCards;

  /// No description provided for @viewMissingCards.
  ///
  /// In en, this message translates to:
  /// **'View missing cards'**
  String get viewMissingCards;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get guest;

  /// No description provided for @localCollection.
  ///
  /// In en, this message translates to:
  /// **'Local collection'**
  String get localCollection;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get editName;

  /// No description provided for @onboardingTagline.
  ///
  /// In en, this message translates to:
  /// **'Track every card you own, see what\'s missing, and complete every set.'**
  String get onboardingTagline;

  /// No description provided for @startCollection.
  ///
  /// In en, this message translates to:
  /// **'Start my collection'**
  String get startCollection;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get haveAccount;

  /// No description provided for @fanMadeDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A fan-made collection tracker · not affiliated with any card publisher.'**
  String get fanMadeDisclaimer;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @profileSummary.
  ///
  /// In en, this message translates to:
  /// **'{cards} cards · {sets} sets'**
  String profileSummary(int cards, int sets);

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signInSync.
  ///
  /// In en, this message translates to:
  /// **'Sign in to sync across devices'**
  String get signInSync;

  /// No description provided for @backupSync.
  ///
  /// In en, this message translates to:
  /// **'Backup & sync'**
  String get backupSync;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @helpFeedback.
  ///
  /// In en, this message translates to:
  /// **'Help & feedback'**
  String get helpFeedback;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About Binderdex'**
  String get aboutApp;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to sync your binder across devices.'**
  String get loginSubtitle;

  /// No description provided for @continueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueGoogle;

  /// No description provided for @continueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueApple;

  /// No description provided for @orLabel.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orLabel;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get logIn;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @authComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sign-in arrives with cloud sync — coming soon.'**
  String get authComingSoon;

  /// No description provided for @wishlist.
  ///
  /// In en, this message translates to:
  /// **'Wishlist'**
  String get wishlist;

  /// No description provided for @cardsWanted.
  ///
  /// In en, this message translates to:
  /// **'{n} cards wanted'**
  String cardsWanted(int n);

  /// No description provided for @wishlistEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Wishlist is empty'**
  String get wishlistEmptyTitle;

  /// No description provided for @wishlistEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Heart the cards you\'re hunting for and they\'ll show up here.'**
  String get wishlistEmptyBody;

  /// No description provided for @addedToWishlist.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to wishlist'**
  String addedToWishlist(String name);

  /// No description provided for @removedFromWishlist.
  ///
  /// In en, this message translates to:
  /// **'Removed from wishlist'**
  String get removedFromWishlist;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @switchToRegister.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get switchToRegister;

  /// No description provided for @switchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get switchToLogin;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in. Check your details and try again.'**
  String get authFailed;

  /// No description provided for @signedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String signedInAs(String email);

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountBody.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account and your collection — from the cloud and this device. This can\'t be undone.'**
  String get deleteAccountBody;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @reauthNeeded.
  ///
  /// In en, this message translates to:
  /// **'For security, sign in again and then retry deleting your account.'**
  String get reauthNeeded;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get accountDeleted;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete your account. Please try again.'**
  String get deleteFailed;

  /// No description provided for @guestEnter.
  ///
  /// In en, this message translates to:
  /// **'Browse as guest'**
  String get guestEnter;

  /// No description provided for @loginRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to add cards'**
  String get loginRequiredTitle;

  /// No description provided for @loginRequiredBody.
  ///
  /// In en, this message translates to:
  /// **'Create a free account or log in to start tracking your collection. As a guest you can only browse.'**
  String get loginRequiredBody;

  /// No description provided for @loginOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Log in or create account'**
  String get loginOrCreate;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeGreetingGuest.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get homeGreetingGuest;

  /// No description provided for @homeAlmostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get homeAlmostThere;

  /// No description provided for @homeDiscover.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get homeDiscover;

  /// No description provided for @homeToGo.
  ///
  /// In en, this message translates to:
  /// **'{n} to go'**
  String homeToGo(int n);

  /// No description provided for @homeSignInCta.
  ///
  /// In en, this message translates to:
  /// **'Sign in to start your collection'**
  String get homeSignInCta;

  /// No description provided for @openMyBinder.
  ///
  /// In en, this message translates to:
  /// **'Open my binder'**
  String get openMyBinder;

  /// No description provided for @askNameTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get askNameTitle;

  /// No description provided for @askNameBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a collector name — it shows on your home and profile.'**
  String get askNameBody;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @chooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose your avatar'**
  String get chooseAvatar;

  /// No description provided for @fillFields.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password.'**
  String get fillFields;

  /// No description provided for @tabCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get tabCommunity;

  /// No description provided for @communityDisclaimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get communityDisclaimerTitle;

  /// No description provided for @communityDisclaimerBody.
  ///
  /// In en, this message translates to:
  /// **'Community connects collectors to trade and sell cards. Deals are between users — Binderdex is not part of and isn\'t responsible for trades, payments or scams. Be careful, confirm with who you\'re trading with and never share sensitive data.'**
  String get communityDisclaimerBody;

  /// No description provided for @communityDisclaimerOk.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get communityDisclaimerOk;

  /// No description provided for @sellOrTrade.
  ///
  /// In en, this message translates to:
  /// **'Sell or trade cards'**
  String get sellOrTrade;

  /// No description provided for @addToCommunity.
  ///
  /// In en, this message translates to:
  /// **'Add to community ({n})'**
  String addToCommunity(Object n);

  /// No description provided for @onlyDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates only'**
  String get onlyDuplicates;

  /// No description provided for @myListings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get myListings;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @modeTrade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get modeTrade;

  /// No description provided for @modeSell.
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get modeSell;

  /// No description provided for @modeBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get modeBoth;

  /// No description provided for @condMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get condMint;

  /// No description provided for @condGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get condGood;

  /// No description provided for @condUsed.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get condUsed;

  /// No description provided for @condDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get condDamaged;

  /// No description provided for @whatIWant.
  ///
  /// In en, this message translates to:
  /// **'What I want in exchange'**
  String get whatIWant;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'Block'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get unblock;

  /// No description provided for @slotsUsed.
  ///
  /// In en, this message translates to:
  /// **'{used}/{limit} slots used'**
  String slotsUsed(Object used, Object limit);

  /// No description provided for @slotLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve hit your slot limit. Unlock more with Premium.'**
  String get slotLimitReached;

  /// No description provided for @premiumSlots.
  ///
  /// In en, this message translates to:
  /// **'Slots & Premium'**
  String get premiumSlots;

  /// No description provided for @recentListings.
  ///
  /// In en, this message translates to:
  /// **'Recent listings'**
  String get recentListings;

  /// No description provided for @searchCardHint.
  ///
  /// In en, this message translates to:
  /// **'Search a card…'**
  String get searchCardHint;

  /// No description provided for @communitySearchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Search a card to see who\'s selling or trading it.'**
  String get communitySearchPrompt;

  /// No description provided for @checkCommunityOffers.
  ///
  /// In en, this message translates to:
  /// **'Check community offers'**
  String get checkCommunityOffers;

  /// No description provided for @noListings.
  ///
  /// In en, this message translates to:
  /// **'No listings yet.'**
  String get noListings;

  /// No description provided for @noListingsBody.
  ///
  /// In en, this message translates to:
  /// **'When new listings are published, they\'ll show up here.'**
  String get noListingsBody;

  /// No description provided for @editListingTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get editListingTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @wantCardsLimit.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the card limit.'**
  String get wantCardsLimit;

  /// No description provided for @wantedCards.
  ///
  /// In en, this message translates to:
  /// **'Cards I want'**
  String get wantedCards;

  /// No description provided for @wishlistEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your wishlist is empty. Search for a card above.'**
  String get wishlistEmpty;

  /// No description provided for @deleteListingAction.
  ///
  /// In en, this message translates to:
  /// **'Delete listing'**
  String get deleteListingAction;

  /// No description provided for @deleteListingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this listing for good?'**
  String get deleteListingConfirm;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @noConversations.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet.'**
  String get noConversations;

  /// No description provided for @noConversationsBody.
  ///
  /// In en, this message translates to:
  /// **'Contact someone from a listing to get started.'**
  String get noConversationsBody;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeMessage;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactWarning.
  ///
  /// In en, this message translates to:
  /// **'You\'re about to share your own contact (email or phone). Binderdex isn\'t responsible for trades, payments or scams.'**
  String get contactWarning;

  /// No description provided for @sendAnyway.
  ///
  /// In en, this message translates to:
  /// **'Send anyway'**
  String get sendAnyway;

  /// No description provided for @blockConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block {name}? You\'ll stop seeing this person\'s listings and messages.'**
  String blockConfirm(Object name);

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'User blocked.'**
  String get userBlocked;

  /// No description provided for @premiumYourPlan.
  ///
  /// In en, this message translates to:
  /// **'Your plan: {name}'**
  String premiumYourPlan(Object name);

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @currentPlanTag.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get currentPlanTag;

  /// No description provided for @perkSlots.
  ///
  /// In en, this message translates to:
  /// **'{n} listing slots'**
  String perkSlots(Object n);

  /// No description provided for @perkBadge.
  ///
  /// In en, this message translates to:
  /// **'Premium badge'**
  String get perkBadge;

  /// No description provided for @perkAvatars.
  ///
  /// In en, this message translates to:
  /// **'Exclusive avatars'**
  String get perkAvatars;

  /// No description provided for @perkTradeMatchesCount.
  ///
  /// In en, this message translates to:
  /// **'See {n} perfect trades'**
  String perkTradeMatchesCount(Object n);

  /// No description provided for @perkTradeMatchesUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited perfect trades'**
  String get perkTradeMatchesUnlimited;

  /// No description provided for @tradeMatches.
  ///
  /// In en, this message translates to:
  /// **'Perfect trades'**
  String get tradeMatches;

  /// No description provided for @tradeMatchesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} perfect trades'**
  String tradeMatchesFound(Object count);

  /// No description provided for @noTradeMatches.
  ///
  /// In en, this message translates to:
  /// **'No perfect trades yet. Add cards to your wishlist and mark your duplicates!'**
  String get noTradeMatches;

  /// No description provided for @tradeReceive.
  ///
  /// In en, this message translates to:
  /// **'You get'**
  String get tradeReceive;

  /// No description provided for @tradeGive.
  ///
  /// In en, this message translates to:
  /// **'You give'**
  String get tradeGive;

  /// No description provided for @tradeMatchesLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium to see your perfect trades.'**
  String get tradeMatchesLockedBody;

  /// No description provided for @tradeMatchesSeeMore.
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} · upgrade to see them all'**
  String tradeMatchesSeeMore(Object shown, Object total);

  /// No description provided for @seePlans.
  ///
  /// In en, this message translates to:
  /// **'See Premium plans'**
  String get seePlans;

  /// No description provided for @collectionValue.
  ///
  /// In en, this message translates to:
  /// **'Collection value'**
  String get collectionValue;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @valueLockedBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium to see your collection\'s value.'**
  String get valueLockedBody;

  /// No description provided for @valueCoverage.
  ///
  /// In en, this message translates to:
  /// **'Based on {priced} of {total} cards'**
  String valueCoverage(Object priced, Object total);

  /// No description provided for @updatePrices.
  ///
  /// In en, this message translates to:
  /// **'Update prices'**
  String get updatePrices;

  /// No description provided for @pricesUpdated.
  ///
  /// In en, this message translates to:
  /// **'Prices updated'**
  String get pricesUpdated;

  /// No description provided for @mostValuable.
  ///
  /// In en, this message translates to:
  /// **'Most valuable'**
  String get mostValuable;

  /// No description provided for @showValue.
  ///
  /// In en, this message translates to:
  /// **'Show value'**
  String get showValue;

  /// No description provided for @hideValue.
  ///
  /// In en, this message translates to:
  /// **'Hide value'**
  String get hideValue;

  /// No description provided for @setsAdded.
  ///
  /// In en, this message translates to:
  /// **'{count} new collections!'**
  String setsAdded(Object count);

  /// No description provided for @setsUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Catalogue up to date'**
  String get setsUpToDate;

  /// No description provided for @refreshFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update'**
  String get refreshFailed;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @adminReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get adminReports;

  /// No description provided for @adminSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get adminSuggestions;

  /// No description provided for @noReports.
  ///
  /// In en, this message translates to:
  /// **'No reports.'**
  String get noReports;

  /// No description provided for @noSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions.'**
  String get noSuggestions;

  /// No description provided for @warnUser.
  ///
  /// In en, this message translates to:
  /// **'Warn'**
  String get warnUser;

  /// No description provided for @banUser.
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get banUser;

  /// No description provided for @markHandled.
  ///
  /// In en, this message translates to:
  /// **'Mark handled'**
  String get markHandled;

  /// No description provided for @warnTitle.
  ///
  /// In en, this message translates to:
  /// **'Warn user'**
  String get warnTitle;

  /// No description provided for @warnHint.
  ///
  /// In en, this message translates to:
  /// **'Warning message'**
  String get warnHint;

  /// No description provided for @banConfirm.
  ///
  /// In en, this message translates to:
  /// **'Ban this user? They won\'t be able to post or message.'**
  String get banConfirm;

  /// No description provided for @userWarned.
  ///
  /// In en, this message translates to:
  /// **'Warning sent'**
  String get userWarned;

  /// No description provided for @userBanned.
  ///
  /// In en, this message translates to:
  /// **'User banned'**
  String get userBanned;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Send a suggestion'**
  String get sendSuggestion;

  /// No description provided for @suggestionHint.
  ///
  /// In en, this message translates to:
  /// **'Your suggestion…'**
  String get suggestionHint;

  /// No description provided for @suggestionSent.
  ///
  /// In en, this message translates to:
  /// **'Suggestion sent. Thanks!'**
  String get suggestionSent;

  /// No description provided for @warningTitle.
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get warningTitle;

  /// No description provided for @accountSuspended.
  ///
  /// In en, this message translates to:
  /// **'Your account has been suspended.'**
  String get accountSuspended;

  /// No description provided for @accountSuspendedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account suspended'**
  String get accountSuspendedTitle;

  /// No description provided for @chatUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this conversation.'**
  String get chatUnavailable;

  /// No description provided for @bannedCommunity.
  ///
  /// In en, this message translates to:
  /// **'You\'re banned, so you can\'t use the Community.'**
  String get bannedCommunity;

  /// No description provided for @bannedPublish.
  ///
  /// In en, this message translates to:
  /// **'You\'re banned, so you can\'t post listings.'**
  String get bannedPublish;

  /// No description provided for @appeal.
  ///
  /// In en, this message translates to:
  /// **'Appeal'**
  String get appeal;

  /// No description provided for @appealHint.
  ///
  /// In en, this message translates to:
  /// **'Explain your situation…'**
  String get appealHint;

  /// No description provided for @appealSent.
  ///
  /// In en, this message translates to:
  /// **'Appeal sent.'**
  String get appealSent;

  /// No description provided for @accountReactivatedTitle.
  ///
  /// In en, this message translates to:
  /// **'Account reactivated'**
  String get accountReactivatedTitle;

  /// No description provided for @accountReactivated.
  ///
  /// In en, this message translates to:
  /// **'Your account has been reactivated.'**
  String get accountReactivated;

  /// No description provided for @adminAppeals.
  ///
  /// In en, this message translates to:
  /// **'Appeals'**
  String get adminAppeals;

  /// No description provided for @noAppeals.
  ///
  /// In en, this message translates to:
  /// **'No appeals.'**
  String get noAppeals;

  /// No description provided for @reportReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting?'**
  String get reportReasonTitle;

  /// No description provided for @reportScam.
  ///
  /// In en, this message translates to:
  /// **'Fraud / scam'**
  String get reportScam;

  /// No description provided for @reportAbuse.
  ///
  /// In en, this message translates to:
  /// **'Abusive messages'**
  String get reportAbuse;

  /// No description provided for @reportInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportInappropriate;

  /// No description provided for @reportFake.
  ///
  /// In en, this message translates to:
  /// **'Fake / not as described'**
  String get reportFake;

  /// No description provided for @reportSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get reportSpam;

  /// No description provided for @reportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportOther;

  /// No description provided for @reportAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get reportAll;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Report sent'**
  String get reportSent;

  /// No description provided for @reporterLabel.
  ///
  /// In en, this message translates to:
  /// **'Reporter'**
  String get reporterLabel;

  /// No description provided for @reportedLabel.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get reportedLabel;

  /// No description provided for @noConversation.
  ///
  /// In en, this message translates to:
  /// **'No conversation between these users.'**
  String get noConversation;

  /// No description provided for @adminBanned.
  ///
  /// In en, this message translates to:
  /// **'Banned users'**
  String get adminBanned;

  /// No description provided for @adminPremium.
  ///
  /// In en, this message translates to:
  /// **'Premium users'**
  String get adminPremium;

  /// No description provided for @adminBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Broadcast'**
  String get adminBroadcast;

  /// No description provided for @noBanned.
  ///
  /// In en, this message translates to:
  /// **'No banned users.'**
  String get noBanned;

  /// No description provided for @unban.
  ///
  /// In en, this message translates to:
  /// **'Unban'**
  String get unban;

  /// No description provided for @noPremiumUsers.
  ///
  /// In en, this message translates to:
  /// **'No premium users.'**
  String get noPremiumUsers;

  /// No description provided for @grantPremium.
  ///
  /// In en, this message translates to:
  /// **'Grant premium (uid)'**
  String get grantPremium;

  /// No description provided for @uidHint.
  ///
  /// In en, this message translates to:
  /// **'User uid'**
  String get uidHint;

  /// No description provided for @grant.
  ///
  /// In en, this message translates to:
  /// **'Grant'**
  String get grant;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @premiumUpdated.
  ///
  /// In en, this message translates to:
  /// **'Premium updated'**
  String get premiumUpdated;

  /// No description provided for @broadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get broadcastTitle;

  /// No description provided for @broadcastBody.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get broadcastBody;

  /// No description provided for @broadcastSend.
  ///
  /// In en, this message translates to:
  /// **'Send to everyone'**
  String get broadcastSend;

  /// No description provided for @broadcastSent.
  ///
  /// In en, this message translates to:
  /// **'Broadcast sent'**
  String get broadcastSent;

  /// No description provided for @listingDeleted.
  ///
  /// In en, this message translates to:
  /// **'Listing deleted'**
  String get listingDeleted;

  /// No description provided for @deleteListing.
  ///
  /// In en, this message translates to:
  /// **'Delete listing'**
  String get deleteListing;

  /// No description provided for @notifBroadcast.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get notifBroadcast;

  /// No description provided for @statListings.
  ///
  /// In en, this message translates to:
  /// **'Active listings'**
  String get statListings;

  /// No description provided for @statReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get statReports;

  /// No description provided for @bannedLabel.
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get bannedLabel;

  /// No description provided for @resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get resolved;

  /// No description provided for @resolvedWarn.
  ///
  /// In en, this message translates to:
  /// **'Resolved · Warned'**
  String get resolvedWarn;

  /// No description provided for @resolvedBan.
  ///
  /// In en, this message translates to:
  /// **'Resolved · Banned'**
  String get resolvedBan;

  /// No description provided for @resolvedDelete.
  ///
  /// In en, this message translates to:
  /// **'Resolved · Listing deleted'**
  String get resolvedDelete;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @premiumOnly.
  ///
  /// In en, this message translates to:
  /// **'Premium only'**
  String get premiumOnly;

  /// No description provided for @premiumUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{name} unlocked!'**
  String premiumUnlocked(Object name);

  /// No description provided for @youUnlocked.
  ///
  /// In en, this message translates to:
  /// **'You unlocked:'**
  String get youUnlocked;

  /// No description provided for @subscriptionNotRenewed.
  ///
  /// In en, this message translates to:
  /// **'Subscription not renewed'**
  String get subscriptionNotRenewed;

  /// No description provided for @backToFreeBody.
  ///
  /// In en, this message translates to:
  /// **'You\'re back on the Free plan — you lost the extra slots, the badge and premium avatars.'**
  String get backToFreeBody;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @archivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedTitle;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'Delete chat'**
  String get deleteConversation;

  /// No description provided for @deleteConversationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this chat? It comes back if you get a new message.'**
  String get deleteConversationConfirm;

  /// No description provided for @noArchived.
  ///
  /// In en, this message translates to:
  /// **'No archived chats.'**
  String get noArchived;

  /// No description provided for @tabBinderShort.
  ///
  /// In en, this message translates to:
  /// **'Binder'**
  String get tabBinderShort;

  /// No description provided for @blockedUsers.
  ///
  /// In en, this message translates to:
  /// **'Blocked people'**
  String get blockedUsers;

  /// No description provided for @noBlockedUsers.
  ///
  /// In en, this message translates to:
  /// **'No blocked people.'**
  String get noBlockedUsers;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications.'**
  String get noNotifications;

  /// No description provided for @notifCleared.
  ///
  /// In en, this message translates to:
  /// **'Notification cleared'**
  String get notifCleared;

  /// No description provided for @notifNewMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get notifNewMessage;

  /// No description provided for @notifWishlistAvailable.
  ///
  /// In en, this message translates to:
  /// **'Tracked card available'**
  String get notifWishlistAvailable;

  /// No description provided for @notifNewCollection.
  ///
  /// In en, this message translates to:
  /// **'New collection'**
  String get notifNewCollection;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
