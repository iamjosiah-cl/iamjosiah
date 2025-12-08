import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../firebase_options.dart'; // generado por FlutterFire CLI

const double kTicketWidthMm = 72.0;
const int kCharsPerLine = 48;
const double kQrSizeMm = 60.0;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Checklist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ChecklistPage(),
    );
  }
}

class Task {
  Task({required this.title, this.done = false});

  final String title;
  bool done;

  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(title: json['title'] as String, done: json['done'] as bool? ?? false);

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
}

class ChecklistPage extends StatefulWidget {
  const ChecklistPage({super.key});

  @override
  State<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends State<ChecklistPage> {
  final _textController = TextEditingController();
  final _formatDate = DateFormat('dd/MM/yyyy HH:mm');
  final List<String> _titles = [
    'Temas hablados',
    'Checklist',
    'Mis Tareas',
    'Lista de Pendientes',
    'Lista de Tareas Completadas'
  ];
  String _selectedTitle = 'Temas hablados';
  final FocusNode _textFocusNode = FocusNode();


  late final DocumentReference<Map<String, dynamic>> _docRef;

  @override
  void initState() {
    super.initState();
    _createNewList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _textFocusNode,
            decoration: const InputDecoration(labelText: 'Nueva tarea'),
            onSubmitted: _addTask,
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: () => _addTask(_textController.text),
          child: const Text('Añadir'),
        ),
      ],
    );
  }


  void _createNewList() {
    final col = FirebaseFirestore.instance.collection('checklists');
    _docRef = col.doc();
    _docRef.set({
      'createdAt': FieldValue.serverTimestamp(),
      'tasks': <Map<String, dynamic>>[],
    });
  }

  Future<void> _addTask(String title) async {
    if (title.trim().isEmpty) return;
    await _docRef.update({
      'tasks': FieldValue.arrayUnion([Task(title: title).toJson()])
    });
    _textController.clear();
    _textFocusNode.requestFocus(); // <- vuelve a enfocar el TextField
  }


  Future<void> _toggleTask(Task task) async {
    final snap = await _docRef.get();
    final List<dynamic> raw = snap.data()?['tasks'] as List<dynamic>? ?? [];
    final tasks = raw
        .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final idx = tasks.indexWhere((t) => t.title == task.title);
    if (idx == -1) return;
    tasks[idx].done = !tasks[idx].done;
    await _docRef.update({'tasks': tasks.map((e) => e.toJson()).toList()});
  }

  Future<void> _printPending(List<Task> tasks) async {
    final pending = tasks.where((t) => !t.done).toList();
    if (pending.isEmpty) return;

    final summary = _buildSummaryText(pending, _selectedTitle);

    final doc = pw.Document();

    final lines = summary
        .split('\n')
        .length;
    final textHeightMm = (lines + 2) * 4.93;
    final pageHeightMm = textHeightMm + kQrSizeMm + 200;

    final pageFormat = PdfPageFormat(
      kTicketWidthMm * PdfPageFormat.mm,
      pageHeightMm * PdfPageFormat.mm,
    );

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) =>
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(summary, style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 8),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  String _buildSummaryText(List<Task> pending, String title) {
    String sep(String char) => char * kCharsPerLine;

    final buffer = StringBuffer();
    buffer.writeln(title.padRight(kCharsPerLine));
    buffer.writeln(_formatDate.format(DateTime.now()));
    buffer.writeln(sep('-'));
    for (var i = 0; i < pending.length; i++) {
      buffer.writeln('${(i + 1).toString().padLeft(2)}. ${pending[i].title}');
    }
    buffer.writeln(sep('-'));
    buffer.writeln('Total: ${pending.length}'.padRight(kCharsPerLine));
    // Agrega 5 líneas vacías para simular 2 cm de espacio
    buffer.writeln(sep('-'));
    buffer.writeln('');
    buffer.writeln('Contacto: +56967279093');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('Creado por: Josías Jofré Pol'.padRight(kCharsPerLine));

    return buffer.toString();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_selectedTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedTitle,
              items: _titles.map((String title) {
                return DropdownMenuItem<String>(
                  value: title,
                  child: Text(title),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTitle = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // 🔹 Input siempre disponible
            _buildInputRow(),

            const SizedBox(height: 16),

            // 🔹 Área dinámica de tareas
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _docRef.snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final raw = snap.data!.data()?['tasks'] as List<dynamic>? ??
                      [];
                  final tasks = raw.map((e) =>
                      Task.fromJson(Map<String, dynamic>.from(e))).toList();
                  final pending = tasks.where((t) => !t.done).toList();

                  return Column(
                    children: [
                      Expanded(
                        child: tasks.isEmpty
                            ? const Center(child: Text('Sin tareas'))
                            : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, idx) {
                            final task = tasks[idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(task.title),
                            );

                          },
                        ),
                      ),
                      if (pending.isNotEmpty)
                        Card(
                          margin: const EdgeInsets.only(top: 12),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200), // límite visible
                            padding: const EdgeInsets.all(12),
                            child: SingleChildScrollView(
                              child: Text(_buildSummaryText(pending, _selectedTitle)),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FilledButton.icon(
                            icon: const Icon(Icons.print),
                            label: const Text('Imprimir'),
                            onPressed: () => _printPending(tasks),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Nueva lista'),
                            onPressed: _createNewList,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}