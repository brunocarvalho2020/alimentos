import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? userType;
  bool isLoading = true;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get();

      setState(() {
        userType = doc.data()?['userType'] ?? 'cliente';
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Bem-vindo!'),
        actions: [
          if (currentUser != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                setState(() {
                  currentUser = null;
                  userType = null;
                });
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
            Text(
              currentUser != null
                  ? 'Você está logado!'
                  : 'Bem-vindo! Faça login para acessar mais recursos.',
              style: TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Outra tela opcional
              },
              child: Text('Ir para outra tela'),
            ),
            SizedBox(height: 20),

            // Se for dono, mostra botão para gerenciar o estabelecimento
            if (userType == 'dono')
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/gerenciar-estabelecimento');
                },
                child: Text('Gerenciar meu estabelecimento'),
              ),

            // Se ainda não está logado, mostra botão para login
            if (currentUser == null)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Fazer login'),
              ),
          ],
        ),
      ),
    );
  }
}
