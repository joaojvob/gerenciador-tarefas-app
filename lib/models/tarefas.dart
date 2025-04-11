class Tarefa {
  final int id;
  final String titulo;
  final String? descricao;
  final DateTime? dataVencimento;
  final String? prioridade;
  final String? status;

  Tarefa({
    required this.id,
    required this.titulo,
    this.descricao,
    this.dataVencimento,
    this.prioridade,
    this.status,
  });

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataVencimento: json['data_vencimento'] != null ? DateTime.parse(json['data_vencimento']) : null,
      prioridade: json['prioridade'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descricao': descricao,
      'data_vencimento': dataVencimento?.toIso8601String(),
      'prioridade': prioridade,
      'status': status,
    };
  }
}