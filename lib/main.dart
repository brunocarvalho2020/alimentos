import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teste_app/views/endereco.dart';
import 'package:teste_app/views/gerenciamento.dart';
import 'package:teste_app/views/minha_conta.dart';
import 'package:teste_app/views/pedidos_cliente.dart';
import 'views/login.dart';
import 'views/home.dart';
import 'firebase_options.dart';
import 'views/analises.dart';
import 'views/pedidos_dono.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.teal[700], // cor de fundo do AppBar
          foregroundColor: Colors.white, // cor do texto e ícones
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        scaffoldBackgroundColor:
            Colors.white, // ou defina outra cor de fundo global
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => LoginView(),
        '/minha-conta': (context) => MinhaContaView(),
        '/home': (_) => HomeView(),
        '/gerenciar-estabelecimento': (context) => ManageStoreScreen(),
        '/pedido-cliente': (context) => const PedidoClienteScreen(),
        '/adicionar-endereco': (context) => AdicionarEnderecoView(),
        '/estatisticas': (_) => EstatisticasScreen(),
        '/pedidos': (context) => const PedidosScreen(),
      },
    ),
  );
}
