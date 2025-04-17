import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:teste_app/controllers/minha_conta_controller.dart';
import '../controllers/endereco_controller.dart';
import 'adicionar_endereco.dart';

class MinhaContaView extends StatefulWidget {
  const MinhaContaView({super.key});

  @override
  State<MinhaContaView> createState() => _MinhaContaViewState();
}

class _MinhaContaViewState extends State<MinhaContaView> {
  User? user = FirebaseAuth.instance.currentUser;
  final _controller = MinhaContaController();
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> enderecos = [];
  List<Map<String, dynamic>> pedidos = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    if (user == null) return;

    try {
      final data = await Future.wait([
        _controller.carregarUserData(),
        _controller.carregarEnderecos(),
        _controller.carregarPedidos(),
      ]);

      setState(() {
        userData = data[0] as Map<String, dynamic>?;
        enderecos = data[1] as List<Map<String, dynamic>>;
        pedidos = data[2] as List<Map<String, dynamic>>;
        isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Minha Conta')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Minha Conta', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informações do usuário
            Text(
              'Informações da Conta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.blue),
                      title: Text('Email'),
                      subtitle: Text(user!.email ?? 'Não informado'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.green),
                      title: Text('Nome'),
                      subtitle: Text(userData?['name'] ?? 'Não informado'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.badge, color: Colors.deepPurple),
                      title: Text('Tipo de Usuário'),
                      subtitle: Text(userData?['userType'] ?? 'cliente'),
                    ),
                    Divider(),
                    if (userData?['userType'] == 'dono') ...[
                      ListTile(
                        leading: Icon(Icons.business, color: Colors.orange),
                        title: Text('Nome da Empresa'),
                        subtitle: Text(
                          userData?['nomeEmpresa'] ?? 'Não informado',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Endereços
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Endereços',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/adicionar-endereco');
                  },
                  icon: Icon(Icons.add_location_alt),
                  label: Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...enderecos.map(
              (endereco) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: Icon(
                    Icons.location_on_outlined,
                    color: Colors.redAccent,
                  ),
                  title: Text('${endereco['rua']}, ${endereco['numero']}'),
                  subtitle: Text(
                    '${endereco['bairro']} - ${endereco['cidade']}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AdicionarEnderecoView(endereco: endereco),
                            ),
                          ).then((value) {
                            if (value == true) carregarDados();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirmar exclusão'),
                                content: Text(
                                  'Você tem certeza de que deseja excluir este endereço?',
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('Cancelar'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Excluir'),
                                    onPressed: () {
                                      EnderecoController()
                                          .removerEndereco(endereco['id'])
                                          .then((_) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Endereço removido com sucesso!',
                                                ),
                                              ),
                                            );
                                            carregarDados();
                                            Navigator.of(context).pop();
                                          })
                                          .catchError((error) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Erro ao remover endereço: $error',
                                                ),
                                              ),
                                            );
                                            Navigator.of(context).pop();
                                          });
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pedidos recentes
            Text(
              'Pedidos Recentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (pedidos.isEmpty)
              Text('Você ainda não fez pedidos.')
            else
              ...pedidos.map(
                (pedido) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: Icon(Icons.shopping_bag, color: Colors.teal),
                    title: Text('Pedido #${pedido['id'] ?? 'N/A'}'),
                    subtitle: Text(
                      'Total: R\$ ${pedido['total']?.toStringAsFixed(2) ?? '0.00'}',
                    ),
                    trailing: Text(
                      pedido['status'] ?? 'Em andamento',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
