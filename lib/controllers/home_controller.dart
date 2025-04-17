import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController {
  User? currentUser;
  String? userType;
  String? userName;
  bool isLoading = true;

  Future<void> loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    currentUser = user;

    if (currentUser != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser!.uid)
              .get();

      userType = doc.data()?['userType'] ?? 'cliente';
      userName = doc.data()?['name'] ?? 'Usuário';
    }

    isLoading = false;
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    currentUser = null;
    userType = null;
    userName = null;
  }

  Stream<QuerySnapshot> getProdutosStream() {
    return FirebaseFirestore.instance.collection('produtos').snapshots();
  }

  Future<Map<String, List<Map<String, dynamic>>>>
  getProdutosAgrupadosPorLoja() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('produtos').get();

    final Map<String, List<Map<String, dynamic>>> agrupado = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final empresa = data['nomeEstabelecimento'] ?? 'Loja Desconhecida';
      agrupado.putIfAbsent(empresa, () => []).add(data);
    }

    return agrupado;
  }
}
