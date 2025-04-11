import 'package:flutter/material.dart';
import 'package:app_tarefas/services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  String _passwordConfirmation = '';
  final ApiService _apiService = ApiService();

  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _apiService.register(_name, _email, _password, _passwordConfirmation);
        Navigator.pushReplacementNamed(context, '/tarefas');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao registrar: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro'), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Nome', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Informe o nome' : null,
                  onChanged: (value) => _name = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'Informe o email' : null,
                  onChanged: (value) => _email = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Senha', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value!.length < 8 ? 'A senha deve ter pelo menos 8 caracteres' : null,
                  onChanged: (value) => _password = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirme a Senha', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value != _password ? 'As senhas não coincidem' : null,
                  onChanged: (value) => _passwordConfirmation = value,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  child: Text('Registrar'),
                  style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}