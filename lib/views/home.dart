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

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
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
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/login');
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
                // Navegar para outra tela
              },
              child: Text('Ir para outra tela'),
            ),
            SizedBox(height: 20),

            // Mostra o botão se for dono
            if (userType == 'dono')
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/gerenciar-estabelecimento');
                },
                child: Text('Gerenciar meu estabelecimento'),
              ),
          ],
        ),
      ),
    );
  }
}
