import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isloading = false;
  final HomeController homeController = HomeController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    homeController.loadUserData().then((_) {
      setState(() {});
    });
  }

  void adicionarAoCarrinho(Map<String, dynamic> produto) {
    final item = CarrinhoItem(
      nome: produto['nome'] ?? '',
      preco: (produto['preco'] ?? 0).toDouble(),
      quantidade: 1,
      idDono: produto['userId'] ?? '',
    );

    setState(() {
      carrinhoController.adicionar(item);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.nome} adicionado ao carrinho!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green[600],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 70, // aumenta a altura da AppBar
            elevation: 4,
            centerTitle: false,
            title: Row(
              children: [
                const SizedBox(width: 8),
                Text(
                  'Olá, ${homeController.userName ?? 'Visitante'}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            actions: [
              if (homeController.currentUser != null) ...[
                IconButton(
                  tooltip: 'Minha conta',
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/minha-conta');
                  },
                ),
                IconButton(
                  tooltip: 'Meus pedidos',
                  icon: const Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/pedido-cliente');
                  },
                ),
                IconButton(
                  tooltip: 'Sair',
                  icon: const Icon(Icons.logout, color: Colors.white, size: 28),
                  onPressed: () async {
                    final sair = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text('Confirmação'),
                            content: const Text(
                              'Tem certeza que deseja sair da sua conta?',
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Sair'),
                              ),
                            ],
                          ),
                    );

                    if (sair == true) {
                      await homeController.logout();
                      setState(() {});
                    }
                  },
                ),
              ],
              Stack(
                children: [
                  IconButton(
                    tooltip: 'Carrinho',
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      // Aguarda a resposta da tela CarrinhoScreen
                      final resultado = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => CarrinhoScreen(
                                controller: carrinhoController,
                              ),
                        ),
                      );

                      // Verifica se o usuário finalizou a compra (resultado == true)
                      if (resultado == true) {
                        setState(() {
                          // Atualiza o estado do carrinho ou o contador de itens, conforme necessário
                          // Por exemplo, limpar o carrinho ou atualizar o ícone
                        });
                      }
                    },
                  ),

                  if (carrinhoController.itens.isNotEmpty)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 2,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          '${carrinhoController.itens.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),

          body: Padding(
            padding: const EdgeInsets.all(16),
            child:
                _isloading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              if (homeController.userType == 'dono')
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[600],
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: Icon(Icons.store, color: Colors.white),
                                  label: Text(
                                    'Gerenciar meu estabelecimento',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/gerenciar-estabelecimento',
                                    );
                                  },
                                ),
                              if (homeController.currentUser == null)
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[600],
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: Icon(Icons.login),
                                  label: Text(
                                    'Fazer login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    final result = await Navigator.pushNamed(
                                      context,
                                      '/login',
                                    );
                                    if (result == true) {
                                      await homeController.loadUserData();
                                      if (mounted) setState(() {});
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                        SizedBox(height: 30),
                        Text(
                          'Produtos disponíveis:',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: FutureBuilder<
                            Map<String, List<Map<String, dynamic>>>
                          >(
                            future:
                                homeController.getProdutosAgrupadosPorLoja(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
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
                                        padding: const EdgeInsets.only(
                                          bottom: 24.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              nomeLoja,
                                              style: GoogleFonts.roboto(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal[800],
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            SizedBox(
                                              height: 220,
                                              child: PageView.builder(
                                                controller: PageController(
                                                  viewportFraction: 0.85,
                                                ),
                                                itemCount: produtos.length,
                                                itemBuilder: (context, index) {
                                                  final produto =
                                                      produtos[index];
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    child: Card(
                                                      elevation: 6,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                              12.0,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              produto['nome'] ??
                                                                  '',
                                                              style: TextStyle(
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              produto['descricao'] ??
                                                                  '',
                                                            ),
                                                            const SizedBox(
                                                              height: 6,
                                                            ),
                                                            Text(
                                                              'R\$ ${produto['preco']?.toStringAsFixed(2) ?? '0.00'}',
                                                            ),
                                                            Text(
                                                              'Estoque: ${produto['quantidade'] ?? 0}',
                                                            ),
                                                            Spacer(),
                                                            Align(
                                                              alignment:
                                                                  Alignment
                                                                      .bottomRight,
                                                              child: ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .teal[600],
                                                                  shape:
                                                                      CircleBorder(),
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        12,
                                                                      ),
                                                                ),
                                                                onPressed: () {
                                                                  adicionarAoCarrinho(
                                                                    produto,
                                                                  );
                                                                },
                                                                child: Icon(
                                                                  Icons.add,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                ),
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
