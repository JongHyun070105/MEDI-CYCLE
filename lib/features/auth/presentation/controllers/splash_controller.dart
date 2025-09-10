import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:io';

part 'splash_controller.freezed.dart';

@freezed
class SplashState with _$SplashState {
  const factory SplashState({
    @Default(false) bool isLoading,
    @Default(false) bool hasNetworkError,
    @Default(false) bool isNetworkConnected,
  }) = _SplashState;
}

class SplashController extends StateNotifier<SplashState> {
  SplashController() : super(const SplashState());

  Future<void> checkNetworkConnection() async {
    state = state.copyWith(isLoading: true, hasNetworkError: false);

    try {
      // 간단한 네트워크 연결 확인
      final result = await InternetAddress.lookup('google.com');

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          isNetworkConnected: true,
          hasNetworkError: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isNetworkConnected: false,
          hasNetworkError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isNetworkConnected: false,
        hasNetworkError: true,
      );
    }
  }
}

final splashControllerProvider =
    StateNotifierProvider<SplashController, SplashState>(
      (ref) => SplashController(),
    );
