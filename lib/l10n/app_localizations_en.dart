// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pokédex';

  @override
  String get searchHint => 'Search by name or number';

  @override
  String get tabPokedex => 'Pokédex';

  @override
  String get tabProgress => 'Progress';

  @override
  String get tabMissing => 'Missing';

  @override
  String get tabSettings => 'Settings';

  @override
  String get caught => 'Caught';

  @override
  String get shiny => 'Shiny';

  @override
  String get quantity => 'Quantity';

  @override
  String get notes => 'Notes';

  @override
  String get baseStats => 'Base stats';

  @override
  String get statHp => 'HP';

  @override
  String get statAttack => 'Attack';

  @override
  String get statDefense => 'Defense';

  @override
  String get statSpAttack => 'Sp. Atk';

  @override
  String get statSpDefense => 'Sp. Def';

  @override
  String get statSpeed => 'Speed';

  @override
  String get filterStatus => 'Status';

  @override
  String get filterGeneration => 'Generation';

  @override
  String get filterType => 'Type';

  @override
  String get statusAll => 'All';

  @override
  String get statusCaught => 'Caught';

  @override
  String get statusMissing => 'Missing';

  @override
  String get statusShiny => 'Shiny';

  @override
  String get progressGlobal => 'Global progress';

  @override
  String progressGeneration(int n) {
    return 'Generation $n';
  }

  @override
  String missingCount(int n) {
    return 'Missing: $n';
  }

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
