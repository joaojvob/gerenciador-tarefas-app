import 'package:flutter/material.dart';
import 'package:app_tarefas/services/api_service.dart';
import 'package:app_tarefas/models/tarefas.dart';
import 'package:app_tarefas/view/tarefa_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_tarefas/services/export_service.dart';

class TelaTarefas extends StatefulWidget {
  @override
  _TelaTarefasState createState() => _TelaTarefasState();
}

class _TelaTarefasState extends State<TelaTarefas> {
  final ApiService api = ApiService();
  final ExportService exportService = ExportService();
  List<Tarefa> tarefas = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  void _carregarTarefas() async {
      setState(() => isLoading = true);
      
      try {
          tarefas = await api.buscarTarefas();
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Tarefas carregadas com sucesso!'),
                  backgroundColor: Colors.green,
              ),
          );
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(e.toString()),
                  backgroundColor: Colors.red,
              ),
          );
      }
      setState(() => isLoading = false);
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
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Tarefa criada com sucesso!'),
                                  backgroundColor: Colors.green,
                              ),
                          );
                      } else {
                          novaTarefa = Tarefa(
                              id: tarefa.id,
                              titulo: novaTarefa.titulo,
                              descricao: novaTarefa.descricao,
                              dataVencimento: novaTarefa.dataVencimento,
                              prioridade: novaTarefa.prioridade,
                              status: novaTarefa.status,
                              ordem: novaTarefa.ordem,
                              userId: tarefa.userId,
                          );
                          await api.atualizarTarefa(novaTarefa);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Tarefa atualizada com sucesso!'),
                                  backgroundColor: Colors.green,
                              ),
                          );
                      }
                      _carregarTarefas();
                      Navigator.pop(context);
                  } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                          ),
                      );
                  }
              },
          ),
      );
  }

  void _excluirTarefa(int id) async {
    bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: Text('Excluir Tarefa'),
            content: Text('Deseja realmente excluir esta tarefa?'),
            actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
                TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Excluir', style: TextStyle(color: Colors.red)),
                ),
            ],
        ),
    );

    if (confirm == true) {
        try {
            await api.excluirTarefa(id);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Tarefa excluída com sucesso!'),
                    backgroundColor: Colors.green,
                ),
            );
            _carregarTarefas();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
      }
    }
  }

  void _logout() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(children: [Icon(Icons.logout, color: Colors.blue), SizedBox(width: 8), Text('Sair')]),
        content: Text('Deseja realmente sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await api.logout();
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        Navigator.pushReplacementNamed(context, '/', arguments: 'Logout realizado com sucesso');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  void _mostrarOpcoesExportacao() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exportar Relatório'),
          content: Text('Escolha o formato para exportar suas tarefas:'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await exportService.exportToPdf(tarefas);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('PDF gerado com sucesso!'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao gerar PDF: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text('PDF'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await exportService.exportToCsv(tarefas);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('CSV gerado com sucesso!'), backgroundColor: Colors.green),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao gerar CSV: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: Text('CSV'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
          ],
        ),
      );
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Tarefas', style: Theme.of(context).textTheme.titleLarge),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.sync, color: Colors.white),
            onPressed: _carregarTarefas,
            tooltip: 'Sincronizar',
          ),
               IconButton(
            icon: Icon(Icons.download, color: Colors.white),  
            onPressed: _mostrarOpcoesExportacao,
            tooltip: 'Exportar Relatório',
          ),
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            tooltip: 'Perfil',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tarefas.isEmpty
              ? Center(child: Text('Nenhuma tarefa encontrada', style: TextStyle(fontSize: 18, color: Colors.grey)))
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
                            if (tarefa.descricao != null) Text(tarefa.descricao!, style: TextStyle(color: Colors.grey[600])),
                            Text('Vencimento: ${tarefa.dataVencimento?.toString().substring(0, 16) ?? 'Não definido'}'),
                            Text('Prioridade: ${tarefa.prioridade ?? 'media'}', style: TextStyle(color: _getPrioridadeColor(tarefa.prioridade))),
                            Text('Status: ${tarefa.status ?? 'Pendente'}'),
                            Text('Ordem: ${tarefa.ordem ?? 'Não definida'}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _mostrarFormulario(tarefa),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _excluirTarefa(tarefa.id!),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormulario(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        elevation: 8,
      ),
    );
  }

  Color _getPrioridadeColor(String? prioridade) {
    switch (prioridade?.toLowerCase()) {  
      case 'alta':
        return Colors.red;
      case 'media':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}