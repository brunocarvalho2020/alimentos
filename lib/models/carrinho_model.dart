class CarrinhoItem {
  final String nome;
  final double preco;

  CarrinhoItem({required this.nome, required this.preco});

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'preco': preco};
  }

  factory CarrinhoItem.fromMap(Map<String, dynamic> map) {
    return CarrinhoItem(
      nome: map['nome'] ?? '',
      preco: (map['preco'] ?? 0).toDouble(),
    );
  }
}
