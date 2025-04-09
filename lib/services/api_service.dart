import 'package:app_tarefas/models/tarefas.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl =
      'http://localhost:8000/api'; // Ajuste conforme necessário
  final String token = 'SEU_TOKEN_AQUI'; // Obtenha via login

  Future<List<Tarefa>> buscarTarefas() async {
    final resposta = await http.get(
      Uri.parse('$baseUrl/tarefas'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (resposta.statusCode == 200) {
      List<dynamic> dados = jsonDecode(resposta.body);
      return dados.map((json) => Tarefa.fromJson(json)).toList();
    }
    throw Exception('Erro ao buscar tarefas');
  }
}
