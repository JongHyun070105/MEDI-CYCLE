import 'package:flutter_test/flutter_test.dart';
import 'package:medi_cycle_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:medi_cycle_app/shared/models/user_model.dart';

void main() {
  group('AuthController', () {
    late AuthController authController;

    setUp(() {
      authController = AuthController();
    });

    test('should initialize with default state', () {
      expect(authController.state.isLoading, isFalse);
      expect(authController.state.isAuthenticated, isFalse);
      expect(authController.state.hasError, isFalse);
      expect(authController.state.errorMessage, isNull);
      expect(authController.state.user, isNull);
    });

    test('should create UserSignupRequest correctly', () {
      const request = UserSignupRequest(
        email: 'test@example.com',
        password: 'password123',
        name: 'Test User',
        age: 25,
        address: 'Test Address',
        gender: 'male',
      );

      expect(request.email, equals('test@example.com'));
      expect(request.password, equals('password123'));
      expect(request.name, equals('Test User'));
      expect(request.age, equals(25));
      expect(request.address, equals('Test Address'));
      expect(request.gender, equals('male'));
    });

    test('should create UserLoginRequest correctly', () {
      const request = UserLoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(request.email, equals('test@example.com'));
      expect(request.password, equals('password123'));
    });

    test('should create User model correctly', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        age: 25,
        address: 'Test Address',
        gender: 'male',
        createdAt: DateTime.now(),
      );

      expect(user.id, equals(1));
      expect(user.email, equals('test@example.com'));
      expect(user.name, equals('Test User'));
      expect(user.age, equals(25));
      expect(user.address, equals('Test Address'));
      expect(user.gender, equals('male'));
      expect(user.createdAt, isA<DateTime>());
    });

    test('should create AuthResponse correctly', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
      );

      final response = AuthResponse(
        accessToken: 'test_token_123',
        tokenType: 'bearer',
        user: user,
      );

      expect(response.accessToken, equals('test_token_123'));
      expect(response.tokenType, equals('bearer'));
      expect(response.user, equals(user));
    });
  });

  group('AuthState', () {
    test('should create AuthState with default values', () {
      const state = AuthState();

      expect(state.isLoading, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.hasError, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.user, isNull);
    });

    test('should create AuthState with custom values', () {
      final user = User(
        id: 1,
        email: 'test@example.com',
        name: 'Test User',
        createdAt: DateTime.now(),
      );

      final state = AuthState(
        isLoading: true,
        isAuthenticated: true,
        hasError: false,
        errorMessage: null,
        user: user,
      );

      expect(state.isLoading, isTrue);
      expect(state.isAuthenticated, isTrue);
      expect(state.hasError, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.user, equals(user));
    });
  });
}
