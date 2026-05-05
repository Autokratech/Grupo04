import 'package:frontend/domain/models/app_user.dart';

abstract class ProfileRepository {
  Future<AppUser> getCurrentUser();
}
