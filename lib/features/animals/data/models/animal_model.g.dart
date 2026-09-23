// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAnimalModelCollection on Isar {
  IsarCollection<AnimalModel> get animalModels => this.collection();
}

const AnimalModelSchema = CollectionSchema(
  name: r'AnimalModel',
  id: -3523492554558404175,
  properties: {
    r'breed': PropertySchema(
      id: 0,
      name: r'breed',
      type: IsarType.string,
    ),
    r'color': PropertySchema(
      id: 1,
      name: r'color',
      type: IsarType.string,
    ),
    r'dateOfBirth': PropertySchema(
      id: 2,
      name: r'dateOfBirth',
      type: IsarType.dateTime,
    ),
    r'expectedCalvingDate': PropertySchema(
      id: 3,
      name: r'expectedCalvingDate',
      type: IsarType.dateTime,
    ),
    r'farmEntryDate': PropertySchema(
      id: 4,
      name: r'farmEntryDate',
      type: IsarType.dateTime,
    ),
    r'farmEntrySeason': PropertySchema(
      id: 5,
      name: r'farmEntrySeason',
      type: IsarType.string,
    ),
    r'fatherAnimalId': PropertySchema(
      id: 6,
      name: r'fatherAnimalId',
      type: IsarType.string,
    ),
    r'fatherTagNumber': PropertySchema(
      id: 7,
      name: r'fatherTagNumber',
      type: IsarType.string,
    ),
    r'firebaseId': PropertySchema(
      id: 8,
      name: r'firebaseId',
      type: IsarType.string,
    ),
    r'hasFarmHistory': PropertySchema(
      id: 9,
      name: r'hasFarmHistory',
      type: IsarType.bool,
    ),
    r'hasFather': PropertySchema(
      id: 10,
      name: r'hasFather',
      type: IsarType.bool,
    ),
    r'hasLineage': PropertySchema(
      id: 11,
      name: r'hasLineage',
      type: IsarType.bool,
    ),
    r'hasMother': PropertySchema(
      id: 12,
      name: r'hasMother',
      type: IsarType.bool,
    ),
    r'identificationNotes': PropertySchema(
      id: 13,
      name: r'identificationNotes',
      type: IsarType.string,
    ),
    r'isMilking': PropertySchema(
      id: 14,
      name: r'isMilking',
      type: IsarType.bool,
    ),
    r'isPregnant': PropertySchema(
      id: 15,
      name: r'isPregnant',
      type: IsarType.bool,
    ),
    r'lactationNumber': PropertySchema(
      id: 16,
      name: r'lactationNumber',
      type: IsarType.long,
    ),
    r'lastCalvingDate': PropertySchema(
      id: 17,
      name: r'lastCalvingDate',
      type: IsarType.dateTime,
    ),
    r'lastSyncAt': PropertySchema(
      id: 18,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'motherAnimalId': PropertySchema(
      id: 19,
      name: r'motherAnimalId',
      type: IsarType.string,
    ),
    r'motherTagNumber': PropertySchema(
      id: 20,
      name: r'motherTagNumber',
      type: IsarType.string,
    ),
    r'pregnancyStatus': PropertySchema(
      id: 21,
      name: r'pregnancyStatus',
      type: IsarType.string,
    ),
    r'previousFarm': PropertySchema(
      id: 22,
      name: r'previousFarm',
      type: IsarType.string,
    ),
    r'purchaseDate': PropertySchema(
      id: 23,
      name: r'purchaseDate',
      type: IsarType.dateTime,
    ),
    r'purchasePrice': PropertySchema(
      id: 24,
      name: r'purchasePrice',
      type: IsarType.double,
    ),
    r'rfidNumber': PropertySchema(
      id: 25,
      name: r'rfidNumber',
      type: IsarType.string,
    ),
    r'sourceType': PropertySchema(
      id: 26,
      name: r'sourceType',
      type: IsarType.string,
    ),
    r'status': PropertySchema(
      id: 27,
      name: r'status',
      type: IsarType.string,
    ),
    r'tagNumber': PropertySchema(
      id: 28,
      name: r'tagNumber',
      type: IsarType.string,
    ),
    r'type': PropertySchema(
      id: 29,
      name: r'type',
      type: IsarType.string,
    ),
    r'wasBornOnFarm': PropertySchema(
      id: 30,
      name: r'wasBornOnFarm',
      type: IsarType.bool,
    ),
    r'wasPurchased': PropertySchema(
      id: 31,
      name: r'wasPurchased',
      type: IsarType.bool,
    ),
    r'wasTransferred': PropertySchema(
      id: 32,
      name: r'wasTransferred',
      type: IsarType.bool,
    )
  },
  estimateSize: _animalModelEstimateSize,
  serialize: _animalModelSerialize,
  deserialize: _animalModelDeserialize,
  deserializeProp: _animalModelDeserializeProp,
  idName: r'id',
  indexes: {
    r'firebaseId': IndexSchema(
      id: -334079192014120732,
      name: r'firebaseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'firebaseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _animalModelGetId,
  getLinks: _animalModelGetLinks,
  attach: _animalModelAttach,
  version: '3.3.2',
);

int _animalModelEstimateSize(
  AnimalModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.breed.length * 3;
  {
    final value = object.color;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.farmEntrySeason;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fatherAnimalId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fatherTagNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.firebaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.identificationNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.motherAnimalId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.motherTagNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.pregnancyStatus.length * 3;
  {
    final value = object.previousFarm;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rfidNumber;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.sourceType.length * 3;
  bytesCount += 3 + object.status.length * 3;
  bytesCount += 3 + object.tagNumber.length * 3;
  bytesCount += 3 + object.type.length * 3;
  return bytesCount;
}

void _animalModelSerialize(
  AnimalModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.breed);
  writer.writeString(offsets[1], object.color);
  writer.writeDateTime(offsets[2], object.dateOfBirth);
  writer.writeDateTime(offsets[3], object.expectedCalvingDate);
  writer.writeDateTime(offsets[4], object.farmEntryDate);
  writer.writeString(offsets[5], object.farmEntrySeason);
  writer.writeString(offsets[6], object.fatherAnimalId);
  writer.writeString(offsets[7], object.fatherTagNumber);
  writer.writeString(offsets[8], object.firebaseId);
  writer.writeBool(offsets[9], object.hasFarmHistory);
  writer.writeBool(offsets[10], object.hasFather);
  writer.writeBool(offsets[11], object.hasLineage);
  writer.writeBool(offsets[12], object.hasMother);
  writer.writeString(offsets[13], object.identificationNotes);
  writer.writeBool(offsets[14], object.isMilking);
  writer.writeBool(offsets[15], object.isPregnant);
  writer.writeLong(offsets[16], object.lactationNumber);
  writer.writeDateTime(offsets[17], object.lastCalvingDate);
  writer.writeDateTime(offsets[18], object.lastSyncAt);
  writer.writeString(offsets[19], object.motherAnimalId);
  writer.writeString(offsets[20], object.motherTagNumber);
  writer.writeString(offsets[21], object.pregnancyStatus);
  writer.writeString(offsets[22], object.previousFarm);
  writer.writeDateTime(offsets[23], object.purchaseDate);
  writer.writeDouble(offsets[24], object.purchasePrice);
  writer.writeString(offsets[25], object.rfidNumber);
  writer.writeString(offsets[26], object.sourceType);
  writer.writeString(offsets[27], object.status);
  writer.writeString(offsets[28], object.tagNumber);
  writer.writeString(offsets[29], object.type);
  writer.writeBool(offsets[30], object.wasBornOnFarm);
  writer.writeBool(offsets[31], object.wasPurchased);
  writer.writeBool(offsets[32], object.wasTransferred);
}

AnimalModel _animalModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AnimalModel(
    breed: reader.readString(offsets[0]),
    color: reader.readStringOrNull(offsets[1]),
    dateOfBirth: reader.readDateTime(offsets[2]),
    expectedCalvingDate: reader.readDateTimeOrNull(offsets[3]),
    farmEntryDate: reader.readDateTimeOrNull(offsets[4]),
    farmEntrySeason: reader.readStringOrNull(offsets[5]),
    fatherAnimalId: reader.readStringOrNull(offsets[6]),
    fatherTagNumber: reader.readStringOrNull(offsets[7]),
    firebaseId: reader.readStringOrNull(offsets[8]),
    identificationNotes: reader.readStringOrNull(offsets[13]),
    isMilking: reader.readBoolOrNull(offsets[14]) ?? true,
    lactationNumber: reader.readLongOrNull(offsets[16]),
    lastCalvingDate: reader.readDateTimeOrNull(offsets[17]),
    lastSyncAt: reader.readDateTimeOrNull(offsets[18]),
    motherAnimalId: reader.readStringOrNull(offsets[19]),
    motherTagNumber: reader.readStringOrNull(offsets[20]),
    pregnancyStatus: reader.readStringOrNull(offsets[21]) ?? 'unknown',
    previousFarm: reader.readStringOrNull(offsets[22]),
    purchaseDate: reader.readDateTimeOrNull(offsets[23]),
    purchasePrice: reader.readDoubleOrNull(offsets[24]),
    rfidNumber: reader.readStringOrNull(offsets[25]),
    sourceType: reader.readStringOrNull(offsets[26]) ?? 'unknown',
    status: reader.readString(offsets[27]),
    tagNumber: reader.readString(offsets[28]),
    type: reader.readString(offsets[29]),
  );
  object.id = id;
  return object;
}

P _animalModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readBool(offset)) as P;
    case 10:
      return (reader.readBool(offset)) as P;
    case 11:
      return (reader.readBool(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 15:
      return (reader.readBool(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 18:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 19:
      return (reader.readStringOrNull(offset)) as P;
    case 20:
      return (reader.readStringOrNull(offset)) as P;
    case 21:
      return (reader.readStringOrNull(offset) ?? 'unknown') as P;
    case 22:
      return (reader.readStringOrNull(offset)) as P;
    case 23:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 24:
      return (reader.readDoubleOrNull(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset) ?? 'unknown') as P;
    case 27:
      return (reader.readString(offset)) as P;
    case 28:
      return (reader.readString(offset)) as P;
    case 29:
      return (reader.readString(offset)) as P;
    case 30:
      return (reader.readBool(offset)) as P;
    case 31:
      return (reader.readBool(offset)) as P;
    case 32:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _animalModelGetId(AnimalModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _animalModelGetLinks(AnimalModel object) {
  return [];
}

void _animalModelAttach(
    IsarCollection<dynamic> col, Id id, AnimalModel object) {
  object.id = id;
}

extension AnimalModelQueryWhereSort
    on QueryBuilder<AnimalModel, AnimalModel, QWhere> {
  QueryBuilder<AnimalModel, AnimalModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension AnimalModelQueryWhere
    on QueryBuilder<AnimalModel, AnimalModel, QWhereClause> {
  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause> firebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firebaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause>
      firebaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'firebaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause> firebaseIdEqualTo(
      String? firebaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firebaseId',
        value: [firebaseId],
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterWhereClause>
      firebaseIdNotEqualTo(String? firebaseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firebaseId',
              lower: [],
              upper: [firebaseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firebaseId',
              lower: [firebaseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firebaseId',
              lower: [firebaseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'firebaseId',
              lower: [],
              upper: [firebaseId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension AnimalModelQueryFilter
    on QueryBuilder<AnimalModel, AnimalModel, QFilterCondition> {
  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> breedEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      breedGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> breedLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> breedBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> breedStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> breedEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> breedContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'breed',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> breedMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'breed',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> breedIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breed',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      breedIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'breed',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'color',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      colorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'color',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      colorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'color',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'color',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'color',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> colorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'color',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      colorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'color',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      dateOfBirthEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      dateOfBirthGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      dateOfBirthLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      dateOfBirthBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateOfBirth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      expectedCalvingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedCalvingDate',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      expectedCalvingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedCalvingDate',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      expectedCalvingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      expectedCalvingDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      expectedCalvingDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      expectedCalvingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedCalvingDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'farmEntryDate',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'farmEntryDate',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'farmEntryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'farmEntryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'farmEntryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'farmEntryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'farmEntrySeason',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'farmEntrySeason',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'farmEntrySeason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'farmEntrySeason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'farmEntrySeason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'farmEntrySeason',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'farmEntrySeason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'farmEntrySeason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'farmEntrySeason',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'farmEntrySeason',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'farmEntrySeason',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      farmEntrySeasonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'farmEntrySeason',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fatherAnimalId',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fatherAnimalId',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatherAnimalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fatherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fatherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fatherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fatherAnimalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherAnimalId',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherAnimalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fatherAnimalId',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fatherTagNumber',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fatherTagNumber',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatherTagNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fatherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fatherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fatherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fatherTagNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatherTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      fatherTagNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fatherTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'firebaseId',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'firebaseId',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firebaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'firebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'firebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'firebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'firebaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      firebaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'firebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      hasFarmHistoryEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasFarmHistory',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      hasFatherEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasFather',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      hasLineageEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasLineage',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      hasMotherEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasMother',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'identificationNotes',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'identificationNotes',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identificationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'identificationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'identificationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'identificationNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'identificationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'identificationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'identificationNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'identificationNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'identificationNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      identificationNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'identificationNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      isMilkingEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMilking',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      isPregnantEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isPregnant',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lactationNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lactationNumber',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lactationNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lactationNumber',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lactationNumberEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lactationNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lactationNumberGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lactationNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lactationNumberLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lactationNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lactationNumberBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lactationNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastCalvingDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastCalvingDate',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastCalvingDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastCalvingDate',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastCalvingDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastCalvingDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastCalvingDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastCalvingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastCalvingDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastCalvingDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastSyncAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastSyncAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastSyncAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastSyncAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      lastSyncAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'motherAnimalId',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'motherAnimalId',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motherAnimalId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motherAnimalId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motherAnimalId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherAnimalId',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherAnimalIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motherAnimalId',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'motherTagNumber',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'motherTagNumber',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'motherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'motherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'motherTagNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'motherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'motherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'motherTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'motherTagNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'motherTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      motherTagNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'motherTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pregnancyStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pregnancyStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pregnancyStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pregnancyStatus',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'pregnancyStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'pregnancyStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'pregnancyStatus',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'pregnancyStatus',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pregnancyStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      pregnancyStatusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'pregnancyStatus',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'previousFarm',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'previousFarm',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousFarm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'previousFarm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'previousFarm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'previousFarm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'previousFarm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'previousFarm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'previousFarm',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'previousFarm',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'previousFarm',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      previousFarmIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'previousFarm',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchaseDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'purchaseDate',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchaseDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'purchaseDate',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchaseDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchaseDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchaseDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchaseDate',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchaseDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchaseDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchasePriceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'purchasePrice',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchasePriceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'purchasePrice',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchasePriceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchasePriceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchasePriceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'purchasePrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      purchasePriceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'purchasePrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rfidNumber',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rfidNumber',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rfidNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rfidNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rfidNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rfidNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rfidNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rfidNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rfidNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rfidNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rfidNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      rfidNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rfidNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      sourceTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceType',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> statusEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      statusGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> statusLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> statusBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> statusContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> statusMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tagNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      tagNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'type',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'type',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'type',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'type',
        value: '',
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      wasBornOnFarmEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasBornOnFarm',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      wasPurchasedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasPurchased',
        value: value,
      ));
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterFilterCondition>
      wasTransferredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wasTransferred',
        value: value,
      ));
    });
  }
}

extension AnimalModelQueryObject
    on QueryBuilder<AnimalModel, AnimalModel, QFilterCondition> {}

extension AnimalModelQueryLinks
    on QueryBuilder<AnimalModel, AnimalModel, QFilterCondition> {}

extension AnimalModelQuerySortBy
    on QueryBuilder<AnimalModel, AnimalModel, QSortBy> {
  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByExpectedCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByFarmEntryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'farmEntryDate', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByFarmEntryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'farmEntryDate', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByFarmEntrySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'farmEntrySeason', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByFarmEntrySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'farmEntrySeason', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByFatherAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherAnimalId', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByFatherAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherAnimalId', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByFatherTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherTagNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByFatherTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherTagNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByHasFarmHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFarmHistory', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByHasFarmHistoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFarmHistory', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByHasFather() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFather', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByHasFatherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFather', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByHasLineage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasLineage', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByHasLineageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasLineage', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByHasMother() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMother', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByHasMotherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMother', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByIdentificationNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identificationNotes', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByIdentificationNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identificationNotes', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByIsMilking() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMilking', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByIsMilkingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMilking', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByIsPregnant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPregnant', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByIsPregnantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPregnant', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByLactationNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lactationNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByLactationNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lactationNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByLastCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByLastCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByMotherAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherAnimalId', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByMotherAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherAnimalId', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByMotherTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherTagNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByMotherTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherTagNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByPregnancyStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyStatus', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByPregnancyStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyStatus', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByPreviousFarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousFarm', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByPreviousFarmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousFarm', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByPurchasePriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByRfidNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rfidNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByRfidNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rfidNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByWasBornOnFarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasBornOnFarm', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByWasBornOnFarmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasBornOnFarm', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByWasPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasPurchased', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByWasPurchasedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasPurchased', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> sortByWasTransferred() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasTransferred', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      sortByWasTransferredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasTransferred', Sort.desc);
    });
  }
}

extension AnimalModelQuerySortThenBy
    on QueryBuilder<AnimalModel, AnimalModel, QSortThenBy> {
  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByBreed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByBreedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breed', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByColor() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByColorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'color', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByExpectedCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByFarmEntryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'farmEntryDate', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByFarmEntryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'farmEntryDate', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByFarmEntrySeason() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'farmEntrySeason', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByFarmEntrySeasonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'farmEntrySeason', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByFatherAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherAnimalId', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByFatherAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherAnimalId', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByFatherTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherTagNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByFatherTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatherTagNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByHasFarmHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFarmHistory', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByHasFarmHistoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFarmHistory', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByHasFather() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFather', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByHasFatherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasFather', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByHasLineage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasLineage', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByHasLineageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasLineage', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByHasMother() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMother', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByHasMotherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMother', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByIdentificationNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identificationNotes', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByIdentificationNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'identificationNotes', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByIsMilking() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMilking', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByIsMilkingDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMilking', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByIsPregnant() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPregnant', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByIsPregnantDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPregnant', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByLactationNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lactationNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByLactationNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lactationNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByLastCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCalvingDate', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByLastCalvingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastCalvingDate', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByMotherAnimalId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherAnimalId', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByMotherAnimalIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherAnimalId', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByMotherTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherTagNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByMotherTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'motherTagNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByPregnancyStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyStatus', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByPregnancyStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pregnancyStatus', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByPreviousFarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousFarm', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByPreviousFarmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'previousFarm', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByPurchaseDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchaseDate', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByPurchasePriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'purchasePrice', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByRfidNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rfidNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByRfidNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rfidNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagNumber', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagNumber', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByWasBornOnFarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasBornOnFarm', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByWasBornOnFarmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasBornOnFarm', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByWasPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasPurchased', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByWasPurchasedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasPurchased', Sort.desc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy> thenByWasTransferred() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasTransferred', Sort.asc);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QAfterSortBy>
      thenByWasTransferredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wasTransferred', Sort.desc);
    });
  }
}

extension AnimalModelQueryWhereDistinct
    on QueryBuilder<AnimalModel, AnimalModel, QDistinct> {
  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByBreed(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breed', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByColor(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'color', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateOfBirth');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct>
      distinctByExpectedCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedCalvingDate');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByFarmEntryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'farmEntryDate');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByFarmEntrySeason(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'farmEntrySeason',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByFatherAnimalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatherAnimalId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByFatherTagNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatherTagNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByFirebaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firebaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByHasFarmHistory() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasFarmHistory');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByHasFather() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasFather');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByHasLineage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasLineage');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByHasMother() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasMother');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct>
      distinctByIdentificationNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'identificationNotes',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByIsMilking() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMilking');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByIsPregnant() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPregnant');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct>
      distinctByLactationNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lactationNumber');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct>
      distinctByLastCalvingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastCalvingDate');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByMotherAnimalId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motherAnimalId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByMotherTagNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'motherTagNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByPregnancyStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pregnancyStatus',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByPreviousFarm(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'previousFarm', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByPurchaseDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchaseDate');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByPurchasePrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'purchasePrice');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByRfidNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rfidNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctBySourceType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByTagNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagNumber', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByWasBornOnFarm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasBornOnFarm');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByWasPurchased() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasPurchased');
    });
  }

  QueryBuilder<AnimalModel, AnimalModel, QDistinct> distinctByWasTransferred() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wasTransferred');
    });
  }
}

extension AnimalModelQueryProperty
    on QueryBuilder<AnimalModel, AnimalModel, QQueryProperty> {
  QueryBuilder<AnimalModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AnimalModel, String, QQueryOperations> breedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breed');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations> colorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'color');
    });
  }

  QueryBuilder<AnimalModel, DateTime, QQueryOperations> dateOfBirthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateOfBirth');
    });
  }

  QueryBuilder<AnimalModel, DateTime?, QQueryOperations>
      expectedCalvingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedCalvingDate');
    });
  }

  QueryBuilder<AnimalModel, DateTime?, QQueryOperations>
      farmEntryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'farmEntryDate');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations>
      farmEntrySeasonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'farmEntrySeason');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations>
      fatherAnimalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatherAnimalId');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations>
      fatherTagNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatherTagNumber');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations> firebaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firebaseId');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> hasFarmHistoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasFarmHistory');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> hasFatherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasFather');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> hasLineageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasLineage');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> hasMotherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasMother');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations>
      identificationNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'identificationNotes');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> isMilkingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMilking');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> isPregnantProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPregnant');
    });
  }

  QueryBuilder<AnimalModel, int?, QQueryOperations> lactationNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lactationNumber');
    });
  }

  QueryBuilder<AnimalModel, DateTime?, QQueryOperations>
      lastCalvingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastCalvingDate');
    });
  }

  QueryBuilder<AnimalModel, DateTime?, QQueryOperations> lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations>
      motherAnimalIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motherAnimalId');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations>
      motherTagNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'motherTagNumber');
    });
  }

  QueryBuilder<AnimalModel, String, QQueryOperations>
      pregnancyStatusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pregnancyStatus');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations> previousFarmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'previousFarm');
    });
  }

  QueryBuilder<AnimalModel, DateTime?, QQueryOperations>
      purchaseDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchaseDate');
    });
  }

  QueryBuilder<AnimalModel, double?, QQueryOperations> purchasePriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'purchasePrice');
    });
  }

  QueryBuilder<AnimalModel, String?, QQueryOperations> rfidNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rfidNumber');
    });
  }

  QueryBuilder<AnimalModel, String, QQueryOperations> sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }

  QueryBuilder<AnimalModel, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<AnimalModel, String, QQueryOperations> tagNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagNumber');
    });
  }

  QueryBuilder<AnimalModel, String, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> wasBornOnFarmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasBornOnFarm');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> wasPurchasedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasPurchased');
    });
  }

  QueryBuilder<AnimalModel, bool, QQueryOperations> wasTransferredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wasTransferred');
    });
  }
}
