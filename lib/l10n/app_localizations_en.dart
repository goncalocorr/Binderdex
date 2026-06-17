// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Card Binder';

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
}
