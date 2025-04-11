import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teste_app/views/manage_store.dart';
import 'views/login.dart';
import 'views/home.dart'; // crie uma tela qualquer pra teste
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Firebase inicializado com sucesso!");
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginView(),
        '/home': (_) => HomeView(),
        '/gerenciar-estabelecimento': (context) => ManageStoreScreen(),
      },
    ),
  );
}
