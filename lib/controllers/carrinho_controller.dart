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
      // Força a quantidade a iniciar com 1
      _itens.add(
        CarrinhoItem(
          nome: novoItem.nome,
          preco: novoItem.preco,
          //imagem: novoItem.imagem,
          quantidade: 1,
        ),
      );
    }
  }

  void remover(int index) => _itens.removeAt(index);
  void limpar() => _itens.clear();

  bool finalizarCompra() {
    if (_itens.isEmpty) return false;
    _itens.clear();
    return true;
  }
}
