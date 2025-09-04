// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication.dart';

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
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get dosage => throw _privateConstructorUsedError;
  String get frequency => throw _privateConstructorUsedError;
  DateTime get startDate => throw _privateConstructorUsedError;
  DateTime get endDate => throw _privateConstructorUsedError;
  int get totalQuantity => throw _privateConstructorUsedError;
  int get remainingQuantity => throw _privateConstructorUsedError;
  String get instructions => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  MedicationStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  String? get sideEffects => throw _privateConstructorUsedError;
  String? get interactions => throw _privateConstructorUsedError;
  String? get storageInstructions => throw _privateConstructorUsedError;
  DateTime? get expiryDate => throw _privateConstructorUsedError;
  String? get prescriptionId => throw _privateConstructorUsedError;
  String? get qrCode => throw _privateConstructorUsedError;

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
      {String id,
      String name,
      String dosage,
      String frequency,
      DateTime startDate,
      DateTime endDate,
      int totalQuantity,
      int remainingQuantity,
      String instructions,
      String imageUrl,
      MedicationStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      String? notes,
      String? sideEffects,
      String? interactions,
      String? storageInstructions,
      DateTime? expiryDate,
      String? prescriptionId,
      String? qrCode});
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
    Object? name = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? totalQuantity = null,
    Object? remainingQuantity = null,
    Object? instructions = null,
    Object? imageUrl = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? notes = freezed,
    Object? sideEffects = freezed,
    Object? interactions = freezed,
    Object? storageInstructions = freezed,
    Object? expiryDate = freezed,
    Object? prescriptionId = freezed,
    Object? qrCode = freezed,
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
      dosage: null == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalQuantity: null == totalQuantity
          ? _value.totalQuantity
          : totalQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      remainingQuantity: null == remainingQuantity
          ? _value.remainingQuantity
          : remainingQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MedicationStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      sideEffects: freezed == sideEffects
          ? _value.sideEffects
          : sideEffects // ignore: cast_nullable_to_non_nullable
              as String?,
      interactions: freezed == interactions
          ? _value.interactions
          : interactions // ignore: cast_nullable_to_non_nullable
              as String?,
      storageInstructions: freezed == storageInstructions
          ? _value.storageInstructions
          : storageInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      prescriptionId: freezed == prescriptionId
          ? _value.prescriptionId
          : prescriptionId // ignore: cast_nullable_to_non_nullable
              as String?,
      qrCode: freezed == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
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
      {String id,
      String name,
      String dosage,
      String frequency,
      DateTime startDate,
      DateTime endDate,
      int totalQuantity,
      int remainingQuantity,
      String instructions,
      String imageUrl,
      MedicationStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      String? notes,
      String? sideEffects,
      String? interactions,
      String? storageInstructions,
      DateTime? expiryDate,
      String? prescriptionId,
      String? qrCode});
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
    Object? name = null,
    Object? dosage = null,
    Object? frequency = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? totalQuantity = null,
    Object? remainingQuantity = null,
    Object? instructions = null,
    Object? imageUrl = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? notes = freezed,
    Object? sideEffects = freezed,
    Object? interactions = freezed,
    Object? storageInstructions = freezed,
    Object? expiryDate = freezed,
    Object? prescriptionId = freezed,
    Object? qrCode = freezed,
  }) {
    return _then(_$MedicationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dosage: null == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String,
      frequency: null == frequency
          ? _value.frequency
          : frequency // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      totalQuantity: null == totalQuantity
          ? _value.totalQuantity
          : totalQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      remainingQuantity: null == remainingQuantity
          ? _value.remainingQuantity
          : remainingQuantity // ignore: cast_nullable_to_non_nullable
              as int,
      instructions: null == instructions
          ? _value.instructions
          : instructions // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: null == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MedicationStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      sideEffects: freezed == sideEffects
          ? _value.sideEffects
          : sideEffects // ignore: cast_nullable_to_non_nullable
              as String?,
      interactions: freezed == interactions
          ? _value.interactions
          : interactions // ignore: cast_nullable_to_non_nullable
              as String?,
      storageInstructions: freezed == storageInstructions
          ? _value.storageInstructions
          : storageInstructions // ignore: cast_nullable_to_non_nullable
              as String?,
      expiryDate: freezed == expiryDate
          ? _value.expiryDate
          : expiryDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      prescriptionId: freezed == prescriptionId
          ? _value.prescriptionId
          : prescriptionId // ignore: cast_nullable_to_non_nullable
              as String?,
      qrCode: freezed == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MedicationImpl implements _Medication {
  const _$MedicationImpl(
      {required this.id,
      required this.name,
      required this.dosage,
      required this.frequency,
      required this.startDate,
      required this.endDate,
      required this.totalQuantity,
      required this.remainingQuantity,
      required this.instructions,
      required this.imageUrl,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.notes,
      this.sideEffects,
      this.interactions,
      this.storageInstructions,
      this.expiryDate,
      this.prescriptionId,
      this.qrCode});

  factory _$MedicationImpl.fromJson(Map<String, dynamic> json) =>
      _$$MedicationImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String dosage;
  @override
  final String frequency;
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final int totalQuantity;
  @override
  final int remainingQuantity;
  @override
  final String instructions;
  @override
  final String imageUrl;
  @override
  final MedicationStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String? notes;
  @override
  final String? sideEffects;
  @override
  final String? interactions;
  @override
  final String? storageInstructions;
  @override
  final DateTime? expiryDate;
  @override
  final String? prescriptionId;
  @override
  final String? qrCode;

  @override
  String toString() {
    return 'Medication(id: $id, name: $name, dosage: $dosage, frequency: $frequency, startDate: $startDate, endDate: $endDate, totalQuantity: $totalQuantity, remainingQuantity: $remainingQuantity, instructions: $instructions, imageUrl: $imageUrl, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, notes: $notes, sideEffects: $sideEffects, interactions: $interactions, storageInstructions: $storageInstructions, expiryDate: $expiryDate, prescriptionId: $prescriptionId, qrCode: $qrCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MedicationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.frequency, frequency) ||
                other.frequency == frequency) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.totalQuantity, totalQuantity) ||
                other.totalQuantity == totalQuantity) &&
            (identical(other.remainingQuantity, remainingQuantity) ||
                other.remainingQuantity == remainingQuantity) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.sideEffects, sideEffects) ||
                other.sideEffects == sideEffects) &&
            (identical(other.interactions, interactions) ||
                other.interactions == interactions) &&
            (identical(other.storageInstructions, storageInstructions) ||
                other.storageInstructions == storageInstructions) &&
            (identical(other.expiryDate, expiryDate) ||
                other.expiryDate == expiryDate) &&
            (identical(other.prescriptionId, prescriptionId) ||
                other.prescriptionId == prescriptionId) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        dosage,
        frequency,
        startDate,
        endDate,
        totalQuantity,
        remainingQuantity,
        instructions,
        imageUrl,
        status,
        createdAt,
        updatedAt,
        notes,
        sideEffects,
        interactions,
        storageInstructions,
        expiryDate,
        prescriptionId,
        qrCode
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
      {required final String id,
      required final String name,
      required final String dosage,
      required final String frequency,
      required final DateTime startDate,
      required final DateTime endDate,
      required final int totalQuantity,
      required final int remainingQuantity,
      required final String instructions,
      required final String imageUrl,
      required final MedicationStatus status,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final String? notes,
      final String? sideEffects,
      final String? interactions,
      final String? storageInstructions,
      final DateTime? expiryDate,
      final String? prescriptionId,
      final String? qrCode}) = _$MedicationImpl;

  factory _Medication.fromJson(Map<String, dynamic> json) =
      _$MedicationImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get dosage;
  @override
  String get frequency;
  @override
  DateTime get startDate;
  @override
  DateTime get endDate;
  @override
  int get totalQuantity;
  @override
  int get remainingQuantity;
  @override
  String get instructions;
  @override
  String get imageUrl;
  @override
  MedicationStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String? get notes;
  @override
  String? get sideEffects;
  @override
  String? get interactions;
  @override
  String? get storageInstructions;
  @override
  DateTime? get expiryDate;
  @override
  String? get prescriptionId;
  @override
  String? get qrCode;
  @override
  @JsonKey(ignore: true)
  _$$MedicationImplCopyWith<_$MedicationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
