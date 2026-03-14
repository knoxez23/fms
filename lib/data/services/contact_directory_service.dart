import 'package:injectable/injectable.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';

enum ContactType { supplier, customer, staffMember }

@lazySingleton
class ContactDirectoryService {
  ContactDirectoryService(this._api);

  final ApiService _api;

  String _path(ContactType type) {
    switch (type) {
      case ContactType.supplier:
        return '/suppliers';
      case ContactType.customer:
        return '/customers';
      case ContactType.staffMember:
        return '/staff-members';
    }
  }

  Future<List<Map<String, dynamic>>> list(ContactType type) async {
    final response = await _api.get(_path(type));
    final data = response.data;
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((item) => item.map(
              (key, value) => MapEntry(key.toString(), value),
            ))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> create(
    ContactType type,
    Map<String, dynamic> payload,
  ) async {
    final response = await _api.post(_path(type), data: payload);
    return _asMap(response.data);
  }

  Future<Map<String, dynamic>> update(
    ContactType type, {
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    final response = await _api.put('${_path(type)}/$id', data: payload);
    return _asMap(response.data);
  }

  Future<void> delete(ContactType type, {required int id}) async {
    await _api.delete('${_path(type)}/$id');
  }

  Future<Map<String, dynamic>> farmContext() async {
    final response = await _api.get('/farm-context');
    return _asMap(response.data);
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, v) => MapEntry(key.toString(), v));
    }
    return <String, dynamic>{};
  }
}
