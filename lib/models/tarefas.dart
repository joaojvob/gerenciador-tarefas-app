import 'package:intl/intl.dart';

class Tarefa {
  final int? id; 
  final String titulo;
  String? descricao;
  DateTime? dataVencimento;
  String? prioridade;
  String? status;
  final int? ordem;
  final int? userId; 

  Tarefa({
    this.id, 
    required this.titulo,
    this.descricao,
    this.dataVencimento,
    this.prioridade,
    this.status,
    this.ordem,
    this.userId, 
  });

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'] != null ? int.parse(json['id'].toString()) : null,
      titulo: json['titulo'] ?? '',
      descricao: json['descricao'],
      dataVencimento: json['data_vencimento'] != null
          ? DateTime.parse(json['data_vencimento'])  
          : null,
      prioridade: json['prioridade']?.toString(),
      status: json['status']?.toString(),
      ordem: json['ordem'] != null ? int.parse(json['ordem'].toString()) : null,
      userId: json['user_id'] != null ? int.parse(json['user_id'].toString()) : null,
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