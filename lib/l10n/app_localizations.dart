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
