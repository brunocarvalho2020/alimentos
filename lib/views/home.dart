import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/carrinho_controller.dart';
import '../models/carrinho_model.dart';
import '../views/carrinho.dart';
import '../controllers/home_controller.dart';

List<Map<String, dynamic>> carrinho = [];
final CarrinhoController carrinhoController = CarrinhoController();

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController homeController = HomeController();

  @override
  void initState() {
    super.initState();
    homeController.loadUserData().then((_) => setState(() {}));
  }

  void adicionarAoCarrinho(Map<String, dynamic> produto) {
    final item = CarrinhoItem(
      nome: produto['nome'] ?? '',
      preco: (produto['preco'] ?? 0).toDouble(),
      quantidade: 1, // Força 1 no carrinho
    );

    setState(() {
      carrinhoController.adicionar(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.nome} adicionado ao carrinho!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (homeController.isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Olá, ${homeController.userName ?? 'Visitante'}!'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          CarrinhoScreen(controller: carrinhoController),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'conta') {
                Navigator.pushNamed(context, '/minha-conta');
              } else if (value == 'sair') {
                await homeController.logout();
                setState(() {});
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(value: 'conta', child: Text('Minha conta')),
                  PopupMenuItem(value: 'sair', child: Text('Sair')),
                ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.home, size: 80, color: Colors.blue),
                  SizedBox(height: 20),
                  Text(
                    homeController.currentUser != null
                        ? 'Você está logado!'
                        : 'Bem-vindo! Faça login para acessar mais recursos.',
                    style: TextStyle(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  if (homeController.userType == 'dono')
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/gerenciar-estabelecimento',
                        );
                      },
                      child: Text('Gerenciar meu estabelecimento'),
                    ),
                  if (homeController.currentUser == null)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text('Fazer login'),
                    ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Produtos disponíveis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: homeController.getProdutosStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('Nenhum produto encontrado.'));
                  }

                  final produtos = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: produtos.length,
                    itemBuilder: (context, index) {
                      final data =
                          produtos[index].data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(data['nome'] ?? 'Sem nome'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['descricao'] ?? 'Sem descrição'),
                              SizedBox(height: 4),
                              Text(
                                'Preço: R\$ ${data['preco']?.toStringAsFixed(2) ?? '0.00'}',
                              ),
                              Text('Quantidade: ${data['quantidade'] ?? 0}'),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              adicionarAoCarrinho(data);
                            },
                            child: Icon(Icons.add),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
