import 'package:injectable/injectable.dart';
import '../domain/repositories/repositories.dart';
import '../domain/entities/user_entity.dart';
import '../domain/value_objects/value_objects.dart';

@lazySingleton
class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);

  Future<UserEntity> execute(String email, String password) async {
    final emailVo = EmailAddress(email);
    final passwordVo = Password(password);
    return await repository.login(emailVo, passwordVo);
  }
}

@lazySingleton
class Register {
  final AuthRepository repository;
  Register(this.repository);

  Future<UserEntity> execute({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? farmName,
    String? location,
  }) async {
    final emailVo = EmailAddress(email);
    final passwordVo = Password(password);
    final passwordConfirmVo = Password(passwordConfirmation);
    return await repository.register(
      name: name,
      email: emailVo,
      password: passwordVo,
      passwordConfirmation: passwordConfirmVo,
      phone: phone,
      farmName: farmName,
      location: location,
    );
  }
}

@lazySingleton
class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);

  Future<void> execute() async => await repository.logout();
}

@lazySingleton
class GetCurrentUser {
  final AuthRepository repository;
  GetCurrentUser(this.repository);

  Future<UserEntity> execute() async => await repository.getCurrentUser();
}

@lazySingleton
class CheckAuthStatusUseCase {
  final AuthRepository repository;
  CheckAuthStatusUseCase(this.repository);

  Future<bool> execute() async => await repository.isAuthenticated();
}
