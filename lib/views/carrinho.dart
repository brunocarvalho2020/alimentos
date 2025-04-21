import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../controllers/carrinho_controller.dart';

class CarrinhoScreen extends StatefulWidget {
  final CarrinhoController controller;

  const CarrinhoScreen({super.key, required this.controller});

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  Future<void> _handleFinalizarCompra() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      final shouldContinue = await Navigator.pushNamed(context, '/login');
      if (shouldContinue != true) return;
    }

    final itens = widget.controller.itens;

    if (itens.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Seu carrinho está vazio.')));
      return;
    }

    bool algumaCompraFeita = false;
    for (var item in itens) {
      final sucesso = await widget.controller.finalizarCompra(
        user!.uid,
        item.idDono,
      );
      if (sucesso) {
        algumaCompraFeita = true;
      }
    }

    if (algumaCompraFeita) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Compras finalizadas com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Nenhuma compra foi realizada.')));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final itens = widget.controller.itens;
    final isEmpty = widget.controller.estaVazio;

    return Scaffold(
      appBar: AppBar(title: Text('Carrinho de Compras'), centerTitle: true),
      body:
          isEmpty
              ? Center(
                child: Text(
                  'Seu carrinho está vazio.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              )
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: itens.length,
                      itemBuilder: (context, index) {
                        final item = itens[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 6,
                          ),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.nome} x${item.quantidade}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'R\$ ${item.preco.toStringAsFixed(2)} cada',
                                        ),
                                        Text(
                                          'Subtotal: R\$ ${(item.preco * item.quantidade).toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            widget.controller.decrementar(
                                              index,
                                            );
                                          });
                                        },
                                      ),
                                      Text('${item.quantidade}'),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color: Colors.green,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            widget.controller.incrementar(
                                              index,
                                            );
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Total: R\$ ${widget.controller.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: Icon(Icons.shopping_cart_checkout),
                          label: Text(
                            'Finalizar Compra',
                            style: TextStyle(fontSize: 16),
                          ),
                          onPressed: () {
                            _handleFinalizarCompra();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
