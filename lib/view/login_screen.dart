import 'package:flutter/material.dart';
import 'package:app_tarefas/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  final ApiService _apiService = ApiService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? message = ModalRoute.of(context)?.settings.arguments as String?;
    if (message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      });
    }
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await _apiService.login(_email, _password);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', response['token']);
        await prefs.setString('user_name', response['user']['name']);
        await prefs.setString('user_email', response['user']['email']);
        Navigator.pushReplacementNamed(context, '/tarefas');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao fazer login: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Informe o email' : null,
                onChanged: (value) => _email = value,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                obscureText: true,
                validator: (value) => value!.isEmpty ? 'Informe a senha' : null,
                onChanged: (value) => _password = value,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                child: Text('Entrar'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('Registrar', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}