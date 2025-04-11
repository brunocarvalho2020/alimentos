import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo!'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/',
              ); // volta para o login
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('Você está logado!', style: TextStyle(fontSize: 22)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Aqui você pode navegar para outra view, ex: tela de clientes
              },
              child: Text('Ir para outra tela'),
            ),
          ],
        ),
      ),
    );
  }
}
