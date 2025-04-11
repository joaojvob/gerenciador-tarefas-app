import 'package:flutter/material.dart';
import 'package:app_tarefas/screens/login_screen.dart';
import 'package:app_tarefas/screens/tela_tarefas.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder<bool>(
              future: _isLoggedIn(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                return snapshot.data == true ? TelaTarefas() : LoginScreen();
              },
            ),
        '/tarefas': (context) => TelaTarefas(),
      },
    );
  }
}