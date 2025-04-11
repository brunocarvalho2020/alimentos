import '../models/user_model.dart';

class AuthService {
  Future<bool> login(Usuario usuario) async {
    // Simulando uma validação simples (você pode adaptar pra Firebase, SQLite, etc.)
    await Future.delayed(Duration(seconds: 1));
    return usuario.email == 'admin@email.com' && usuario.senha == '1234';
  }
}
