import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageStoreScreen extends StatefulWidget {
  const ManageStoreScreen({super.key});

  @override
  State<ManageStoreScreen> createState() => _ManageStoreScreenState();
}

class _ManageStoreScreenState extends State<ManageStoreScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciar Estabelecimento')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : userData == null
              ? Center(child: Text('Erro ao carregar dados.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome: ${userData!['name']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'E-mail: ${userData!['email']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Tipo: ${userData!['userType']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Criado em: ${userData!['createdAt'].toDate().toString().split('.')[0]}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Aqui depois você pode navegar para a tela de cadastro de produtos
                      },
                      icon: Icon(Icons.add_business),
                      label: Text('Adicionar produto'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Volta para HomeView
                      },
                      child: Text('Voltar'),
                    ),
                  ],
                ),
              ),
    );
  }
}
