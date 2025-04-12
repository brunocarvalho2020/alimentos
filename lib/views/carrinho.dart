import 'package:flutter/material.dart';
import '../controllers/carrinho_controller.dart';

class CarrinhoScreen extends StatefulWidget {
  final CarrinhoController controller;

  const CarrinhoScreen({super.key, required this.controller});

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
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
                          title: Text(item.nome),
                          subtitle: Text(
                            'R\$ ${item.preco.toStringAsFixed(2)}',
                          ),
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
                          onPressed: () {
                            setState(() {
                              widget.controller.limpar();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Compra finalizada!')),
                            );
                            Navigator.pop(context);
                          },
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
