import 'package:cloud_firestore/cloud_firestore.dart';

class MinhaContaController {
  Future<Map<String, dynamic>?> carregarUsuarioDados(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data();
    } catch (e) {
      print('Erro ao carregar dados do usuário: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> carregarEnderecos(String uid) async {
    try {
      final enderecoSnapshot =
          await FirebaseFirestore.instance
              .collection('enderecos')
              .where("usuarioId", isEqualTo: uid)
              .orderBy('cep', descending: true)
              .get();

      return enderecoSnapshot.docs.map((e) {
        var endereco = e.data();
        endereco['id'] = e.id;
        return endereco;
      }).toList();
    } catch (e) {
      print('Erro ao carregar endereços: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> carregarPedidos(String uid) async {
    try {
      final pedidosSnapshot =
          await FirebaseFirestore.instance
              .collection('pedidos')
              .where('userId', isEqualTo: uid)
              .orderBy('data', descending: true)
              .get();

      return pedidosSnapshot.docs.map((p) => p.data()).toList();
    } catch (e) {
      print('Erro ao carregar pedidos: $e');
      return [];
    }
  }

  Future<void> removerEndereco(String enderecoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('enderecos')
          .doc(enderecoId)
          .delete();
    } catch (e) {
      print('Erro ao remover endereço: $e');
    }
  }
}
