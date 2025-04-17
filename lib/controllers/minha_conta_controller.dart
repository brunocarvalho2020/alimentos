import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MinhaContaController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<Map<String, dynamic>?> carregarUserData() async {
    final doc =
        await _firestore.collection('users').doc(currentUser!.uid).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> carregarEnderecos() async {
    final snapshot =
        await _firestore
            .collection('enderecos')
            .where('usuarioId', isEqualTo: currentUser!.uid)
            .orderBy('cep', descending: true)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> carregarPedidos() async {
    final snapshot =
        await _firestore
            .collection('pedidos')
            .where('userId', isEqualTo: currentUser!.uid)
            .orderBy('data', descending: true)
            .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
