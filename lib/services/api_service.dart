import 'package:app_tarefas/models/tarefas.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao fazer login: ${response.body}');
  }

  Future<List<Tarefa>> buscarTarefas() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/tarefas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
    
      return data.map((json) => Tarefa.fromJson(json)).toList();
    }

    throw Exception('Erro ao buscar tarefas: ${response.body}');
  }

  Future<Tarefa> criarTarefa(Tarefa tarefa) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/tarefas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(tarefa.toJson()),
    );

    if (response.statusCode == 201) {
    
      return Tarefa.fromJson(jsonDecode(response.body));
    }
    
    throw Exception('Erro ao criar tarefa: ${response.body}');
  }

  Future<Tarefa> atualizarTarefa(Tarefa tarefa) async {
    final token = await _getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/tarefas/${tarefa.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(tarefa.toJson()),
    );

    if (response.statusCode == 200) {
    
      return Tarefa.fromJson(jsonDecode(response.body));
    }

    throw Exception('Erro ao atualizar tarefa: ${response.body}');
  }
}