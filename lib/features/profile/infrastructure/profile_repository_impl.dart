import 'package:injectable/injectable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pamoja_twalima/data/services/auth_service.dart';
import 'package:pamoja_twalima/data/network/api_service.dart';
import 'package:pamoja_twalima/features/auth/domain/repositories/auth_repository.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/entities/user_profile_entity.dart';
import '../domain/entities/audit_event_entity.dart';
import '../domain/value_objects/phone_number.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final AuthService _authService;
  final AuthRepository _authRepository;
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ProfileRepositoryImpl(this._authService, this._authRepository, this._apiService);

  @override
  Future<UserProfileEntity> getProfile() async {
    try {
      final user = await _authService.getCurrentUser();
      return UserProfileEntity(
        id: user.id?.toString(),
        name: user.name,
        phone: user.phone == null ? null : PhoneNumber(user.phone!),
        location: user.location,
      );
    } catch (_) {
      final name = await _storage.read(key: 'user_name');
      return UserProfileEntity(
        id: await _storage.read(key: 'user_id'),
        name: name ?? 'Farmer',
        phone: null,
        location: null,
      );
    }
  }

  @override
  Future<void> logout() async {
    await _authRepository.logout();
  }

  @override
  Future<List<AuditEventEntity>> getAuditEvents({int limit = 100}) async {
    final response = await _apiService.get(
      '/audit-events',
      queryParameters: {'limit': limit},
    );

    final raw = List<dynamic>.from(response.data as List);
    return raw.map((e) {
      final item = Map<String, dynamic>.from(e as Map);
      final occurredAtRaw = item['occurred_at']?.toString();
      return AuditEventEntity(
        id: item['id']?.toString() ?? '',
        eventType: item['event_type']?.toString() ?? 'unknown',
        entityType: item['entity_type']?.toString() ?? 'unknown',
        entityId: item['entity_id']?.toString(),
        metadata: item['metadata'] is Map
            ? Map<String, dynamic>.from(item['metadata'] as Map)
            : <String, dynamic>{},
        occurredAt: DateTime.tryParse(occurredAtRaw ?? '') ?? DateTime.now(),
      );
    }).toList();
  }
}
