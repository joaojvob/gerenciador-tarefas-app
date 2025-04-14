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
    final response = await http.post(Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('auth_token', data['token']);
    
      return data;
    }

    throw Exception('Erro ao fazer login: ${response.body}');
  }

  Future<void> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Erro ao registrar: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', data['token']);
  }

  Future<void> logout() async {
    final token    = await _getToken();
    final response = await http.post(Uri.parse('$baseUrl/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao fazer logout: ${response.body}');
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    final token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/update-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar senha: ${response.body}');
    }
  }

  Future<List<Tarefa>> buscarTarefas() async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('Token de autenticação não encontrado. Faça login novamente.');
    }

    final response = await http.get(Uri.parse('$baseUrl/tarefas'),
      headers: {
        'Authorization': 'Bearer $token', 
        'Accept': 'application/json',
        'Content-Type': 'application/json',  
      },
    );
    
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic> tarefasJson = jsonResponse['data'];

      return tarefasJson.map((json) => Tarefa.fromJson(json)).toList();
    } else {

      throw Exception('Erro ao carregar tarefas: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Tarefa> criarTarefa(Tarefa tarefa) async {
    final token    = await _getToken();
    final response = await http.post(Uri.parse('$baseUrl/tarefas'),
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
    final token    = await _getToken();
    final response = await http.patch(Uri.parse('$baseUrl/tarefas/${tarefa.id}'),
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

  Future<void> excluirTarefa(int id) async {
    final token    = await _getToken();
    final response = await http.delete(Uri.parse('$baseUrl/tarefas/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir tarefa: ${response.body}');
    }
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isTokenValid() async {
    final token = await _getToken();

    if (token == null) return false;

    try {
      final response = await http.get(Uri.parse('$baseUrl/tarefas'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}