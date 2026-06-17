// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PokemonTableTable extends PokemonTable
    with TableInfo<$PokemonTableTable, PokemonTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
      'name_en', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _type1Meta = const VerificationMeta('type1');
  @override
  late final GeneratedColumn<String> type1 = GeneratedColumn<String>(
      'type1', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _type2Meta = const VerificationMeta('type2');
  @override
  late final GeneratedColumn<String> type2 = GeneratedColumn<String>(
      'type2', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _generationMeta =
      const VerificationMeta('generation');
  @override
  late final GeneratedColumn<int> generation = GeneratedColumn<int>(
      'generation', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hpMeta = const VerificationMeta('hp');
  @override
  late final GeneratedColumn<int> hp = GeneratedColumn<int>(
      'hp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _attackMeta = const VerificationMeta('attack');
  @override
  late final GeneratedColumn<int> attack = GeneratedColumn<int>(
      'attack', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _defenseMeta =
      const VerificationMeta('defense');
  @override
  late final GeneratedColumn<int> defense = GeneratedColumn<int>(
      'defense', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _spAttackMeta =
      const VerificationMeta('spAttack');
  @override
  late final GeneratedColumn<int> spAttack = GeneratedColumn<int>(
      'sp_attack', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _spDefenseMeta =
      const VerificationMeta('spDefense');
  @override
  late final GeneratedColumn<int> spDefense = GeneratedColumn<int>(
      'sp_defense', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<int> speed = GeneratedColumn<int>(
      'speed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        nameEn,
        type1,
        type2,
        generation,
        hp,
        attack,
        defense,
        spAttack,
        spDefense,
        speed,
        description
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_table';
  @override
  VerificationContext validateIntegrity(Insertable<PokemonTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(_nameEnMeta,
          nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta));
    } else if (isInserting) {
      context.missing(_nameEnMeta);
    }
    if (data.containsKey('type1')) {
      context.handle(
          _type1Meta, type1.isAcceptableOrUnknown(data['type1']!, _type1Meta));
    } else if (isInserting) {
      context.missing(_type1Meta);
    }
    if (data.containsKey('type2')) {
      context.handle(
          _type2Meta, type2.isAcceptableOrUnknown(data['type2']!, _type2Meta));
    }
    if (data.containsKey('generation')) {
      context.handle(
          _generationMeta,
          generation.isAcceptableOrUnknown(
              data['generation']!, _generationMeta));
    } else if (isInserting) {
      context.missing(_generationMeta);
    }
    if (data.containsKey('hp')) {
      context.handle(_hpMeta, hp.isAcceptableOrUnknown(data['hp']!, _hpMeta));
    } else if (isInserting) {
      context.missing(_hpMeta);
    }
    if (data.containsKey('attack')) {
      context.handle(_attackMeta,
          attack.isAcceptableOrUnknown(data['attack']!, _attackMeta));
    } else if (isInserting) {
      context.missing(_attackMeta);
    }
    if (data.containsKey('defense')) {
      context.handle(_defenseMeta,
          defense.isAcceptableOrUnknown(data['defense']!, _defenseMeta));
    } else if (isInserting) {
      context.missing(_defenseMeta);
    }
    if (data.containsKey('sp_attack')) {
      context.handle(_spAttackMeta,
          spAttack.isAcceptableOrUnknown(data['sp_attack']!, _spAttackMeta));
    } else if (isInserting) {
      context.missing(_spAttackMeta);
    }
    if (data.containsKey('sp_defense')) {
      context.handle(_spDefenseMeta,
          spDefense.isAcceptableOrUnknown(data['sp_defense']!, _spDefenseMeta));
    } else if (isInserting) {
      context.missing(_spDefenseMeta);
    }
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
    } else if (isInserting) {
      context.missing(_speedMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      nameEn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_en'])!,
      type1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type1'])!,
      type2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type2']),
      generation: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}generation'])!,
      hp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hp'])!,
      attack: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attack'])!,
      defense: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}defense'])!,
      spAttack: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sp_attack'])!,
      spDefense: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sp_defense'])!,
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}speed'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
    );
  }

  @override
  $PokemonTableTable createAlias(String alias) {
    return $PokemonTableTable(attachedDatabase, alias);
  }
}

class PokemonTableData extends DataClass
    implements Insertable<PokemonTableData> {
  final int id;
  final String name;
  final String nameEn;
  final String type1;
  final String? type2;
  final int generation;
  final int hp;
  final int attack;
  final int defense;
  final int spAttack;
  final int spDefense;
  final int speed;
  final String description;
  const PokemonTableData(
      {required this.id,
      required this.name,
      required this.nameEn,
      required this.type1,
      this.type2,
      required this.generation,
      required this.hp,
      required this.attack,
      required this.defense,
      required this.spAttack,
      required this.spDefense,
      required this.speed,
      required this.description});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['name_en'] = Variable<String>(nameEn);
    map['type1'] = Variable<String>(type1);
    if (!nullToAbsent || type2 != null) {
      map['type2'] = Variable<String>(type2);
    }
    map['generation'] = Variable<int>(generation);
    map['hp'] = Variable<int>(hp);
    map['attack'] = Variable<int>(attack);
    map['defense'] = Variable<int>(defense);
    map['sp_attack'] = Variable<int>(spAttack);
    map['sp_defense'] = Variable<int>(spDefense);
    map['speed'] = Variable<int>(speed);
    map['description'] = Variable<String>(description);
    return map;
  }

  PokemonTableCompanion toCompanion(bool nullToAbsent) {
    return PokemonTableCompanion(
      id: Value(id),
      name: Value(name),
      nameEn: Value(nameEn),
      type1: Value(type1),
      type2:
          type2 == null && nullToAbsent ? const Value.absent() : Value(type2),
      generation: Value(generation),
      hp: Value(hp),
      attack: Value(attack),
      defense: Value(defense),
      spAttack: Value(spAttack),
      spDefense: Value(spDefense),
      speed: Value(speed),
      description: Value(description),
    );
  }

  factory PokemonTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameEn: serializer.fromJson<String>(json['nameEn']),
      type1: serializer.fromJson<String>(json['type1']),
      type2: serializer.fromJson<String?>(json['type2']),
      generation: serializer.fromJson<int>(json['generation']),
      hp: serializer.fromJson<int>(json['hp']),
      attack: serializer.fromJson<int>(json['attack']),
      defense: serializer.fromJson<int>(json['defense']),
      spAttack: serializer.fromJson<int>(json['spAttack']),
      spDefense: serializer.fromJson<int>(json['spDefense']),
      speed: serializer.fromJson<int>(json['speed']),
      description: serializer.fromJson<String>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameEn': serializer.toJson<String>(nameEn),
      'type1': serializer.toJson<String>(type1),
      'type2': serializer.toJson<String?>(type2),
      'generation': serializer.toJson<int>(generation),
      'hp': serializer.toJson<int>(hp),
      'attack': serializer.toJson<int>(attack),
      'defense': serializer.toJson<int>(defense),
      'spAttack': serializer.toJson<int>(spAttack),
      'spDefense': serializer.toJson<int>(spDefense),
      'speed': serializer.toJson<int>(speed),
      'description': serializer.toJson<String>(description),
    };
  }

  PokemonTableData copyWith(
          {int? id,
          String? name,
          String? nameEn,
          String? type1,
          Value<String?> type2 = const Value.absent(),
          int? generation,
          int? hp,
          int? attack,
          int? defense,
          int? spAttack,
          int? spDefense,
          int? speed,
          String? description}) =>
      PokemonTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        nameEn: nameEn ?? this.nameEn,
        type1: type1 ?? this.type1,
        type2: type2.present ? type2.value : this.type2,
        generation: generation ?? this.generation,
        hp: hp ?? this.hp,
        attack: attack ?? this.attack,
        defense: defense ?? this.defense,
        spAttack: spAttack ?? this.spAttack,
        spDefense: spDefense ?? this.spDefense,
        speed: speed ?? this.speed,
        description: description ?? this.description,
      );
  PokemonTableData copyWithCompanion(PokemonTableCompanion data) {
    return PokemonTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      type1: data.type1.present ? data.type1.value : this.type1,
      type2: data.type2.present ? data.type2.value : this.type2,
      generation:
          data.generation.present ? data.generation.value : this.generation,
      hp: data.hp.present ? data.hp.value : this.hp,
      attack: data.attack.present ? data.attack.value : this.attack,
      defense: data.defense.present ? data.defense.value : this.defense,
      spAttack: data.spAttack.present ? data.spAttack.value : this.spAttack,
      spDefense: data.spDefense.present ? data.spDefense.value : this.spDefense,
      speed: data.speed.present ? data.speed.value : this.speed,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('type1: $type1, ')
          ..write('type2: $type2, ')
          ..write('generation: $generation, ')
          ..write('hp: $hp, ')
          ..write('attack: $attack, ')
          ..write('defense: $defense, ')
          ..write('spAttack: $spAttack, ')
          ..write('spDefense: $spDefense, ')
          ..write('speed: $speed, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameEn, type1, type2, generation,
      hp, attack, defense, spAttack, spDefense, speed, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameEn == this.nameEn &&
          other.type1 == this.type1 &&
          other.type2 == this.type2 &&
          other.generation == this.generation &&
          other.hp == this.hp &&
          other.attack == this.attack &&
          other.defense == this.defense &&
          other.spAttack == this.spAttack &&
          other.spDefense == this.spDefense &&
          other.speed == this.speed &&
          other.description == this.description);
}

class PokemonTableCompanion extends UpdateCompanion<PokemonTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> nameEn;
  final Value<String> type1;
  final Value<String?> type2;
  final Value<int> generation;
  final Value<int> hp;
  final Value<int> attack;
  final Value<int> defense;
  final Value<int> spAttack;
  final Value<int> spDefense;
  final Value<int> speed;
  final Value<String> description;
  const PokemonTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.type1 = const Value.absent(),
    this.type2 = const Value.absent(),
    this.generation = const Value.absent(),
    this.hp = const Value.absent(),
    this.attack = const Value.absent(),
    this.defense = const Value.absent(),
    this.spAttack = const Value.absent(),
    this.spDefense = const Value.absent(),
    this.speed = const Value.absent(),
    this.description = const Value.absent(),
  });
  PokemonTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String nameEn,
    required String type1,
    this.type2 = const Value.absent(),
    required int generation,
    required int hp,
    required int attack,
    required int defense,
    required int spAttack,
    required int spDefense,
    required int speed,
    required String description,
  })  : name = Value(name),
        nameEn = Value(nameEn),
        type1 = Value(type1),
        generation = Value(generation),
        hp = Value(hp),
        attack = Value(attack),
        defense = Value(defense),
        spAttack = Value(spAttack),
        spDefense = Value(spDefense),
        speed = Value(speed),
        description = Value(description);
  static Insertable<PokemonTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameEn,
    Expression<String>? type1,
    Expression<String>? type2,
    Expression<int>? generation,
    Expression<int>? hp,
    Expression<int>? attack,
    Expression<int>? defense,
    Expression<int>? spAttack,
    Expression<int>? spDefense,
    Expression<int>? speed,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameEn != null) 'name_en': nameEn,
      if (type1 != null) 'type1': type1,
      if (type2 != null) 'type2': type2,
      if (generation != null) 'generation': generation,
      if (hp != null) 'hp': hp,
      if (attack != null) 'attack': attack,
      if (defense != null) 'defense': defense,
      if (spAttack != null) 'sp_attack': spAttack,
      if (spDefense != null) 'sp_defense': spDefense,
      if (speed != null) 'speed': speed,
      if (description != null) 'description': description,
    });
  }

  PokemonTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? nameEn,
      Value<String>? type1,
      Value<String?>? type2,
      Value<int>? generation,
      Value<int>? hp,
      Value<int>? attack,
      Value<int>? defense,
      Value<int>? spAttack,
      Value<int>? spDefense,
      Value<int>? speed,
      Value<String>? description}) {
    return PokemonTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      type1: type1 ?? this.type1,
      type2: type2 ?? this.type2,
      generation: generation ?? this.generation,
      hp: hp ?? this.hp,
      attack: attack ?? this.attack,
      defense: defense ?? this.defense,
      spAttack: spAttack ?? this.spAttack,
      spDefense: spDefense ?? this.spDefense,
      speed: speed ?? this.speed,
      description: description ?? this.description,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (type1.present) {
      map['type1'] = Variable<String>(type1.value);
    }
    if (type2.present) {
      map['type2'] = Variable<String>(type2.value);
    }
    if (generation.present) {
      map['generation'] = Variable<int>(generation.value);
    }
    if (hp.present) {
      map['hp'] = Variable<int>(hp.value);
    }
    if (attack.present) {
      map['attack'] = Variable<int>(attack.value);
    }
    if (defense.present) {
      map['defense'] = Variable<int>(defense.value);
    }
    if (spAttack.present) {
      map['sp_attack'] = Variable<int>(spAttack.value);
    }
    if (spDefense.present) {
      map['sp_defense'] = Variable<int>(spDefense.value);
    }
    if (speed.present) {
      map['speed'] = Variable<int>(speed.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('type1: $type1, ')
          ..write('type2: $type2, ')
          ..write('generation: $generation, ')
          ..write('hp: $hp, ')
          ..write('attack: $attack, ')
          ..write('defense: $defense, ')
          ..write('spAttack: $spAttack, ')
          ..write('spDefense: $spDefense, ')
          ..write('speed: $speed, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }
}

class $UserEntriesTable extends UserEntries
    with TableInfo<$UserEntriesTable, UserEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta =
      const VerificationMeta('pokemonId');
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
      'pokemon_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _caughtMeta = const VerificationMeta('caught');
  @override
  late final GeneratedColumn<bool> caught = GeneratedColumn<bool>(
      'caught', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("caught" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _shinyMeta = const VerificationMeta('shiny');
  @override
  late final GeneratedColumn<bool> shiny = GeneratedColumn<bool>(
      'shiny', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("shiny" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
      [pokemonId, caught, shiny, quantity, notes, updatedAt, dirty];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_entries';
  @override
  VerificationContext validateIntegrity(Insertable<UserEntryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(_pokemonIdMeta,
          pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta));
    }
    if (data.containsKey('caught')) {
      context.handle(_caughtMeta,
          caught.isAcceptableOrUnknown(data['caught']!, _caughtMeta));
    }
    if (data.containsKey('shiny')) {
      context.handle(
          _shinyMeta, shiny.isAcceptableOrUnknown(data['shiny']!, _shinyMeta));
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
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
  Set<GeneratedColumn> get $primaryKey => {pokemonId};
  @override
  UserEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserEntryRow(
      pokemonId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pokemon_id'])!,
      caught: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}caught'])!,
      shiny: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}shiny'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
    );
  }

  @override
  $UserEntriesTable createAlias(String alias) {
    return $UserEntriesTable(attachedDatabase, alias);
  }
}

class UserEntryRow extends DataClass implements Insertable<UserEntryRow> {
  final int pokemonId;
  final bool caught;
  final bool shiny;
  final int quantity;
  final String notes;
  final DateTime updatedAt;

  /// Marcado quando há alterações por sincronizar. Usado na Etapa 2.
  final bool dirty;
  const UserEntryRow(
      {required this.pokemonId,
      required this.caught,
      required this.shiny,
      required this.quantity,
      required this.notes,
      required this.updatedAt,
      required this.dirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['caught'] = Variable<bool>(caught);
    map['shiny'] = Variable<bool>(shiny);
    map['quantity'] = Variable<int>(quantity);
    map['notes'] = Variable<String>(notes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  UserEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserEntriesCompanion(
      pokemonId: Value(pokemonId),
      caught: Value(caught),
      shiny: Value(shiny),
      quantity: Value(quantity),
      notes: Value(notes),
      updatedAt: Value(updatedAt),
      dirty: Value(dirty),
    );
  }

  factory UserEntryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserEntryRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      caught: serializer.fromJson<bool>(json['caught']),
      shiny: serializer.fromJson<bool>(json['shiny']),
      quantity: serializer.fromJson<int>(json['quantity']),
      notes: serializer.fromJson<String>(json['notes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'caught': serializer.toJson<bool>(caught),
      'shiny': serializer.toJson<bool>(shiny),
      'quantity': serializer.toJson<int>(quantity),
      'notes': serializer.toJson<String>(notes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  UserEntryRow copyWith(
          {int? pokemonId,
          bool? caught,
          bool? shiny,
          int? quantity,
          String? notes,
          DateTime? updatedAt,
          bool? dirty}) =>
      UserEntryRow(
        pokemonId: pokemonId ?? this.pokemonId,
        caught: caught ?? this.caught,
        shiny: shiny ?? this.shiny,
        quantity: quantity ?? this.quantity,
        notes: notes ?? this.notes,
        updatedAt: updatedAt ?? this.updatedAt,
        dirty: dirty ?? this.dirty,
      );
  UserEntryRow copyWithCompanion(UserEntriesCompanion data) {
    return UserEntryRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      caught: data.caught.present ? data.caught.value : this.caught,
      shiny: data.shiny.present ? data.shiny.value : this.shiny,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserEntryRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('caught: $caught, ')
          ..write('shiny: $shiny, ')
          ..write('quantity: $quantity, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(pokemonId, caught, shiny, quantity, notes, updatedAt, dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserEntryRow &&
          other.pokemonId == this.pokemonId &&
          other.caught == this.caught &&
          other.shiny == this.shiny &&
          other.quantity == this.quantity &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt &&
          other.dirty == this.dirty);
}

class UserEntriesCompanion extends UpdateCompanion<UserEntryRow> {
  final Value<int> pokemonId;
  final Value<bool> caught;
  final Value<bool> shiny;
  final Value<int> quantity;
  final Value<String> notes;
  final Value<DateTime> updatedAt;
  final Value<bool> dirty;
  const UserEntriesCompanion({
    this.pokemonId = const Value.absent(),
    this.caught = const Value.absent(),
    this.shiny = const Value.absent(),
    this.quantity = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.dirty = const Value.absent(),
  });
  UserEntriesCompanion.insert({
    this.pokemonId = const Value.absent(),
    this.caught = const Value.absent(),
    this.shiny = const Value.absent(),
    this.quantity = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime updatedAt,
    this.dirty = const Value.absent(),
  }) : updatedAt = Value(updatedAt);
  static Insertable<UserEntryRow> custom({
    Expression<int>? pokemonId,
    Expression<bool>? caught,
    Expression<bool>? shiny,
    Expression<int>? quantity,
    Expression<String>? notes,
    Expression<DateTime>? updatedAt,
    Expression<bool>? dirty,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (caught != null) 'caught': caught,
      if (shiny != null) 'shiny': shiny,
      if (quantity != null) 'quantity': quantity,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (dirty != null) 'dirty': dirty,
    });
  }

  UserEntriesCompanion copyWith(
      {Value<int>? pokemonId,
      Value<bool>? caught,
      Value<bool>? shiny,
      Value<int>? quantity,
      Value<String>? notes,
      Value<DateTime>? updatedAt,
      Value<bool>? dirty}) {
    return UserEntriesCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      caught: caught ?? this.caught,
      shiny: shiny ?? this.shiny,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      dirty: dirty ?? this.dirty,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (caught.present) {
      map['caught'] = Variable<bool>(caught.value);
    }
    if (shiny.present) {
      map['shiny'] = Variable<bool>(shiny.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserEntriesCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('caught: $caught, ')
          ..write('shiny: $shiny, ')
          ..write('quantity: $quantity, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PokemonTableTable pokemonTable = $PokemonTableTable(this);
  late final $UserEntriesTable userEntries = $UserEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [pokemonTable, userEntries];
}

typedef $$PokemonTableTableCreateCompanionBuilder = PokemonTableCompanion
    Function({
  Value<int> id,
  required String name,
  required String nameEn,
  required String type1,
  Value<String?> type2,
  required int generation,
  required int hp,
  required int attack,
  required int defense,
  required int spAttack,
  required int spDefense,
  required int speed,
  required String description,
});
typedef $$PokemonTableTableUpdateCompanionBuilder = PokemonTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> nameEn,
  Value<String> type1,
  Value<String?> type2,
  Value<int> generation,
  Value<int> hp,
  Value<int> attack,
  Value<int> defense,
  Value<int> spAttack,
  Value<int> spDefense,
  Value<int> speed,
  Value<String> description,
});

class $$PokemonTableTableFilterComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type1 => $composableBuilder(
      column: $table.type1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type2 => $composableBuilder(
      column: $table.type2, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get generation => $composableBuilder(
      column: $table.generation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hp => $composableBuilder(
      column: $table.hp, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attack => $composableBuilder(
      column: $table.attack, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defense => $composableBuilder(
      column: $table.defense, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spAttack => $composableBuilder(
      column: $table.spAttack, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get spDefense => $composableBuilder(
      column: $table.spDefense, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));
}

class $$PokemonTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameEn => $composableBuilder(
      column: $table.nameEn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type1 => $composableBuilder(
      column: $table.type1, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type2 => $composableBuilder(
      column: $table.type2, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get generation => $composableBuilder(
      column: $table.generation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hp => $composableBuilder(
      column: $table.hp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attack => $composableBuilder(
      column: $table.attack, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defense => $composableBuilder(
      column: $table.defense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spAttack => $composableBuilder(
      column: $table.spAttack, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get spDefense => $composableBuilder(
      column: $table.spDefense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get speed => $composableBuilder(
      column: $table.speed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));
}

class $$PokemonTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PokemonTableTable> {
  $$PokemonTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get type1 =>
      $composableBuilder(column: $table.type1, builder: (column) => column);

  GeneratedColumn<String> get type2 =>
      $composableBuilder(column: $table.type2, builder: (column) => column);

  GeneratedColumn<int> get generation => $composableBuilder(
      column: $table.generation, builder: (column) => column);

  GeneratedColumn<int> get hp =>
      $composableBuilder(column: $table.hp, builder: (column) => column);

  GeneratedColumn<int> get attack =>
      $composableBuilder(column: $table.attack, builder: (column) => column);

  GeneratedColumn<int> get defense =>
      $composableBuilder(column: $table.defense, builder: (column) => column);

  GeneratedColumn<int> get spAttack =>
      $composableBuilder(column: $table.spAttack, builder: (column) => column);

  GeneratedColumn<int> get spDefense =>
      $composableBuilder(column: $table.spDefense, builder: (column) => column);

  GeneratedColumn<int> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);
}

class $$PokemonTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PokemonTableTable,
    PokemonTableData,
    $$PokemonTableTableFilterComposer,
    $$PokemonTableTableOrderingComposer,
    $$PokemonTableTableAnnotationComposer,
    $$PokemonTableTableCreateCompanionBuilder,
    $$PokemonTableTableUpdateCompanionBuilder,
    (
      PokemonTableData,
      BaseReferences<_$AppDatabase, $PokemonTableTable, PokemonTableData>
    ),
    PokemonTableData,
    PrefetchHooks Function()> {
  $$PokemonTableTableTableManager(_$AppDatabase db, $PokemonTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PokemonTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PokemonTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PokemonTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> nameEn = const Value.absent(),
            Value<String> type1 = const Value.absent(),
            Value<String?> type2 = const Value.absent(),
            Value<int> generation = const Value.absent(),
            Value<int> hp = const Value.absent(),
            Value<int> attack = const Value.absent(),
            Value<int> defense = const Value.absent(),
            Value<int> spAttack = const Value.absent(),
            Value<int> spDefense = const Value.absent(),
            Value<int> speed = const Value.absent(),
            Value<String> description = const Value.absent(),
          }) =>
              PokemonTableCompanion(
            id: id,
            name: name,
            nameEn: nameEn,
            type1: type1,
            type2: type2,
            generation: generation,
            hp: hp,
            attack: attack,
            defense: defense,
            spAttack: spAttack,
            spDefense: spDefense,
            speed: speed,
            description: description,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String nameEn,
            required String type1,
            Value<String?> type2 = const Value.absent(),
            required int generation,
            required int hp,
            required int attack,
            required int defense,
            required int spAttack,
            required int spDefense,
            required int speed,
            required String description,
          }) =>
              PokemonTableCompanion.insert(
            id: id,
            name: name,
            nameEn: nameEn,
            type1: type1,
            type2: type2,
            generation: generation,
            hp: hp,
            attack: attack,
            defense: defense,
            spAttack: spAttack,
            spDefense: spDefense,
            speed: speed,
            description: description,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PokemonTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PokemonTableTable,
    PokemonTableData,
    $$PokemonTableTableFilterComposer,
    $$PokemonTableTableOrderingComposer,
    $$PokemonTableTableAnnotationComposer,
    $$PokemonTableTableCreateCompanionBuilder,
    $$PokemonTableTableUpdateCompanionBuilder,
    (
      PokemonTableData,
      BaseReferences<_$AppDatabase, $PokemonTableTable, PokemonTableData>
    ),
    PokemonTableData,
    PrefetchHooks Function()>;
typedef $$UserEntriesTableCreateCompanionBuilder = UserEntriesCompanion
    Function({
  Value<int> pokemonId,
  Value<bool> caught,
  Value<bool> shiny,
  Value<int> quantity,
  Value<String> notes,
  required DateTime updatedAt,
  Value<bool> dirty,
});
typedef $$UserEntriesTableUpdateCompanionBuilder = UserEntriesCompanion
    Function({
  Value<int> pokemonId,
  Value<bool> caught,
  Value<bool> shiny,
  Value<int> quantity,
  Value<String> notes,
  Value<DateTime> updatedAt,
  Value<bool> dirty,
});

class $$UserEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserEntriesTable> {
  $$UserEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pokemonId => $composableBuilder(
      column: $table.pokemonId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get caught => $composableBuilder(
      column: $table.caught, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get shiny => $composableBuilder(
      column: $table.shiny, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));
}

class $$UserEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserEntriesTable> {
  $$UserEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pokemonId => $composableBuilder(
      column: $table.pokemonId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get caught => $composableBuilder(
      column: $table.caught, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get shiny => $composableBuilder(
      column: $table.shiny, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));
}

class $$UserEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserEntriesTable> {
  $$UserEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pokemonId =>
      $composableBuilder(column: $table.pokemonId, builder: (column) => column);

  GeneratedColumn<bool> get caught =>
      $composableBuilder(column: $table.caught, builder: (column) => column);

  GeneratedColumn<bool> get shiny =>
      $composableBuilder(column: $table.shiny, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$UserEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserEntriesTable,
    UserEntryRow,
    $$UserEntriesTableFilterComposer,
    $$UserEntriesTableOrderingComposer,
    $$UserEntriesTableAnnotationComposer,
    $$UserEntriesTableCreateCompanionBuilder,
    $$UserEntriesTableUpdateCompanionBuilder,
    (
      UserEntryRow,
      BaseReferences<_$AppDatabase, $UserEntriesTable, UserEntryRow>
    ),
    UserEntryRow,
    PrefetchHooks Function()> {
  $$UserEntriesTableTableManager(_$AppDatabase db, $UserEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> pokemonId = const Value.absent(),
            Value<bool> caught = const Value.absent(),
            Value<bool> shiny = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
          }) =>
              UserEntriesCompanion(
            pokemonId: pokemonId,
            caught: caught,
            shiny: shiny,
            quantity: quantity,
            notes: notes,
            updatedAt: updatedAt,
            dirty: dirty,
          ),
          createCompanionCallback: ({
            Value<int> pokemonId = const Value.absent(),
            Value<bool> caught = const Value.absent(),
            Value<bool> shiny = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<String> notes = const Value.absent(),
            required DateTime updatedAt,
            Value<bool> dirty = const Value.absent(),
          }) =>
              UserEntriesCompanion.insert(
            pokemonId: pokemonId,
            caught: caught,
            shiny: shiny,
            quantity: quantity,
            notes: notes,
            updatedAt: updatedAt,
            dirty: dirty,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserEntriesTable,
    UserEntryRow,
    $$UserEntriesTableFilterComposer,
    $$UserEntriesTableOrderingComposer,
    $$UserEntriesTableAnnotationComposer,
    $$UserEntriesTableCreateCompanionBuilder,
    $$UserEntriesTableUpdateCompanionBuilder,
    (
      UserEntryRow,
      BaseReferences<_$AppDatabase, $UserEntriesTable, UserEntryRow>
    ),
    UserEntryRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PokemonTableTableTableManager get pokemonTable =>
      $$PokemonTableTableTableManager(_db, _db.pokemonTable);
  $$UserEntriesTableTableManager get userEntries =>
      $$UserEntriesTableTableManager(_db, _db.userEntries);
}
