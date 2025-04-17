import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/gerenciamento_controller.dart';
import 'analises.dart';

class ManageStoreScreen extends StatefulWidget {
  const ManageStoreScreen({super.key});

  @override
  State<ManageStoreScreen> createState() => _ManageStoreScreenState();
}

class _ManageStoreScreenState extends State<ManageStoreScreen> {
  final GerenciamentoController controller = GerenciamentoController();
  Map<String, dynamic>? userData;
  bool isLoading = true;
  List<XFile> imagensSelecionadas = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final dados = await controller.carregarDadosUsuario();
    setState(() {
      userData = dados;
      isLoading = false;
    });
  }

  void _recebeProduto(BuildContext context) {
    final nomeController = TextEditingController();
    final precoController = TextEditingController();
    final descricaoController = TextEditingController();
    final quantidadeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Cadastrar Produto'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: precoController,
                  decoration: InputDecoration(labelText: 'Preço'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição'),
                ),
                TextField(
                  controller: quantidadeController,
                  decoration: InputDecoration(labelText: 'Quantidade'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nome = nomeController.text;
                final preco = double.tryParse(precoController.text) ?? 0.0;
                final descricao = descricaoController.text;
                final quantidade = int.tryParse(quantidadeController.text) ?? 0;

                try {
                  await controller.cadastrarProduto(
                    nome: nome,
                    preco: preco,
                    descricao: descricao,
                    quantidade: quantidade,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Produto "$nome" cadastrado!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Erro: $e')));
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciar Estabelecimento')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : userData == null
              ? Center(child: Text('Erro ao carregar dados.'))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome: ${userData!['name']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'E-mail: ${userData!['email']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Tipo: ${userData!['userType']}',
                      style: TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Criado em: ${userData!['createdAt'].toDate().toString().split('.')[0]}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () => _recebeProduto(context),
                      icon: Icon(Icons.add_business),
                      label: Text('Adicionar produto'),
                    ),
                    if (userData!['userType'] == 'dono')
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EstatisticasScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.bar_chart),
                        label: Text('Ver análises de dados'),
                      ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Voltar'),
                    ),
                  ],
                ),
              ),
    );
  }
}
