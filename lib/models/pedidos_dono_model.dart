import 'package:cloud_firestore/cloud_firestore.dart';

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

  PedidoModel({
    required this.id,
    required this.idDono,
    required this.usuarioId,
    required this.nome,
    required this.preco,
    required this.quantidade,
    required this.total,
    required this.data,
    required this.entregue,
  });

  factory PedidoModel.fromFirestore(Map<String, dynamic> map, String docId) {
    return PedidoModel(
      id: docId,
      idDono: map['idDono'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      nome: map['nome'] ?? '',
      preco: (map['preco'] ?? 0).toDouble(),
      quantidade: map['quantidade'] ?? 0,
      total: (map['total'] ?? 0).toDouble(),
      data: (map['data'] as Timestamp).toDate(),
      entregue: map['entregue'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idDono': idDono,
      'usuarioId': usuarioId,
      'nome': nome,
      'preco': preco,
      'quantidade': quantidade,
      'total': total,
      'data': data,
      'entregue': entregue,
    };
  }
}
