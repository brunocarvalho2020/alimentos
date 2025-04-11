import '../models/user_model.dart';
import '../services/auth_user.dart';

class LoginController {
  final AuthService _authService = AuthService();

  Future<bool> autenticar(String email, String senha) async {
    final usuario = Usuario(email: email, senha: senha);
    return await _authService.login(usuario);
  }
}
