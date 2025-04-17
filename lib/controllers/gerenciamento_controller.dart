import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GerenciamentoController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> carregarDadosUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> cadastrarProduto({
    required String nome,
    required double preco,
    required String descricao,
    required int quantidade,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Usuário não autenticado");

    final docUsuario = await _firestore.collection('users').doc(user.uid).get();
    final nomeLoja = docUsuario.data()?['nomeEmpresa'] ?? 'Loja Desconhecida';

    await _firestore.collection('produtos').add({
      'nome': nome,
      'preco': preco,
      'descricao': descricao,
      'quantidade': quantidade,
      'userId': user.uid,
      'nomeEstabelecimento': nomeLoja,
      'criadoEm': Timestamp.now(),
    });
  }
}
