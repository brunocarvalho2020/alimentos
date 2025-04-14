import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teste_app/views/adicionar_endereco.dart';
import 'package:teste_app/views/manage_store.dart';
import 'package:teste_app/views/minha_conta.dart';
import 'views/login.dart';
import 'views/home.dart'; // crie uma tela qualquer pra teste
import 'firebase_options.dart';
import 'views/analises.dart';

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
        '/minha-conta': (context) => MinhaContaView(),
        '/home': (_) => HomeView(),
        '/gerenciar-estabelecimento': (context) => ManageStoreScreen(),
        '/adicionar-endereco': (context) => AdicionarEnderecoView(),
        '/estatisticas': (_) => EstatisticasScreen(),
      },
    ),
  );
}
