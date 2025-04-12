import '../models/carrinho_model.dart';

class CarrinhoController {
  final List<CarrinhoItem> _itens = [];

  List<CarrinhoItem> get itens => _itens;
  double get total => _itens.fold(0, (soma, item) => soma + item.preco);
  bool get estaVazio => _itens.isEmpty;

  void adicionar(CarrinhoItem item) => _itens.add(item);
  void remover(int index) => _itens.removeAt(index);
  void limpar() => _itens.clear();

  /// Finaliza a compra e retorna true se foi finalizada com sucesso.
  bool finalizarCompra() {
    if (_itens.isEmpty) return false;
    _itens.clear();
    return true;
  }
}
