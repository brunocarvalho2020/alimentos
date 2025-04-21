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
        CarrinhoItem(
          nome: novoItem.nome,
          preco: novoItem.preco,
          idDono: novoItem.idDono,
          quantidade: 1,
        ),
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

  /// FINALIZA CADA ITEM COMO UM PEDIDO INDIVIDUAL
  Future<bool> finalizarCompra(String usuarioId, String idDono) async {
    if (_itens.isEmpty) return false;

    try {
      for (var item in _itens) {
        final pedido = {
          'idDono': item.idDono,
          'usuarioId': usuarioId,
          'nome': item.nome,
          'preco': item.preco,
          'quantidade': item.quantidade,
          'total': item.preco * item.quantidade,
          'data': Timestamp.now(),
          'entregue': false,
        };

        await FirebaseFirestore.instance.collection('pedidos').add(pedido);
      }

      _itens.clear();
      return true;
    } catch (e) {
      print('Erro ao finalizar pedido: $e');
      return false;
    }
  }
}
