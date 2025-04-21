import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/carrinho_model.dart';

class CarrinhoController {
  final List<CarrinhoItem> _itens = [];

  List<CarrinhoItem> get itens => _itens;

  double get total =>
      _itens.fold(0, (soma, item) => soma + (item.preco * item.quantidade));

  bool get estaVazio => _itens.isEmpty;

  void adicionar(CarrinhoItem novoItem) {
    final existente = _itens.indexWhere((item) => item.nome == novoItem.nome);
    if (existente != -1) {
      _itens[existente].quantidade += 1;
    } else {
      _itens.add(
        CarrinhoItem(nome: novoItem.nome, preco: novoItem.preco, quantidade: 1),
      );
    }
  }

  void incrementar(int index) {
    _itens[index].quantidade++;
  }

  void decrementar(int index) {
    if (_itens[index].quantidade > 1) {
      _itens[index].quantidade--;
    } else {
      remover(index);
    }
  }

  void remover(int index) => _itens.removeAt(index);

  void limpar() => _itens.clear();

  /// FINALIZA COMPRA E SALVA NO FIRESTORE
  Future<bool> finalizarCompra(String usuarioId) async {
    if (_itens.isEmpty) return false;

    try {
      final pedido = {
        'usuarioId': usuarioId,
        'itens': _itens.map((item) => item.toMap()).toList(),
        'total': total,
        'data': Timestamp.now(),
        'entregue': false, // campo que você pediu
      };

      await FirebaseFirestore.instance.collection('pedidos').add(pedido);
      _itens.clear();
      return true;
    } catch (e) {
      print('Erro ao finalizar pedido: $e');
      return false;
    }
  }
}
