import 'package:flutter/material.dart';
import 'package:app_tarefas/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String _currentPassword = '';
  String _newPassword = '';
  String _newPasswordConfirmation = '';
  final ApiService _apiService = ApiService();
  String? _userName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Usuário';
      _userEmail = prefs.getString('user_email') ?? 'email@exemplo.com';
    });
  }

  void _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _apiService.updatePassword(_currentPassword, _newPassword, _newPasswordConfirmation);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Senha atualizada com sucesso')));
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar senha: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil', style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person, size: 30)),
                  title: Text(_userName ?? 'Carregando...', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_userEmail ?? 'Carregando...'),
                ),
              ),
              SizedBox(height: 24),
              Text('Atualizar Senha', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Senha Atual', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) => value!.isEmpty ? 'Informe a senha atual' : null,
                      onChanged: (value) => _currentPassword = value,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Nova Senha', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) => value!.length < 8 ? 'A senha deve ter pelo menos 8 caracteres' : null,
                      onChanged: (value) => _newPassword = value,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Confirme a Nova Senha', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) => value != _newPassword ? 'As senhas não coincidem' : null,
                      onChanged: (value) => _newPasswordConfirmation = value,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _updatePassword,
                      child: Text('Atualizar Senha'),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}