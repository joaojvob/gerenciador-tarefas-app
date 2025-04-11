import 'package:flutter/material.dart';
import 'package:app_tarefas/services/api_service.dart';
import 'package:app_tarefas/models/tarefas.dart';
import 'package:app_tarefas/screens/tarefa_form.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TelaTarefas extends StatefulWidget {
  @override
  _TelaTarefasState createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final ApiService api = ApiService();
  List<Tarefa> tarefas = [];

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  void _carregarTarefas() async {
    try {
      tarefas = await api.buscarTarefas();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _mostrarFormulario([Tarefa? tarefa]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TarefaForm(
        tarefa: tarefa,
        onSave: (novaTarefa) async {
          try {
            if (tarefa == null) {
              await api.criarTarefa(novaTarefa);
            } else {
              novaTarefa = Tarefa(
                id: tarefa.id,
                titulo: novaTarefa.titulo,
                descricao: novaTarefa.descricao,
                dataVencimento: novaTarefa.dataVencimento,
                prioridade: novaTarefa.prioridade,
                status: novaTarefa.status,
              );
              await api.atualizarTarefa(novaTarefa);
            }
            _carregarTarefas();
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
      ),
    );
  }

  void _logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.blue),
            SizedBox(width: 8),
            Text('Sair'),
          ],
        ),
        content: Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      Navigator.pushReplacementNamed(context, '/', arguments: 'Logout realizado com sucesso');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Tarefas', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      body: tarefas.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = tarefas[index];
                return Card(
                  child: ListTile(
                    title: Text(tarefa.titulo, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tarefa.descricao != null) Text(tarefa.descricao!),
                        Text('Vencimento: ${tarefa.dataVencimento?.toString().substring(0, 16) ?? 'Não definido'}'),
                        Text('Prioridade: ${tarefa.prioridade ?? 'Média'}', style: TextStyle(color: _getPrioridadeColor(tarefa.prioridade))),
                        Text('Status: ${tarefa.status ?? 'Pendente'}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _mostrarFormulario(tarefa),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Color _getPrioridadeColor(String? prioridade) {
    switch (prioridade) {
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}