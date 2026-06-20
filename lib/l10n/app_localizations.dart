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
  /// **'Card Binder'**
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
