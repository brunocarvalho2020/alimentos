class CarrinhoItem {
  final String nome;
  final double preco;
  final String idDono;
  int quantidade;

  CarrinhoItem({
    required this.nome,
    required this.preco,
    required this.idDono,
    this.quantidade = 1,
  });

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'preco': preco, 'quantidade': quantidade};
  }

  factory CarrinhoItem.fromMap(Map<String, dynamic> map) {
    return CarrinhoItem(
      nome: map['nome'] ?? '',
      preco: (map['preco'] ?? 0).toDouble(),
      quantidade: map['quantidade'] ?? 1,
      idDono: map['idDono'] ?? '',
    );
  }
}
