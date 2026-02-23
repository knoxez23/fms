import '../../domain/entities/user_entity.dart';
import '../../domain/value_objects/value_objects.dart';
import '../../../../data/models/user.dart';

class UserMapper {
  static UserEntity toEntity(User user) {
    return UserEntity(
      id: user.id,
      name: user.name,
      email: EmailAddress(user.email),
      phone: user.phone,
      farmName: user.farmName,
      location: user.location,
    );
  }
}
