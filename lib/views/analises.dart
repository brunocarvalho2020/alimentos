import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EstatisticasScreen extends StatelessWidget {
  const EstatisticasScreen({super.key});

  Future<Map<String, dynamic>?> buscarAnalise() async {
    final doc =
        await FirebaseFirestore.instance
            .collection('analises')
            .doc('ultima')
            .get();

    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Análises de Dados')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: buscarAnalise(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data == null)
            return Center(child: Text('Nenhuma análise encontrada.'));

          final dados = snapshot.data!;
          final produtoTop = dados['produto_mais_vendido'] ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  title: Text('Total de pedidos'),
                  trailing: Text('${dados['total_pedidos']}'),
                ),
              ),
              Card(
                child: ListTile(
                  title: Text('Valor total vendido'),
                  trailing: Text(
                    'R\$ ${dados['total_vendas'].toStringAsFixed(2)}',
                  ),
                ),
              ),
              if (produtoTop.isNotEmpty)
                Card(
                  child: ListTile(
                    title: Text('Produto mais vendido'),
                    subtitle: Text(produtoTop['nome'] ?? '---'),
                    trailing: Text('${produtoTop['quantidade']} vendas'),
                  ),
                ),
              if (dados['gerado_em'] != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Atualizado em: ${DateTime.parse(dados['gerado_em']).toLocal().toString().split('.')[0]}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
