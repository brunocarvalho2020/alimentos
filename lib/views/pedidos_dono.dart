import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({Key? key}) : super(key: key);

  @override
  _PedidosScreenState createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final currentUser = FirebaseAuth.instance.currentUser;
  final Map<String, String> _clientesCache =
      {}; // Cache para armazenar nomes de clientes

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Função para buscar o nome do cliente
  Future<String> _getClienteName(String clienteId) async {
    // Verifica se o nome já está em cache
    if (_clientesCache.containsKey(clienteId)) {
      return _clientesCache[clienteId]!;
    }

    try {
      // Busca o documento do usuário no Firestore
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(clienteId)
              .get();

      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        final nome = userData['name'] ?? 'Cliente sem nome';

        // Salva no cache para uso futuro
        _clientesCache[clienteId] = nome;
        return nome;
      } else {
        return 'Cliente não encontrado';
      }
    } catch (e) {
      print('Erro ao buscar cliente: $e');
      return 'Erro ao buscar cliente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciamento de Pedidos'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Pendentes'), Tab(text: 'Finalizados')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Lista de pedidos pendentes
          _buildPedidosList(false),
          // Lista de pedidos finalizados
          _buildPedidosList(true),
        ],
      ),
    );
  }

  Widget _buildPedidosList(bool entregue) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('pedidos')
              .where('idDono', isEqualTo: currentUser?.uid)
              .where('entregue', isEqualTo: entregue)
              .orderBy('data', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar pedidos: ${snapshot.error}'),
          );
        }

        final pedidos = snapshot.data?.docs ?? [];

        if (pedidos.isEmpty) {
          return Center(
            child: Text(
              entregue ? 'Nenhum pedido finalizado' : 'Nenhum pedido pendente',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: pedidos.length,
          itemBuilder: (context, index) {
            final pedido = pedidos[index].data() as Map<String, dynamic>;
            final pedidoId = pedidos[index].id;
            final data = (pedido['data'] as Timestamp).toDate();
            final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(data);
            final clienteId = pedido['usuarioId'] ?? '';

            return FutureBuilder<String>(
              future: _getClienteName(clienteId),
              builder: (context, clienteSnapshot) {
                final clienteNome = clienteSnapshot.data ?? 'Carregando...';

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                pedido['nome'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    entregue
                                        ? Colors.green[100]
                                        : Colors.orange[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                entregue ? 'Finalizado' : 'Pendente',
                                style: TextStyle(
                                  color:
                                      entregue
                                          ? Colors.green[800]
                                          : Colors.orange[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Cliente: $clienteNome',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quantidade: ${pedido['quantidade']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'R\$ ${pedido['total'].toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        if (!entregue)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed:
                                      () => _marcarComoEntregue(pedidoId),
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Marcar como Entregue'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _marcarComoEntregue(String pedidoId) async {
    try {
      await FirebaseFirestore.instance
          .collection('pedidos')
          .doc(pedidoId)
          .update({'entregue': true});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido marcado como entregue com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar pedido: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
