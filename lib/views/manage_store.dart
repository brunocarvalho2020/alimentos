import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database.dart';
import 'package:image_picker/image_picker.dart';
import 'carrinho.dart';

List<Map<String, dynamic>> carrinho = [];

class ManageStoreScreen extends StatefulWidget {
  const ManageStoreScreen({super.key});

  @override
  State<ManageStoreScreen> createState() => _ManageStoreScreenState();
}

class _ManageStoreScreenState extends State<ManageStoreScreen> {
  final user = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  List<XFile> imagensSelecionadas = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();

      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    }
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
                SizedBox(height: 12),
                /*ElevatedButton.icon(
                  onPressed: selecionarImagens,
                  icon: Icon(Icons.image),
                  label: Text('Selecionar até 5 imagens'),
                ),
                SizedBox(height: 10),
                if (imagensSelecionadas.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        imagensSelecionadas.map((img) {
                          return Image.file(
                            File(img.path),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          );
                        }).toList(),
                  ),*/
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // fecha o diálogo
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nome = nomeController.text;
                final preco = double.tryParse(precoController.text) ?? 0.0;
                final descricao = descricaoController.text;
                final quantidade = int.tryParse(quantidadeController.text) ?? 0;

                /*if (imagensSelecionadas.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Selecione pelo menos uma imagem')),
                  );
                  return;
                }*/

                await adicionaProduto(
                  nome,
                  preco,
                  descricao,
                  quantidade,
                  //imagensSelecionadas,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Produto "$nome" cadastrado!')),
                );

                /*setState(() {
                  imagensSelecionadas.clear();
                });*/
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  /*Future<void> selecionarImagens() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> imagens = await picker.pickMultiImage();

    if (imagens.length > 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Selecione no máximo 5 imagens')));
      return;
    }

    setState(() {
      imagensSelecionadas = imagens;
    });

    print('Total de imagens selecionadas: ${imagensSelecionadas.length}');
  }*/

  void adicionarAoCarrinho(Map<String, dynamic> produto) {
    setState(() {
      carrinho.add(produto);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${produto['nome']} adicionado ao carrinho!')),
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
                      onPressed: () {
                        _recebeProduto(context);
                      },
                      icon: Icon(Icons.add_business),
                      label: Text('Adicionar produto'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Volta para HomeView
                      },
                      child: Text('Voltar'),
                    ),
                  ],
                ),
              ),
    );
  }
}
