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
  String? prioridade;
  String? status;
  int? ordem;

  @override
  void initState() {
    super.initState();
    titulo = widget.tarefa?.titulo ?? '';
    descricao = widget.tarefa?.descricao;
    dataVencimento = widget.tarefa?.dataVencimento;
    prioridade = _normalizePrioridade(widget.tarefa?.prioridade) ?? 'Media';
    status = _normalizeStatus(widget.tarefa?.status) ?? 'Pendente';
    ordem = widget.tarefa?.ordem;
  }

  String? _normalizePrioridade(String? value) {
    const validValues = ['Baixa', 'Media', 'Alta'];
    if (value != null && validValues.contains(value)) {
      return value;
    }
    return 'Media';
  }

  String? _normalizeStatus(String? value) {
    const validValues = ['Pendente', 'Em Andamento', 'Concluida', 'Cancelada'];
    if (value != null && validValues.contains(value)) {
      return value;
    }
    return 'Pendente';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.tarefa == null ? 'Nova Tarefa' : 'Editar Tarefa',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
                maxLength: 500,
                onChanged: (value) => descricao = value,
              ),
              SizedBox(height: 8),
              TextFormField(
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
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: prioridade,
                decoration: InputDecoration(labelText: 'Prioridade', border: OutlineInputBorder()),
                items: ['Baixa', 'Media', 'Alta']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => prioridade = value),
                validator: (value) => value == null ? 'Selecione uma prioridade' : null,
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: status,
                decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Pendente', 'Em Andamento', 'Concluida', 'Cancelada']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => status = value),
                validator: (value) => value == null ? 'Selecione um status' : null,
              ),
              SizedBox(height: 8),
              TextFormField(
                initialValue: ordem?.toString(),
                decoration: InputDecoration(labelText: 'Ordem', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (value) => ordem = int.tryParse(value),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    widget.onSave(Tarefa(
                      id: widget.tarefa?.id ?? 0,
                      titulo: titulo,
                      descricao: descricao,
                      dataVencimento: dataVencimento,
                      prioridade: prioridade ?? 'Media',
                      status: status ?? 'Pendente',
                      ordem: ordem,
                      userId: widget.tarefa?.userId ?? 0,
                    ));
                  }
                },
                child: Text('Salvar'),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}