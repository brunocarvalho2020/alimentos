import 'package:cloud_firestore/cloud_firestore.dart';

void adicionarDados() {
  FirebaseFirestore.instance.collection('usuarios').add({
    'nome': 'Maria',
    'idade': 30,
    'endereco': 'Padre Pinto, Lucilia',
    'wpp': '31999701709',
  });
}
