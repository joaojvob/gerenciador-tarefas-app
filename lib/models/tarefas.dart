class Tarefa {
  final int id;
  final String titulo;
  final String? descricao;
  final bool concluida;

  Tarefa(
      {required this.id,
      required this.titulo,
      this.descricao,
      required this.concluida});

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      id: json['id'],
      titulo: json['titulo'],
      descricao: json['descricao'],
      concluida: json['concluida'],
    );
  }
}
