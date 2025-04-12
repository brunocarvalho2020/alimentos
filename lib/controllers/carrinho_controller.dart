import '../models/carrinho_model.dart';

class CarrinhoController {
  final List<CarrinhoItem> _itens = [];

  List<CarrinhoItem> get itens => _itens;

  double get total => _itens.fold(0, (soma, item) => soma + (item.preco));

  void adicionar(CarrinhoItem item) {
    _itens.add(item);
  }

  void remover(int index) {
    _itens.removeAt(index);
  }

  void limpar() {
    _itens.clear();
  }

  bool get estaVazio => _itens.isEmpty;
}
