import 'package:flutter/material.dart';
import '../controllers/endereco_controller.dart';
import '../models/endereco_model.dart';

class AdicionarEnderecoView extends StatefulWidget {
  const AdicionarEnderecoView({super.key});

  @override
  State<AdicionarEnderecoView> createState() => _AdicionarEnderecoViewState();
}

class _AdicionarEnderecoViewState extends State<AdicionarEnderecoView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = EnderecoController();

  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _estadoController = TextEditingController();
  final _cepController = TextEditingController();
  final _complementoController = TextEditingController();

  bool _isLoading = false;

  void _salvarEndereco() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final endereco = Endereco(
        rua: _ruaController.text,
        numero: _numeroController.text,
        bairro: _bairroController.text,
        cidade: _cidadeController.text,
        estado: _estadoController.text,
        cep: _cepController.text,
        complemento: _complementoController.text,
      );

      await _controller.adicionarEndereco(endereco);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Endereço salvo com sucesso!')));

      Navigator.pop(context); // Volta para a tela anterior
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar endereço')));
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _ruaController.dispose();
    _numeroController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _estadoController.dispose();
    _cepController.dispose();
    _complementoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Adicionar Endereço')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _ruaController,
                decoration: InputDecoration(labelText: 'Rua'),
                validator: (value) => value!.isEmpty ? 'Informe a rua' : null,
              ),
              TextFormField(
                controller: _numeroController,
                decoration: InputDecoration(labelText: 'Número'),
                validator:
                    (value) => value!.isEmpty ? 'Informe o número' : null,
              ),
              TextFormField(
                controller: _bairroController,
                decoration: InputDecoration(labelText: 'Bairro'),
                validator:
                    (value) => value!.isEmpty ? 'Informe o bairro' : null,
              ),
              TextFormField(
                controller: _cidadeController,
                decoration: InputDecoration(labelText: 'Cidade'),
                validator:
                    (value) => value!.isEmpty ? 'Informe a cidade' : null,
              ),
              TextFormField(
                controller: _estadoController,
                decoration: InputDecoration(labelText: 'Estado'),
                validator:
                    (value) => value!.isEmpty ? 'Informe o estado' : null,
              ),
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(labelText: 'CEP'),
                validator: (value) => value!.isEmpty ? 'Informe o CEP' : null,
              ),
              TextFormField(
                controller: _complementoController,
                decoration: InputDecoration(
                  labelText: 'Complemento (opcional)',
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _salvarEndereco,
                    child: Text('Salvar Endereço'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
