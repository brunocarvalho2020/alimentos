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

  Future<void> atualizarEndereco(String enderecoId, Endereco endereco) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("Usuário não autenticado");

    final enderecoRef = _firestore.collection('enderecos').doc(enderecoId);

    // Verifica se o endereço pertence ao usuário
    final enderecoDoc = await enderecoRef.get();
    if (!enderecoDoc.exists) {
      throw Exception("Endereço não encontrado");
    }

    // Verifica se o usuário é o dono do endereço
    if (enderecoDoc.data()?['usuarioId'] != userId) {
      throw Exception("Este endereço não pertence ao usuário");
    }

    // Atualiza o endereço no Firestore
    await enderecoRef.update(endereco.toMap(userId));
  }

  Future<void> removerEndereco(String enderecoId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception("Usuário não autenticado");

    final enderecoRef = _firestore.collection('enderecos').doc(enderecoId);

    // Verifica se o endereço existe
    final enderecoDoc = await enderecoRef.get();
    if (!enderecoDoc.exists) {
      throw Exception("Endereço não encontrado");
    }

    // Verifica se o endereço pertence ao usuário
    if (enderecoDoc.data()?['usuarioId'] != userId) {
      throw Exception("Este endereço não pertence ao usuário");
    }

    // Remove o endereço do Firestore
    await enderecoRef.delete();
  }
}
