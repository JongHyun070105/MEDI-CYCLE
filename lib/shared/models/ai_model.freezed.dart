// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ai_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AiChatRequest _$AiChatRequestFromJson(Map<String, dynamic> json) {
  return _AiChatRequest.fromJson(json);
}

/// @nodoc
mixin _$AiChatRequest {
  String get message => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AiChatRequestCopyWith<AiChatRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiChatRequestCopyWith<$Res> {
  factory $AiChatRequestCopyWith(
          AiChatRequest value, $Res Function(AiChatRequest) then) =
      _$AiChatRequestCopyWithImpl<$Res, AiChatRequest>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AiChatRequestCopyWithImpl<$Res, $Val extends AiChatRequest>
    implements $AiChatRequestCopyWith<$Res> {
  _$AiChatRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiChatRequestImplCopyWith<$Res>
    implements $AiChatRequestCopyWith<$Res> {
  factory _$$AiChatRequestImplCopyWith(
          _$AiChatRequestImpl value, $Res Function(_$AiChatRequestImpl) then) =
      __$$AiChatRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AiChatRequestImplCopyWithImpl<$Res>
    extends _$AiChatRequestCopyWithImpl<$Res, _$AiChatRequestImpl>
    implements _$$AiChatRequestImplCopyWith<$Res> {
  __$$AiChatRequestImplCopyWithImpl(
      _$AiChatRequestImpl _value, $Res Function(_$AiChatRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
  }) {
    return _then(_$AiChatRequestImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiChatRequestImpl implements _AiChatRequest {
  const _$AiChatRequestImpl({required this.message});

  factory _$AiChatRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiChatRequestImplFromJson(json);

  @override
  final String message;

  @override
  String toString() {
    return 'AiChatRequest(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiChatRequestImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, message);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AiChatRequestImplCopyWith<_$AiChatRequestImpl> get copyWith =>
      __$$AiChatRequestImplCopyWithImpl<_$AiChatRequestImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiChatRequestImplToJson(
      this,
    );
  }
}

abstract class _AiChatRequest implements AiChatRequest {
  const factory _AiChatRequest({required final String message}) =
      _$AiChatRequestImpl;

  factory _AiChatRequest.fromJson(Map<String, dynamic> json) =
      _$AiChatRequestImpl.fromJson;

  @override
  String get message;
  @override
  @JsonKey(ignore: true)
  _$$AiChatRequestImplCopyWith<_$AiChatRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiFeedbackRequest _$AiFeedbackRequestFromJson(Map<String, dynamic> json) {
  return _AiFeedbackRequest.fromJson(json);
}

/// @nodoc
mixin _$AiFeedbackRequest {
  String? get itemName => throw _privateConstructorUsedError;
  String? get entpName => throw _privateConstructorUsedError;
  String? get question => throw _privateConstructorUsedError;
  String? get context => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AiFeedbackRequestCopyWith<AiFeedbackRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiFeedbackRequestCopyWith<$Res> {
  factory $AiFeedbackRequestCopyWith(
          AiFeedbackRequest value, $Res Function(AiFeedbackRequest) then) =
      _$AiFeedbackRequestCopyWithImpl<$Res, AiFeedbackRequest>;
  @useResult
  $Res call(
      {String? itemName, String? entpName, String? question, String? context});
}

/// @nodoc
class _$AiFeedbackRequestCopyWithImpl<$Res, $Val extends AiFeedbackRequest>
    implements $AiFeedbackRequestCopyWith<$Res> {
  _$AiFeedbackRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemName = freezed,
    Object? entpName = freezed,
    Object? question = freezed,
    Object? context = freezed,
  }) {
    return _then(_value.copyWith(
      itemName: freezed == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String?,
      entpName: freezed == entpName
          ? _value.entpName
          : entpName // ignore: cast_nullable_to_non_nullable
              as String?,
      question: freezed == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String?,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiFeedbackRequestImplCopyWith<$Res>
    implements $AiFeedbackRequestCopyWith<$Res> {
  factory _$$AiFeedbackRequestImplCopyWith(_$AiFeedbackRequestImpl value,
          $Res Function(_$AiFeedbackRequestImpl) then) =
      __$$AiFeedbackRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? itemName, String? entpName, String? question, String? context});
}

/// @nodoc
class __$$AiFeedbackRequestImplCopyWithImpl<$Res>
    extends _$AiFeedbackRequestCopyWithImpl<$Res, _$AiFeedbackRequestImpl>
    implements _$$AiFeedbackRequestImplCopyWith<$Res> {
  __$$AiFeedbackRequestImplCopyWithImpl(_$AiFeedbackRequestImpl _value,
      $Res Function(_$AiFeedbackRequestImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? itemName = freezed,
    Object? entpName = freezed,
    Object? question = freezed,
    Object? context = freezed,
  }) {
    return _then(_$AiFeedbackRequestImpl(
      itemName: freezed == itemName
          ? _value.itemName
          : itemName // ignore: cast_nullable_to_non_nullable
              as String?,
      entpName: freezed == entpName
          ? _value.entpName
          : entpName // ignore: cast_nullable_to_non_nullable
              as String?,
      question: freezed == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String?,
      context: freezed == context
          ? _value.context
          : context // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiFeedbackRequestImpl implements _AiFeedbackRequest {
  const _$AiFeedbackRequestImpl(
      {this.itemName, this.entpName, this.question, this.context});

  factory _$AiFeedbackRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiFeedbackRequestImplFromJson(json);

  @override
  final String? itemName;
  @override
  final String? entpName;
  @override
  final String? question;
  @override
  final String? context;

  @override
  String toString() {
    return 'AiFeedbackRequest(itemName: $itemName, entpName: $entpName, question: $question, context: $context)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiFeedbackRequestImpl &&
            (identical(other.itemName, itemName) ||
                other.itemName == itemName) &&
            (identical(other.entpName, entpName) ||
                other.entpName == entpName) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.context, context) || other.context == context));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, itemName, entpName, question, context);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AiFeedbackRequestImplCopyWith<_$AiFeedbackRequestImpl> get copyWith =>
      __$$AiFeedbackRequestImplCopyWithImpl<_$AiFeedbackRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiFeedbackRequestImplToJson(
      this,
    );
  }
}

abstract class _AiFeedbackRequest implements AiFeedbackRequest {
  const factory _AiFeedbackRequest(
      {final String? itemName,
      final String? entpName,
      final String? question,
      final String? context}) = _$AiFeedbackRequestImpl;

  factory _AiFeedbackRequest.fromJson(Map<String, dynamic> json) =
      _$AiFeedbackRequestImpl.fromJson;

  @override
  String? get itemName;
  @override
  String? get entpName;
  @override
  String? get question;
  @override
  String? get context;
  @override
  @JsonKey(ignore: true)
  _$$AiFeedbackRequestImplCopyWith<_$AiFeedbackRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiResponse _$AiResponseFromJson(Map<String, dynamic> json) {
  return _AiResponse.fromJson(json);
}

/// @nodoc
mixin _$AiResponse {
  String? get reply => throw _privateConstructorUsedError;
  String? get answer => throw _privateConstructorUsedError;
  String? get answerType => throw _privateConstructorUsedError;
  String? get productName => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AiResponseCopyWith<AiResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiResponseCopyWith<$Res> {
  factory $AiResponseCopyWith(
          AiResponse value, $Res Function(AiResponse) then) =
      _$AiResponseCopyWithImpl<$Res, AiResponse>;
  @useResult
  $Res call(
      {String? reply,
      String? answer,
      String? answerType,
      String? productName,
      String source,
      DateTime? createdAt});
}

/// @nodoc
class _$AiResponseCopyWithImpl<$Res, $Val extends AiResponse>
    implements $AiResponseCopyWith<$Res> {
  _$AiResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reply = freezed,
    Object? answer = freezed,
    Object? answerType = freezed,
    Object? productName = freezed,
    Object? source = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      reply: freezed == reply
          ? _value.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as String?,
      answer: freezed == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String?,
      answerType: freezed == answerType
          ? _value.answerType
          : answerType // ignore: cast_nullable_to_non_nullable
              as String?,
      productName: freezed == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiResponseImplCopyWith<$Res>
    implements $AiResponseCopyWith<$Res> {
  factory _$$AiResponseImplCopyWith(
          _$AiResponseImpl value, $Res Function(_$AiResponseImpl) then) =
      __$$AiResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? reply,
      String? answer,
      String? answerType,
      String? productName,
      String source,
      DateTime? createdAt});
}

/// @nodoc
class __$$AiResponseImplCopyWithImpl<$Res>
    extends _$AiResponseCopyWithImpl<$Res, _$AiResponseImpl>
    implements _$$AiResponseImplCopyWith<$Res> {
  __$$AiResponseImplCopyWithImpl(
      _$AiResponseImpl _value, $Res Function(_$AiResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reply = freezed,
    Object? answer = freezed,
    Object? answerType = freezed,
    Object? productName = freezed,
    Object? source = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$AiResponseImpl(
      reply: freezed == reply
          ? _value.reply
          : reply // ignore: cast_nullable_to_non_nullable
              as String?,
      answer: freezed == answer
          ? _value.answer
          : answer // ignore: cast_nullable_to_non_nullable
              as String?,
      answerType: freezed == answerType
          ? _value.answerType
          : answerType // ignore: cast_nullable_to_non_nullable
              as String?,
      productName: freezed == productName
          ? _value.productName
          : productName // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiResponseImpl implements _AiResponse {
  const _$AiResponseImpl(
      {this.reply,
      this.answer,
      this.answerType,
      this.productName,
      required this.source,
      this.createdAt});

  factory _$AiResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiResponseImplFromJson(json);

  @override
  final String? reply;
  @override
  final String? answer;
  @override
  final String? answerType;
  @override
  final String? productName;
  @override
  final String source;
  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'AiResponse(reply: $reply, answer: $answer, answerType: $answerType, productName: $productName, source: $source, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiResponseImpl &&
            (identical(other.reply, reply) || other.reply == reply) &&
            (identical(other.answer, answer) || other.answer == answer) &&
            (identical(other.answerType, answerType) ||
                other.answerType == answerType) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, reply, answer, answerType, productName, source, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AiResponseImplCopyWith<_$AiResponseImpl> get copyWith =>
      __$$AiResponseImplCopyWithImpl<_$AiResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiResponseImplToJson(
      this,
    );
  }
}

abstract class _AiResponse implements AiResponse {
  const factory _AiResponse(
      {final String? reply,
      final String? answer,
      final String? answerType,
      final String? productName,
      required final String source,
      final DateTime? createdAt}) = _$AiResponseImpl;

  factory _AiResponse.fromJson(Map<String, dynamic> json) =
      _$AiResponseImpl.fromJson;

  @override
  String? get reply;
  @override
  String? get answer;
  @override
  String? get answerType;
  @override
  String? get productName;
  @override
  String get source;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$AiResponseImplCopyWith<_$AiResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AiFeedbackLog _$AiFeedbackLogFromJson(Map<String, dynamic> json) {
  return _AiFeedbackLog.fromJson(json);
}

/// @nodoc
mixin _$AiFeedbackLog {
  int get id => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  String get kind => throw _privateConstructorUsedError;
  String get requestText => throw _privateConstructorUsedError;
  String? get responseText => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AiFeedbackLogCopyWith<AiFeedbackLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AiFeedbackLogCopyWith<$Res> {
  factory $AiFeedbackLogCopyWith(
          AiFeedbackLog value, $Res Function(AiFeedbackLog) then) =
      _$AiFeedbackLogCopyWithImpl<$Res, AiFeedbackLog>;
  @useResult
  $Res call(
      {int id,
      int userId,
      String kind,
      String requestText,
      String? responseText,
      String source,
      DateTime createdAt});
}

/// @nodoc
class _$AiFeedbackLogCopyWithImpl<$Res, $Val extends AiFeedbackLog>
    implements $AiFeedbackLogCopyWith<$Res> {
  _$AiFeedbackLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? kind = null,
    Object? requestText = null,
    Object? responseText = freezed,
    Object? source = null,
    Object? createdAt = null,
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
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      requestText: null == requestText
          ? _value.requestText
          : requestText // ignore: cast_nullable_to_non_nullable
              as String,
      responseText: freezed == responseText
          ? _value.responseText
          : responseText // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AiFeedbackLogImplCopyWith<$Res>
    implements $AiFeedbackLogCopyWith<$Res> {
  factory _$$AiFeedbackLogImplCopyWith(
          _$AiFeedbackLogImpl value, $Res Function(_$AiFeedbackLogImpl) then) =
      __$$AiFeedbackLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int userId,
      String kind,
      String requestText,
      String? responseText,
      String source,
      DateTime createdAt});
}

/// @nodoc
class __$$AiFeedbackLogImplCopyWithImpl<$Res>
    extends _$AiFeedbackLogCopyWithImpl<$Res, _$AiFeedbackLogImpl>
    implements _$$AiFeedbackLogImplCopyWith<$Res> {
  __$$AiFeedbackLogImplCopyWithImpl(
      _$AiFeedbackLogImpl _value, $Res Function(_$AiFeedbackLogImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? kind = null,
    Object? requestText = null,
    Object? responseText = freezed,
    Object? source = null,
    Object? createdAt = null,
  }) {
    return _then(_$AiFeedbackLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as int,
      kind: null == kind
          ? _value.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as String,
      requestText: null == requestText
          ? _value.requestText
          : requestText // ignore: cast_nullable_to_non_nullable
              as String,
      responseText: freezed == responseText
          ? _value.responseText
          : responseText // ignore: cast_nullable_to_non_nullable
              as String?,
      source: null == source
          ? _value.source
          : source // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AiFeedbackLogImpl implements _AiFeedbackLog {
  const _$AiFeedbackLogImpl(
      {required this.id,
      required this.userId,
      required this.kind,
      required this.requestText,
      this.responseText,
      required this.source,
      required this.createdAt});

  factory _$AiFeedbackLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$AiFeedbackLogImplFromJson(json);

  @override
  final int id;
  @override
  final int userId;
  @override
  final String kind;
  @override
  final String requestText;
  @override
  final String? responseText;
  @override
  final String source;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'AiFeedbackLog(id: $id, userId: $userId, kind: $kind, requestText: $requestText, responseText: $responseText, source: $source, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AiFeedbackLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.requestText, requestText) ||
                other.requestText == requestText) &&
            (identical(other.responseText, responseText) ||
                other.responseText == responseText) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, kind, requestText,
      responseText, source, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AiFeedbackLogImplCopyWith<_$AiFeedbackLogImpl> get copyWith =>
      __$$AiFeedbackLogImplCopyWithImpl<_$AiFeedbackLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AiFeedbackLogImplToJson(
      this,
    );
  }
}

abstract class _AiFeedbackLog implements AiFeedbackLog {
  const factory _AiFeedbackLog(
      {required final int id,
      required final int userId,
      required final String kind,
      required final String requestText,
      final String? responseText,
      required final String source,
      required final DateTime createdAt}) = _$AiFeedbackLogImpl;

  factory _AiFeedbackLog.fromJson(Map<String, dynamic> json) =
      _$AiFeedbackLogImpl.fromJson;

  @override
  int get id;
  @override
  int get userId;
  @override
  String get kind;
  @override
  String get requestText;
  @override
  String? get responseText;
  @override
  String get source;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$AiFeedbackLogImplCopyWith<_$AiFeedbackLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
