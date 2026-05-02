import 'package:frontend/data/mappers/app_user_mapper.dart';
import 'package:frontend/data/repositories/profile_repository/profile_repository.dart';
import 'package:frontend/data/services/remote/user_api_service.dart';
import 'package:frontend/domain/models/app_user.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final UserApiService _userApiService;

  ProfileRepositoryImpl({
    required UserApiService userApiService,
  }) : _userApiService = userApiService;

  @override
  Future<AppUser> getCurrentUser() async {
    final userDto = await _userApiService.getCurrentUser();
    return AppUserMapper.toDomain(userDto);
  }
}