import '../domain/repositories/repositories.dart';

class SignIn {
  final AuthRepository repository;
  SignIn(this.repository);

  Future<Map<String, dynamic>> execute(String email, String password) async {
    return await repository.login(email, password);
  }
}

class Register {
  final AuthRepository repository;
  Register(this.repository);

  Future<Map<String, dynamic>> execute({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? farmName,
    String? location,
  }) async {
    return await repository.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
      farmName: farmName,
      location: location,
    );
  }
}

class SignOut {
  final AuthRepository repository;
  SignOut(this.repository);

  Future<void> execute() async => await repository.logout();
}
