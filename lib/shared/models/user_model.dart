import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String email,
    String? name,
    int? age,
    String? address,
    String? gender,
    DateTime? createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserSignupRequest with _$UserSignupRequest {
  const factory UserSignupRequest({
    required String email,
    required String password,
    String? name,
    int? age,
    String? address,
    String? gender,
  }) = _UserSignupRequest;

  factory UserSignupRequest.fromJson(Map<String, dynamic> json) =>
      _$UserSignupRequestFromJson(json);
}

@freezed
class UserLoginRequest with _$UserLoginRequest {
  const factory UserLoginRequest({
    required String email,
    required String password,
  }) = _UserLoginRequest;

  factory UserLoginRequest.fromJson(Map<String, dynamic> json) =>
      _$UserLoginRequestFromJson(json);
}

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'token_type') required String tokenType,
    required User user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
