// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MedicationSchedule _$MedicationScheduleFromJson(Map<String, dynamic> json) {
  return _MedicationSchedule.fromJson(json);
}

/// @nodoc
mixin _$MedicationSchedule {
  String get id => throw _privateConstructorUsedError;
  String get medicationId => throw _privateConstructorUsedError;
  String get medicationName => throw _privateConstructorUsedError;
  DateTime get scheduledTime => throw _privateConstructorUsedError;
  bool get isTaken => throw _privateConstructorUsedError;
  bool get isSkipped => throw _privateConstructorUsedError;
  DateTime? get takenAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MedicationScheduleCopyWith<MedicationSchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MedicationScheduleCopyWith<$Res> {
  factory $MedicationScheduleCopyWith(
          MedicationSchedule value, $Res Function(MedicationSchedule) then) =
      _$MedicationScheduleCopyWithImpl<$Res, MedicationSchedule>;
  @useResult
  $Res call(
      {String id,
      String medicationId,
      String medicationName,
      DateTime scheduledTime,
      bool isTaken,
      bool isSkipped,
      DateTime? takenAt,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$MedicationScheduleCopyWithImpl<$Res, $Val extends MedicationSchedule>
    implements $MedicationScheduleCopyWith<$Res> {
  _$MedicationScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicationId = null,
    Object? medicationName = null,
    Object? scheduledTime = null,
    Object? isTaken = null,
    Object? isSkipped = null,
    Object? takenAt = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      medicationId: null == medicationId
          ? _value.medicationId
          : medicationId // ignore: cast_nullable_to_non_nullable
              as String,
      medicationName: null == medicationName
          ? _value.medicationName
          : medicationName // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isTaken: null == isTaken
          ? _value.isTaken
          : isTaken // ignore: cast_nullable_to_non_nullable
              as bool,
      isSkipped: null == isSkipped
          ? _value.isSkipped
          : isSkipped // ignore: cast_nullable_to_non_nullable
              as bool,
      takenAt: freezed == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
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
}

/// @nodoc
abstract class _$$MedicationScheduleImplCopyWith<$Res>
    implements $MedicationScheduleCopyWith<$Res> {
  factory _$$MedicationScheduleImplCopyWith(_$MedicationScheduleImpl value,
          $Res Function(_$MedicationScheduleImpl) then) =
      __$$MedicationScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String medicationId,
      String medicationName,
      DateTime scheduledTime,
      bool isTaken,
      bool isSkipped,
      DateTime? takenAt,
      String? notes,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$MedicationScheduleImplCopyWithImpl<$Res>
    extends _$MedicationScheduleCopyWithImpl<$Res, _$MedicationScheduleImpl>
    implements _$$MedicationScheduleImplCopyWith<$Res> {
  __$$MedicationScheduleImplCopyWithImpl(_$MedicationScheduleImpl _value,
      $Res Function(_$MedicationScheduleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? medicationId = null,
    Object? medicationName = null,
    Object? scheduledTime = null,
    Object? isTaken = null,
    Object? isSkipped = null,
    Object? takenAt = freezed,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$MedicationScheduleImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      medicationId: null == medicationId
          ? _value.medicationId
          : medicationId // ignore: cast_nullable_to_non_nullable
              as String,
      medicationName: null == medicationName
          ? _value.medicationName
          : medicationName // ignore: cast_nullable_to_non_nullable
              as String,
      scheduledTime: null == scheduledTime
          ? _value.scheduledTime
          : scheduledTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isTaken: null == isTaken
          ? _value.isTaken
          : isTaken // ignore: cast_nullable_to_non_nullable
              as bool,
      isSkipped: null == isSkipped
          ? _value.isSkipped
          : isSkipped // ignore: cast_nullable_to_non_nullable
              as bool,
      takenAt: freezed == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
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
class _$MedicationScheduleImpl implements _MedicationSchedule {
  const _$MedicationScheduleImpl(
      {required this.id,
      required this.medicationId,
      required this.medicationName,
      required this.scheduledTime,
      required this.isTaken,
      required this.isSkipped,
      this.takenAt,
      this.notes,
      required this.createdAt,
      required this.updatedAt});

  factory _$MedicationScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationScheduleImplFromJson(json);

  @override
  final String id;
  @override
  final String medicationId;
  @override
  final String medicationName;
  @override
  final DateTime scheduledTime;
  @override
  final bool isTaken;
  @override
  final bool isSkipped;
  @override
  final DateTime? takenAt;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'MedicationSchedule(id: $id, medicationId: $medicationId, medicationName: $medicationName, scheduledTime: $scheduledTime, isTaken: $isTaken, isSkipped: $isSkipped, takenAt: $takenAt, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationScheduleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.medicationId, medicationId) ||
                other.medicationId == medicationId) &&
            (identical(other.medicationName, medicationName) ||
                other.medicationName == medicationName) &&
            (identical(other.scheduledTime, scheduledTime) ||
                other.scheduledTime == scheduledTime) &&
            (identical(other.isTaken, isTaken) || other.isTaken == isTaken) &&
            (identical(other.isSkipped, isSkipped) ||
                other.isSkipped == isSkipped) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, medicationId, medicationName,
      scheduledTime, isTaken, isSkipped, takenAt, notes, createdAt, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MedicationScheduleImplCopyWith<_$MedicationScheduleImpl> get copyWith =>
      __$$MedicationScheduleImplCopyWithImpl<_$MedicationScheduleImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MedicationScheduleImplToJson(
      this,
    );
  }
}

abstract class _MedicationSchedule implements MedicationSchedule {
  const factory _MedicationSchedule(
      {required final String id,
      required final String medicationId,
      required final String medicationName,
      required final DateTime scheduledTime,
      required final bool isTaken,
      required final bool isSkipped,
      final DateTime? takenAt,
      final String? notes,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$MedicationScheduleImpl;

  factory _MedicationSchedule.fromJson(Map<String, dynamic> json) =
      _$MedicationScheduleImpl.fromJson;

  @override
  String get id;
  @override
  String get medicationId;
  @override
  String get medicationName;
  @override
  DateTime get scheduledTime;
  @override
  bool get isTaken;
  @override
  bool get isSkipped;
  @override
  DateTime? get takenAt;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$MedicationScheduleImplCopyWith<_$MedicationScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailySchedule _$DailyScheduleFromJson(Map<String, dynamic> json) {
  return _DailySchedule.fromJson(json);
}

/// @nodoc
mixin _$DailySchedule {
  DateTime get date => throw _privateConstructorUsedError;
  List<MedicationSchedule> get schedules => throw _privateConstructorUsedError;
  int get totalMedications => throw _privateConstructorUsedError;
  int get takenMedications => throw _privateConstructorUsedError;
  int get skippedMedications => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DailyScheduleCopyWith<DailySchedule> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyScheduleCopyWith<$Res> {
  factory $DailyScheduleCopyWith(
          DailySchedule value, $Res Function(DailySchedule) then) =
      _$DailyScheduleCopyWithImpl<$Res, DailySchedule>;
  @useResult
  $Res call(
      {DateTime date,
      List<MedicationSchedule> schedules,
      int totalMedications,
      int takenMedications,
      int skippedMedications});
}

/// @nodoc
class _$DailyScheduleCopyWithImpl<$Res, $Val extends DailySchedule>
    implements $DailyScheduleCopyWith<$Res> {
  _$DailyScheduleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? schedules = null,
    Object? totalMedications = null,
    Object? takenMedications = null,
    Object? skippedMedications = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      schedules: null == schedules
          ? _value.schedules
          : schedules // ignore: cast_nullable_to_non_nullable
              as List<MedicationSchedule>,
      totalMedications: null == totalMedications
          ? _value.totalMedications
          : totalMedications // ignore: cast_nullable_to_non_nullable
              as int,
      takenMedications: null == takenMedications
          ? _value.takenMedications
          : takenMedications // ignore: cast_nullable_to_non_nullable
              as int,
      skippedMedications: null == skippedMedications
          ? _value.skippedMedications
          : skippedMedications // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyScheduleImplCopyWith<$Res>
    implements $DailyScheduleCopyWith<$Res> {
  factory _$$DailyScheduleImplCopyWith(
          _$DailyScheduleImpl value, $Res Function(_$DailyScheduleImpl) then) =
      __$$DailyScheduleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      List<MedicationSchedule> schedules,
      int totalMedications,
      int takenMedications,
      int skippedMedications});
}

/// @nodoc
class __$$DailyScheduleImplCopyWithImpl<$Res>
    extends _$DailyScheduleCopyWithImpl<$Res, _$DailyScheduleImpl>
    implements _$$DailyScheduleImplCopyWith<$Res> {
  __$$DailyScheduleImplCopyWithImpl(
      _$DailyScheduleImpl _value, $Res Function(_$DailyScheduleImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? schedules = null,
    Object? totalMedications = null,
    Object? takenMedications = null,
    Object? skippedMedications = null,
  }) {
    return _then(_$DailyScheduleImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      schedules: null == schedules
          ? _value._schedules
          : schedules // ignore: cast_nullable_to_non_nullable
              as List<MedicationSchedule>,
      totalMedications: null == totalMedications
          ? _value.totalMedications
          : totalMedications // ignore: cast_nullable_to_non_nullable
              as int,
      takenMedications: null == takenMedications
          ? _value.takenMedications
          : takenMedications // ignore: cast_nullable_to_non_nullable
              as int,
      skippedMedications: null == skippedMedications
          ? _value.skippedMedications
          : skippedMedications // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DailyScheduleImpl implements _DailySchedule {
  const _$DailyScheduleImpl(
      {required this.date,
      required final List<MedicationSchedule> schedules,
      required this.totalMedications,
      required this.takenMedications,
      required this.skippedMedications})
      : _schedules = schedules;

  factory _$DailyScheduleImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyScheduleImplFromJson(json);

  @override
  final DateTime date;
  final List<MedicationSchedule> _schedules;
  @override
  List<MedicationSchedule> get schedules {
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_schedules);
  }

  @override
  final int totalMedications;
  @override
  final int takenMedications;
  @override
  final int skippedMedications;

  @override
  String toString() {
    return 'DailySchedule(date: $date, schedules: $schedules, totalMedications: $totalMedications, takenMedications: $takenMedications, skippedMedications: $skippedMedications)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyScheduleImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality()
                .equals(other._schedules, _schedules) &&
            (identical(other.totalMedications, totalMedications) ||
                other.totalMedications == totalMedications) &&
            (identical(other.takenMedications, takenMedications) ||
                other.takenMedications == takenMedications) &&
            (identical(other.skippedMedications, skippedMedications) ||
                other.skippedMedications == skippedMedications));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      date,
      const DeepCollectionEquality().hash(_schedules),
      totalMedications,
      takenMedications,
      skippedMedications);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyScheduleImplCopyWith<_$DailyScheduleImpl> get copyWith =>
      __$$DailyScheduleImplCopyWithImpl<_$DailyScheduleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyScheduleImplToJson(
      this,
    );
  }
}

abstract class _DailySchedule implements DailySchedule {
  const factory _DailySchedule(
      {required final DateTime date,
      required final List<MedicationSchedule> schedules,
      required final int totalMedications,
      required final int takenMedications,
      required final int skippedMedications}) = _$DailyScheduleImpl;

  factory _DailySchedule.fromJson(Map<String, dynamic> json) =
      _$DailyScheduleImpl.fromJson;

  @override
  DateTime get date;
  @override
  List<MedicationSchedule> get schedules;
  @override
  int get totalMedications;
  @override
  int get takenMedications;
  @override
  int get skippedMedications;
  @override
  @JsonKey(ignore: true)
  _$$DailyScheduleImplCopyWith<_$DailyScheduleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
