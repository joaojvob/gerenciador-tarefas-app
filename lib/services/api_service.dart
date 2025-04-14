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

  String _parseErrorMessage(String responseBody) {
    try {
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['errors'] != null) {
        final errors = jsonResponse['errors'] as Map<String, dynamic>;
        return errors.values.where((value) => value != null).join(' ');
      }

      return jsonResponse['message'] ?? 'Ocorreu um erro inesperado.';
    } catch (e) {

      return 'Ocorreu um erro inesperado.';
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('auth_token', data['token']);
        return data;
      }

      throw Exception(_parseErrorMessage(response.body));
    } catch (e) {

      throw Exception('Erro ao fazer login: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> register(String name, String email, String password, String passwordConfirmation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('auth_token', data['token']);

        return;
      }

      throw Exception(_parseErrorMessage(response.body));
    } catch (e) {
      throw Exception('Erro ao registrar: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> logout() async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        
        return;
      }

      throw Exception(_parseErrorMessage(response.body));
    } catch (e) {
      throw Exception('Erro ao fazer logout: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    try {
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

      if (response.statusCode == 200) {
        return;
      }

      throw Exception(_parseErrorMessage(response.body));
    } catch (e) {
      throw Exception('Erro ao atualizar senha: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<List<Tarefa>> buscarTarefas() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('Token de autenticação não encontrado. Faça login novamente.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/tarefas'),
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
      }

      throw Exception(_parseErrorMessage(response.body));
    } catch (e) {
      throw Exception('Erro ao carregar tarefas: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<Tarefa> criarTarefa(Tarefa tarefa) async {
    try {
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
        final responseData = jsonDecode(response.body);
        return Tarefa.fromJson(responseData['data'] ?? responseData);
      }

      throw Exception(_parseErrorMessage(response.body));
    } catch (e) {
      throw Exception('Erro ao criar tarefa: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<Tarefa> atualizarTarefa(Tarefa tarefa) async {
    try {
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
        final responseData = jsonDecode(response.body);
        return Tarefa.fromJson(responseData['data'] ?? responseData);
      }

      throw Exception(_parseErrorMessage(response.body));
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  Future<void> excluirTarefa(int id) async {
    try {
      final token = await _getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/tarefas/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return;
      }

      throw Exception(_parseErrorMessage(response.body));
    } catch (e) {
      throw Exception('Erro ao excluir tarefa: ${e.toString().replaceFirst('Exception: ', '')}');
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
      final response = await http.get(
        Uri.parse('$baseUrl/tarefas'),
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