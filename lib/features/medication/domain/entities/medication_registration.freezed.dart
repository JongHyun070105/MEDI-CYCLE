// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_registration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MedicationRegistration _$MedicationRegistrationFromJson(
    Map<String, dynamic> json) {
  return _MedicationRegistration.fromJson(json);
}

/// @nodoc
mixin _$MedicationRegistration {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get manufacturer => throw _privateConstructorUsedError;
  String? get ingredient => throw _privateConstructorUsedError;
  String? get dosage => throw _privateConstructorUsedError;
  int get dailyFrequency => throw _privateConstructorUsedError;
  List<DosageTime> get dosageTimes => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  bool get isIndefinite => throw _privateConstructorUsedError;
  RegistrationStatus get status => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicationRegistrationCopyWith<MedicationRegistration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationRegistrationCopyWith<$Res> {
  factory $MedicationRegistrationCopyWith(MedicationRegistration value,
          $Res Function(MedicationRegistration) then) =
      _$MedicationRegistrationCopyWithImpl<$Res, MedicationRegistration>;
  @useResult
  $Res call(
      {String id,
      String name,
      String? imageUrl,
      String? manufacturer,
      String? ingredient,
      String? dosage,
      int dailyFrequency,
      List<DosageTime> dosageTimes,
      DateTime startDate,
      DateTime? endDate,
      bool isIndefinite,
      RegistrationStatus status,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$MedicationRegistrationCopyWithImpl<$Res,
        $Val extends MedicationRegistration>
    implements $MedicationRegistrationCopyWith<$Res> {
  _$MedicationRegistrationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = freezed,
    Object? manufacturer = freezed,
    Object? ingredient = freezed,
    Object? dosage = freezed,
    Object? dailyFrequency = null,
    Object? dosageTimes = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isIndefinite = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      manufacturer: freezed == manufacturer
          ? _value.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredient: freezed == ingredient
          ? _value.ingredient
          : ingredient // ignore: cast_nullable_to_non_nullable
              as String?,
      dosage: freezed == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyFrequency: null == dailyFrequency
          ? _value.dailyFrequency
          : dailyFrequency // ignore: cast_nullable_to_non_nullable
              as int,
      dosageTimes: null == dosageTimes
          ? _value.dosageTimes
          : dosageTimes // ignore: cast_nullable_to_non_nullable
              as List<DosageTime>,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RegistrationStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MedicationRegistrationImplCopyWith<$Res>
    implements $MedicationRegistrationCopyWith<$Res> {
  factory _$$MedicationRegistrationImplCopyWith(
          _$MedicationRegistrationImpl value,
          $Res Function(_$MedicationRegistrationImpl) then) =
      __$$MedicationRegistrationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? imageUrl,
      String? manufacturer,
      String? ingredient,
      String? dosage,
      int dailyFrequency,
      List<DosageTime> dosageTimes,
      DateTime startDate,
      DateTime? endDate,
      bool isIndefinite,
      RegistrationStatus status,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$$MedicationRegistrationImplCopyWithImpl<$Res>
    extends _$MedicationRegistrationCopyWithImpl<$Res,
        _$MedicationRegistrationImpl>
    implements _$$MedicationRegistrationImplCopyWith<$Res> {
  __$$MedicationRegistrationImplCopyWithImpl(
      _$MedicationRegistrationImpl _value,
      $Res Function(_$MedicationRegistrationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? imageUrl = freezed,
    Object? manufacturer = freezed,
    Object? ingredient = freezed,
    Object? dosage = freezed,
    Object? dailyFrequency = null,
    Object? dosageTimes = null,
    Object? startDate = null,
    Object? endDate = freezed,
    Object? isIndefinite = null,
    Object? status = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_$MedicationRegistrationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      manufacturer: freezed == manufacturer
          ? _value.manufacturer
          : manufacturer // ignore: cast_nullable_to_non_nullable
              as String?,
      ingredient: freezed == ingredient
          ? _value.ingredient
          : ingredient // ignore: cast_nullable_to_non_nullable
              as String?,
      dosage: freezed == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String?,
      dailyFrequency: null == dailyFrequency
          ? _value.dailyFrequency
          : dailyFrequency // ignore: cast_nullable_to_non_nullable
              as int,
      dosageTimes: null == dosageTimes
          ? _value._dosageTimes
          : dosageTimes // ignore: cast_nullable_to_non_nullable
              as List<DosageTime>,
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
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as RegistrationStatus,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationRegistrationImpl implements _MedicationRegistration {
  const _$MedicationRegistrationImpl(
      {required this.id,
      required this.name,
      this.imageUrl,
      this.manufacturer,
      this.ingredient,
      this.dosage,
      required this.dailyFrequency,
      required final List<DosageTime> dosageTimes,
      required this.startDate,
      this.endDate,
      this.isIndefinite = false,
      required this.status,
      this.createdAt,
      this.updatedAt})
      : _dosageTimes = dosageTimes;

  factory _$MedicationRegistrationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationRegistrationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? imageUrl;
  @override
  final String? manufacturer;
  @override
  final String? ingredient;
  @override
  final String? dosage;
  @override
  final int dailyFrequency;
  final List<DosageTime> _dosageTimes;
  @override
  List<DosageTime> get dosageTimes {
    if (_dosageTimes is EqualUnmodifiableListView) return _dosageTimes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dosageTimes);
  }

  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  @JsonKey()
  final bool isIndefinite;
  @override
  final RegistrationStatus status;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'MedicationRegistration(id: $id, name: $name, imageUrl: $imageUrl, manufacturer: $manufacturer, ingredient: $ingredient, dosage: $dosage, dailyFrequency: $dailyFrequency, dosageTimes: $dosageTimes, startDate: $startDate, endDate: $endDate, isIndefinite: $isIndefinite, status: $status, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationRegistrationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.ingredient, ingredient) ||
                other.ingredient == ingredient) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.dailyFrequency, dailyFrequency) ||
                other.dailyFrequency == dailyFrequency) &&
            const DeepCollectionEquality()
                .equals(other._dosageTimes, _dosageTimes) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.isIndefinite, isIndefinite) ||
                other.isIndefinite == isIndefinite) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      imageUrl,
      manufacturer,
      ingredient,
      dosage,
      dailyFrequency,
      const DeepCollectionEquality().hash(_dosageTimes),
      startDate,
      endDate,
      isIndefinite,
      status,
      createdAt,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationRegistrationImplCopyWith<_$MedicationRegistrationImpl>
      get copyWith => __$$MedicationRegistrationImplCopyWithImpl<
          _$MedicationRegistrationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationRegistrationImplToJson(
      this,
    );
  }
}

abstract class _MedicationRegistration implements MedicationRegistration {
  const factory _MedicationRegistration(
      {required final String id,
      required final String name,
      final String? imageUrl,
      final String? manufacturer,
      final String? ingredient,
      final String? dosage,
      required final int dailyFrequency,
      required final List<DosageTime> dosageTimes,
      required final DateTime startDate,
      final DateTime? endDate,
      final bool isIndefinite,
      required final RegistrationStatus status,
      final DateTime? createdAt,
      final DateTime? updatedAt}) = _$MedicationRegistrationImpl;

  factory _MedicationRegistration.fromJson(Map<String, dynamic> json) =
      _$MedicationRegistrationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get imageUrl;
  @override
  String? get manufacturer;
  @override
  String? get ingredient;
  @override
  String? get dosage;
  @override
  int get dailyFrequency;
  @override
  List<DosageTime> get dosageTimes;
  @override
  DateTime get startDate;
  @override
  DateTime? get endDate;
  @override
  bool get isIndefinite;
  @override
  RegistrationStatus get status;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MedicationRegistrationImplCopyWith<_$MedicationRegistrationImpl>
      get copyWith => throw _privateConstructorUsedError;
}

DosageTime _$DosageTimeFromJson(Map<String, dynamic> json) {
  return _DosageTime.fromJson(json);
}

/// @nodoc
mixin _$DosageTime {
  String get id => throw _privateConstructorUsedError;
  TimeOfDay get time => throw _privateConstructorUsedError;
  MealRelation get mealRelation => throw _privateConstructorUsedError;
  int get mealOffsetMinutes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DosageTimeCopyWith<DosageTime> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DosageTimeCopyWith<$Res> {
  factory $DosageTimeCopyWith(
          DosageTime value, $Res Function(DosageTime) then) =
      _$DosageTimeCopyWithImpl<$Res, DosageTime>;
  @useResult
  $Res call(
      {String id,
      TimeOfDay time,
      MealRelation mealRelation,
      int mealOffsetMinutes});

  $TimeOfDayCopyWith<$Res> get time;
}

/// @nodoc
class _$DosageTimeCopyWithImpl<$Res, $Val extends DosageTime>
    implements $DosageTimeCopyWith<$Res> {
  _$DosageTimeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? mealRelation = null,
    Object? mealOffsetMinutes = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      mealRelation: null == mealRelation
          ? _value.mealRelation
          : mealRelation // ignore: cast_nullable_to_non_nullable
              as MealRelation,
      mealOffsetMinutes: null == mealOffsetMinutes
          ? _value.mealOffsetMinutes
          : mealOffsetMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $TimeOfDayCopyWith<$Res> get time {
    return $TimeOfDayCopyWith<$Res>(_value.time, (value) {
      return _then(_value.copyWith(time: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DosageTimeImplCopyWith<$Res>
    implements $DosageTimeCopyWith<$Res> {
  factory _$$DosageTimeImplCopyWith(
          _$DosageTimeImpl value, $Res Function(_$DosageTimeImpl) then) =
      __$$DosageTimeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      TimeOfDay time,
      MealRelation mealRelation,
      int mealOffsetMinutes});

  @override
  $TimeOfDayCopyWith<$Res> get time;
}

/// @nodoc
class __$$DosageTimeImplCopyWithImpl<$Res>
    extends _$DosageTimeCopyWithImpl<$Res, _$DosageTimeImpl>
    implements _$$DosageTimeImplCopyWith<$Res> {
  __$$DosageTimeImplCopyWithImpl(
      _$DosageTimeImpl _value, $Res Function(_$DosageTimeImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? time = null,
    Object? mealRelation = null,
    Object? mealOffsetMinutes = null,
  }) {
    return _then(_$DosageTimeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as TimeOfDay,
      mealRelation: null == mealRelation
          ? _value.mealRelation
          : mealRelation // ignore: cast_nullable_to_non_nullable
              as MealRelation,
      mealOffsetMinutes: null == mealOffsetMinutes
          ? _value.mealOffsetMinutes
          : mealOffsetMinutes // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DosageTimeImpl implements _DosageTime {
  const _$DosageTimeImpl(
      {required this.id,
      required this.time,
      required this.mealRelation,
      required this.mealOffsetMinutes});

  factory _$DosageTimeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DosageTimeImplFromJson(json);

  @override
  final String id;
  @override
  final TimeOfDay time;
  @override
  final MealRelation mealRelation;
  @override
  final int mealOffsetMinutes;

  @override
  String toString() {
    return 'DosageTime(id: $id, time: $time, mealRelation: $mealRelation, mealOffsetMinutes: $mealOffsetMinutes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DosageTimeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.mealRelation, mealRelation) ||
                other.mealRelation == mealRelation) &&
            (identical(other.mealOffsetMinutes, mealOffsetMinutes) ||
                other.mealOffsetMinutes == mealOffsetMinutes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, time, mealRelation, mealOffsetMinutes);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DosageTimeImplCopyWith<_$DosageTimeImpl> get copyWith =>
      __$$DosageTimeImplCopyWithImpl<_$DosageTimeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DosageTimeImplToJson(
      this,
    );
  }
}

abstract class _DosageTime implements DosageTime {
  const factory _DosageTime(
      {required final String id,
      required final TimeOfDay time,
      required final MealRelation mealRelation,
      required final int mealOffsetMinutes}) = _$DosageTimeImpl;

  factory _DosageTime.fromJson(Map<String, dynamic> json) =
      _$DosageTimeImpl.fromJson;

  @override
  String get id;
  @override
  TimeOfDay get time;
  @override
  MealRelation get mealRelation;
  @override
  int get mealOffsetMinutes;
  @override
  @JsonKey(ignore: true)
  _$$DosageTimeImplCopyWith<_$DosageTimeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeOfDay _$TimeOfDayFromJson(Map<String, dynamic> json) {
  return _TimeOfDay.fromJson(json);
}

/// @nodoc
mixin _$TimeOfDay {
  int get hour => throw _privateConstructorUsedError;
  int get minute => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimeOfDayCopyWith<TimeOfDay> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeOfDayCopyWith<$Res> {
  factory $TimeOfDayCopyWith(TimeOfDay value, $Res Function(TimeOfDay) then) =
      _$TimeOfDayCopyWithImpl<$Res, TimeOfDay>;
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class _$TimeOfDayCopyWithImpl<$Res, $Val extends TimeOfDay>
    implements $TimeOfDayCopyWith<$Res> {
  _$TimeOfDayCopyWithImpl(this._value, this._then);

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
abstract class _$$TimeOfDayImplCopyWith<$Res>
    implements $TimeOfDayCopyWith<$Res> {
  factory _$$TimeOfDayImplCopyWith(
          _$TimeOfDayImpl value, $Res Function(_$TimeOfDayImpl) then) =
      __$$TimeOfDayImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int hour, int minute});
}

/// @nodoc
class __$$TimeOfDayImplCopyWithImpl<$Res>
    extends _$TimeOfDayCopyWithImpl<$Res, _$TimeOfDayImpl>
    implements _$$TimeOfDayImplCopyWith<$Res> {
  __$$TimeOfDayImplCopyWithImpl(
      _$TimeOfDayImpl _value, $Res Function(_$TimeOfDayImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hour = null,
    Object? minute = null,
  }) {
    return _then(_$TimeOfDayImpl(
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
class _$TimeOfDayImpl implements _TimeOfDay {
  const _$TimeOfDayImpl({required this.hour, required this.minute});

  factory _$TimeOfDayImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeOfDayImplFromJson(json);

  @override
  final int hour;
  @override
  final int minute;

  @override
  String toString() {
    return 'TimeOfDay(hour: $hour, minute: $minute)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeOfDayImpl &&
            (identical(other.hour, hour) || other.hour == hour) &&
            (identical(other.minute, minute) || other.minute == minute));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, hour, minute);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeOfDayImplCopyWith<_$TimeOfDayImpl> get copyWith =>
      __$$TimeOfDayImplCopyWithImpl<_$TimeOfDayImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeOfDayImplToJson(
      this,
    );
  }
}

abstract class _TimeOfDay implements TimeOfDay {
  const factory _TimeOfDay(
      {required final int hour, required final int minute}) = _$TimeOfDayImpl;

  factory _TimeOfDay.fromJson(Map<String, dynamic> json) =
      _$TimeOfDayImpl.fromJson;

  @override
  int get hour;
  @override
  int get minute;
  @override
  @JsonKey(ignore: true)
  _$$TimeOfDayImplCopyWith<_$TimeOfDayImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
