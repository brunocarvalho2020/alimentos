
# 📘 Documentação Técnica do Aplicativo

## 1. Informações Gerais

- **Nome do projeto:** []
- **Stack principal:** Flutter (Dart), Firebase (Firestore, Auth, Storage)
- **Finalidade:** Aplicativo de delivery com funcionalidades administrativas e analíticas para estabelecimentos.

## 2. Arquitetura do Projeto

O projeto segue uma arquitetura baseada em separação por camadas:

- **Model:** Representação das entidades (Produto, Usuário, Pedido, etc.).
- **Controller:** Lógica de negócio, comunicação com Firebase, controle de estado.
- **View:** Telas e componentes visuais.
- **Service:** Serviços específicos (upload de imagem, autenticação, etc.)

## 3. Gerenciamento de Estado

Gerenciamento de estado global dos modelos (`CarrinhoModel`, `AuthController` e `PedidoController`), feito manualmente.

## 4. Dependências Principais (pubspec.yaml)

``yaml
dependencies:
  flutter:
  firebase_core:
  firebase_auth:
  cloud_firestore:
  firebase_storage:
  provider:
  fluttertoast:
  charts_flutter:
``

## 5. Estrutura de Diretórios

```dart
/lib
  /models
    produto_model.dart
    usuario_model.dart
    pedido_model.dart
  /controllers
    auth_controller.dart
    produto_controller.dart
    carrinho_controller.dart
    pedido_controller.dart
  /views
    login_view.dart
    register_view.dart
    home_view.dart
    conta_view.dart
    analise_dados_view.dart
    adicionar_produto_view.dart
    carrinho_view.dart
    endereco_view.dart
    pedidos_cliente_view.dart
    pedidos_dono_view.dart
  /services
    firebase_service.dart
    storage_service.dart
  main.dart
```

## 6. Modelos

### CarrinhoModel

```dart
class CarrinhoItem {
  final String nome;
  final double preco;
  final String idDono;
  int quantidade;
}
```

### EnderecoModel

```dart
class Endereco {
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String? complemento;
  final String? id;
}
```

### PedidosModel
```dart
class PedidoModel {
  final String id;
  final String idDono;
  final String usuarioId;
  final String nome;
  final double preco;
  final int quantidade;
  final double total;
  final DateTime data;
  final bool entregue;
}
```

### UserModel
```dart
class Usuario {
  final String email;
  final String senha;

  Usuario({required this.email, required this.senha});
}
```

## 7. Controllers

### CarrinhoController

- Controla uma lista local de CarrinhoItem.
- Calcula o total dinamicamente.
- Envia cada item como pedido individual no Firestore (finalizarCompra()).
- Importante: Nenhuma sincronização contínua com Firestore — tudo é feito sob demanda.

### EnderecoController

- Gerencia CRUD completo dos endereços do usuário autenticado.
- Usa validações manuais para garantir que apenas o dono possa alterar/remover endereços.
- Usa FirebaseAuth.instance.currentUser?.uid.

### GerenciamentoController

- Funções para o dono da loja:
  - Cadastro de produto
  - Marcar pedido como entregue
  - Relatórios (totais, vendas finalizadas)

- Observações: obterTotaisPedidos() e obterTotalVendas() realizam consultas agregadas manuais.

### HomeController

- Carrega dados do usuário atual (nome, tipo).
- Permite logout.
- Agrupa produtos por loja (útil para UI com seções de "Restaurantes").

### LoginController

- Apenas autenticação, delegada para AuthService.
- Simples, direto ao ponto.

### MinhaContaController
- Funções para clientes:

  - Carregar dados pessoais
  - Listar endereços e pedidos
  - Remover endereços

- Usa UID passado como parâmetro.

## 8. Fluxo de Telas

1. **Login/Register**
2. **HomeView** – Lista produtos disponíveis
3. **Carrinho** – Finalização de pedido
4. **PedidosClienteView/PedidosDonoView** – Histórico do cliente e gerência de pedidos, respectivamente
5. **MinhaConta** - Gerenciamento, pedidos, endereços e análises
6. **EnderecoView** - Controle de endereços
7. **GerenciamentoView** - Análises de dados, pedidos e produtos
8. **AnalisesView** - Visualização das análises (gráficos, projeções, etc)


## 9. Estruturas Firestore

### /usuarios

```json
{
  "uid": "...",
  "nome": "Fulano",
  "email": "fulano@x.com",
  "tipo": "cliente" | "dono"
}
```

### /produtos

```json
{
  "nome": "Hamburguer",
  "preco": 25.0,
  "imagens": ["url1", "url2"],
  "donoId": "uid_dono"
}
```

### /pedidos

```json
{
  "clienteId": "uid_cliente",
  "donoId": "uid_dono",
  "produtos": [{ "nome": "...", "preco": 10 }],
  "status": "pendente",
  "data": "2025-04-22T12:00:00"
}
```

### /carrinho

```json
{
  "nome": "Hamburguer",
  "preco": 25.0,
  "quantidade": 2,
  "idDono": "uid_do_dono"
}
```

### /endereco

```json
{
  "usuarioId": "uid_do_usuario",
  "rua": "Rua XYZ",
  "numero": "123",
  "bairro": "Bairro ABC",
  "cidade": "Cidade DEF",
  "estado": "Estado GHI",
  "cep": "12345-678",
  "complemento": "Apt 101"
}
```

## 10. Pontos Importantes

- StreamBuilder para refletir mudanças em tempo real
- Análises baseadas em pedidos
- Imagens no Storage, links no Firestore
- Usuários separados por tipo

## 11. Melhorias Futuras

- Pagamento integrado (ex: Stripe, Pix)
- Notificações via FCM
- Sistema de avaliações
- Multi-loja com localização
- Dashboard analítico avançado

## 12. Estratégia de Gerenciamento de Estado

Este projeto AINDA não utiliza bibliotecas externas como Provider.

- Os controllers são classes independentes com métodos diretos.
- O estado é atualizado por chamadas explícitas via setState nas views.
- Dados em tempo real do Firestore são acessados via `StreamBuilder` diretamente nas views.
- As operações de escrita/leitura no Firestore são encapsuladas em cada controller.

### Exemplo: `CarrinhoController`

- Os itens são armazenados localmente numa lista.
- Ao finalizar a compra, cada item é transformado em um documento de pedido.
- Não há sincronização contínua com Firestore, exceto nas telas que usam `StreamBuilder`.
