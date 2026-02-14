import 'package:injectable/injectable.dart';
import '../domain/repositories/repositories.dart';
import '../domain/entities/user_profile_entity.dart';
import '../domain/entities/audit_event_entity.dart';

@lazySingleton
class GetProfile {
  final ProfileRepository repository;
  GetProfile(this.repository);

  Future<UserProfileEntity> execute() async => await repository.getProfile();
}

@lazySingleton
class Logout {
  final ProfileRepository repository;
  Logout(this.repository);

  Future<void> execute() async => await repository.logout();
}

@lazySingleton
class GetAuditEvents {
  final ProfileRepository repository;
  GetAuditEvents(this.repository);

  Future<List<AuditEventEntity>> execute({int limit = 100}) async =>
      await repository.getAuditEvents(limit: limit);
}
