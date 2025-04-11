class Tarefa {
  final int id;
  final String titulo;
  String? descricao;
  DateTime? dataVencimento;
  String? prioridade;
  String? status;
  final int? ordem;
  final int userId;

  Tarefa({
    required this.id,
    required this.titulo,
    this.descricao,
    this.dataVencimento,
    this.prioridade,
    this.status,
    this.ordem,
    required this.userId,
  });

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      dataVencimento: json['data_vencimento'] != null ? DateTime.parse(json['data_vencimento']) : null,
      prioridade: json['prioridade']?.toString().toLowerCase(),  
      status: json['status']?.toString().toLowerCase(),  
      ordem: json['ordem'],
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'data_vencimento': dataVencimento?.toIso8601String(),
      'prioridade': prioridade,
      'status': status,
      'ordem': ordem,
      'user_id': userId,
    };
  }
}