
# 📘 Documentação Técnica do Aplicativo

## 1. Informações Gerais

- **Nome do projeto:** Alimentos
- **Stack principal:** Flutter (Dart), Firebase (Firestore, Auth, Storage)
- **Finalidade:** Aplicativo de delivery com funcionalidades administrativas e analíticas para estabelecimentos.

## 2. Arquitetura do Projeto

O projeto segue uma arquitetura baseada em separação por camadas:

- **Model:** Representação das entidades (Produto, Usuário, Pedido, etc.).
- **Controller:** Lógica de negócio, comunicação com Firebase, controle de estado.
- **View:** Telas e componentes visuais.
- **Service:** Serviços específicos (upload de imagem, autenticação, etc.)

## 3. Gerenciamento de Estado

Utiliza **Provider** para gerenciamento de estado global dos modelos `CarrinhoModel`, `AuthController` e `PedidoController`. Cada controller implementa `ChangeNotifier`.

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

### ProdutoModel

```dart
class Produto {
  final String id;
  final String nome;
  final double preco;
  final List<String> imagens;
  final String donoId;
}
```

### PedidoModel

```dart
class Pedido {
  final String id;
  final String clienteId;
  final String donoId;
  final List<Produto> produtos;
  final String status; // 'pendente' ou 'finalizado'
  final DateTime data;
}
```

## 7. Controllers

### AuthController

- Login, logout e verificação de tipo de usuário (cliente ou dono)
- Utiliza FirebaseAuth

### ProdutoController

- CRUD de produtos
- Upload de imagens no Storage
- Armazena links no Firestore

### CarrinhoController

- Adição e remoção de produtos
- Totalização
- Geração de pedido a partir do carrinho

### PedidoController

- Registro e atualização do status dos pedidos
- Consulta por donoId ou clienteId

## 8. Fluxo de Telas

1. **Login/Register**
2. **HomeView** – Lista produtos disponíveis
3. **Carrinho** – Finalização de pedido
4. **PedidosClienteView** – Histórico do cliente
5. **PedidosDonoView** – Gerência de pedidos

## 9. Firestore – Estrutura Esperada

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
