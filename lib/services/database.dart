<<<<<<< HEAD
=======
import 'dart:ffi';
>>>>>>> 372ca4e5ff88cd326ff17deb96806e93d2feffb5
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> adicionaProduto(
  String nome,
  double preco,
  String descricao,
  int quantidade,
) async {
  await FirebaseFirestore.instance.collection('produtos').add({
    'nome': nome,
    'preco': preco,
    'descricao': descricao,
    'quantidade': quantidade,
    'criadoEm': Timestamp.now(),
  });
}
