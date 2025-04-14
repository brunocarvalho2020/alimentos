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

    final sucesso = widget.controller.finalizarCompra();

    if (sucesso) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Compra finalizada com sucesso!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Seu carrinho está vazio.')));
    }

    setState(() {}); // para atualizar a interface depois de limpar
  }

  @override
  Widget build(BuildContext context) {
    final itens = widget.controller.itens;

    return Scaffold(
      appBar: AppBar(title: Text('Carrinho de Compras')),
      body:
          widget.controller.estaVazio
              ? Center(child: Text('Seu carrinho está vazio.'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: itens.length,
                      itemBuilder: (context, index) {
                        final item = itens[index];
                        return ListTile(
                          title: Text('${item.nome} x${item.quantidade}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('R\$ ${item.preco.toStringAsFixed(2)} cada'),
                              Text(
                                'Subtotal: R\$ ${(item.preco * item.quantidade).toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                widget.controller.remover(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Total: R\$ ${widget.controller.total.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _handleFinalizarCompra,
                          child: Text('Finalizar Compra'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
