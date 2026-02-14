import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:pamoja_twalima/data/services/auth_service.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/core/network/token_manager.dart';
import 'package:pamoja_twalima/data/models/user.dart';

class MockApiService extends Mock implements ApiService {}
class MockTokenManager extends Mock implements TokenManager {}

void main() {
  late AuthService authService;
  late MockApiService mockApiService;
  late MockTokenManager mockTokenManager;
  const MethodChannel secureStorageChannel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final messenger = TestWidgetsFlutterBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(secureStorageChannel, (call) async {
      // Return null for write/delete/read operations.
      return null;
    });
  });

  tearDownAll(() {
    final messenger = TestWidgetsFlutterBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(secureStorageChannel, null);
  });

  setUp(() {
    mockApiService = MockApiService();
    mockTokenManager = MockTokenManager();
    authService = AuthService(mockApiService, mockTokenManager);
  });

  group('AuthService', () {
    group('login', () {
      test('should return User when login is successful', () async {
        final response = Response(
          requestOptions: RequestOptions(path: '/login'),
          data: {
            'user': {
              'id': 1,
              'name': 'Test User',
              'email': 'test@example.com',
            },
            'access_token': 'test_access_token',
            'refresh_token': 'test_refresh_token',
            'expires_at': DateTime.now()
                .add(const Duration(hours: 1))
                .toIso8601String(),
          },
        );

        when(() => mockApiService.post(
              '/login',
              data: any(named: 'data'),
            )).thenAnswer((_) async => response);

        when(() => mockTokenManager.saveTokens(
              accessToken: any(named: 'accessToken'),
              refreshToken: any(named: 'refreshToken'),
              expiresAt: any(named: 'expiresAt'),
            )).thenAnswer((_) async {});

        final result = await authService.login(
          email: 'test@example.com',
          password: 'password123',
        );

        expect(result, isA<User>());
        expect(result.email, 'test@example.com');
        expect(result.name, 'Test User');

        verify(() => mockApiService.post(
              '/login',
              data: {
                'email': 'test@example.com',
                'password': 'password123',
              },
            )).called(1);

        verify(() => mockTokenManager.saveTokens(
              accessToken: 'test_access_token',
              refreshToken: 'test_refresh_token',
              expiresAt: any(named: 'expiresAt'),
            )).called(1);
      });

      test('should throw exception when login fails', () async {
        when(() => mockApiService.post(
              '/login',
              data: any(named: 'data'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/login'),
          response: Response(
            requestOptions: RequestOptions(path: '/login'),
            statusCode: 401,
            data: {'message': 'Invalid credentials'},
          ),
        ));

        expect(
          () => authService.login(
            email: 'wrong@example.com',
            password: 'wrongpass',
          ),
          throwsA(isA<DioException>()),
        );
      });
    });

    group('register', () {
      test('should return User when registration is successful', () async {
        final response = Response(
          requestOptions: RequestOptions(path: '/register'),
          data: {
            'user': {
              'id': 1,
              'name': 'New User',
              'email': 'new@example.com',
            },
            'access_token': 'test_access_token',
            'refresh_token': 'test_refresh_token',
            'expires_at': DateTime.now()
                .add(const Duration(hours: 1))
                .toIso8601String(),
          },
        );

        when(() => mockApiService.post(
              '/register',
              data: any(named: 'data'),
            )).thenAnswer((_) async => response);

        when(() => mockTokenManager.saveTokens(
              accessToken: any(named: 'accessToken'),
              refreshToken: any(named: 'refreshToken'),
              expiresAt: any(named: 'expiresAt'),
            )).thenAnswer((_) async {});

        final result = await authService.register(
          name: 'New User',
          email: 'new@example.com',
          password: 'StrongPass123!@',
          passwordConfirmation: 'StrongPass123!@',
        );

        expect(result, isA<User>());
        expect(result.email, 'new@example.com');
        expect(result.name, 'New User');
      });
    });

    group('logout', () {
      test('should clear tokens on logout', () async {
        final response = Response(
          requestOptions: RequestOptions(path: '/logout'),
          data: {'message': 'Logged out'},
        );

        when(() => mockApiService.post('/logout'))
            .thenAnswer((_) async => response);

        when(() => mockTokenManager.clearTokens())
            .thenAnswer((_) async {});

        await authService.logout();

        verify(() => mockApiService.post('/logout')).called(1);
        verify(() => mockTokenManager.clearTokens()).called(1);
      });
    });
  });
}
