import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/gerenciamento_controller.dart';
import 'analises.dart';
import 'pedidos_dono.dart';

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
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações do Estabelecimento',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Nome: ${userData!['name']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'E-mail: ${userData!['email']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Tipo: ${userData!['userType']}',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Criado em: ${userData!['createdAt'].toDate().toString().split('.')[0]}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Gerenciamento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    _buildMenuOption(
                      icon: Icons.add_business,
                      title: 'Adicionar produto',
                      onTap: () => _recebeProduto(context),
                    ),
                    _buildMenuOption(
                      icon: Icons.shopping_bag,
                      title: 'Gerenciar Pedidos',
                      subtitle: 'Visualize pedidos pendentes e finalizados',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PedidosScreen()),
                        );
                      },
                    ),
                    if (userData!['userType'] == 'dono')
                      _buildMenuOption(
                        icon: Icons.bar_chart,
                        title: 'Análises de Dados',
                        subtitle: 'Visualize estatísticas de vendas',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EstatisticasScreen(),
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                        ),
                        child: Text('Voltar'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
