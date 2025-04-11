import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/login.dart';
import 'views/home.dart'; // crie uma tela qualquer pra teste
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginView(),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginView(),
        '/home': (_) => HomeView(), // depois você cria esse widget
      },
    ),
  );
}
