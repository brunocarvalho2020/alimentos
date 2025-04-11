import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/endereco_model.dart';

class EnderecoController {
  final _firestore = FirebaseFirestore.instance;

  Future<void> adicionarEndereco(Endereco endereco) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("Usuário não autenticado");

    await _firestore.collection('enderecos').add(endereco.toMap(userId));
  }

  Future<List<Endereco>> buscarEnderecos() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("Usuário não autenticado");

    final snapshot =
        await _firestore
            .collection('enderecos')
            .where('usuarioId', isEqualTo: userId)
            .get();

    return snapshot.docs.map((doc) {
      return Endereco.fromMap(doc.id, doc.data());
    }).toList();
  }
}
