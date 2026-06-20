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
}
