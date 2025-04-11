class Endereco {
  final String rua;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String cep;
  final String? complemento;
  final String? id;

  Endereco({
    this.id,
    required this.rua,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.cep,
    this.complemento,
  });

  Map<String, dynamic> toMap(String userId) {
    return {
      'usuarioId': userId,
      'rua': rua,
      'numero': numero,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'cep': cep,
      'complemento': complemento ?? '',
    };
  }

  factory Endereco.fromMap(String id, Map<String, dynamic> map) {
    return Endereco(
      id: id,
      rua: map['rua'],
      numero: map['numero'],
      bairro: map['bairro'],
      cidade: map['cidade'],
      estado: map['estado'],
      cep: map['cep'],
      complemento: map['complemento'],
    );
  }
}
