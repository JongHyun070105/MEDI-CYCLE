// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_completion_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileCompletionState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProfileCompletionStateCopyWith<ProfileCompletionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCompletionStateCopyWith<$Res> {
  factory $ProfileCompletionStateCopyWith(ProfileCompletionState value,
          $Res Function(ProfileCompletionState) then) =
      _$ProfileCompletionStateCopyWithImpl<$Res, ProfileCompletionState>;
  @useResult
  $Res call(
      {bool isLoading,
      bool isCompleted,
      bool hasError,
      String? errorMessage,
      int? age,
      String? gender,
      String? address});
}

/// @nodoc
class _$ProfileCompletionStateCopyWithImpl<$Res,
        $Val extends ProfileCompletionState>
    implements $ProfileCompletionStateCopyWith<$Res> {
  _$ProfileCompletionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isCompleted = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? address = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileCompletionStateImplCopyWith<$Res>
    implements $ProfileCompletionStateCopyWith<$Res> {
  factory _$$ProfileCompletionStateImplCopyWith(
          _$ProfileCompletionStateImpl value,
          $Res Function(_$ProfileCompletionStateImpl) then) =
      __$$ProfileCompletionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      bool isCompleted,
      bool hasError,
      String? errorMessage,
      int? age,
      String? gender,
      String? address});
}

/// @nodoc
class __$$ProfileCompletionStateImplCopyWithImpl<$Res>
    extends _$ProfileCompletionStateCopyWithImpl<$Res,
        _$ProfileCompletionStateImpl>
    implements _$$ProfileCompletionStateImplCopyWith<$Res> {
  __$$ProfileCompletionStateImplCopyWithImpl(
      _$ProfileCompletionStateImpl _value,
      $Res Function(_$ProfileCompletionStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isCompleted = null,
    Object? hasError = null,
    Object? errorMessage = freezed,
    Object? age = freezed,
    Object? gender = freezed,
    Object? address = freezed,
  }) {
    return _then(_$ProfileCompletionStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isCompleted: null == isCompleted
          ? _value.isCompleted
          : isCompleted // ignore: cast_nullable_to_non_nullable
              as bool,
      hasError: null == hasError
          ? _value.hasError
          : hasError // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      age: freezed == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ProfileCompletionStateImpl implements _ProfileCompletionState {
  const _$ProfileCompletionStateImpl(
      {this.isLoading = false,
      this.isCompleted = false,
      this.hasError = false,
      this.errorMessage,
      this.age,
      this.gender,
      this.address});

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final bool hasError;
  @override
  final String? errorMessage;
  @override
  final int? age;
  @override
  final String? gender;
  @override
  final String? address;

  @override
  String toString() {
    return 'ProfileCompletionState(isLoading: $isLoading, isCompleted: $isCompleted, hasError: $hasError, errorMessage: $errorMessage, age: $age, gender: $gender, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileCompletionStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.age, age) || other.age == age) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.address, address) || other.address == address));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, isCompleted, hasError,
      errorMessage, age, gender, address);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileCompletionStateImplCopyWith<_$ProfileCompletionStateImpl>
      get copyWith => __$$ProfileCompletionStateImplCopyWithImpl<
          _$ProfileCompletionStateImpl>(this, _$identity);
}

abstract class _ProfileCompletionState implements ProfileCompletionState {
  const factory _ProfileCompletionState(
      {final bool isLoading,
      final bool isCompleted,
      final bool hasError,
      final String? errorMessage,
      final int? age,
      final String? gender,
      final String? address}) = _$ProfileCompletionStateImpl;

  @override
  bool get isLoading;
  @override
  bool get isCompleted;
  @override
  bool get hasError;
  @override
  String? get errorMessage;
  @override
  int? get age;
  @override
  String? get gender;
  @override
  String? get address;
  @override
  @JsonKey(ignore: true)
  _$$ProfileCompletionStateImplCopyWith<_$ProfileCompletionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
