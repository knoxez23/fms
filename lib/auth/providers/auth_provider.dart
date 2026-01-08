import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/services/auth_service.dart';
import '../auth_state.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _authenticated = false;
  bool get isAuthenticated => _authenticated;

  String? _token;
  String? get token => _token;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _token = await _storage.read(key: 'auth_token');
    _authenticated = _token != null && _token!.isNotEmpty;
    AuthState.isAuthenticated.value = _authenticated;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _authService.login(email, password);
    _token = res['token'];
    _authenticated = _token != null;
    AuthState.isAuthenticated.value = _authenticated;
    notifyListeners();
    return res;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final res = await _authService.register(
      name: data['name'],
      email: data['email'],
      password: data['password'],
      phone: data['phone'],
      farmName: data['farm_name'],
      location: data['location'],
    );
    _token = res['token'];
    _authenticated = _token != null;
    AuthState.isAuthenticated.value = _authenticated;
    notifyListeners();
    return res;
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _authenticated = false;
    AuthState.isAuthenticated.value = false;
    notifyListeners();
  }

  // Called when a 401 occurs elsewhere (ApiService deletes token)
  Future<void> handleUnauthenticated() async {
    _token = await _storage.read(key: 'auth_token');
    _authenticated = _token != null && _token!.isNotEmpty;
    if (!_authenticated) notifyListeners();
  }
}
