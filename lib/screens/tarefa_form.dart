import 'package:flutter/material.dart';
import 'package:app_tarefas/models/tarefas.dart';

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