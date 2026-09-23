// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPregnancyModelCollection on Isar {
  IsarCollection<PregnancyModel> get pregnancyModels => this.collection();
}

const PregnancyModelSchema = CollectionSchema(
  name: r'PregnancyModel',
  id: -4146719148592825819,
  properties: {
    r'actualDeliveryDate': PropertySchema(
      id: 0,
      name: r'actualDeliveryDate',
      type: IsarType.dateTime,
    ),
    r'animalFirebaseId': PropertySchema(
      id: 1,
      name: r'animalFirebaseId',
      type: IsarType.string,
    ),
    r'animalTagNumber': PropertySchema(
      id: 2,
      name: r'animalTagNumber',
      type: IsarType.string,
    ),
    r'breedingDate': PropertySchema(
      id: 3,
      name: r'breedingDate',
      type: IsarType.dateTime,
    ),
    r'bullOrSemenDetail': PropertySchema(
      id: 4,
      name: r'bullOrSemenDetail',
      type: IsarType.string,
    ),
    r'expectedDeliveryDate': PropertySchema(
      id: 5,
      name: r'expectedDeliveryDate',
      type: IsarType.dateTime,
    ),
    r'firebaseId': PropertySchema(
      id: 6,
      name: r'firebaseId',
      type: IsarType.string,
    ),
    r'lastSyncAt': PropertySchema(
      id: 7,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'status': PropertySchema(
      id: 8,
      name: r'status',
      type: IsarType.string,
    )
  },
  estimateSize: _pregnancyModelEstimateSize,
  serialize: _pregnancyModelSerialize,
  deserialize: _pregnancyModelDeserialize,
  deserializeProp: _pregnancyModelDeserializeProp,
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
    ),
    r'animalFirebaseId': IndexSchema(
      id: 5461958912510973493,
      name: r'animalFirebaseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'animalFirebaseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _pregnancyModelGetId,
  getLinks: _pregnancyModelGetLinks,
  attach: _pregnancyModelAttach,
  version: '3.3.2',
);

int _pregnancyModelEstimateSize(
  PregnancyModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.animalFirebaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.animalTagNumber.length * 3;
  bytesCount += 3 + object.bullOrSemenDetail.length * 3;
  {
    final value = object.firebaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.status.length * 3;
  return bytesCount;
}

void _pregnancyModelSerialize(
  PregnancyModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.actualDeliveryDate);
  writer.writeString(offsets[1], object.animalFirebaseId);
  writer.writeString(offsets[2], object.animalTagNumber);
  writer.writeDateTime(offsets[3], object.breedingDate);
  writer.writeString(offsets[4], object.bullOrSemenDetail);
  writer.writeDateTime(offsets[5], object.expectedDeliveryDate);
  writer.writeString(offsets[6], object.firebaseId);
  writer.writeDateTime(offsets[7], object.lastSyncAt);
  writer.writeString(offsets[8], object.status);
}

PregnancyModel _pregnancyModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PregnancyModel(
    actualDeliveryDate: reader.readDateTimeOrNull(offsets[0]),
    animalFirebaseId: reader.readStringOrNull(offsets[1]),
    animalTagNumber: reader.readString(offsets[2]),
    breedingDate: reader.readDateTime(offsets[3]),
    bullOrSemenDetail: reader.readString(offsets[4]),
    expectedDeliveryDate: reader.readDateTimeOrNull(offsets[5]),
    firebaseId: reader.readStringOrNull(offsets[6]),
    lastSyncAt: reader.readDateTimeOrNull(offsets[7]),
    status: reader.readString(offsets[8]),
  );
  object.id = id;
  return object;
}

P _pregnancyModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pregnancyModelGetId(PregnancyModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pregnancyModelGetLinks(PregnancyModel object) {
  return [];
}

void _pregnancyModelAttach(
    IsarCollection<dynamic> col, Id id, PregnancyModel object) {
  object.id = id;
}

extension PregnancyModelQueryWhereSort
    on QueryBuilder<PregnancyModel, PregnancyModel, QWhere> {
  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PregnancyModelQueryWhere
    on QueryBuilder<PregnancyModel, PregnancyModel, QWhereClause> {
  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause>
      firebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firebaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause>
      firebaseIdEqualTo(String? firebaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firebaseId',
        value: [firebaseId],
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause>
      animalFirebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalFirebaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause>
      animalFirebaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'animalFirebaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause>
      animalFirebaseIdEqualTo(String? animalFirebaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalFirebaseId',
        value: [animalFirebaseId],
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterWhereClause>
      animalFirebaseIdNotEqualTo(String? animalFirebaseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalFirebaseId',
              lower: [],
              upper: [animalFirebaseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalFirebaseId',
              lower: [animalFirebaseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalFirebaseId',
              lower: [animalFirebaseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'animalFirebaseId',
              lower: [],
              upper: [animalFirebaseId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PregnancyModelQueryFilter
    on QueryBuilder<PregnancyModel, PregnancyModel, QFilterCondition> {
  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      actualDeliveryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'actualDeliveryDate',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      actualDeliveryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'actualDeliveryDate',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      actualDeliveryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actualDeliveryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      actualDeliveryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actualDeliveryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      actualDeliveryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actualDeliveryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      actualDeliveryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actualDeliveryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'animalFirebaseId',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'animalFirebaseId',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalFirebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animalFirebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animalFirebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animalFirebaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'animalFirebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'animalFirebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalFirebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalFirebaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalFirebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalFirebaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalFirebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'animalTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'animalTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'animalTagNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'animalTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'animalTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalTagNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      animalTagNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      breedingDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breedingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      breedingDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breedingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      breedingDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breedingDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      breedingDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breedingDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bullOrSemenDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bullOrSemenDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bullOrSemenDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bullOrSemenDetail',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bullOrSemenDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bullOrSemenDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bullOrSemenDetail',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bullOrSemenDetail',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bullOrSemenDetail',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      bullOrSemenDetailIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bullOrSemenDetail',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      expectedDeliveryDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'expectedDeliveryDate',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      expectedDeliveryDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'expectedDeliveryDate',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      expectedDeliveryDateEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'expectedDeliveryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      expectedDeliveryDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'expectedDeliveryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      expectedDeliveryDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'expectedDeliveryDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      expectedDeliveryDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'expectedDeliveryDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      firebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'firebaseId',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      firebaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'firebaseId',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      firebaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'firebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      firebaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'firebaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      firebaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      firebaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'firebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      lastSyncAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      lastSyncAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      lastSyncAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      statusEqualTo(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      statusLessThan(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      statusBetween(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      statusEndsWith(
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

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      statusContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      statusMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterFilterCondition>
      statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }
}

extension PregnancyModelQueryObject
    on QueryBuilder<PregnancyModel, PregnancyModel, QFilterCondition> {}

extension PregnancyModelQueryLinks
    on QueryBuilder<PregnancyModel, PregnancyModel, QFilterCondition> {}

extension PregnancyModelQuerySortBy
    on QueryBuilder<PregnancyModel, PregnancyModel, QSortBy> {
  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByActualDeliveryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDeliveryDate', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByActualDeliveryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDeliveryDate', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByAnimalFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalFirebaseId', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByAnimalFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalFirebaseId', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByAnimalTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalTagNumber', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByAnimalTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalTagNumber', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByBreedingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breedingDate', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByBreedingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breedingDate', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByBullOrSemenDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bullOrSemenDetail', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByBullOrSemenDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bullOrSemenDetail', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByExpectedDeliveryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDeliveryDate', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByExpectedDeliveryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDeliveryDate', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension PregnancyModelQuerySortThenBy
    on QueryBuilder<PregnancyModel, PregnancyModel, QSortThenBy> {
  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByActualDeliveryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDeliveryDate', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByActualDeliveryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actualDeliveryDate', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByAnimalFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalFirebaseId', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByAnimalFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalFirebaseId', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByAnimalTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalTagNumber', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByAnimalTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalTagNumber', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByBreedingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breedingDate', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByBreedingDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breedingDate', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByBullOrSemenDetail() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bullOrSemenDetail', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByBullOrSemenDetailDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bullOrSemenDetail', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByExpectedDeliveryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDeliveryDate', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByExpectedDeliveryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'expectedDeliveryDate', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QAfterSortBy>
      thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }
}

extension PregnancyModelQueryWhereDistinct
    on QueryBuilder<PregnancyModel, PregnancyModel, QDistinct> {
  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct>
      distinctByActualDeliveryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actualDeliveryDate');
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct>
      distinctByAnimalFirebaseId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalFirebaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct>
      distinctByAnimalTagNumber({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalTagNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct>
      distinctByBreedingDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breedingDate');
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct>
      distinctByBullOrSemenDetail({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bullOrSemenDetail',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct>
      distinctByExpectedDeliveryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'expectedDeliveryDate');
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct> distinctByFirebaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firebaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct>
      distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<PregnancyModel, PregnancyModel, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }
}

extension PregnancyModelQueryProperty
    on QueryBuilder<PregnancyModel, PregnancyModel, QQueryProperty> {
  QueryBuilder<PregnancyModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PregnancyModel, DateTime?, QQueryOperations>
      actualDeliveryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actualDeliveryDate');
    });
  }

  QueryBuilder<PregnancyModel, String?, QQueryOperations>
      animalFirebaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalFirebaseId');
    });
  }

  QueryBuilder<PregnancyModel, String, QQueryOperations>
      animalTagNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalTagNumber');
    });
  }

  QueryBuilder<PregnancyModel, DateTime, QQueryOperations>
      breedingDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breedingDate');
    });
  }

  QueryBuilder<PregnancyModel, String, QQueryOperations>
      bullOrSemenDetailProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bullOrSemenDetail');
    });
  }

  QueryBuilder<PregnancyModel, DateTime?, QQueryOperations>
      expectedDeliveryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'expectedDeliveryDate');
    });
  }

  QueryBuilder<PregnancyModel, String?, QQueryOperations> firebaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firebaseId');
    });
  }

  QueryBuilder<PregnancyModel, DateTime?, QQueryOperations>
      lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<PregnancyModel, String, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }
}
