import '../domain/repositories/auth_repository.dart';
import 'package:pamoja_twalima/data/services/auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _service;

  AuthRepositoryImpl({AuthService? service}) : _service = service ?? AuthService();

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _service.login(email, password);
  }

  @override
  Future<Map<String, dynamic>> register({required String name, required String email, required String password, String? phone, String? farmName, String? location}) async {
    return await _service.register(name: name, email: email, password: password, phone: phone, farmName: farmName, location: location);
  }

  @override
  Future<void> logout() async {
    await _service.logout();
  }
}
