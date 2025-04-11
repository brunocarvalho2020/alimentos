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
  String userType = 'cliente'; // cliente ou dono

  bool isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      try {
        // Tentativa de criação segura
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: email.trim(),
              password: password.trim(),
            );

        // Salva os dados no Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'name': name.trim(),
              'email': email.trim(),
              'userType': userType, // por exemplo: 'cliente' ou 'dono'
              'createdAt': Timestamp.now(),
            });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Conta criada com sucesso!')));
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
      appBar: AppBar(title: Text('Registro')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Nome'),
                        onChanged: (value) => name = value,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Digite seu nome' : null,
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'E-mail'),
                        onChanged: (value) => email = value,
                        validator:
                            (value) =>
                                value!.contains('@')
                                    ? null
                                    : 'Digite um e-mail válido',
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Senha'),
                        obscureText: true,
                        onChanged: (value) => password = value,
                        validator:
                            (value) =>
                                value!.length < 6 ? 'Senha muito curta' : null,
                      ),
                      SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: userType,
                        items: [
                          DropdownMenuItem(
                            value: 'cliente',
                            child: Text('Cliente'),
                          ),
                          DropdownMenuItem(
                            value: 'dono',
                            child: Text('Dono da Doceria'),
                          ),
                        ],
                        onChanged: (value) => setState(() => userType = value!),
                        decoration: InputDecoration(
                          labelText: 'Tipo de usuário',
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _register,
                        child: Text('Registrar'),
                      ),
                      SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(
                            context,
                          ); // Volta para a tela anterior (login)
                        },
                        child: Text('Voltar para login'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
