import 'package:flutter/widgets.dart';
import 'package:need_mobile_app/models/app_user.dart';
import 'package:need_mobile_app/services/user_service.dart';
import 'package:need_mobile_app/utils/api_exception.dart';

class UserProvider extends ChangeNotifier{
  final UserService _service = UserService();

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      _currentUser = await _service.getCurrentUser();
      _errorMessage = null;
    } on ApiException catch(e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    _setLoading(true);
    try {
      _currentUser = await _service.updateCurrentUser(firstName: firstName, lastName: lastName);
      _errorMessage = null;
      return true;
    } on ApiException catch(e) {
      _errorMessage = e.message;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}