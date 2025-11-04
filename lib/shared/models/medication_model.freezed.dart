// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Medication _$MedicationFromJson(Map<String, dynamic> json) {
  return _Medication.fromJson(json);
}

/// @nodoc
mixin _$Medication {
  int get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get dailyCount => throw _privateConstructorUsedError; // 복용 시간 정보 (최대 6개)
  Time? get time1 => throw _privateConstructorUsedError;
  String? get time1Meal => throw _privateConstructorUsedError;
  int? get time1OffsetMin => throw _privateConstructorUsedError;
  Time? get time2 => throw _privateConstructorUsedError;
  String? get time2Meal => throw _privateConstructorUsedError;
  int? get time2OffsetMin => throw _privateConstructorUsedError;
  Time? get time3 => throw _privateConstructorUsedError;
  String? get time3Meal => throw _privateConstructorUsedError;
  int? get time3OffsetMin => throw _privateConstructorUsedError;
  Time? get time4 => throw _privateConstructorUsedError;
  String? get time4Meal => throw _privateConstructorUsedError;
  int? get time4OffsetMin => throw _privateConstructorUsedError;
  Time? get time5 => throw _privateConstructorUsedError;
  String? get time5Meal => throw _privateConstructorUsedError;
  int? get time5OffsetMin => throw _privateConstructorUsedError;
  Time? get time6 => throw _privateConstructorUsedError;
  String? get time6Meal => throw _privateConstructorUsedError;
  int? get time6OffsetMin => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  bool get isIndefinite => throw _privateConstructorUsedError;
  DateTime? get expirationDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicationCopyWith<Medication> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationCopyWith<$Res> {
  factory $MedicationCopyWith(
          Medication value, $Res Function(Medication) then) =
      _$MedicationCopyWithImpl<$Res, Medication>;
  @useResult
  $Res call(
      {int id,
      int userId,
      String name,
      int dailyCount,
      Time? time1,
      String? time1Meal,
      int? time1OffsetMin,
      Time? time2,
      String? time2Meal,
      int? time2OffsetMin,
      Time? time3,
      String? time3Meal,
      int? time3OffsetMin,
      Time? time4,
      String? time4Meal,
      int? time4OffsetMin,
      Time? time5,
      String? time5Meal,
      int? time5OffsetMin,
      Time? time6,
      String? time6Meal,
      int? time6OffsetMin,
      DateTime startDate,
      DateTime? endDate,
      bool isIndefinite,
      DateTime? expirationDate,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt});

  $TimeCopyWith<$Res>? get time1;
  $TimeCopyWith<$Res>? get time2;
  $TimeCopyWith<$Res>? get time3;
  $TimeCopyWith<$Res>? get time4;
  $TimeCopyWith<$Res>? get time5;
  $TimeCopyWith<$Res>? get time6;
}

/// @nodoc
class _$MedicationCopyWithImpl<$Res, $Val extends Medication>
    implements $MedicationCopyWith<$Res> {
  _$MedicationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? dailyCount = null,
    Object? time1 = freezed,
    Object? time1Meal = freezed,
    Object? time1OffsetMin = freezed,
    Object? time2 = freezed,
    Object? time2Meal = freezed,
    Object? time2OffsetMin = freezed,
    Object? time3 = freezed,
    Object? time3Meal = freezed,
    Object? time3OffsetMin = freezed,
    Object? time4 = freezed,
    Object? time4Meal = freezed,
    Object? time4OffsetMin = freezed,
    Object? time5 = freezed,
    Object? time5Meal = freezed,
    Object? time5OffsetMin = freezed,
    Object? time6 = freezed,
    Object? time6Meal = freezed,
    Object? time6OffsetMin = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isIndefinite = null,
    Object? expirationDate = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dailyCount: null == dailyCount
          ? _value.dailyCount
          : dailyCount // ignore: cast_nullable_to_non_nullable
              as int,
      time1: freezed == time1
          ? _value.time1
          : time1 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time1Meal: freezed == time1Meal
          ? _value.time1Meal
          : time1Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time1OffsetMin: freezed == time1OffsetMin
          ? _value.time1OffsetMin
          : time1OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time2: freezed == time2
          ? _value.time2
          : time2 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time2Meal: freezed == time2Meal
          ? _value.time2Meal
          : time2Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time2OffsetMin: freezed == time2OffsetMin
          ? _value.time2OffsetMin
          : time2OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time3: freezed == time3
          ? _value.time3
          : time3 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time3Meal: freezed == time3Meal
          ? _value.time3Meal
          : time3Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time3OffsetMin: freezed == time3OffsetMin
          ? _value.time3OffsetMin
          : time3OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time4: freezed == time4
          ? _value.time4
          : time4 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time4Meal: freezed == time4Meal
          ? _value.time4Meal
          : time4Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time4OffsetMin: freezed == time4OffsetMin
          ? _value.time4OffsetMin
          : time4OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time5: freezed == time5
          ? _value.time5
          : time5 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time5Meal: freezed == time5Meal
          ? _value.time5Meal
          : time5Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time5OffsetMin: freezed == time5OffsetMin
          ? _value.time5OffsetMin
          : time5OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time6: freezed == time6
          ? _value.time6
          : time6 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time6Meal: freezed == time6Meal
          ? _value.time6Meal
          : time6Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time6OffsetMin: freezed == time6OffsetMin
          ? _value.time6OffsetMin
          : time6OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIndefinite: null == isIndefinite
          ? _value.isIndefinite
          : isIndefinite // ignore: cast_nullable_to_non_nullable
              as bool,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time1 {
    if (_value.time1 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time1!, (value) {
      return _then(_value.copyWith(time1: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time2 {
    if (_value.time2 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time2!, (value) {
      return _then(_value.copyWith(time2: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time3 {
    if (_value.time3 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time3!, (value) {
      return _then(_value.copyWith(time3: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time4 {
    if (_value.time4 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time4!, (value) {
      return _then(_value.copyWith(time4: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time5 {
    if (_value.time5 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time5!, (value) {
      return _then(_value.copyWith(time5: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time6 {
    if (_value.time6 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time6!, (value) {
      return _then(_value.copyWith(time6: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MedicationImplCopyWith<$Res>
    implements $MedicationCopyWith<$Res> {
  factory _$$MedicationImplCopyWith(
          _$MedicationImpl value, $Res Function(_$MedicationImpl) then) =
      __$$MedicationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int userId,
      String name,
      int dailyCount,
      Time? time1,
      String? time1Meal,
      int? time1OffsetMin,
      Time? time2,
      String? time2Meal,
      int? time2OffsetMin,
      Time? time3,
      String? time3Meal,
      int? time3OffsetMin,
      Time? time4,
      String? time4Meal,
      int? time4OffsetMin,
      Time? time5,
      String? time5Meal,
      int? time5OffsetMin,
      Time? time6,
      String? time6Meal,
      int? time6OffsetMin,
      DateTime startDate,
      DateTime? endDate,
      bool isIndefinite,
      DateTime? expirationDate,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt});

  @override
  $TimeCopyWith<$Res>? get time1;
  @override
  $TimeCopyWith<$Res>? get time2;
  @override
  $TimeCopyWith<$Res>? get time3;
  @override
  $TimeCopyWith<$Res>? get time4;
  @override
  $TimeCopyWith<$Res>? get time5;
  @override
  $TimeCopyWith<$Res>? get time6;
}

/// @nodoc
class __$$MedicationImplCopyWithImpl<$Res>
    extends _$MedicationCopyWithImpl<$Res, _$MedicationImpl>
    implements _$$MedicationImplCopyWith<$Res> {
  __$$MedicationImplCopyWithImpl(
      _$MedicationImpl _value, $Res Function(_$MedicationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? dailyCount = null,
    Object? time1 = freezed,
    Object? time1Meal = freezed,
    Object? time1OffsetMin = freezed,
    Object? time2 = freezed,
    Object? time2Meal = freezed,
    Object? time2OffsetMin = freezed,
    Object? time3 = freezed,
    Object? time3Meal = freezed,
    Object? time3OffsetMin = freezed,
    Object? time4 = freezed,
    Object? time4Meal = freezed,
    Object? time4OffsetMin = freezed,
    Object? time5 = freezed,
    Object? time5Meal = freezed,
    Object? time5OffsetMin = freezed,
    Object? time6 = freezed,
    Object? time6Meal = freezed,
    Object? time6OffsetMin = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isIndefinite = null,
    Object? expirationDate = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MedicationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dailyCount: null == dailyCount
          ? _value.dailyCount
          : dailyCount // ignore: cast_nullable_to_non_nullable
              as int,
      time1: freezed == time1
          ? _value.time1
          : time1 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time1Meal: freezed == time1Meal
          ? _value.time1Meal
          : time1Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time1OffsetMin: freezed == time1OffsetMin
          ? _value.time1OffsetMin
          : time1OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time2: freezed == time2
          ? _value.time2
          : time2 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time2Meal: freezed == time2Meal
          ? _value.time2Meal
          : time2Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time2OffsetMin: freezed == time2OffsetMin
          ? _value.time2OffsetMin
          : time2OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time3: freezed == time3
          ? _value.time3
          : time3 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time3Meal: freezed == time3Meal
          ? _value.time3Meal
          : time3Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time3OffsetMin: freezed == time3OffsetMin
          ? _value.time3OffsetMin
          : time3OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time4: freezed == time4
          ? _value.time4
          : time4 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time4Meal: freezed == time4Meal
          ? _value.time4Meal
          : time4Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time4OffsetMin: freezed == time4OffsetMin
          ? _value.time4OffsetMin
          : time4OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time5: freezed == time5
          ? _value.time5
          : time5 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time5Meal: freezed == time5Meal
          ? _value.time5Meal
          : time5Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time5OffsetMin: freezed == time5OffsetMin
          ? _value.time5OffsetMin
          : time5OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time6: freezed == time6
          ? _value.time6
          : time6 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time6Meal: freezed == time6Meal
          ? _value.time6Meal
          : time6Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time6OffsetMin: freezed == time6OffsetMin
          ? _value.time6OffsetMin
          : time6OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIndefinite: null == isIndefinite
          ? _value.isIndefinite
          : isIndefinite // ignore: cast_nullable_to_non_nullable
              as bool,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationImpl implements _Medication {
  const _$MedicationImpl(
      {required this.id,
      required this.userId,
      required this.name,
      required this.dailyCount,
      this.time1,
      this.time1Meal,
      this.time1OffsetMin,
      this.time2,
      this.time2Meal,
      this.time2OffsetMin,
      this.time3,
      this.time3Meal,
      this.time3OffsetMin,
      this.time4,
      this.time4Meal,
      this.time4OffsetMin,
      this.time5,
      this.time5Meal,
      this.time5OffsetMin,
      this.time6,
      this.time6Meal,
      this.time6OffsetMin,
      required this.startDate,
      this.endDate,
      required this.isIndefinite,
      this.expirationDate,
      this.notes,
      required this.createdAt,
      required this.updatedAt});

  factory _$MedicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationImplFromJson(json);

  @override
  final int id;
  @override
  final int userId;
  @override
  final String name;
  @override
  final int dailyCount;
// 복용 시간 정보 (최대 6개)
  @override
  final Time? time1;
  @override
  final String? time1Meal;
  @override
  final int? time1OffsetMin;
  @override
  final Time? time2;
  @override
  final String? time2Meal;
  @override
  final int? time2OffsetMin;
  @override
  final Time? time3;
  @override
  final String? time3Meal;
  @override
  final int? time3OffsetMin;
  @override
  final Time? time4;
  @override
  final String? time4Meal;
  @override
  final int? time4OffsetMin;
  @override
  final Time? time5;
  @override
  final String? time5Meal;
  @override
  final int? time5OffsetMin;
  @override
  final Time? time6;
  @override
  final String? time6Meal;
  @override
  final int? time6OffsetMin;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final bool isIndefinite;
  @override
  final DateTime? expirationDate;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Medication(id: $id, userId: $userId, name: $name, dailyCount: $dailyCount, time1: $time1, time1Meal: $time1Meal, time1OffsetMin: $time1OffsetMin, time2: $time2, time2Meal: $time2Meal, time2OffsetMin: $time2OffsetMin, time3: $time3, time3Meal: $time3Meal, time3OffsetMin: $time3OffsetMin, time4: $time4, time4Meal: $time4Meal, time4OffsetMin: $time4OffsetMin, time5: $time5, time5Meal: $time5Meal, time5OffsetMin: $time5OffsetMin, time6: $time6, time6Meal: $time6Meal, time6OffsetMin: $time6OffsetMin, startDate: $startDate, endDate: $endDate, isIndefinite: $isIndefinite, expirationDate: $expirationDate, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dailyCount, dailyCount) ||
                other.dailyCount == dailyCount) &&
            (identical(other.time1, time1) || other.time1 == time1) &&
            (identical(other.time1Meal, time1Meal) ||
                other.time1Meal == time1Meal) &&
            (identical(other.time1OffsetMin, time1OffsetMin) ||
                other.time1OffsetMin == time1OffsetMin) &&
            (identical(other.time2, time2) || other.time2 == time2) &&
            (identical(other.time2Meal, time2Meal) ||
                other.time2Meal == time2Meal) &&
            (identical(other.time2OffsetMin, time2OffsetMin) ||
                other.time2OffsetMin == time2OffsetMin) &&
            (identical(other.time3, time3) || other.time3 == time3) &&
            (identical(other.time3Meal, time3Meal) ||
                other.time3Meal == time3Meal) &&
            (identical(other.time3OffsetMin, time3OffsetMin) ||
                other.time3OffsetMin == time3OffsetMin) &&
            (identical(other.time4, time4) || other.time4 == time4) &&
            (identical(other.time4Meal, time4Meal) ||
                other.time4Meal == time4Meal) &&
            (identical(other.time4OffsetMin, time4OffsetMin) ||
                other.time4OffsetMin == time4OffsetMin) &&
            (identical(other.time5, time5) || other.time5 == time5) &&
            (identical(other.time5Meal, time5Meal) ||
                other.time5Meal == time5Meal) &&
            (identical(other.time5OffsetMin, time5OffsetMin) ||
                other.time5OffsetMin == time5OffsetMin) &&
            (identical(other.time6, time6) || other.time6 == time6) &&
            (identical(other.time6Meal, time6Meal) ||
                other.time6Meal == time6Meal) &&
            (identical(other.time6OffsetMin, time6OffsetMin) ||
                other.time6OffsetMin == time6OffsetMin) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isIndefinite, isIndefinite) ||
                other.isIndefinite == isIndefinite) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        name,
        dailyCount,
        time1,
        time1Meal,
        time1OffsetMin,
        time2,
        time2Meal,
        time2OffsetMin,
        time3,
        time3Meal,
        time3OffsetMin,
        time4,
        time4Meal,
        time4OffsetMin,
        time5,
        time5Meal,
        time5OffsetMin,
        time6,
        time6Meal,
        time6OffsetMin,
        startDate,
        endDate,
        isIndefinite,
        expirationDate,
        notes,
        createdAt,
        updatedAt
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationImplCopyWith<_$MedicationImpl> get copyWith =>
      __$$MedicationImplCopyWithImpl<_$MedicationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationImplToJson(
      this,
    );
  }
}

abstract class _Medication implements Medication {
  const factory _Medication(
      {required final int id,
      required final int userId,
      required final String name,
      required final int dailyCount,
      final Time? time1,
      final String? time1Meal,
      final int? time1OffsetMin,
      final Time? time2,
      final String? time2Meal,
      final int? time2OffsetMin,
      final Time? time3,
      final String? time3Meal,
      final int? time3OffsetMin,
      final Time? time4,
      final String? time4Meal,
      final int? time4OffsetMin,
      final Time? time5,
      final String? time5Meal,
      final int? time5OffsetMin,
      final Time? time6,
      final String? time6Meal,
      final int? time6OffsetMin,
      required final DateTime startDate,
      final DateTime? endDate,
      required final bool isIndefinite,
      final DateTime? expirationDate,
      final String? notes,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$MedicationImpl;

  factory _Medication.fromJson(Map<String, dynamic> json) =
      _$MedicationImpl.fromJson;

  @override
  int get id;
  @override
  int get userId;
  @override
  String get name;
  @override
  int get dailyCount;
  @override // 복용 시간 정보 (최대 6개)
  Time? get time1;
  @override
  String? get time1Meal;
  @override
  int? get time1OffsetMin;
  @override
  Time? get time2;
  @override
  String? get time2Meal;
  @override
  int? get time2OffsetMin;
  @override
  Time? get time3;
  @override
  String? get time3Meal;
  @override
  int? get time3OffsetMin;
  @override
  Time? get time4;
  @override
  String? get time4Meal;
  @override
  int? get time4OffsetMin;
  @override
  Time? get time5;
  @override
  String? get time5Meal;
  @override
  int? get time5OffsetMin;
  @override
  Time? get time6;
  @override
  String? get time6Meal;
  @override
  int? get time6OffsetMin;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  bool get isIndefinite;
  @override
  DateTime? get expirationDate;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MedicationImplCopyWith<_$MedicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Time _$TimeFromJson(Map<String, dynamic> json) {
  return _Time.fromJson(json);
}

/// @nodoc
mixin _$Time {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeCopyWith<Time> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeCopyWith<$Res> {
  factory $TimeCopyWith(Time value, $Res Function(Time) then) =
      _$TimeCopyWithImpl<$Res, Time>;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeCopyWithImpl<$Res, $Val extends Time>
    implements $TimeCopyWith<$Res> {
  _$TimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_value.copyWith(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimeImplCopyWith<$Res> implements $TimeCopyWith<$Res> {
  factory _$$TimeImplCopyWith(
          _$TimeImpl value, $Res Function(_$TimeImpl) then) =
      __$$TimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$$TimeImplCopyWithImpl<$Res>
    extends _$TimeCopyWithImpl<$Res, _$TimeImpl>
    implements _$$TimeImplCopyWith<$Res> {
  __$$TimeImplCopyWithImpl(_$TimeImpl _value, $Res Function(_$TimeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_$TimeImpl(
      hour: null == hour
          ? _value.hour
          : hour // ignore: cast_nullable_to_non_nullable
              as int,
      minute: null == minute
          ? _value.minute
          : minute // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeImpl implements _Time {
  const _$TimeImpl({required this.hour, required this.minute});

  factory _$TimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeImplFromJson(json);

  @override
  final int hour;
  @override
  final int minute;

  @override
  String toString() {
    return 'Time(hour: $hour, minute: $minute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeImplCopyWith<_$TimeImpl> get copyWith =>
      __$$TimeImplCopyWithImpl<_$TimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeImplToJson(
      this,
    );
  }
}

abstract class _Time implements Time {
  const factory _Time({required final int hour, required final int minute}) =
      _$TimeImpl;

  factory _Time.fromJson(Map<String, dynamic> json) = _$TimeImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;
  @override
  @JsonKey(ignore: true)
  _$$TimeImplCopyWith<_$TimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MedicationCreateRequest _$MedicationCreateRequestFromJson(
    Map<String, dynamic> json) {
  return _MedicationCreateRequest.fromJson(json);
}

/// @nodoc
mixin _$MedicationCreateRequest {
  String get name => throw _privateConstructorUsedError;
  int get dailyCount => throw _privateConstructorUsedError;
  Time? get time1 => throw _privateConstructorUsedError;
  String? get time1Meal => throw _privateConstructorUsedError;
  int? get time1OffsetMin => throw _privateConstructorUsedError;
  Time? get time2 => throw _privateConstructorUsedError;
  String? get time2Meal => throw _privateConstructorUsedError;
  int? get time2OffsetMin => throw _privateConstructorUsedError;
  Time? get time3 => throw _privateConstructorUsedError;
  String? get time3Meal => throw _privateConstructorUsedError;
  int? get time3OffsetMin => throw _privateConstructorUsedError;
  Time? get time4 => throw _privateConstructorUsedError;
  String? get time4Meal => throw _privateConstructorUsedError;
  int? get time4OffsetMin => throw _privateConstructorUsedError;
  Time? get time5 => throw _privateConstructorUsedError;
  String? get time5Meal => throw _privateConstructorUsedError;
  int? get time5OffsetMin => throw _privateConstructorUsedError;
  Time? get time6 => throw _privateConstructorUsedError;
  String? get time6Meal => throw _privateConstructorUsedError;
  int? get time6OffsetMin => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  bool get isIndefinite => throw _privateConstructorUsedError;
  DateTime? get expirationDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicationCreateRequestCopyWith<MedicationCreateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationCreateRequestCopyWith<$Res> {
  factory $MedicationCreateRequestCopyWith(MedicationCreateRequest value,
          $Res Function(MedicationCreateRequest) then) =
      _$MedicationCreateRequestCopyWithImpl<$Res, MedicationCreateRequest>;
  @useResult
  $Res call(
      {String name,
      int dailyCount,
      Time? time1,
      String? time1Meal,
      int? time1OffsetMin,
      Time? time2,
      String? time2Meal,
      int? time2OffsetMin,
      Time? time3,
      String? time3Meal,
      int? time3OffsetMin,
      Time? time4,
      String? time4Meal,
      int? time4OffsetMin,
      Time? time5,
      String? time5Meal,
      int? time5OffsetMin,
      Time? time6,
      String? time6Meal,
      int? time6OffsetMin,
      DateTime startDate,
      DateTime? endDate,
      bool isIndefinite,
      DateTime? expirationDate,
      String? notes});

  $TimeCopyWith<$Res>? get time1;
  $TimeCopyWith<$Res>? get time2;
  $TimeCopyWith<$Res>? get time3;
  $TimeCopyWith<$Res>? get time4;
  $TimeCopyWith<$Res>? get time5;
  $TimeCopyWith<$Res>? get time6;
}

/// @nodoc
class _$MedicationCreateRequestCopyWithImpl<$Res,
        $Val extends MedicationCreateRequest>
    implements $MedicationCreateRequestCopyWith<$Res> {
  _$MedicationCreateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dailyCount = null,
    Object? time1 = freezed,
    Object? time1Meal = freezed,
    Object? time1OffsetMin = freezed,
    Object? time2 = freezed,
    Object? time2Meal = freezed,
    Object? time2OffsetMin = freezed,
    Object? time3 = freezed,
    Object? time3Meal = freezed,
    Object? time3OffsetMin = freezed,
    Object? time4 = freezed,
    Object? time4Meal = freezed,
    Object? time4OffsetMin = freezed,
    Object? time5 = freezed,
    Object? time5Meal = freezed,
    Object? time5OffsetMin = freezed,
    Object? time6 = freezed,
    Object? time6Meal = freezed,
    Object? time6OffsetMin = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isIndefinite = null,
    Object? expirationDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dailyCount: null == dailyCount
          ? _value.dailyCount
          : dailyCount // ignore: cast_nullable_to_non_nullable
              as int,
      time1: freezed == time1
          ? _value.time1
          : time1 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time1Meal: freezed == time1Meal
          ? _value.time1Meal
          : time1Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time1OffsetMin: freezed == time1OffsetMin
          ? _value.time1OffsetMin
          : time1OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time2: freezed == time2
          ? _value.time2
          : time2 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time2Meal: freezed == time2Meal
          ? _value.time2Meal
          : time2Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time2OffsetMin: freezed == time2OffsetMin
          ? _value.time2OffsetMin
          : time2OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time3: freezed == time3
          ? _value.time3
          : time3 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time3Meal: freezed == time3Meal
          ? _value.time3Meal
          : time3Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time3OffsetMin: freezed == time3OffsetMin
          ? _value.time3OffsetMin
          : time3OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time4: freezed == time4
          ? _value.time4
          : time4 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time4Meal: freezed == time4Meal
          ? _value.time4Meal
          : time4Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time4OffsetMin: freezed == time4OffsetMin
          ? _value.time4OffsetMin
          : time4OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time5: freezed == time5
          ? _value.time5
          : time5 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time5Meal: freezed == time5Meal
          ? _value.time5Meal
          : time5Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time5OffsetMin: freezed == time5OffsetMin
          ? _value.time5OffsetMin
          : time5OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time6: freezed == time6
          ? _value.time6
          : time6 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time6Meal: freezed == time6Meal
          ? _value.time6Meal
          : time6Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time6OffsetMin: freezed == time6OffsetMin
          ? _value.time6OffsetMin
          : time6OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIndefinite: null == isIndefinite
          ? _value.isIndefinite
          : isIndefinite // ignore: cast_nullable_to_non_nullable
              as bool,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time1 {
    if (_value.time1 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time1!, (value) {
      return _then(_value.copyWith(time1: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time2 {
    if (_value.time2 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time2!, (value) {
      return _then(_value.copyWith(time2: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time3 {
    if (_value.time3 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time3!, (value) {
      return _then(_value.copyWith(time3: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time4 {
    if (_value.time4 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time4!, (value) {
      return _then(_value.copyWith(time4: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time5 {
    if (_value.time5 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time5!, (value) {
      return _then(_value.copyWith(time5: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time6 {
    if (_value.time6 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time6!, (value) {
      return _then(_value.copyWith(time6: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MedicationCreateRequestImplCopyWith<$Res>
    implements $MedicationCreateRequestCopyWith<$Res> {
  factory _$$MedicationCreateRequestImplCopyWith(
          _$MedicationCreateRequestImpl value,
          $Res Function(_$MedicationCreateRequestImpl) then) =
      __$$MedicationCreateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      int dailyCount,
      Time? time1,
      String? time1Meal,
      int? time1OffsetMin,
      Time? time2,
      String? time2Meal,
      int? time2OffsetMin,
      Time? time3,
      String? time3Meal,
      int? time3OffsetMin,
      Time? time4,
      String? time4Meal,
      int? time4OffsetMin,
      Time? time5,
      String? time5Meal,
      int? time5OffsetMin,
      Time? time6,
      String? time6Meal,
      int? time6OffsetMin,
      DateTime startDate,
      DateTime? endDate,
      bool isIndefinite,
      DateTime? expirationDate,
      String? notes});

  @override
  $TimeCopyWith<$Res>? get time1;
  @override
  $TimeCopyWith<$Res>? get time2;
  @override
  $TimeCopyWith<$Res>? get time3;
  @override
  $TimeCopyWith<$Res>? get time4;
  @override
  $TimeCopyWith<$Res>? get time5;
  @override
  $TimeCopyWith<$Res>? get time6;
}

/// @nodoc
class __$$MedicationCreateRequestImplCopyWithImpl<$Res>
    extends _$MedicationCreateRequestCopyWithImpl<$Res,
        _$MedicationCreateRequestImpl>
    implements _$$MedicationCreateRequestImplCopyWith<$Res> {
  __$$MedicationCreateRequestImplCopyWithImpl(
      _$MedicationCreateRequestImpl _value,
      $Res Function(_$MedicationCreateRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? dailyCount = null,
    Object? time1 = freezed,
    Object? time1Meal = freezed,
    Object? time1OffsetMin = freezed,
    Object? time2 = freezed,
    Object? time2Meal = freezed,
    Object? time2OffsetMin = freezed,
    Object? time3 = freezed,
    Object? time3Meal = freezed,
    Object? time3OffsetMin = freezed,
    Object? time4 = freezed,
    Object? time4Meal = freezed,
    Object? time4OffsetMin = freezed,
    Object? time5 = freezed,
    Object? time5Meal = freezed,
    Object? time5OffsetMin = freezed,
    Object? time6 = freezed,
    Object? time6Meal = freezed,
    Object? time6OffsetMin = freezed,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isIndefinite = null,
    Object? expirationDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$MedicationCreateRequestImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dailyCount: null == dailyCount
          ? _value.dailyCount
          : dailyCount // ignore: cast_nullable_to_non_nullable
              as int,
      time1: freezed == time1
          ? _value.time1
          : time1 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time1Meal: freezed == time1Meal
          ? _value.time1Meal
          : time1Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time1OffsetMin: freezed == time1OffsetMin
          ? _value.time1OffsetMin
          : time1OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time2: freezed == time2
          ? _value.time2
          : time2 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time2Meal: freezed == time2Meal
          ? _value.time2Meal
          : time2Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time2OffsetMin: freezed == time2OffsetMin
          ? _value.time2OffsetMin
          : time2OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time3: freezed == time3
          ? _value.time3
          : time3 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time3Meal: freezed == time3Meal
          ? _value.time3Meal
          : time3Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time3OffsetMin: freezed == time3OffsetMin
          ? _value.time3OffsetMin
          : time3OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time4: freezed == time4
          ? _value.time4
          : time4 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time4Meal: freezed == time4Meal
          ? _value.time4Meal
          : time4Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time4OffsetMin: freezed == time4OffsetMin
          ? _value.time4OffsetMin
          : time4OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time5: freezed == time5
          ? _value.time5
          : time5 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time5Meal: freezed == time5Meal
          ? _value.time5Meal
          : time5Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time5OffsetMin: freezed == time5OffsetMin
          ? _value.time5OffsetMin
          : time5OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time6: freezed == time6
          ? _value.time6
          : time6 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time6Meal: freezed == time6Meal
          ? _value.time6Meal
          : time6Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time6OffsetMin: freezed == time6OffsetMin
          ? _value.time6OffsetMin
          : time6OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIndefinite: null == isIndefinite
          ? _value.isIndefinite
          : isIndefinite // ignore: cast_nullable_to_non_nullable
              as bool,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationCreateRequestImpl implements _MedicationCreateRequest {
  const _$MedicationCreateRequestImpl(
      {required this.name,
      required this.dailyCount,
      this.time1,
      this.time1Meal,
      this.time1OffsetMin,
      this.time2,
      this.time2Meal,
      this.time2OffsetMin,
      this.time3,
      this.time3Meal,
      this.time3OffsetMin,
      this.time4,
      this.time4Meal,
      this.time4OffsetMin,
      this.time5,
      this.time5Meal,
      this.time5OffsetMin,
      this.time6,
      this.time6Meal,
      this.time6OffsetMin,
      required this.startDate,
      this.endDate,
      this.isIndefinite = false,
      this.expirationDate,
      this.notes});

  factory _$MedicationCreateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationCreateRequestImplFromJson(json);

  @override
  final String name;
  @override
  final int dailyCount;
  @override
  final Time? time1;
  @override
  final String? time1Meal;
  @override
  final int? time1OffsetMin;
  @override
  final Time? time2;
  @override
  final String? time2Meal;
  @override
  final int? time2OffsetMin;
  @override
  final Time? time3;
  @override
  final String? time3Meal;
  @override
  final int? time3OffsetMin;
  @override
  final Time? time4;
  @override
  final String? time4Meal;
  @override
  final int? time4OffsetMin;
  @override
  final Time? time5;
  @override
  final String? time5Meal;
  @override
  final int? time5OffsetMin;
  @override
  final Time? time6;
  @override
  final String? time6Meal;
  @override
  final int? time6OffsetMin;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final bool isIndefinite;
  @override
  final DateTime? expirationDate;
  @override
  final String? notes;

  @override
  String toString() {
    return 'MedicationCreateRequest(name: $name, dailyCount: $dailyCount, time1: $time1, time1Meal: $time1Meal, time1OffsetMin: $time1OffsetMin, time2: $time2, time2Meal: $time2Meal, time2OffsetMin: $time2OffsetMin, time3: $time3, time3Meal: $time3Meal, time3OffsetMin: $time3OffsetMin, time4: $time4, time4Meal: $time4Meal, time4OffsetMin: $time4OffsetMin, time5: $time5, time5Meal: $time5Meal, time5OffsetMin: $time5OffsetMin, time6: $time6, time6Meal: $time6Meal, time6OffsetMin: $time6OffsetMin, startDate: $startDate, endDate: $endDate, isIndefinite: $isIndefinite, expirationDate: $expirationDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationCreateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dailyCount, dailyCount) ||
                other.dailyCount == dailyCount) &&
            (identical(other.time1, time1) || other.time1 == time1) &&
            (identical(other.time1Meal, time1Meal) ||
                other.time1Meal == time1Meal) &&
            (identical(other.time1OffsetMin, time1OffsetMin) ||
                other.time1OffsetMin == time1OffsetMin) &&
            (identical(other.time2, time2) || other.time2 == time2) &&
            (identical(other.time2Meal, time2Meal) ||
                other.time2Meal == time2Meal) &&
            (identical(other.time2OffsetMin, time2OffsetMin) ||
                other.time2OffsetMin == time2OffsetMin) &&
            (identical(other.time3, time3) || other.time3 == time3) &&
            (identical(other.time3Meal, time3Meal) ||
                other.time3Meal == time3Meal) &&
            (identical(other.time3OffsetMin, time3OffsetMin) ||
                other.time3OffsetMin == time3OffsetMin) &&
            (identical(other.time4, time4) || other.time4 == time4) &&
            (identical(other.time4Meal, time4Meal) ||
                other.time4Meal == time4Meal) &&
            (identical(other.time4OffsetMin, time4OffsetMin) ||
                other.time4OffsetMin == time4OffsetMin) &&
            (identical(other.time5, time5) || other.time5 == time5) &&
            (identical(other.time5Meal, time5Meal) ||
                other.time5Meal == time5Meal) &&
            (identical(other.time5OffsetMin, time5OffsetMin) ||
                other.time5OffsetMin == time5OffsetMin) &&
            (identical(other.time6, time6) || other.time6 == time6) &&
            (identical(other.time6Meal, time6Meal) ||
                other.time6Meal == time6Meal) &&
            (identical(other.time6OffsetMin, time6OffsetMin) ||
                other.time6OffsetMin == time6OffsetMin) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isIndefinite, isIndefinite) ||
                other.isIndefinite == isIndefinite) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        name,
        dailyCount,
        time1,
        time1Meal,
        time1OffsetMin,
        time2,
        time2Meal,
        time2OffsetMin,
        time3,
        time3Meal,
        time3OffsetMin,
        time4,
        time4Meal,
        time4OffsetMin,
        time5,
        time5Meal,
        time5OffsetMin,
        time6,
        time6Meal,
        time6OffsetMin,
        startDate,
        endDate,
        isIndefinite,
        expirationDate,
        notes
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationCreateRequestImplCopyWith<_$MedicationCreateRequestImpl>
      get copyWith => __$$MedicationCreateRequestImplCopyWithImpl<
          _$MedicationCreateRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationCreateRequestImplToJson(
      this,
    );
  }
}

abstract class _MedicationCreateRequest implements MedicationCreateRequest {
  const factory _MedicationCreateRequest(
      {required final String name,
      required final int dailyCount,
      final Time? time1,
      final String? time1Meal,
      final int? time1OffsetMin,
      final Time? time2,
      final String? time2Meal,
      final int? time2OffsetMin,
      final Time? time3,
      final String? time3Meal,
      final int? time3OffsetMin,
      final Time? time4,
      final String? time4Meal,
      final int? time4OffsetMin,
      final Time? time5,
      final String? time5Meal,
      final int? time5OffsetMin,
      final Time? time6,
      final String? time6Meal,
      final int? time6OffsetMin,
      required final DateTime startDate,
      final DateTime? endDate,
      final bool isIndefinite,
      final DateTime? expirationDate,
      final String? notes}) = _$MedicationCreateRequestImpl;

  factory _MedicationCreateRequest.fromJson(Map<String, dynamic> json) =
      _$MedicationCreateRequestImpl.fromJson;

  @override
  String get name;
  @override
  int get dailyCount;
  @override
  Time? get time1;
  @override
  String? get time1Meal;
  @override
  int? get time1OffsetMin;
  @override
  Time? get time2;
  @override
  String? get time2Meal;
  @override
  int? get time2OffsetMin;
  @override
  Time? get time3;
  @override
  String? get time3Meal;
  @override
  int? get time3OffsetMin;
  @override
  Time? get time4;
  @override
  String? get time4Meal;
  @override
  int? get time4OffsetMin;
  @override
  Time? get time5;
  @override
  String? get time5Meal;
  @override
  int? get time5OffsetMin;
  @override
  Time? get time6;
  @override
  String? get time6Meal;
  @override
  int? get time6OffsetMin;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  bool get isIndefinite;
  @override
  DateTime? get expirationDate;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$MedicationCreateRequestImplCopyWith<_$MedicationCreateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}

MedicationUpdateRequest _$MedicationUpdateRequestFromJson(
    Map<String, dynamic> json) {
  return _MedicationUpdateRequest.fromJson(json);
}

/// @nodoc
mixin _$MedicationUpdateRequest {
  String? get name => throw _privateConstructorUsedError;
  int? get dailyCount => throw _privateConstructorUsedError;
  Time? get time1 => throw _privateConstructorUsedError;
  String? get time1Meal => throw _privateConstructorUsedError;
  int? get time1OffsetMin => throw _privateConstructorUsedError;
  Time? get time2 => throw _privateConstructorUsedError;
  String? get time2Meal => throw _privateConstructorUsedError;
  int? get time2OffsetMin => throw _privateConstructorUsedError;
  Time? get time3 => throw _privateConstructorUsedError;
  String? get time3Meal => throw _privateConstructorUsedError;
  int? get time3OffsetMin => throw _privateConstructorUsedError;
  Time? get time4 => throw _privateConstructorUsedError;
  String? get time4Meal => throw _privateConstructorUsedError;
  int? get time4OffsetMin => throw _privateConstructorUsedError;
  Time? get time5 => throw _privateConstructorUsedError;
  String? get time5Meal => throw _privateConstructorUsedError;
  int? get time5OffsetMin => throw _privateConstructorUsedError;
  Time? get time6 => throw _privateConstructorUsedError;
  String? get time6Meal => throw _privateConstructorUsedError;
  int? get time6OffsetMin => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  bool? get isIndefinite => throw _privateConstructorUsedError;
  DateTime? get expirationDate => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicationUpdateRequestCopyWith<MedicationUpdateRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationUpdateRequestCopyWith<$Res> {
  factory $MedicationUpdateRequestCopyWith(MedicationUpdateRequest value,
          $Res Function(MedicationUpdateRequest) then) =
      _$MedicationUpdateRequestCopyWithImpl<$Res, MedicationUpdateRequest>;
  @useResult
  $Res call(
      {String? name,
      int? dailyCount,
      Time? time1,
      String? time1Meal,
      int? time1OffsetMin,
      Time? time2,
      String? time2Meal,
      int? time2OffsetMin,
      Time? time3,
      String? time3Meal,
      int? time3OffsetMin,
      Time? time4,
      String? time4Meal,
      int? time4OffsetMin,
      Time? time5,
      String? time5Meal,
      int? time5OffsetMin,
      Time? time6,
      String? time6Meal,
      int? time6OffsetMin,
      DateTime? startDate,
      DateTime? endDate,
      bool? isIndefinite,
      DateTime? expirationDate,
      String? notes});

  $TimeCopyWith<$Res>? get time1;
  $TimeCopyWith<$Res>? get time2;
  $TimeCopyWith<$Res>? get time3;
  $TimeCopyWith<$Res>? get time4;
  $TimeCopyWith<$Res>? get time5;
  $TimeCopyWith<$Res>? get time6;
}

/// @nodoc
class _$MedicationUpdateRequestCopyWithImpl<$Res,
        $Val extends MedicationUpdateRequest>
    implements $MedicationUpdateRequestCopyWith<$Res> {
  _$MedicationUpdateRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? dailyCount = freezed,
    Object? time1 = freezed,
    Object? time1Meal = freezed,
    Object? time1OffsetMin = freezed,
    Object? time2 = freezed,
    Object? time2Meal = freezed,
    Object? time2OffsetMin = freezed,
    Object? time3 = freezed,
    Object? time3Meal = freezed,
    Object? time3OffsetMin = freezed,
    Object? time4 = freezed,
    Object? time4Meal = freezed,
    Object? time4OffsetMin = freezed,
    Object? time5 = freezed,
    Object? time5Meal = freezed,
    Object? time5OffsetMin = freezed,
    Object? time6 = freezed,
    Object? time6Meal = freezed,
    Object? time6OffsetMin = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? isIndefinite = freezed,
    Object? expirationDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyCount: freezed == dailyCount
          ? _value.dailyCount
          : dailyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      time1: freezed == time1
          ? _value.time1
          : time1 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time1Meal: freezed == time1Meal
          ? _value.time1Meal
          : time1Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time1OffsetMin: freezed == time1OffsetMin
          ? _value.time1OffsetMin
          : time1OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time2: freezed == time2
          ? _value.time2
          : time2 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time2Meal: freezed == time2Meal
          ? _value.time2Meal
          : time2Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time2OffsetMin: freezed == time2OffsetMin
          ? _value.time2OffsetMin
          : time2OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time3: freezed == time3
          ? _value.time3
          : time3 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time3Meal: freezed == time3Meal
          ? _value.time3Meal
          : time3Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time3OffsetMin: freezed == time3OffsetMin
          ? _value.time3OffsetMin
          : time3OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time4: freezed == time4
          ? _value.time4
          : time4 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time4Meal: freezed == time4Meal
          ? _value.time4Meal
          : time4Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time4OffsetMin: freezed == time4OffsetMin
          ? _value.time4OffsetMin
          : time4OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time5: freezed == time5
          ? _value.time5
          : time5 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time5Meal: freezed == time5Meal
          ? _value.time5Meal
          : time5Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time5OffsetMin: freezed == time5OffsetMin
          ? _value.time5OffsetMin
          : time5OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time6: freezed == time6
          ? _value.time6
          : time6 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time6Meal: freezed == time6Meal
          ? _value.time6Meal
          : time6Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time6OffsetMin: freezed == time6OffsetMin
          ? _value.time6OffsetMin
          : time6OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIndefinite: freezed == isIndefinite
          ? _value.isIndefinite
          : isIndefinite // ignore: cast_nullable_to_non_nullable
              as bool?,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time1 {
    if (_value.time1 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time1!, (value) {
      return _then(_value.copyWith(time1: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time2 {
    if (_value.time2 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time2!, (value) {
      return _then(_value.copyWith(time2: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time3 {
    if (_value.time3 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time3!, (value) {
      return _then(_value.copyWith(time3: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time4 {
    if (_value.time4 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time4!, (value) {
      return _then(_value.copyWith(time4: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time5 {
    if (_value.time5 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time5!, (value) {
      return _then(_value.copyWith(time5: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeCopyWith<$Res>? get time6 {
    if (_value.time6 == null) {
      return null;
    }

    return $TimeCopyWith<$Res>(_value.time6!, (value) {
      return _then(_value.copyWith(time6: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MedicationUpdateRequestImplCopyWith<$Res>
    implements $MedicationUpdateRequestCopyWith<$Res> {
  factory _$$MedicationUpdateRequestImplCopyWith(
          _$MedicationUpdateRequestImpl value,
          $Res Function(_$MedicationUpdateRequestImpl) then) =
      __$$MedicationUpdateRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      int? dailyCount,
      Time? time1,
      String? time1Meal,
      int? time1OffsetMin,
      Time? time2,
      String? time2Meal,
      int? time2OffsetMin,
      Time? time3,
      String? time3Meal,
      int? time3OffsetMin,
      Time? time4,
      String? time4Meal,
      int? time4OffsetMin,
      Time? time5,
      String? time5Meal,
      int? time5OffsetMin,
      Time? time6,
      String? time6Meal,
      int? time6OffsetMin,
      DateTime? startDate,
      DateTime? endDate,
      bool? isIndefinite,
      DateTime? expirationDate,
      String? notes});

  @override
  $TimeCopyWith<$Res>? get time1;
  @override
  $TimeCopyWith<$Res>? get time2;
  @override
  $TimeCopyWith<$Res>? get time3;
  @override
  $TimeCopyWith<$Res>? get time4;
  @override
  $TimeCopyWith<$Res>? get time5;
  @override
  $TimeCopyWith<$Res>? get time6;
}

/// @nodoc
class __$$MedicationUpdateRequestImplCopyWithImpl<$Res>
    extends _$MedicationUpdateRequestCopyWithImpl<$Res,
        _$MedicationUpdateRequestImpl>
    implements _$$MedicationUpdateRequestImplCopyWith<$Res> {
  __$$MedicationUpdateRequestImplCopyWithImpl(
      _$MedicationUpdateRequestImpl _value,
      $Res Function(_$MedicationUpdateRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? dailyCount = freezed,
    Object? time1 = freezed,
    Object? time1Meal = freezed,
    Object? time1OffsetMin = freezed,
    Object? time2 = freezed,
    Object? time2Meal = freezed,
    Object? time2OffsetMin = freezed,
    Object? time3 = freezed,
    Object? time3Meal = freezed,
    Object? time3OffsetMin = freezed,
    Object? time4 = freezed,
    Object? time4Meal = freezed,
    Object? time4OffsetMin = freezed,
    Object? time5 = freezed,
    Object? time5Meal = freezed,
    Object? time5OffsetMin = freezed,
    Object? time6 = freezed,
    Object? time6Meal = freezed,
    Object? time6OffsetMin = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? isIndefinite = freezed,
    Object? expirationDate = freezed,
    Object? notes = freezed,
  }) {
    return _then(_$MedicationUpdateRequestImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyCount: freezed == dailyCount
          ? _value.dailyCount
          : dailyCount // ignore: cast_nullable_to_non_nullable
              as int?,
      time1: freezed == time1
          ? _value.time1
          : time1 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time1Meal: freezed == time1Meal
          ? _value.time1Meal
          : time1Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time1OffsetMin: freezed == time1OffsetMin
          ? _value.time1OffsetMin
          : time1OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time2: freezed == time2
          ? _value.time2
          : time2 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time2Meal: freezed == time2Meal
          ? _value.time2Meal
          : time2Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time2OffsetMin: freezed == time2OffsetMin
          ? _value.time2OffsetMin
          : time2OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time3: freezed == time3
          ? _value.time3
          : time3 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time3Meal: freezed == time3Meal
          ? _value.time3Meal
          : time3Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time3OffsetMin: freezed == time3OffsetMin
          ? _value.time3OffsetMin
          : time3OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time4: freezed == time4
          ? _value.time4
          : time4 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time4Meal: freezed == time4Meal
          ? _value.time4Meal
          : time4Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time4OffsetMin: freezed == time4OffsetMin
          ? _value.time4OffsetMin
          : time4OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time5: freezed == time5
          ? _value.time5
          : time5 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time5Meal: freezed == time5Meal
          ? _value.time5Meal
          : time5Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time5OffsetMin: freezed == time5OffsetMin
          ? _value.time5OffsetMin
          : time5OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      time6: freezed == time6
          ? _value.time6
          : time6 // ignore: cast_nullable_to_non_nullable
              as Time?,
      time6Meal: freezed == time6Meal
          ? _value.time6Meal
          : time6Meal // ignore: cast_nullable_to_non_nullable
              as String?,
      time6OffsetMin: freezed == time6OffsetMin
          ? _value.time6OffsetMin
          : time6OffsetMin // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: freezed == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isIndefinite: freezed == isIndefinite
          ? _value.isIndefinite
          : isIndefinite // ignore: cast_nullable_to_non_nullable
              as bool?,
      expirationDate: freezed == expirationDate
          ? _value.expirationDate
          : expirationDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationUpdateRequestImpl implements _MedicationUpdateRequest {
  const _$MedicationUpdateRequestImpl(
      {this.name,
      this.dailyCount,
      this.time1,
      this.time1Meal,
      this.time1OffsetMin,
      this.time2,
      this.time2Meal,
      this.time2OffsetMin,
      this.time3,
      this.time3Meal,
      this.time3OffsetMin,
      this.time4,
      this.time4Meal,
      this.time4OffsetMin,
      this.time5,
      this.time5Meal,
      this.time5OffsetMin,
      this.time6,
      this.time6Meal,
      this.time6OffsetMin,
      this.startDate,
      this.endDate,
      this.isIndefinite,
      this.expirationDate,
      this.notes});

  factory _$MedicationUpdateRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationUpdateRequestImplFromJson(json);

  @override
  final String? name;
  @override
  final int? dailyCount;
  @override
  final Time? time1;
  @override
  final String? time1Meal;
  @override
  final int? time1OffsetMin;
  @override
  final Time? time2;
  @override
  final String? time2Meal;
  @override
  final int? time2OffsetMin;
  @override
  final Time? time3;
  @override
  final String? time3Meal;
  @override
  final int? time3OffsetMin;
  @override
  final Time? time4;
  @override
  final String? time4Meal;
  @override
  final int? time4OffsetMin;
  @override
  final Time? time5;
  @override
  final String? time5Meal;
  @override
  final int? time5OffsetMin;
  @override
  final Time? time6;
  @override
  final String? time6Meal;
  @override
  final int? time6OffsetMin;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final bool? isIndefinite;
  @override
  final DateTime? expirationDate;
  @override
  final String? notes;

  @override
  String toString() {
    return 'MedicationUpdateRequest(name: $name, dailyCount: $dailyCount, time1: $time1, time1Meal: $time1Meal, time1OffsetMin: $time1OffsetMin, time2: $time2, time2Meal: $time2Meal, time2OffsetMin: $time2OffsetMin, time3: $time3, time3Meal: $time3Meal, time3OffsetMin: $time3OffsetMin, time4: $time4, time4Meal: $time4Meal, time4OffsetMin: $time4OffsetMin, time5: $time5, time5Meal: $time5Meal, time5OffsetMin: $time5OffsetMin, time6: $time6, time6Meal: $time6Meal, time6OffsetMin: $time6OffsetMin, startDate: $startDate, endDate: $endDate, isIndefinite: $isIndefinite, expirationDate: $expirationDate, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationUpdateRequestImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dailyCount, dailyCount) ||
                other.dailyCount == dailyCount) &&
            (identical(other.time1, time1) || other.time1 == time1) &&
            (identical(other.time1Meal, time1Meal) ||
                other.time1Meal == time1Meal) &&
            (identical(other.time1OffsetMin, time1OffsetMin) ||
                other.time1OffsetMin == time1OffsetMin) &&
            (identical(other.time2, time2) || other.time2 == time2) &&
            (identical(other.time2Meal, time2Meal) ||
                other.time2Meal == time2Meal) &&
            (identical(other.time2OffsetMin, time2OffsetMin) ||
                other.time2OffsetMin == time2OffsetMin) &&
            (identical(other.time3, time3) || other.time3 == time3) &&
            (identical(other.time3Meal, time3Meal) ||
                other.time3Meal == time3Meal) &&
            (identical(other.time3OffsetMin, time3OffsetMin) ||
                other.time3OffsetMin == time3OffsetMin) &&
            (identical(other.time4, time4) || other.time4 == time4) &&
            (identical(other.time4Meal, time4Meal) ||
                other.time4Meal == time4Meal) &&
            (identical(other.time4OffsetMin, time4OffsetMin) ||
                other.time4OffsetMin == time4OffsetMin) &&
            (identical(other.time5, time5) || other.time5 == time5) &&
            (identical(other.time5Meal, time5Meal) ||
                other.time5Meal == time5Meal) &&
            (identical(other.time5OffsetMin, time5OffsetMin) ||
                other.time5OffsetMin == time5OffsetMin) &&
            (identical(other.time6, time6) || other.time6 == time6) &&
            (identical(other.time6Meal, time6Meal) ||
                other.time6Meal == time6Meal) &&
            (identical(other.time6OffsetMin, time6OffsetMin) ||
                other.time6OffsetMin == time6OffsetMin) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isIndefinite, isIndefinite) ||
                other.isIndefinite == isIndefinite) &&
            (identical(other.expirationDate, expirationDate) ||
                other.expirationDate == expirationDate) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        name,
        dailyCount,
        time1,
        time1Meal,
        time1OffsetMin,
        time2,
        time2Meal,
        time2OffsetMin,
        time3,
        time3Meal,
        time3OffsetMin,
        time4,
        time4Meal,
        time4OffsetMin,
        time5,
        time5Meal,
        time5OffsetMin,
        time6,
        time6Meal,
        time6OffsetMin,
        startDate,
        endDate,
        isIndefinite,
        expirationDate,
        notes
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationUpdateRequestImplCopyWith<_$MedicationUpdateRequestImpl>
      get copyWith => __$$MedicationUpdateRequestImplCopyWithImpl<
          _$MedicationUpdateRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationUpdateRequestImplToJson(
      this,
    );
  }
}

abstract class _MedicationUpdateRequest implements MedicationUpdateRequest {
  const factory _MedicationUpdateRequest(
      {final String? name,
      final int? dailyCount,
      final Time? time1,
      final String? time1Meal,
      final int? time1OffsetMin,
      final Time? time2,
      final String? time2Meal,
      final int? time2OffsetMin,
      final Time? time3,
      final String? time3Meal,
      final int? time3OffsetMin,
      final Time? time4,
      final String? time4Meal,
      final int? time4OffsetMin,
      final Time? time5,
      final String? time5Meal,
      final int? time5OffsetMin,
      final Time? time6,
      final String? time6Meal,
      final int? time6OffsetMin,
      final DateTime? startDate,
      final DateTime? endDate,
      final bool? isIndefinite,
      final DateTime? expirationDate,
      final String? notes}) = _$MedicationUpdateRequestImpl;

  factory _MedicationUpdateRequest.fromJson(Map<String, dynamic> json) =
      _$MedicationUpdateRequestImpl.fromJson;

  @override
  String? get name;
  @override
  int? get dailyCount;
  @override
  Time? get time1;
  @override
  String? get time1Meal;
  @override
  int? get time1OffsetMin;
  @override
  Time? get time2;
  @override
  String? get time2Meal;
  @override
  int? get time2OffsetMin;
  @override
  Time? get time3;
  @override
  String? get time3Meal;
  @override
  int? get time3OffsetMin;
  @override
  Time? get time4;
  @override
  String? get time4Meal;
  @override
  int? get time4OffsetMin;
  @override
  Time? get time5;
  @override
  String? get time5Meal;
  @override
  int? get time5OffsetMin;
  @override
  Time? get time6;
  @override
  String? get time6Meal;
  @override
  int? get time6OffsetMin;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  bool? get isIndefinite;
  @override
  DateTime? get expirationDate;
  @override
  String? get notes;
  @override
  @JsonKey(ignore: true)
  _$$MedicationUpdateRequestImplCopyWith<_$MedicationUpdateRequestImpl>
      get copyWith => throw _privateConstructorUsedError;
}
