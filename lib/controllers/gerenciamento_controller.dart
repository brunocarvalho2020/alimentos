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

  /// Obtém os pedidos do usuário logado (como dono do estabelecimento)
  Stream<QuerySnapshot> obterPedidos(bool entregue) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado");
    }

    return _firestore
        .collection('pedidos')
        .where('idDono', isEqualTo: user.uid)
        .where('entregue', isEqualTo: entregue)
        .orderBy('data', descending: true)
        .snapshots();
  }

  /// Marca um pedido como entregue
  Future<void> marcarComoEntregue(String pedidoId) async {
    await _firestore.collection('pedidos').doc(pedidoId).update({
      'entregue': true,
    });
  }

  /// Obtém o total de pedidos por status
  Future<Map<String, int>> obterTotaisPedidos() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado");
    }

    final pendentes =
        await _firestore
            .collection('pedidos')
            .where('idDono', isEqualTo: user.uid)
            .where('entregue', isEqualTo: false)
            .count()
            .get();

    final finalizados =
        await _firestore
            .collection('pedidos')
            .where('idDono', isEqualTo: user.uid)
            .where('entregue', isEqualTo: true)
            .count()
            .get();

    return {
      'pendentes': pendentes.count ?? 0,
      'finalizados': finalizados.count ?? 0,
    };
  }

  /// Obtém o total de vendas finalizadas
  Future<double> obterTotalVendas({int dias = 30}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("Usuário não autenticado");
    }

    final dataLimite = DateTime.now().subtract(Duration(days: dias));

    final querySnapshot =
        await _firestore
            .collection('pedidos')
            .where('idDono', isEqualTo: user.uid)
            .where('entregue', isEqualTo: true)
            .where(
              'data',
              isGreaterThanOrEqualTo: Timestamp.fromDate(dataLimite),
            )
            .get();

    double total = 0;
    for (var doc in querySnapshot.docs) {
      total += (doc.data()['total'] ?? 0).toDouble();
    }

    return total;
  }
}
