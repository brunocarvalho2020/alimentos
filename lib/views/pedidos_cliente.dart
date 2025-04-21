import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teste_app/models/pedidos_model.dart';

class PedidoClienteScreen extends StatelessWidget {
  const PedidoClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String usuarioId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pedidos')),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('pedidos')
                .where('usuarioId', isEqualTo: usuarioId)
                .orderBy('data', descending: true)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar pedidos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pedidos =
              snapshot.data!.docs
                  .map(
                    (doc) => PedidoModel.fromFirestore(
                      doc.data() as Map<String, dynamic>,
                      doc.id,
                    ),
                  )
                  .toList();

          final pedidosPendentes = pedidos.where((p) => !p.entregue).toList();
          final pedidosEntregues = pedidos.where((p) => p.entregue).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pedidosPendentes.isNotEmpty) ...[
                const Text(
                  'Pedidos Pendentes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...pedidosPendentes.map((pedido) => _buildPedidoTile(pedido)),
                const SizedBox(height: 20),
              ],
              const Text(
                'Histórico de Pedidos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...pedidosEntregues.map((pedido) => _buildPedidoTile(pedido)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPedidoTile(PedidoModel pedido) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(pedido.nome),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantidade: ${pedido.quantidade}'),
            Text('Preço unitário: R\$ ${pedido.preco.toStringAsFixed(2)}'),
            Text('Total: R\$ ${pedido.total.toStringAsFixed(2)}'),
            Text('Data: ${_formatarData(pedido.data)}'),
            Text(
              pedido.entregue ? 'Status: Entregue' : 'Status: Pendente',
              style: TextStyle(
                color: pedido.entregue ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year} - '
        '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}
