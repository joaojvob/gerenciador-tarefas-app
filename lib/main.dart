import 'package:flutter/material.dart';
import 'package:app_tarefas/services/api_service.dart';
import 'package:app_tarefas/models/tarefas.dart';

void main() {
  runApp(MeuApp());
}

class MeuApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardTheme(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Minhas Tarefas', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
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
      case 'alta': return Colors.red;
      case 'media': return Colors.orange;
      default: return Colors.green;
    }
  }
}

class TarefaForm extends StatefulWidget {
  final Tarefa? tarefa;
  final Function(Tarefa) onSave;

  TarefaForm({this.tarefa, required this.onSave});

  @override
  _TarefaFormState createState() => _TarefaFormState();
}

class _TarefaFormState extends State<TarefaForm> {
  final _formKey = GlobalKey<FormState>();
  late String titulo;
  String? descricao;
  DateTime? dataVencimento;
  String? prioridade = 'media';
  String? status = 'pendente';

  @override
  void initState() {
    super.initState();
    titulo = widget.tarefa?.titulo ?? '';
    descricao = widget.tarefa?.descricao;
    dataVencimento = widget.tarefa?.dataVencimento;
    prioridade = widget.tarefa?.prioridade ?? 'media';
    status = widget.tarefa?.status ?? 'pendente';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            TextFormField(
              initialValue: titulo,
              decoration: InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Informe o título' : null,
              onChanged: (value) => titulo = value,
            ),
            SizedBox(height: 8),
            TextFormField(
              initialValue: descricao,
              decoration: InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
              maxLines: 3,
              onChanged: (value) => descricao = value,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Data de Vencimento',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: dataVencimento ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(dataVencimento ?? DateTime.now()),
                            );
                            if (time != null) {
                              setState(() {
                                dataVencimento = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                              });
                            }
                          }
                        },
                      ),
                    ),
                    controller: TextEditingController(
                      text: dataVencimento?.toString().substring(0, 16) ?? '',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: prioridade,
              decoration: InputDecoration(labelText: 'Prioridade', border: OutlineInputBorder()),
              items: ['baixa', 'media', 'alta'].map((value) => DropdownMenuItem(value: value, child: Text(value.capitalize()))).toList(),
              onChanged: (value) => setState(() => prioridade = value),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: status,
              decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: ['pendente', 'em_andamento', 'concluida'].map((value) => DropdownMenuItem(value: value, child: Text(value.replaceAll('_', ' ').capitalize()))).toList(),
              onChanged: (value) => setState(() => status = value),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSave(Tarefa(
                    id: widget.tarefa?.id ?? 0,
                    titulo: titulo,
                    descricao: descricao,
                    dataVencimento: dataVencimento,
                    prioridade: prioridade,
                    status: status,
                  ));
                }
              },
              child: Text('Salvar'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}