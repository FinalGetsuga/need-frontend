import 'package:need_mobile_app/utils/api_endpoints.dart';

import '../models/app_user.dart';
import '../utils/base_api_service.dart';

class UserService extends BaseApiService {

  Future<AppUser> getCurrentUser() async {
    final response = await get(ApiEndpoints.getCurrentUser);
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AppUser> updateCurrentUser({required String firstName, required String lastName}) async {
    final response = await put(ApiEndpoints.updateCurrentUser, {
      'firstName': firstName,
      'lastName': lastName,
    });
    return AppUser.fromJson(response.data as Map<String, dynamic>);
  }
}