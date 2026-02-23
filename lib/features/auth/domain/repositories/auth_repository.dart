import '../entities/user_entity.dart';
import '../value_objects/value_objects.dart';

abstract class AuthRepository {
  Future<UserEntity> login(EmailAddress email, Password password);
  Future<UserEntity> register({
    required String name,
    required EmailAddress email,
    required Password password,
    required Password passwordConfirmation,
    String? phone,
    String? farmName,
    String? location,
  });
  Future<void> logout();
  Future<UserEntity> getCurrentUser();
  Future<bool> isAuthenticated();
}
