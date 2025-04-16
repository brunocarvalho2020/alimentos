import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String nomeEmpresa = '';
  String userType = 'cliente';

  bool isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'name': name.trim(),
              'email': email.trim(),
              'userType': userType,
              'nomeEmpresa': nomeEmpresa.trim(),
              'createdAt': Timestamp.now(),
            });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conta criada com sucesso!')),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Erro ao registrar.';

        if (e.code == 'email-already-in-use') {
          errorMessage = 'Este e-mail já está em uso.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'E-mail inválido.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'A senha deve ter pelo menos 6 caracteres.';
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro inesperado: $e')));
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Conteúdo
          Center(
            child:
                isLoading
                    ? const CircularProgressIndicator()
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Crie sua conta',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Nome',
                                  ),
                                  onChanged: (value) => name = value,
                                  validator:
                                      (value) =>
                                          value!.isEmpty
                                              ? 'Digite seu nome'
                                              : null,
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'E-mail',
                                  ),
                                  onChanged: (value) => email = value,
                                  validator:
                                      (value) =>
                                          value!.contains('@')
                                              ? null
                                              : 'Digite um e-mail válido',
                                ),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Senha',
                                  ),
                                  obscureText: true,
                                  onChanged: (value) => password = value,
                                  validator:
                                      (value) =>
                                          value!.length < 6
                                              ? 'Senha muito curta'
                                              : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: userType,
                                  decoration: const InputDecoration(
                                    labelText: 'Tipo de usuário',
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'cliente',
                                      child: Text('Cliente'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'dono',
                                      child: Text('Dono da Doceria'),
                                    ),
                                  ],
                                  onChanged:
                                      (value) =>
                                          setState(() => userType = value!),
                                ),
                                if (userType == 'dono')
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Nome da loja',
                                    ),
                                    onChanged: (value) => nomeEmpresa = value,
                                    validator: (value) {
                                      if (userType == 'dono' &&
                                          value!.trim().isEmpty) {
                                        return 'Digite o nome da loja';
                                      }
                                      return null;
                                    },
                                  ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[600],
                                    minimumSize: Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Registrar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Voltar para login'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
