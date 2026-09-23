// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milk_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMilkModelCollection on Isar {
  IsarCollection<MilkModel> get milkModels => this.collection();
}

const MilkModelSchema = CollectionSchema(
  name: r'MilkModel',
  id: -7277722541795066498,
  properties: {
    r'animalFirebaseId': PropertySchema(
      id: 0,
      name: r'animalFirebaseId',
      type: IsarType.string,
    ),
    r'animalTagNumber': PropertySchema(
      id: 1,
      name: r'animalTagNumber',
      type: IsarType.string,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'fat': PropertySchema(
      id: 3,
      name: r'fat',
      type: IsarType.double,
    ),
    r'firebaseId': PropertySchema(
      id: 4,
      name: r'firebaseId',
      type: IsarType.string,
    ),
    r'lastSyncAt': PropertySchema(
      id: 5,
      name: r'lastSyncAt',
      type: IsarType.dateTime,
    ),
    r'quantityInLiters': PropertySchema(
      id: 6,
      name: r'quantityInLiters',
      type: IsarType.double,
    ),
    r'ratePerLiter': PropertySchema(
      id: 7,
      name: r'ratePerLiter',
      type: IsarType.double,
    ),
    r'shift': PropertySchema(
      id: 8,
      name: r'shift',
      type: IsarType.string,
    ),
    r'snf': PropertySchema(
      id: 9,
      name: r'snf',
      type: IsarType.double,
    ),
    r'totalPrice': PropertySchema(
      id: 10,
      name: r'totalPrice',
      type: IsarType.double,
    )
  },
  estimateSize: _milkModelEstimateSize,
  serialize: _milkModelSerialize,
  deserialize: _milkModelDeserialize,
  deserializeProp: _milkModelDeserializeProp,
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
  getId: _milkModelGetId,
  getLinks: _milkModelGetLinks,
  attach: _milkModelAttach,
  version: '3.3.2',
);

int _milkModelEstimateSize(
  MilkModel object,
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
  {
    final value = object.firebaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.shift.length * 3;
  return bytesCount;
}

void _milkModelSerialize(
  MilkModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.animalFirebaseId);
  writer.writeString(offsets[1], object.animalTagNumber);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeDouble(offsets[3], object.fat);
  writer.writeString(offsets[4], object.firebaseId);
  writer.writeDateTime(offsets[5], object.lastSyncAt);
  writer.writeDouble(offsets[6], object.quantityInLiters);
  writer.writeDouble(offsets[7], object.ratePerLiter);
  writer.writeString(offsets[8], object.shift);
  writer.writeDouble(offsets[9], object.snf);
  writer.writeDouble(offsets[10], object.totalPrice);
}

MilkModel _milkModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MilkModel(
    animalFirebaseId: reader.readStringOrNull(offsets[0]),
    animalTagNumber: reader.readString(offsets[1]),
    date: reader.readDateTime(offsets[2]),
    fat: reader.readDouble(offsets[3]),
    firebaseId: reader.readStringOrNull(offsets[4]),
    lastSyncAt: reader.readDateTimeOrNull(offsets[5]),
    quantityInLiters: reader.readDouble(offsets[6]),
    ratePerLiter: reader.readDouble(offsets[7]),
    shift: reader.readString(offsets[8]),
    snf: reader.readDouble(offsets[9]),
    totalPrice: reader.readDouble(offsets[10]),
  );
  object.id = id;
  return object;
}

P _milkModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _milkModelGetId(MilkModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _milkModelGetLinks(MilkModel object) {
  return [];
}

void _milkModelAttach(IsarCollection<dynamic> col, Id id, MilkModel object) {
  object.id = id;
}

extension MilkModelQueryWhereSort
    on QueryBuilder<MilkModel, MilkModel, QWhere> {
  QueryBuilder<MilkModel, MilkModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MilkModelQueryWhere
    on QueryBuilder<MilkModel, MilkModel, QWhereClause> {
  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> idBetween(
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

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> firebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firebaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> firebaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'firebaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> firebaseIdEqualTo(
      String? firebaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'firebaseId',
        value: [firebaseId],
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> firebaseIdNotEqualTo(
      String? firebaseId) {
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

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause>
      animalFirebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalFirebaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause>
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

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause> animalFirebaseIdEqualTo(
      String? animalFirebaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'animalFirebaseId',
        value: [animalFirebaseId],
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterWhereClause>
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

extension MilkModelQueryFilter
    on QueryBuilder<MilkModel, MilkModel, QFilterCondition> {
  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalFirebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'animalFirebaseId',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalFirebaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'animalFirebaseId',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalFirebaseIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalFirebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalFirebaseIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalFirebaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalFirebaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalFirebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalFirebaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalFirebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalTagNumberContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'animalTagNumber',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalTagNumberMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'animalTagNumber',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalTagNumberIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'animalTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      animalTagNumberIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'animalTagNumber',
        value: '',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> dateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> fatEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> fatGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> fatLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> fatBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> firebaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'firebaseId',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      firebaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'firebaseId',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> firebaseIdEqualTo(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> firebaseIdLessThan(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> firebaseIdBetween(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> firebaseIdEndsWith(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> firebaseIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'firebaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> firebaseIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'firebaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      firebaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      firebaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'firebaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> lastSyncAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      lastSyncAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncAt',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> lastSyncAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> lastSyncAtLessThan(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> lastSyncAtBetween(
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

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      quantityInLitersEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'quantityInLiters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      quantityInLitersGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'quantityInLiters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      quantityInLitersLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'quantityInLiters',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      quantityInLitersBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'quantityInLiters',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> ratePerLiterEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'ratePerLiter',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      ratePerLiterGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'ratePerLiter',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      ratePerLiterLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'ratePerLiter',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> ratePerLiterBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'ratePerLiter',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'shift',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'shift',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'shift',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'shift',
        value: '',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> shiftIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'shift',
        value: '',
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> snfEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'snf',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> snfGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'snf',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> snfLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'snf',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> snfBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'snf',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> totalPriceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition>
      totalPriceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> totalPriceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalPrice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterFilterCondition> totalPriceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalPrice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension MilkModelQueryObject
    on QueryBuilder<MilkModel, MilkModel, QFilterCondition> {}

extension MilkModelQueryLinks
    on QueryBuilder<MilkModel, MilkModel, QFilterCondition> {}

extension MilkModelQuerySortBy on QueryBuilder<MilkModel, MilkModel, QSortBy> {
  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByAnimalFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalFirebaseId', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy>
      sortByAnimalFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalFirebaseId', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByAnimalTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalTagNumber', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByAnimalTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalTagNumber', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByQuantityInLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityInLiters', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy>
      sortByQuantityInLitersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityInLiters', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByRatePerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratePerLiter', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByRatePerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratePerLiter', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByShiftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortBySnf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snf', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortBySnfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snf', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> sortByTotalPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.desc);
    });
  }
}

extension MilkModelQuerySortThenBy
    on QueryBuilder<MilkModel, MilkModel, QSortThenBy> {
  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByAnimalFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalFirebaseId', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy>
      thenByAnimalFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalFirebaseId', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByAnimalTagNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalTagNumber', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByAnimalTagNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'animalTagNumber', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByFatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fat', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByFirebaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByFirebaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firebaseId', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByLastSyncAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncAt', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByQuantityInLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityInLiters', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy>
      thenByQuantityInLitersDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'quantityInLiters', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByRatePerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratePerLiter', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByRatePerLiterDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'ratePerLiter', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByShift() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByShiftDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'shift', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenBySnf() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snf', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenBySnfDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'snf', Sort.desc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.asc);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QAfterSortBy> thenByTotalPriceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalPrice', Sort.desc);
    });
  }
}

extension MilkModelQueryWhereDistinct
    on QueryBuilder<MilkModel, MilkModel, QDistinct> {
  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByAnimalFirebaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalFirebaseId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByAnimalTagNumber(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'animalTagNumber',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByFat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fat');
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByFirebaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firebaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByLastSyncAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncAt');
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByQuantityInLiters() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'quantityInLiters');
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByRatePerLiter() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'ratePerLiter');
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByShift(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'shift', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctBySnf() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'snf');
    });
  }

  QueryBuilder<MilkModel, MilkModel, QDistinct> distinctByTotalPrice() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalPrice');
    });
  }
}

extension MilkModelQueryProperty
    on QueryBuilder<MilkModel, MilkModel, QQueryProperty> {
  QueryBuilder<MilkModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MilkModel, String?, QQueryOperations>
      animalFirebaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalFirebaseId');
    });
  }

  QueryBuilder<MilkModel, String, QQueryOperations> animalTagNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'animalTagNumber');
    });
  }

  QueryBuilder<MilkModel, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<MilkModel, double, QQueryOperations> fatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fat');
    });
  }

  QueryBuilder<MilkModel, String?, QQueryOperations> firebaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firebaseId');
    });
  }

  QueryBuilder<MilkModel, DateTime?, QQueryOperations> lastSyncAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncAt');
    });
  }

  QueryBuilder<MilkModel, double, QQueryOperations> quantityInLitersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'quantityInLiters');
    });
  }

  QueryBuilder<MilkModel, double, QQueryOperations> ratePerLiterProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ratePerLiter');
    });
  }

  QueryBuilder<MilkModel, String, QQueryOperations> shiftProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'shift');
    });
  }

  QueryBuilder<MilkModel, double, QQueryOperations> snfProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'snf');
    });
  }

  QueryBuilder<MilkModel, double, QQueryOperations> totalPriceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalPrice');
    });
  }
}
