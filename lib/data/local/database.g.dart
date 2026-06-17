// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CardSetsTable extends CardSets
    with TableInfo<$CardSetsTable, CardSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _seriesMeta = const VerificationMeta('series');
  @override
  late final GeneratedColumn<String> series = GeneratedColumn<String>(
      'series', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _printedTotalMeta =
      const VerificationMeta('printedTotal');
  @override
  late final GeneratedColumn<int> printedTotal = GeneratedColumn<int>(
      'printed_total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
      'total', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _releaseDateMeta =
      const VerificationMeta('releaseDate');
  @override
  late final GeneratedColumn<String> releaseDate = GeneratedColumn<String>(
      'release_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolUrlMeta =
      const VerificationMeta('symbolUrl');
  @override
  late final GeneratedColumn<String> symbolUrl = GeneratedColumn<String>(
      'symbol_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _logoUrlMeta =
      const VerificationMeta('logoUrl');
  @override
  late final GeneratedColumn<String> logoUrl = GeneratedColumn<String>(
      'logo_url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardsSyncedMeta =
      const VerificationMeta('cardsSynced');
  @override
  late final GeneratedColumn<bool> cardsSynced = GeneratedColumn<bool>(
      'cards_synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("cards_synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        series,
        printedTotal,
        total,
        releaseDate,
        symbolUrl,
        logoUrl,
        cardsSynced
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_sets';
  @override
  VerificationContext validateIntegrity(Insertable<CardSetRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('series')) {
      context.handle(_seriesMeta,
          series.isAcceptableOrUnknown(data['series']!, _seriesMeta));
    } else if (isInserting) {
      context.missing(_seriesMeta);
    }
    if (data.containsKey('printed_total')) {
      context.handle(
          _printedTotalMeta,
          printedTotal.isAcceptableOrUnknown(
              data['printed_total']!, _printedTotalMeta));
    } else if (isInserting) {
      context.missing(_printedTotalMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
          _totalMeta, total.isAcceptableOrUnknown(data['total']!, _totalMeta));
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('release_date')) {
      context.handle(
          _releaseDateMeta,
          releaseDate.isAcceptableOrUnknown(
              data['release_date']!, _releaseDateMeta));
    } else if (isInserting) {
      context.missing(_releaseDateMeta);
    }
    if (data.containsKey('symbol_url')) {
      context.handle(_symbolUrlMeta,
          symbolUrl.isAcceptableOrUnknown(data['symbol_url']!, _symbolUrlMeta));
    } else if (isInserting) {
      context.missing(_symbolUrlMeta);
    }
    if (data.containsKey('logo_url')) {
      context.handle(_logoUrlMeta,
          logoUrl.isAcceptableOrUnknown(data['logo_url']!, _logoUrlMeta));
    } else if (isInserting) {
      context.missing(_logoUrlMeta);
    }
    if (data.containsKey('cards_synced')) {
      context.handle(
          _cardsSyncedMeta,
          cardsSynced.isAcceptableOrUnknown(
              data['cards_synced']!, _cardsSyncedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardSetRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      series: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}series'])!,
      printedTotal: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}printed_total'])!,
      total: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total'])!,
      releaseDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}release_date'])!,
      symbolUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol_url'])!,
      logoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}logo_url'])!,
      cardsSynced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}cards_synced'])!,
    );
  }

  @override
  $CardSetsTable createAlias(String alias) {
    return $CardSetsTable(attachedDatabase, alias);
  }
}

class CardSetRow extends DataClass implements Insertable<CardSetRow> {
  final String id;
  final String name;
  final String series;
  final int printedTotal;
  final int total;
  final String releaseDate;
  final String symbolUrl;
  final String logoUrl;

  /// True quando as cartas deste set já foram buscadas e cacheadas.
  final bool cardsSynced;
  const CardSetRow(
      {required this.id,
      required this.name,
      required this.series,
      required this.printedTotal,
      required this.total,
      required this.releaseDate,
      required this.symbolUrl,
      required this.logoUrl,
      required this.cardsSynced});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['series'] = Variable<String>(series);
    map['printed_total'] = Variable<int>(printedTotal);
    map['total'] = Variable<int>(total);
    map['release_date'] = Variable<String>(releaseDate);
    map['symbol_url'] = Variable<String>(symbolUrl);
    map['logo_url'] = Variable<String>(logoUrl);
    map['cards_synced'] = Variable<bool>(cardsSynced);
    return map;
  }

  CardSetsCompanion toCompanion(bool nullToAbsent) {
    return CardSetsCompanion(
      id: Value(id),
      name: Value(name),
      series: Value(series),
      printedTotal: Value(printedTotal),
      total: Value(total),
      releaseDate: Value(releaseDate),
      symbolUrl: Value(symbolUrl),
      logoUrl: Value(logoUrl),
      cardsSynced: Value(cardsSynced),
    );
  }

  factory CardSetRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardSetRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      series: serializer.fromJson<String>(json['series']),
      printedTotal: serializer.fromJson<int>(json['printedTotal']),
      total: serializer.fromJson<int>(json['total']),
      releaseDate: serializer.fromJson<String>(json['releaseDate']),
      symbolUrl: serializer.fromJson<String>(json['symbolUrl']),
      logoUrl: serializer.fromJson<String>(json['logoUrl']),
      cardsSynced: serializer.fromJson<bool>(json['cardsSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'series': serializer.toJson<String>(series),
      'printedTotal': serializer.toJson<int>(printedTotal),
      'total': serializer.toJson<int>(total),
      'releaseDate': serializer.toJson<String>(releaseDate),
      'symbolUrl': serializer.toJson<String>(symbolUrl),
      'logoUrl': serializer.toJson<String>(logoUrl),
      'cardsSynced': serializer.toJson<bool>(cardsSynced),
    };
  }

  CardSetRow copyWith(
          {String? id,
          String? name,
          String? series,
          int? printedTotal,
          int? total,
          String? releaseDate,
          String? symbolUrl,
          String? logoUrl,
          bool? cardsSynced}) =>
      CardSetRow(
        id: id ?? this.id,
        name: name ?? this.name,
        series: series ?? this.series,
        printedTotal: printedTotal ?? this.printedTotal,
        total: total ?? this.total,
        releaseDate: releaseDate ?? this.releaseDate,
        symbolUrl: symbolUrl ?? this.symbolUrl,
        logoUrl: logoUrl ?? this.logoUrl,
        cardsSynced: cardsSynced ?? this.cardsSynced,
      );
  CardSetRow copyWithCompanion(CardSetsCompanion data) {
    return CardSetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      series: data.series.present ? data.series.value : this.series,
      printedTotal: data.printedTotal.present
          ? data.printedTotal.value
          : this.printedTotal,
      total: data.total.present ? data.total.value : this.total,
      releaseDate:
          data.releaseDate.present ? data.releaseDate.value : this.releaseDate,
      symbolUrl: data.symbolUrl.present ? data.symbolUrl.value : this.symbolUrl,
      logoUrl: data.logoUrl.present ? data.logoUrl.value : this.logoUrl,
      cardsSynced:
          data.cardsSynced.present ? data.cardsSynced.value : this.cardsSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardSetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('series: $series, ')
          ..write('printedTotal: $printedTotal, ')
          ..write('total: $total, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('symbolUrl: $symbolUrl, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('cardsSynced: $cardsSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, series, printedTotal, total,
      releaseDate, symbolUrl, logoUrl, cardsSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardSetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.series == this.series &&
          other.printedTotal == this.printedTotal &&
          other.total == this.total &&
          other.releaseDate == this.releaseDate &&
          other.symbolUrl == this.symbolUrl &&
          other.logoUrl == this.logoUrl &&
          other.cardsSynced == this.cardsSynced);
}

class CardSetsCompanion extends UpdateCompanion<CardSetRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> series;
  final Value<int> printedTotal;
  final Value<int> total;
  final Value<String> releaseDate;
  final Value<String> symbolUrl;
  final Value<String> logoUrl;
  final Value<bool> cardsSynced;
  final Value<int> rowid;
  const CardSetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.series = const Value.absent(),
    this.printedTotal = const Value.absent(),
    this.total = const Value.absent(),
    this.releaseDate = const Value.absent(),
    this.symbolUrl = const Value.absent(),
    this.logoUrl = const Value.absent(),
    this.cardsSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardSetsCompanion.insert({
    required String id,
    required String name,
    required String series,
    required int printedTotal,
    required int total,
    required String releaseDate,
    required String symbolUrl,
    required String logoUrl,
    this.cardsSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        series = Value(series),
        printedTotal = Value(printedTotal),
        total = Value(total),
        releaseDate = Value(releaseDate),
        symbolUrl = Value(symbolUrl),
        logoUrl = Value(logoUrl);
  static Insertable<CardSetRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? series,
    Expression<int>? printedTotal,
    Expression<int>? total,
    Expression<String>? releaseDate,
    Expression<String>? symbolUrl,
    Expression<String>? logoUrl,
    Expression<bool>? cardsSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (series != null) 'series': series,
      if (printedTotal != null) 'printed_total': printedTotal,
      if (total != null) 'total': total,
      if (releaseDate != null) 'release_date': releaseDate,
      if (symbolUrl != null) 'symbol_url': symbolUrl,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (cardsSynced != null) 'cards_synced': cardsSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardSetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? series,
      Value<int>? printedTotal,
      Value<int>? total,
      Value<String>? releaseDate,
      Value<String>? symbolUrl,
      Value<String>? logoUrl,
      Value<bool>? cardsSynced,
      Value<int>? rowid}) {
    return CardSetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      series: series ?? this.series,
      printedTotal: printedTotal ?? this.printedTotal,
      total: total ?? this.total,
      releaseDate: releaseDate ?? this.releaseDate,
      symbolUrl: symbolUrl ?? this.symbolUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      cardsSynced: cardsSynced ?? this.cardsSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (series.present) {
      map['series'] = Variable<String>(series.value);
    }
    if (printedTotal.present) {
      map['printed_total'] = Variable<int>(printedTotal.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (releaseDate.present) {
      map['release_date'] = Variable<String>(releaseDate.value);
    }
    if (symbolUrl.present) {
      map['symbol_url'] = Variable<String>(symbolUrl.value);
    }
    if (logoUrl.present) {
      map['logo_url'] = Variable<String>(logoUrl.value);
    }
    if (cardsSynced.present) {
      map['cards_synced'] = Variable<bool>(cardsSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardSetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('series: $series, ')
          ..write('printedTotal: $printedTotal, ')
          ..write('total: $total, ')
          ..write('releaseDate: $releaseDate, ')
          ..write('symbolUrl: $symbolUrl, ')
          ..write('logoUrl: $logoUrl, ')
          ..write('cardsSynced: $cardsSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TcgCardsTable extends TcgCards
    with TableInfo<$TcgCardsTable, TcgCardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TcgCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
      'set_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<String> number = GeneratedColumn<String>(
      'number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberSortMeta =
      const VerificationMeta('numberSort');
  @override
  late final GeneratedColumn<int> numberSort = GeneratedColumn<int>(
      'number_sort', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rarityMeta = const VerificationMeta('rarity');
  @override
  late final GeneratedColumn<String> rarity = GeneratedColumn<String>(
      'rarity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _supertypeMeta =
      const VerificationMeta('supertype');
  @override
  late final GeneratedColumn<String> supertype = GeneratedColumn<String>(
      'supertype', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _imageSmallMeta =
      const VerificationMeta('imageSmall');
  @override
  late final GeneratedColumn<String> imageSmall = GeneratedColumn<String>(
      'image_small', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageLargeMeta =
      const VerificationMeta('imageLarge');
  @override
  late final GeneratedColumn<String> imageLarge = GeneratedColumn<String>(
      'image_large', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        setId,
        name,
        number,
        numberSort,
        rarity,
        supertype,
        type,
        imageSmall,
        imageLarge
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tcg_cards';
  @override
  VerificationContext validateIntegrity(Insertable<TcgCardRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
          _setIdMeta, setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta));
    } else if (isInserting) {
      context.missing(_setIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('number_sort')) {
      context.handle(
          _numberSortMeta,
          numberSort.isAcceptableOrUnknown(
              data['number_sort']!, _numberSortMeta));
    } else if (isInserting) {
      context.missing(_numberSortMeta);
    }
    if (data.containsKey('rarity')) {
      context.handle(_rarityMeta,
          rarity.isAcceptableOrUnknown(data['rarity']!, _rarityMeta));
    }
    if (data.containsKey('supertype')) {
      context.handle(_supertypeMeta,
          supertype.isAcceptableOrUnknown(data['supertype']!, _supertypeMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('image_small')) {
      context.handle(
          _imageSmallMeta,
          imageSmall.isAcceptableOrUnknown(
              data['image_small']!, _imageSmallMeta));
    } else if (isInserting) {
      context.missing(_imageSmallMeta);
    }
    if (data.containsKey('image_large')) {
      context.handle(
          _imageLargeMeta,
          imageLarge.isAcceptableOrUnknown(
              data['image_large']!, _imageLargeMeta));
    } else if (isInserting) {
      context.missing(_imageLargeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TcgCardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TcgCardRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      setId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}set_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}number'])!,
      numberSort: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number_sort'])!,
      rarity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rarity']),
      supertype: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supertype']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type']),
      imageSmall: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_small'])!,
      imageLarge: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_large'])!,
    );
  }

  @override
  $TcgCardsTable createAlias(String alias) {
    return $TcgCardsTable(attachedDatabase, alias);
  }
}

class TcgCardRow extends DataClass implements Insertable<TcgCardRow> {
  final String id;
  final String setId;
  final String name;
  final String number;
  final int numberSort;
  final String? rarity;
  final String? supertype;
  final String? type;
  final String imageSmall;
  final String imageLarge;
  const TcgCardRow(
      {required this.id,
      required this.setId,
      required this.name,
      required this.number,
      required this.numberSort,
      this.rarity,
      this.supertype,
      this.type,
      required this.imageSmall,
      required this.imageLarge});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['set_id'] = Variable<String>(setId);
    map['name'] = Variable<String>(name);
    map['number'] = Variable<String>(number);
    map['number_sort'] = Variable<int>(numberSort);
    if (!nullToAbsent || rarity != null) {
      map['rarity'] = Variable<String>(rarity);
    }
    if (!nullToAbsent || supertype != null) {
      map['supertype'] = Variable<String>(supertype);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    map['image_small'] = Variable<String>(imageSmall);
    map['image_large'] = Variable<String>(imageLarge);
    return map;
  }

  TcgCardsCompanion toCompanion(bool nullToAbsent) {
    return TcgCardsCompanion(
      id: Value(id),
      setId: Value(setId),
      name: Value(name),
      number: Value(number),
      numberSort: Value(numberSort),
      rarity:
          rarity == null && nullToAbsent ? const Value.absent() : Value(rarity),
      supertype: supertype == null && nullToAbsent
          ? const Value.absent()
          : Value(supertype),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      imageSmall: Value(imageSmall),
      imageLarge: Value(imageLarge),
    );
  }

  factory TcgCardRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TcgCardRow(
      id: serializer.fromJson<String>(json['id']),
      setId: serializer.fromJson<String>(json['setId']),
      name: serializer.fromJson<String>(json['name']),
      number: serializer.fromJson<String>(json['number']),
      numberSort: serializer.fromJson<int>(json['numberSort']),
      rarity: serializer.fromJson<String?>(json['rarity']),
      supertype: serializer.fromJson<String?>(json['supertype']),
      type: serializer.fromJson<String?>(json['type']),
      imageSmall: serializer.fromJson<String>(json['imageSmall']),
      imageLarge: serializer.fromJson<String>(json['imageLarge']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'setId': serializer.toJson<String>(setId),
      'name': serializer.toJson<String>(name),
      'number': serializer.toJson<String>(number),
      'numberSort': serializer.toJson<int>(numberSort),
      'rarity': serializer.toJson<String?>(rarity),
      'supertype': serializer.toJson<String?>(supertype),
      'type': serializer.toJson<String?>(type),
      'imageSmall': serializer.toJson<String>(imageSmall),
      'imageLarge': serializer.toJson<String>(imageLarge),
    };
  }

  TcgCardRow copyWith(
          {String? id,
          String? setId,
          String? name,
          String? number,
          int? numberSort,
          Value<String?> rarity = const Value.absent(),
          Value<String?> supertype = const Value.absent(),
          Value<String?> type = const Value.absent(),
          String? imageSmall,
          String? imageLarge}) =>
      TcgCardRow(
        id: id ?? this.id,
        setId: setId ?? this.setId,
        name: name ?? this.name,
        number: number ?? this.number,
        numberSort: numberSort ?? this.numberSort,
        rarity: rarity.present ? rarity.value : this.rarity,
        supertype: supertype.present ? supertype.value : this.supertype,
        type: type.present ? type.value : this.type,
        imageSmall: imageSmall ?? this.imageSmall,
        imageLarge: imageLarge ?? this.imageLarge,
      );
  TcgCardRow copyWithCompanion(TcgCardsCompanion data) {
    return TcgCardRow(
      id: data.id.present ? data.id.value : this.id,
      setId: data.setId.present ? data.setId.value : this.setId,
      name: data.name.present ? data.name.value : this.name,
      number: data.number.present ? data.number.value : this.number,
      numberSort:
          data.numberSort.present ? data.numberSort.value : this.numberSort,
      rarity: data.rarity.present ? data.rarity.value : this.rarity,
      supertype: data.supertype.present ? data.supertype.value : this.supertype,
      type: data.type.present ? data.type.value : this.type,
      imageSmall:
          data.imageSmall.present ? data.imageSmall.value : this.imageSmall,
      imageLarge:
          data.imageLarge.present ? data.imageLarge.value : this.imageLarge,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TcgCardRow(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('numberSort: $numberSort, ')
          ..write('rarity: $rarity, ')
          ..write('supertype: $supertype, ')
          ..write('type: $type, ')
          ..write('imageSmall: $imageSmall, ')
          ..write('imageLarge: $imageLarge')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, setId, name, number, numberSort, rarity,
      supertype, type, imageSmall, imageLarge);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TcgCardRow &&
          other.id == this.id &&
          other.setId == this.setId &&
          other.name == this.name &&
          other.number == this.number &&
          other.numberSort == this.numberSort &&
          other.rarity == this.rarity &&
          other.supertype == this.supertype &&
          other.type == this.type &&
          other.imageSmall == this.imageSmall &&
          other.imageLarge == this.imageLarge);
}

class TcgCardsCompanion extends UpdateCompanion<TcgCardRow> {
  final Value<String> id;
  final Value<String> setId;
  final Value<String> name;
  final Value<String> number;
  final Value<int> numberSort;
  final Value<String?> rarity;
  final Value<String?> supertype;
  final Value<String?> type;
  final Value<String> imageSmall;
  final Value<String> imageLarge;
  final Value<int> rowid;
  const TcgCardsCompanion({
    this.id = const Value.absent(),
    this.setId = const Value.absent(),
    this.name = const Value.absent(),
    this.number = const Value.absent(),
    this.numberSort = const Value.absent(),
    this.rarity = const Value.absent(),
    this.supertype = const Value.absent(),
    this.type = const Value.absent(),
    this.imageSmall = const Value.absent(),
    this.imageLarge = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TcgCardsCompanion.insert({
    required String id,
    required String setId,
    required String name,
    required String number,
    required int numberSort,
    this.rarity = const Value.absent(),
    this.supertype = const Value.absent(),
    this.type = const Value.absent(),
    required String imageSmall,
    required String imageLarge,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        setId = Value(setId),
        name = Value(name),
        number = Value(number),
        numberSort = Value(numberSort),
        imageSmall = Value(imageSmall),
        imageLarge = Value(imageLarge);
  static Insertable<TcgCardRow> custom({
    Expression<String>? id,
    Expression<String>? setId,
    Expression<String>? name,
    Expression<String>? number,
    Expression<int>? numberSort,
    Expression<String>? rarity,
    Expression<String>? supertype,
    Expression<String>? type,
    Expression<String>? imageSmall,
    Expression<String>? imageLarge,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (setId != null) 'set_id': setId,
      if (name != null) 'name': name,
      if (number != null) 'number': number,
      if (numberSort != null) 'number_sort': numberSort,
      if (rarity != null) 'rarity': rarity,
      if (supertype != null) 'supertype': supertype,
      if (type != null) 'type': type,
      if (imageSmall != null) 'image_small': imageSmall,
      if (imageLarge != null) 'image_large': imageLarge,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TcgCardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? setId,
      Value<String>? name,
      Value<String>? number,
      Value<int>? numberSort,
      Value<String?>? rarity,
      Value<String?>? supertype,
      Value<String?>? type,
      Value<String>? imageSmall,
      Value<String>? imageLarge,
      Value<int>? rowid}) {
    return TcgCardsCompanion(
      id: id ?? this.id,
      setId: setId ?? this.setId,
      name: name ?? this.name,
      number: number ?? this.number,
      numberSort: numberSort ?? this.numberSort,
      rarity: rarity ?? this.rarity,
      supertype: supertype ?? this.supertype,
      type: type ?? this.type,
      imageSmall: imageSmall ?? this.imageSmall,
      imageLarge: imageLarge ?? this.imageLarge,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (number.present) {
      map['number'] = Variable<String>(number.value);
    }
    if (numberSort.present) {
      map['number_sort'] = Variable<int>(numberSort.value);
    }
    if (rarity.present) {
      map['rarity'] = Variable<String>(rarity.value);
    }
    if (supertype.present) {
      map['supertype'] = Variable<String>(supertype.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (imageSmall.present) {
      map['image_small'] = Variable<String>(imageSmall.value);
    }
    if (imageLarge.present) {
      map['image_large'] = Variable<String>(imageLarge.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TcgCardsCompanion(')
          ..write('id: $id, ')
          ..write('setId: $setId, ')
          ..write('name: $name, ')
          ..write('number: $number, ')
          ..write('numberSort: $numberSort, ')
          ..write('rarity: $rarity, ')
          ..write('supertype: $supertype, ')
          ..write('type: $type, ')
          ..write('imageSmall: $imageSmall, ')
          ..write('imageLarge: $imageLarge, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserCardEntriesTable extends UserCardEntries
    with TableInfo<$UserCardEntriesTable, UserCardEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCardEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ownedMeta = const VerificationMeta('owned');
  @override
  late final GeneratedColumn<bool> owned = GeneratedColumn<bool>(
      'owned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("owned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _variantMeta =
      const VerificationMeta('variant');
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
      'variant', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('normal'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [cardId, owned, quantity, variant, notes, updatedAt, dirty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_card_entries';
  @override
  VerificationContext validateIntegrity(Insertable<UserCardEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('owned')) {
      context.handle(
          _ownedMeta, owned.isAcceptableOrUnknown(data['owned']!, _ownedMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('variant')) {
      context.handle(_variantMeta,
          variant.isAcceptableOrUnknown(data['variant']!, _variantMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cardId};
  @override
  UserCardEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCardEntryRow(
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      owned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}owned'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      variant: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variant'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
    );
  }

  @override
  $UserCardEntriesTable createAlias(String alias) {
    return $UserCardEntriesTable(attachedDatabase, alias);
  }
}

class UserCardEntryRow extends DataClass
    implements Insertable<UserCardEntryRow> {
  final String cardId;
  final bool owned;
  final int quantity;
  final String variant;
  final String notes;
  final DateTime updatedAt;
  final bool dirty;
  const UserCardEntryRow(
      {required this.cardId,
      required this.owned,
      required this.quantity,
      required this.variant,
      required this.notes,
      required this.updatedAt,
      required this.dirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['card_id'] = Variable<String>(cardId);
    map['owned'] = Variable<bool>(owned);
    map['quantity'] = Variable<int>(quantity);
    map['variant'] = Variable<String>(variant);
    map['notes'] = Variable<String>(notes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  UserCardEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserCardEntriesCompanion(
      cardId: Value(cardId),
      owned: Value(owned),
      quantity: Value(quantity),
      variant: Value(variant),
      notes: Value(notes),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
    );
  }

  factory UserCardEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCardEntryRow(
      cardId: serializer.fromJson<String>(json['cardId']),
      owned: serializer.fromJson<bool>(json['owned']),
      quantity: serializer.fromJson<int>(json['quantity']),
      variant: serializer.fromJson<String>(json['variant']),
      notes: serializer.fromJson<String>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cardId': serializer.toJson<String>(cardId),
      'owned': serializer.toJson<bool>(owned),
      'quantity': serializer.toJson<int>(quantity),
      'variant': serializer.toJson<String>(variant),
      'notes': serializer.toJson<String>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  UserCardEntryRow copyWith(
          {String? cardId,
          bool? owned,
          int? quantity,
          String? variant,
          String? notes,
          DateTime? updatedAt,
          bool? dirty}) =>
      UserCardEntryRow(
        cardId: cardId ?? this.cardId,
        owned: owned ?? this.owned,
        quantity: quantity ?? this.quantity,
        variant: variant ?? this.variant,
        notes: notes ?? this.notes,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
      );
  UserCardEntryRow copyWithCompanion(UserCardEntriesCompanion data) {
    return UserCardEntryRow(
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      owned: data.owned.present ? data.owned.value : this.owned,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      variant: data.variant.present ? data.variant.value : this.variant,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCardEntryRow(')
          ..write('cardId: $cardId, ')
          ..write('owned: $owned, ')
          ..write('quantity: $quantity, ')
          ..write('variant: $variant, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(cardId, owned, quantity, variant, notes, updatedAt, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCardEntryRow &&
          other.cardId == this.cardId &&
          other.owned == this.owned &&
          other.quantity == this.quantity &&
          other.variant == this.variant &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty);
}

class UserCardEntriesCompanion extends UpdateCompanion<UserCardEntryRow> {
  final Value<String> cardId;
  final Value<bool> owned;
  final Value<int> quantity;
  final Value<String> variant;
  final Value<String> notes;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  final Value<int> rowid;
  const UserCardEntriesCompanion({
    this.cardId = const Value.absent(),
    this.owned = const Value.absent(),
    this.quantity = const Value.absent(),
    this.variant = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCardEntriesCompanion.insert({
    required String cardId,
    this.owned = const Value.absent(),
    this.quantity = const Value.absent(),
    this.variant = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : cardId = Value(cardId),
        updatedAt = Value(updatedAt);
  static Insertable<UserCardEntryRow> custom({
    Expression<String>? cardId,
    Expression<bool>? owned,
    Expression<int>? quantity,
    Expression<String>? variant,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cardId != null) 'card_id': cardId,
      if (owned != null) 'owned': owned,
      if (quantity != null) 'quantity': quantity,
      if (variant != null) 'variant': variant,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCardEntriesCompanion copyWith(
      {Value<String>? cardId,
      Value<bool>? owned,
      Value<int>? quantity,
      Value<String>? variant,
      Value<String>? notes,
      Value<DateTime>? updatedAt,
      Value<bool>? dirty,
      Value<int>? rowid}) {
    return UserCardEntriesCompanion(
      cardId: cardId ?? this.cardId,
      owned: owned ?? this.owned,
      quantity: quantity ?? this.quantity,
      variant: variant ?? this.variant,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (owned.present) {
      map['owned'] = Variable<bool>(owned.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCardEntriesCompanion(')
          ..write('cardId: $cardId, ')
          ..write('owned: $owned, ')
          ..write('quantity: $quantity, ')
          ..write('variant: $variant, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CardSetsTable cardSets = $CardSetsTable(this);
  late final $TcgCardsTable tcgCards = $TcgCardsTable(this);
  late final $UserCardEntriesTable userCardEntries =
      $UserCardEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [cardSets, tcgCards, userCardEntries];
}

typedef $$CardSetsTableCreateCompanionBuilder = CardSetsCompanion Function({
  required String id,
  required String name,
  required String series,
  required int printedTotal,
  required int total,
  required String releaseDate,
  required String symbolUrl,
  required String logoUrl,
  Value<bool> cardsSynced,
  Value<int> rowid,
});
typedef $$CardSetsTableUpdateCompanionBuilder = CardSetsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> series,
  Value<int> printedTotal,
  Value<int> total,
  Value<String> releaseDate,
  Value<String> symbolUrl,
  Value<String> logoUrl,
  Value<bool> cardsSynced,
  Value<int> rowid,
});

class $$CardSetsTableFilterComposer
    extends Composer<_$AppDatabase, $CardSetsTable> {
  $$CardSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get series => $composableBuilder(
      column: $table.series, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get printedTotal => $composableBuilder(
      column: $table.printedTotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbolUrl => $composableBuilder(
      column: $table.symbolUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get cardsSynced => $composableBuilder(
      column: $table.cardsSynced, builder: (column) => ColumnFilters(column));
}

class $$CardSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardSetsTable> {
  $$CardSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get series => $composableBuilder(
      column: $table.series, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get printedTotal => $composableBuilder(
      column: $table.printedTotal,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get total => $composableBuilder(
      column: $table.total, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbolUrl => $composableBuilder(
      column: $table.symbolUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get logoUrl => $composableBuilder(
      column: $table.logoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get cardsSynced => $composableBuilder(
      column: $table.cardsSynced, builder: (column) => ColumnOrderings(column));
}

class $$CardSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardSetsTable> {
  $$CardSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get series =>
      $composableBuilder(column: $table.series, builder: (column) => column);

  GeneratedColumn<int> get printedTotal => $composableBuilder(
      column: $table.printedTotal, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get releaseDate => $composableBuilder(
      column: $table.releaseDate, builder: (column) => column);

  GeneratedColumn<String> get symbolUrl =>
      $composableBuilder(column: $table.symbolUrl, builder: (column) => column);

  GeneratedColumn<String> get logoUrl =>
      $composableBuilder(column: $table.logoUrl, builder: (column) => column);

  GeneratedColumn<bool> get cardsSynced => $composableBuilder(
      column: $table.cardsSynced, builder: (column) => column);
}

class $$CardSetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardSetsTable,
    CardSetRow,
    $$CardSetsTableFilterComposer,
    $$CardSetsTableOrderingComposer,
    $$CardSetsTableAnnotationComposer,
    $$CardSetsTableCreateCompanionBuilder,
    $$CardSetsTableUpdateCompanionBuilder,
    (CardSetRow, BaseReferences<_$AppDatabase, $CardSetsTable, CardSetRow>),
    CardSetRow,
    PrefetchHooks Function()> {
  $$CardSetsTableTableManager(_$AppDatabase db, $CardSetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> series = const Value.absent(),
            Value<int> printedTotal = const Value.absent(),
            Value<int> total = const Value.absent(),
            Value<String> releaseDate = const Value.absent(),
            Value<String> symbolUrl = const Value.absent(),
            Value<String> logoUrl = const Value.absent(),
            Value<bool> cardsSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardSetsCompanion(
            id: id,
            name: name,
            series: series,
            printedTotal: printedTotal,
            total: total,
            releaseDate: releaseDate,
            symbolUrl: symbolUrl,
            logoUrl: logoUrl,
            cardsSynced: cardsSynced,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String series,
            required int printedTotal,
            required int total,
            required String releaseDate,
            required String symbolUrl,
            required String logoUrl,
            Value<bool> cardsSynced = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardSetsCompanion.insert(
            id: id,
            name: name,
            series: series,
            printedTotal: printedTotal,
            total: total,
            releaseDate: releaseDate,
            symbolUrl: symbolUrl,
            logoUrl: logoUrl,
            cardsSynced: cardsSynced,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardSetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardSetsTable,
    CardSetRow,
    $$CardSetsTableFilterComposer,
    $$CardSetsTableOrderingComposer,
    $$CardSetsTableAnnotationComposer,
    $$CardSetsTableCreateCompanionBuilder,
    $$CardSetsTableUpdateCompanionBuilder,
    (CardSetRow, BaseReferences<_$AppDatabase, $CardSetsTable, CardSetRow>),
    CardSetRow,
    PrefetchHooks Function()>;
typedef $$TcgCardsTableCreateCompanionBuilder = TcgCardsCompanion Function({
  required String id,
  required String setId,
  required String name,
  required String number,
  required int numberSort,
  Value<String?> rarity,
  Value<String?> supertype,
  Value<String?> type,
  required String imageSmall,
  required String imageLarge,
  Value<int> rowid,
});
typedef $$TcgCardsTableUpdateCompanionBuilder = TcgCardsCompanion Function({
  Value<String> id,
  Value<String> setId,
  Value<String> name,
  Value<String> number,
  Value<int> numberSort,
  Value<String?> rarity,
  Value<String?> supertype,
  Value<String?> type,
  Value<String> imageSmall,
  Value<String> imageLarge,
  Value<int> rowid,
});

class $$TcgCardsTableFilterComposer
    extends Composer<_$AppDatabase, $TcgCardsTable> {
  $$TcgCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get setId => $composableBuilder(
      column: $table.setId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get numberSort => $composableBuilder(
      column: $table.numberSort, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rarity => $composableBuilder(
      column: $table.rarity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supertype => $composableBuilder(
      column: $table.supertype, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageSmall => $composableBuilder(
      column: $table.imageSmall, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageLarge => $composableBuilder(
      column: $table.imageLarge, builder: (column) => ColumnFilters(column));
}

class $$TcgCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $TcgCardsTable> {
  $$TcgCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get setId => $composableBuilder(
      column: $table.setId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get numberSort => $composableBuilder(
      column: $table.numberSort, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rarity => $composableBuilder(
      column: $table.rarity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supertype => $composableBuilder(
      column: $table.supertype, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageSmall => $composableBuilder(
      column: $table.imageSmall, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageLarge => $composableBuilder(
      column: $table.imageLarge, builder: (column) => ColumnOrderings(column));
}

class $$TcgCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TcgCardsTable> {
  $$TcgCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get setId =>
      $composableBuilder(column: $table.setId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<int> get numberSort => $composableBuilder(
      column: $table.numberSort, builder: (column) => column);

  GeneratedColumn<String> get rarity =>
      $composableBuilder(column: $table.rarity, builder: (column) => column);

  GeneratedColumn<String> get supertype =>
      $composableBuilder(column: $table.supertype, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get imageSmall => $composableBuilder(
      column: $table.imageSmall, builder: (column) => column);

  GeneratedColumn<String> get imageLarge => $composableBuilder(
      column: $table.imageLarge, builder: (column) => column);
}

class $$TcgCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TcgCardsTable,
    TcgCardRow,
    $$TcgCardsTableFilterComposer,
    $$TcgCardsTableOrderingComposer,
    $$TcgCardsTableAnnotationComposer,
    $$TcgCardsTableCreateCompanionBuilder,
    $$TcgCardsTableUpdateCompanionBuilder,
    (TcgCardRow, BaseReferences<_$AppDatabase, $TcgCardsTable, TcgCardRow>),
    TcgCardRow,
    PrefetchHooks Function()> {
  $$TcgCardsTableTableManager(_$AppDatabase db, $TcgCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TcgCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TcgCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TcgCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> setId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> number = const Value.absent(),
            Value<int> numberSort = const Value.absent(),
            Value<String?> rarity = const Value.absent(),
            Value<String?> supertype = const Value.absent(),
            Value<String?> type = const Value.absent(),
            Value<String> imageSmall = const Value.absent(),
            Value<String> imageLarge = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TcgCardsCompanion(
            id: id,
            setId: setId,
            name: name,
            number: number,
            numberSort: numberSort,
            rarity: rarity,
            supertype: supertype,
            type: type,
            imageSmall: imageSmall,
            imageLarge: imageLarge,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String setId,
            required String name,
            required String number,
            required int numberSort,
            Value<String?> rarity = const Value.absent(),
            Value<String?> supertype = const Value.absent(),
            Value<String?> type = const Value.absent(),
            required String imageSmall,
            required String imageLarge,
            Value<int> rowid = const Value.absent(),
          }) =>
              TcgCardsCompanion.insert(
            id: id,
            setId: setId,
            name: name,
            number: number,
            numberSort: numberSort,
            rarity: rarity,
            supertype: supertype,
            type: type,
            imageSmall: imageSmall,
            imageLarge: imageLarge,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TcgCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TcgCardsTable,
    TcgCardRow,
    $$TcgCardsTableFilterComposer,
    $$TcgCardsTableOrderingComposer,
    $$TcgCardsTableAnnotationComposer,
    $$TcgCardsTableCreateCompanionBuilder,
    $$TcgCardsTableUpdateCompanionBuilder,
    (TcgCardRow, BaseReferences<_$AppDatabase, $TcgCardsTable, TcgCardRow>),
    TcgCardRow,
    PrefetchHooks Function()>;
typedef $$UserCardEntriesTableCreateCompanionBuilder = UserCardEntriesCompanion
    Function({
  required String cardId,
  Value<bool> owned,
  Value<int> quantity,
  Value<String> variant,
  Value<String> notes,
  required DateTime updatedAt,
  Value<bool> dirty,
  Value<int> rowid,
});
typedef $$UserCardEntriesTableUpdateCompanionBuilder = UserCardEntriesCompanion
    Function({
  Value<String> cardId,
  Value<bool> owned,
  Value<int> quantity,
  Value<String> variant,
  Value<String> notes,
  Value<DateTime> updatedAt,
  Value<bool> dirty,
  Value<int> rowid,
});

class $$UserCardEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserCardEntriesTable> {
  $$UserCardEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get owned => $composableBuilder(
      column: $table.owned, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variant => $composableBuilder(
      column: $table.variant, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));
}

class $$UserCardEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCardEntriesTable> {
  $$UserCardEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cardId => $composableBuilder(
      column: $table.cardId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get owned => $composableBuilder(
      column: $table.owned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variant => $composableBuilder(
      column: $table.variant, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));
}

class $$UserCardEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCardEntriesTable> {
  $$UserCardEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cardId =>
      $composableBuilder(column: $table.cardId, builder: (column) => column);

  GeneratedColumn<bool> get owned =>
      $composableBuilder(column: $table.owned, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$UserCardEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserCardEntriesTable,
    UserCardEntryRow,
    $$UserCardEntriesTableFilterComposer,
    $$UserCardEntriesTableOrderingComposer,
    $$UserCardEntriesTableAnnotationComposer,
    $$UserCardEntriesTableCreateCompanionBuilder,
    $$UserCardEntriesTableUpdateCompanionBuilder,
    (
      UserCardEntryRow,
      BaseReferences<_$AppDatabase, $UserCardEntriesTable, UserCardEntryRow>
    ),
    UserCardEntryRow,
    PrefetchHooks Function()> {
  $$UserCardEntriesTableTableManager(
      _$AppDatabase db, $UserCardEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCardEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCardEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCardEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> cardId = const Value.absent(),
            Value<bool> owned = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> variant = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserCardEntriesCompanion(
            cardId: cardId,
            owned: owned,
            quantity: quantity,
            variant: variant,
            notes: notes,
            updatedAt: updatedAt,
            dirty: dirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String cardId,
            Value<bool> owned = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> variant = const Value.absent(),
            Value<String> notes = const Value.absent(),
            required DateTime updatedAt,
            Value<bool> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserCardEntriesCompanion.insert(
            cardId: cardId,
            owned: owned,
            quantity: quantity,
            variant: variant,
            notes: notes,
            updatedAt: updatedAt,
            dirty: dirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserCardEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserCardEntriesTable,
    UserCardEntryRow,
    $$UserCardEntriesTableFilterComposer,
    $$UserCardEntriesTableOrderingComposer,
    $$UserCardEntriesTableAnnotationComposer,
    $$UserCardEntriesTableCreateCompanionBuilder,
    $$UserCardEntriesTableUpdateCompanionBuilder,
    (
      UserCardEntryRow,
      BaseReferences<_$AppDatabase, $UserCardEntriesTable, UserCardEntryRow>
    ),
    UserCardEntryRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CardSetsTableTableManager get cardSets =>
      $$CardSetsTableTableManager(_db, _db.cardSets);
  $$TcgCardsTableTableManager get tcgCards =>
      $$TcgCardsTableTableManager(_db, _db.tcgCards);
  $$UserCardEntriesTableTableManager get userCardEntries =>
      $$UserCardEntriesTableTableManager(_db, _db.userCardEntries);
}
