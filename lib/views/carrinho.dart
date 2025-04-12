import 'package:flutter/material.dart';

class CarrinhoScreen extends StatefulWidget {
  final List<Map<String, dynamic>> carrinho;

  const CarrinhoScreen({super.key, required this.carrinho});

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  @override
  Widget build(BuildContext context) {
    double total = widget.carrinho.fold(
      0,
      (soma, item) => soma + (item['preco'] ?? 0),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Carrinho de Compras')),
      body:
          widget.carrinho.isEmpty
              ? Center(child: Text('Seu carrinho está vazio.'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.carrinho.length,
                      itemBuilder: (context, index) {
                        final item = widget.carrinho[index];
                        return ListTile(
                          title: Text(item['nome']),
                          subtitle: Text(
                            'R\$ ${item['preco'].toStringAsFixed(2)}',
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                widget.carrinho.removeAt(index);
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
                          'Total: R\$ ${total.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              widget.carrinho.clear();
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
