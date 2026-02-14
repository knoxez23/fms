import '../entities/user_profile_entity.dart';
import '../entities/audit_event_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity> getProfile();
  Future<List<AuditEventEntity>> getAuditEvents({int limit = 100});
  Future<void> logout();
}
