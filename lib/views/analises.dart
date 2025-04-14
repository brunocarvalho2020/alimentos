import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EstatisticasScreen extends StatefulWidget {
  const EstatisticasScreen({super.key});

  @override
  State<EstatisticasScreen> createState() => _EstatisticasScreenState();
}

class _EstatisticasScreenState extends State<EstatisticasScreen> {
  int totalPedidos = 0;
  double totalVendido = 0.0;
  Map<String, int> produtosVendidos = {};

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('pedidos').get();

    int pedidos = snapshot.docs.length;
    double vendido = 0.0;
    Map<String, int> contagemProdutos = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      vendido += (data['total'] ?? 0).toDouble();

      if (data['itens'] != null) {
        for (var item in List.from(data['itens'])) {
          final nome = item['nome'] ?? 'Desconhecido';
          final qtd = (item['quantidade'] ?? 1);
          final qtdInt = (qtd is int) ? qtd : (qtd as num).toInt();
          contagemProdutos[nome] = (contagemProdutos[nome] ?? 0) + qtdInt;
        }
      }
    }

    setState(() {
      totalPedidos = pedidos;
      totalVendido = vendido;
      produtosVendidos = contagemProdutos;
    });
  }

  @override
  Widget build(BuildContext context) {
    final produtoMaisVendido =
        produtosVendidos.entries.isEmpty
            ? null
            : produtosVendidos.entries.reduce(
              (a, b) => a.value > b.value ? a : b,
            );

    return Scaffold(
      appBar: AppBar(title: Text('Análises de Dados')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            totalPedidos == 0
                ? Center(child: Text('Nenhum pedido encontrado.'))
                : ListView(
                  children: [
                    Card(
                      child: ListTile(
                        title: Text('Total de pedidos'),
                        trailing: Text('$totalPedidos'),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        title: Text('Valor total vendido'),
                        trailing: Text(
                          'R\$ ${totalVendido.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                    if (produtoMaisVendido != null)
                      Card(
                        child: ListTile(
                          title: Text('Produto mais vendido'),
                          subtitle: Text(produtoMaisVendido.key),
                          trailing: Text('${produtoMaisVendido.value} vendas'),
                        ),
                      ),
                  ],
                ),
      ),
    );
  }
}
