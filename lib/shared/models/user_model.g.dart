// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      name: json['name'] as String?,
      age: (json['age'] as num?)?.toInt(),
      address: json['address'] as String?,
      gender: json['gender'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'age': instance.age,
      'address': instance.address,
      'gender': instance.gender,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$UserSignupRequestImpl _$$UserSignupRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UserSignupRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String?,
      age: (json['age'] as num?)?.toInt(),
      address: json['address'] as String?,
      gender: json['gender'] as String?,
    );

Map<String, dynamic> _$$UserSignupRequestImplToJson(
        _$UserSignupRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'name': instance.name,
      'age': instance.age,
      'address': instance.address,
      'gender': instance.gender,
    };

_$UserLoginRequestImpl _$$UserLoginRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$UserLoginRequestImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$UserLoginRequestImplToJson(
        _$UserLoginRequestImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'user': instance.user,
    };
