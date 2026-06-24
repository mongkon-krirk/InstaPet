import '../../../../core/storage/token_storage.dart';
import '../../domain/models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  AuthRepository(this._service, this._storage);

  final AuthService _service;
  final TokenStorage _storage;

  Future<UserModel> login(String identifier, String password) async {
    final token = await _service.login(identifier, password);
    await _storage.writeToken(token);
    return _service.getCurrentUser();
  }

  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final token = await _service.register(
      username: username,
      email: email,
      password: password,
    );
    await _storage.writeToken(token);
    return _service.getCurrentUser();
  }

  Future<UserModel?> restoreSession() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return null;
    return _service.getCurrentUser();
  }

  Future<void> logout() => _storage.deleteToken();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) =>
      _service.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmation: confirmation,
      );
}
