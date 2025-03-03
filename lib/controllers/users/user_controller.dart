import 'package:stivy/services/users/user_service.dart';
import 'package:stivy/models/user/user_model.dart';

class UserController {
  final UserService _userService = UserService();

  Future<List<User>> getUsers() async {
    return await _userService.fetchUsers();
  }
}