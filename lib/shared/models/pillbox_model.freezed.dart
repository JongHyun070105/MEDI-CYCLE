// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pillbox_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PillboxStatus _$PillboxStatusFromJson(Map<String, dynamic> json) {
  return _PillboxStatus.fromJson(json);
}

/// @nodoc
mixin _$PillboxStatus {
  int get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  bool get detected => throw _privateConstructorUsedError;
  int? get batteryPercent => throw _privateConstructorUsedError;
  bool get isLocked => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PillboxStatusCopyWith<PillboxStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PillboxStatusCopyWith<$Res> {
  factory $PillboxStatusCopyWith(
          PillboxStatus value, $Res Function(PillboxStatus) then) =
      _$PillboxStatusCopyWithImpl<$Res, PillboxStatus>;
  @useResult
  $Res call(
      {int id,
      int userId,
      bool detected,
      int? batteryPercent,
      bool isLocked,
      DateTime updatedAt});
}

/// @nodoc
class _$PillboxStatusCopyWithImpl<$Res, $Val extends PillboxStatus>
    implements $PillboxStatusCopyWith<$Res> {
  _$PillboxStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? detected = null,
    Object? batteryPercent = freezed,
    Object? isLocked = null,
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
      detected: null == detected
          ? _value.detected
          : detected // ignore: cast_nullable_to_non_nullable
              as bool,
      batteryPercent: freezed == batteryPercent
          ? _value.batteryPercent
          : batteryPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PillboxStatusImplCopyWith<$Res>
    implements $PillboxStatusCopyWith<$Res> {
  factory _$$PillboxStatusImplCopyWith(
          _$PillboxStatusImpl value, $Res Function(_$PillboxStatusImpl) then) =
      __$$PillboxStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int userId,
      bool detected,
      int? batteryPercent,
      bool isLocked,
      DateTime updatedAt});
}

/// @nodoc
class __$$PillboxStatusImplCopyWithImpl<$Res>
    extends _$PillboxStatusCopyWithImpl<$Res, _$PillboxStatusImpl>
    implements _$$PillboxStatusImplCopyWith<$Res> {
  __$$PillboxStatusImplCopyWithImpl(
      _$PillboxStatusImpl _value, $Res Function(_$PillboxStatusImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? detected = null,
    Object? batteryPercent = freezed,
    Object? isLocked = null,
    Object? updatedAt = null,
  }) {
    return _then(_$PillboxStatusImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      detected: null == detected
          ? _value.detected
          : detected // ignore: cast_nullable_to_non_nullable
              as bool,
      batteryPercent: freezed == batteryPercent
          ? _value.batteryPercent
          : batteryPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      isLocked: null == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PillboxStatusImpl implements _PillboxStatus {
  const _$PillboxStatusImpl(
      {required this.id,
      required this.userId,
      required this.detected,
      this.batteryPercent,
      required this.isLocked,
      required this.updatedAt});

  factory _$PillboxStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$PillboxStatusImplFromJson(json);

  @override
  final int id;
  @override
  final int userId;
  @override
  final bool detected;
  @override
  final int? batteryPercent;
  @override
  final bool isLocked;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'PillboxStatus(id: $id, userId: $userId, detected: $detected, batteryPercent: $batteryPercent, isLocked: $isLocked, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PillboxStatusImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.detected, detected) ||
                other.detected == detected) &&
            (identical(other.batteryPercent, batteryPercent) ||
                other.batteryPercent == batteryPercent) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, userId, detected, batteryPercent, isLocked, updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PillboxStatusImplCopyWith<_$PillboxStatusImpl> get copyWith =>
      __$$PillboxStatusImplCopyWithImpl<_$PillboxStatusImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PillboxStatusImplToJson(
      this,
    );
  }
}

abstract class _PillboxStatus implements PillboxStatus {
  const factory _PillboxStatus(
      {required final int id,
      required final int userId,
      required final bool detected,
      final int? batteryPercent,
      required final bool isLocked,
      required final DateTime updatedAt}) = _$PillboxStatusImpl;

  factory _PillboxStatus.fromJson(Map<String, dynamic> json) =
      _$PillboxStatusImpl.fromJson;

  @override
  int get id;
  @override
  int get userId;
  @override
  bool get detected;
  @override
  int? get batteryPercent;
  @override
  bool get isLocked;
  @override
  DateTime get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$PillboxStatusImplCopyWith<_$PillboxStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PillboxStatusUpdate _$PillboxStatusUpdateFromJson(Map<String, dynamic> json) {
  return _PillboxStatusUpdate.fromJson(json);
}

/// @nodoc
mixin _$PillboxStatusUpdate {
  bool? get detected => throw _privateConstructorUsedError;
  int? get batteryPercent => throw _privateConstructorUsedError;
  bool? get isLocked => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PillboxStatusUpdateCopyWith<PillboxStatusUpdate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PillboxStatusUpdateCopyWith<$Res> {
  factory $PillboxStatusUpdateCopyWith(
          PillboxStatusUpdate value, $Res Function(PillboxStatusUpdate) then) =
      _$PillboxStatusUpdateCopyWithImpl<$Res, PillboxStatusUpdate>;
  @useResult
  $Res call({bool? detected, int? batteryPercent, bool? isLocked});
}

/// @nodoc
class _$PillboxStatusUpdateCopyWithImpl<$Res, $Val extends PillboxStatusUpdate>
    implements $PillboxStatusUpdateCopyWith<$Res> {
  _$PillboxStatusUpdateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detected = freezed,
    Object? batteryPercent = freezed,
    Object? isLocked = freezed,
  }) {
    return _then(_value.copyWith(
      detected: freezed == detected
          ? _value.detected
          : detected // ignore: cast_nullable_to_non_nullable
              as bool?,
      batteryPercent: freezed == batteryPercent
          ? _value.batteryPercent
          : batteryPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      isLocked: freezed == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PillboxStatusUpdateImplCopyWith<$Res>
    implements $PillboxStatusUpdateCopyWith<$Res> {
  factory _$$PillboxStatusUpdateImplCopyWith(_$PillboxStatusUpdateImpl value,
          $Res Function(_$PillboxStatusUpdateImpl) then) =
      __$$PillboxStatusUpdateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool? detected, int? batteryPercent, bool? isLocked});
}

/// @nodoc
class __$$PillboxStatusUpdateImplCopyWithImpl<$Res>
    extends _$PillboxStatusUpdateCopyWithImpl<$Res, _$PillboxStatusUpdateImpl>
    implements _$$PillboxStatusUpdateImplCopyWith<$Res> {
  __$$PillboxStatusUpdateImplCopyWithImpl(_$PillboxStatusUpdateImpl _value,
      $Res Function(_$PillboxStatusUpdateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? detected = freezed,
    Object? batteryPercent = freezed,
    Object? isLocked = freezed,
  }) {
    return _then(_$PillboxStatusUpdateImpl(
      detected: freezed == detected
          ? _value.detected
          : detected // ignore: cast_nullable_to_non_nullable
              as bool?,
      batteryPercent: freezed == batteryPercent
          ? _value.batteryPercent
          : batteryPercent // ignore: cast_nullable_to_non_nullable
              as int?,
      isLocked: freezed == isLocked
          ? _value.isLocked
          : isLocked // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PillboxStatusUpdateImpl implements _PillboxStatusUpdate {
  const _$PillboxStatusUpdateImpl(
      {this.detected, this.batteryPercent, this.isLocked});

  factory _$PillboxStatusUpdateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PillboxStatusUpdateImplFromJson(json);

  @override
  final bool? detected;
  @override
  final int? batteryPercent;
  @override
  final bool? isLocked;

  @override
  String toString() {
    return 'PillboxStatusUpdate(detected: $detected, batteryPercent: $batteryPercent, isLocked: $isLocked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PillboxStatusUpdateImpl &&
            (identical(other.detected, detected) ||
                other.detected == detected) &&
            (identical(other.batteryPercent, batteryPercent) ||
                other.batteryPercent == batteryPercent) &&
            (identical(other.isLocked, isLocked) ||
                other.isLocked == isLocked));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, detected, batteryPercent, isLocked);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PillboxStatusUpdateImplCopyWith<_$PillboxStatusUpdateImpl> get copyWith =>
      __$$PillboxStatusUpdateImplCopyWithImpl<_$PillboxStatusUpdateImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PillboxStatusUpdateImplToJson(
      this,
    );
  }
}

abstract class _PillboxStatusUpdate implements PillboxStatusUpdate {
  const factory _PillboxStatusUpdate(
      {final bool? detected,
      final int? batteryPercent,
      final bool? isLocked}) = _$PillboxStatusUpdateImpl;

  factory _PillboxStatusUpdate.fromJson(Map<String, dynamic> json) =
      _$PillboxStatusUpdateImpl.fromJson;

  @override
  bool? get detected;
  @override
  int? get batteryPercent;
  @override
  bool? get isLocked;
  @override
  @JsonKey(ignore: true)
  _$$PillboxStatusUpdateImplCopyWith<_$PillboxStatusUpdateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
