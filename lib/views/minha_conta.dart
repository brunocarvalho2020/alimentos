import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/endereco_controller.dart';
import 'adicionar_endereco.dart';

class MinhaContaView extends StatefulWidget {
  const MinhaContaView({super.key});

  @override
  State<MinhaContaView> createState() => _MinhaContaViewState();
}

class _MinhaContaViewState extends State<MinhaContaView> {
  User? user = FirebaseAuth.instance.currentUser;
  User? address = FirebaseAuth.instance.currentUser;
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
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      final enderecoSnapshot =
          await FirebaseFirestore.instance
              .collection('enderecos')
              .where("usuarioId", isEqualTo: user!.uid)
              .orderBy('cep', descending: true)
              .get();

      final pedidosSnapshot =
          await FirebaseFirestore.instance
              .collection('pedidos')
              .where('userId', isEqualTo: user!.uid)
              .orderBy('data', descending: true)
              .get();

      setState(() {
        userData = doc.data();
        // Agora estamos incluindo o 'id' de cada documento de endereço
        enderecos =
            enderecoSnapshot.docs.map((e) {
              var endereco = e.data(); // Dados do endereço
              endereco['id'] = e.id; // Adicionando o ID do documento
              return endereco; // Retornando os dados com o ID
            }).toList();
        pedidos = pedidosSnapshot.docs.map((p) => p.data()).toList();
        isLoading = false;
        print(enderecos);
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
      appBar: AppBar(title: Text('Minha Conta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dados do usuário
            Text(
              'Informações da Conta',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Email: ${user!.email}'),
            Text('Nome: ${userData?['name'] ?? 'Não informado'}'),
            Text('Tipo: ${userData?['userType'] ?? 'cliente'}'),
            Text(
              'Nome da Empresa: ${userData?['nomeEmpresa'] ?? 'Não informado'}',
            ),
            const Divider(height: 32),

            // Endereços
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Endereços',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/adicionar-endereco');
                  },
                  child: Text('Adicionar'),
                ),
              ],
            ),
            ...enderecos.map(
              (endereco) => ListTile(
                leading: Icon(Icons.location_on),
                title: Text('${endereco['rua']}, ${endereco['numero']}'),
                subtitle: Text('${endereco['bairro']} - ${endereco['cidade']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit), // Botão de editar
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    AdicionarEnderecoView(endereco: endereco),
                          ),
                        ).then((value) {
                          if (value == true) {
                            // Se a tela retornou com sucesso e dados foram alterados
                            carregarDados();
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete), // Botão de remover
                      onPressed: () {
                        // Exibe o popup de confirmação
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Confirmar exclusão'),
                              content: Text(
                                'Você tem certeza de que deseja excluir este endereço?',
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Cancelar'),
                                  onPressed: () {
                                    // Fecha o diálogo sem excluir
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('Excluir'),
                                  onPressed: () {
                                    // Lógica para remover o item
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
                                          carregarDados(); // Atualiza a lista de endereços
                                          Navigator.of(
                                            context,
                                          ).pop(); // Fecha o diálogo após a exclusão
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
                                          Navigator.of(
                                            context,
                                          ).pop(); // Fecha o diálogo em caso de erro
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
            const Divider(height: 32),

            // Pedidos
            Text(
              'Pedidos Recentes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (pedidos.isEmpty)
              Text('Você ainda não fez pedidos.')
            else
              ...pedidos.map(
                (pedido) => ListTile(
                  leading: Icon(Icons.shopping_bag),
                  title: Text('Pedido #${pedido['id'] ?? 'N/A'}'),
                  subtitle: Text(
                    'Total: R\$ ${pedido['total']?.toStringAsFixed(2) ?? '0.00'}',
                  ),
                  trailing: Text(pedido['status'] ?? 'Em andamento'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
