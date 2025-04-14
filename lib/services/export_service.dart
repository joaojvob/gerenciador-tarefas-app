import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:app_tarefas/models/tarefas.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;  
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class ExportService {
  Future<String?> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'Usuário';
  }

  Future<String> _getFilePath(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Permission.storage.request();
    }
  }

  Future<void> exportToCsv(List<Tarefa> tarefas) async {
    await _requestPermissions();

    List<List<dynamic>> rows = [
      ['ID', 'Título', 'Descrição', 'Data de Vencimento', 'Prioridade', 'Status', 'Ordem'],
    ];

    for (var tarefa in tarefas) {
      rows.add([
        tarefa.id ?? '',
        tarefa.titulo,
        tarefa.descricao ?? '',
        tarefa.dataVencimento?.toString() ?? '',
        tarefa.prioridade ?? '',
        tarefa.status ?? '',
        tarefa.ordem ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    if (kIsWeb) {
      final bytes = Uint8List.fromList(csv.codeUnits);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'tarefas_${DateTime.now().toIso8601String()}.csv')
        ..click();
      html.Url.revokeObjectUrl(url);

    } else {
      final filePath = await _getFilePath('tarefas_${DateTime.now().toIso8601String()}.csv');
      final file = File(filePath);

      await file.writeAsString(csv);
      await OpenFile.open(filePath);
    }
  }

  Future<void> exportToPdf(List<Tarefa> tarefas) async {
    await _requestPermissions();

    final pdf = pw.Document();
    final userName = await _getUserName();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.all(10),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Relatório de Tarefas',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                'Gerado em: ${DateTime.now().toString().substring(0, 16)}',
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.all(10),
          child: pw.Text(
            'Relatório gerado por $userName',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headers: ['ID', 'Título', 'Descrição', 'Vencimento', 'Prioridade', 'Status', 'Ordem'],
            data: tarefas.map((tarefa) => [
              tarefa.id?.toString() ?? '',
              tarefa.titulo,
              tarefa.descricao ?? '',
              tarefa.dataVencimento?.toString().substring(0, 16) ?? '',
              tarefa.prioridade ?? '',
              tarefa.status ?? '',
              tarefa.ordem?.toString() ?? '',
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.all(5),
          ),
        ],
      ),
    );

    if (kIsWeb) {
      final pdfBytes = await pdf.save();
      final blob = html.Blob([pdfBytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      html.window.open(url, '_blank');  
      html.Url.revokeObjectUrl(url);

    } else {
      final filePath = await _getFilePath('tarefas_${DateTime.now().toIso8601String()}.pdf');
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(filePath);
    }
  }
}