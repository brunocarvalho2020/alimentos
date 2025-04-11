import 'dart:ffi';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> adicionaProduto(
  String nome,
  String descricao,
  double preco,
  int quantidade,
) async {
  await FirebaseFirestore.instance.collection('produtos').add({
    'nome': nome,
    'descricao': descricao,
    'preco': preco,
    'quantidade': quantidade,
  });
}
