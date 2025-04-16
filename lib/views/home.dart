import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    homeController.loadUserData().then((_) {
      // Força o rebuild da página após o carregamento dos dados do usuário
      setState(() {});
    });
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
    return StreamBuilder<User?>(
      stream:
          _auth.authStateChanges(), // Escuta as mudanças no estado do Firebase
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ); // Exibe carregando enquanto aguarda
        }

        User? currentUser =
            snapshot.data; // Atualiza o usuário com os dados atuais

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
                      if (homeController.currentUser == null) ...[
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/login',
                            );

                            if (result == true) {
                              await homeController.loadUserData();

                              if (mounted) {
                                setState(() {});
                              }
                            }
                          },
                          child: Text('Fazer login'),
                        ),
                      ],
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
                  child: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
                    future: homeController.getProdutosAgrupadosPorLoja(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                          child: Text('Nenhum produto encontrado.'),
                        );
                      }

                      final lojas = snapshot.data!;

                      return ListView(
                        children:
                            lojas.entries.map((entry) {
                              final nomeLoja = entry.key;
                              final produtos = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nomeLoja,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 200,
                                      child: PageView.builder(
                                        controller: PageController(
                                          viewportFraction: 0.85,
                                        ),
                                        itemCount: produtos.length,
                                        itemBuilder: (context, index) {
                                          final produto = produtos[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Card(
                                              elevation: 4,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  12.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      produto['nome'] ?? '',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      produto['descricao'] ??
                                                          '',
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      'R\$ ${produto['preco']?.toStringAsFixed(2) ?? '0.00'}',
                                                    ),
                                                    Text(
                                                      'Estoque: ${produto['quantidade'] ?? 0}',
                                                    ),
                                                    Spacer(),
                                                    Align(
                                                      alignment:
                                                          Alignment.bottomRight,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          adicionarAoCarrinho(
                                                            produto,
                                                          );
                                                        },
                                                        child: Icon(Icons.add),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
