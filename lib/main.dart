import 'package:app_tarefas/models/tarefas.dart';
import 'package:app_tarefas/services/api_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TelaTarefas(),
    );
  }
}

class TelaTarefas extends StatefulWidget {
  @override
  _TelaTarefasState createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Minhas Tarefas')),
      body: FutureBuilder<List<Tarefa>>(
        future: api.buscarTarefas(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(snapshot.data![index].titulo),
                  subtitle: Text(snapshot.data![index].descricao ?? ''),
                );
              },
            );
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
