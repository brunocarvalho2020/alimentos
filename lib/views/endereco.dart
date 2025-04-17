import 'package:flutter/material.dart';
import '../controllers/endereco_controller.dart';
import '../models/endereco_model.dart';

class AdicionarEnderecoView extends StatefulWidget {
  final Map<String, dynamic>? endereco;

  const AdicionarEnderecoView({super.key, this.endereco});

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

  @override
  void initState() {
    super.initState();
    if (widget.endereco != null) {
      _ruaController.text = widget.endereco!['rua'];
      _numeroController.text = widget.endereco!['numero'];
      _bairroController.text = widget.endereco!['bairro'];
      _cidadeController.text = widget.endereco!['cidade'];
      _estadoController.text = widget.endereco!['estado'];
      _cepController.text = widget.endereco!['cep'];
      _complementoController.text = widget.endereco!['complemento'] ?? '';
    }
  }

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

      if (widget.endereco == null) {
        await _controller.adicionarEndereco(endereco);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço salvo com sucesso!')),
        );
      } else {
        await _controller.atualizarEndereco(widget.endereco!['id']!, endereco);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço alterado com sucesso!')),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Erro ao salvar endereço')));
    }

    setState(() => _isLoading = false);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
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
    final isEditing = widget.endereco != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Alterar Endereço' : 'Adicionar Endereço'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ruaController,
                decoration: _inputDecoration('Rua'),
                validator: (value) => value!.isEmpty ? 'Informe a rua' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numeroController,
                decoration: _inputDecoration('Número'),
                validator:
                    (value) => value!.isEmpty ? 'Informe o número' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bairroController,
                decoration: _inputDecoration('Bairro'),
                validator:
                    (value) => value!.isEmpty ? 'Informe o bairro' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cidadeController,
                decoration: _inputDecoration('Cidade'),
                validator:
                    (value) => value!.isEmpty ? 'Informe a cidade' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _estadoController,
                decoration: _inputDecoration('Estado'),
                validator:
                    (value) => value!.isEmpty ? 'Informe o estado' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cepController,
                decoration: _inputDecoration('CEP'),
                validator: (value) => value!.isEmpty ? 'Informe o CEP' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _complementoController,
                decoration: _inputDecoration('Complemento (opcional)'),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(isEditing ? Icons.edit_location : Icons.save),
                      onPressed: _salvarEndereco,
                      label: Text(
                        isEditing ? 'Alterar Endereço' : 'Salvar Endereço',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
