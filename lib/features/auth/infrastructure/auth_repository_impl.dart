import 'package:injectable/injectable.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/entities/user_entity.dart';
import '../domain/value_objects/value_objects.dart';
import 'package:pamoja_twalima/data/services/auth_service.dart';
import 'package:pamoja_twalima/core/network/token_manager.dart';
import 'mappers/user_mapper.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;
  final TokenManager _tokenManager;

  AuthRepositoryImpl(this._service, this._tokenManager);

  @override
  Future<UserEntity> login(EmailAddress email, Password password) async {
    final user = await _service.login(
      email: email.value,
      password: password.value,
    );
    return UserMapper.toEntity(user);
  }

  @override
  Future<UserEntity> register({
    required String name,
    required EmailAddress email,
    required Password password,
    required Password passwordConfirmation,
    String? phone,
    String? farmName,
    String? location,
  }) async {
    final user = await _service.register(
      name: name,
      email: email.value,
      password: password.value,
      passwordConfirmation: passwordConfirmation.value,
      phone: phone,
      farmName: farmName,
      location: location,
    );
    return UserMapper.toEntity(user);
  }

  @override
  Future<void> logout() async {
    await _service.logout();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final user = await _service.getCurrentUser();
    return UserMapper.toEntity(user);
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _tokenManager.isAuthenticated();
  }
}
