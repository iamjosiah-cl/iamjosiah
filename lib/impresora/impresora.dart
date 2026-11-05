import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../firebase_options.dart';
import 'text_editor_80mm.dart';

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
      title: 'Checklist Pro',
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

  // 🎨 Input mejorado con bordes redondeados e icono
  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            focusNode: _textFocusNode,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'Escribe una tarea…',
              prefixIcon: const Icon(Icons.task_alt),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onSubmitted: _addTask,
          ),
        ),
        const SizedBox(width: 10),
        FilledButton.tonalIcon(
          onPressed: () => _addTask(_textController.text),
          icon: const Icon(Icons.add),
          label: const Text('Añadir'),
        ),
      ],
    );
  }

  // 🎨 Barra de estadísticas con chips
  Widget _statsBar({required int total, required int pending}) {
    return Row(
      children: [
        Chip(
          avatar: const Icon(Icons.list_alt, size: 18),
          label: Text('Total: $total'),
        ),
        const SizedBox(width: 8),
        Chip(
          avatar: const Icon(Icons.pending_actions, size: 18),
          label: Text('Pendientes: $pending'),
        ),
      ],
    );
  }

  // 🎨 Card de tarea con checkbox animado
  Widget _taskTile(Task task) {
    return Card(
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggleTask(task),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: CheckboxListTile(
            value: task.done,
            onChanged: (_) => _toggleTask(task),
            controlAffinity: ListTileControlAffinity.leading,
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 16,
                decoration: task.done ? TextDecoration.lineThrough : null,
                color: task.done
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              child: Text(task.title),
            ),
            secondary: Icon(
              task.done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: task.done
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
      ),
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
    _textFocusNode.requestFocus();
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

    final lines = summary.split('\n').length;
    final textHeightMm = (lines + 2) * 4.93;
    final pageHeightMm = textHeightMm + kQrSizeMm + 200;

    final pageFormat = PdfPageFormat(
      kTicketWidthMm * PdfPageFormat.mm,
      pageHeightMm * PdfPageFormat.mm,
    );

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Column(
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
      appBar: AppBar(
        title: Text(_selectedTitle),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Nueva lista',
            onPressed: _createNewList,
            icon: const Icon(Icons.playlist_add),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TextEditorPage()),
          );
        },
        icon: const Icon(Icons.edit_note),
        label: const Text('Editor 80mm'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(.35),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
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

                _buildInputRow(),
                const SizedBox(height: 16),

                Expanded(
                  child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _docRef.snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final raw = snap.data!.data()?['tasks'] as List<dynamic>? ?? [];
                      final tasks = raw
                          .map((e) => Task.fromJson(Map<String, dynamic>.from(e)))
                          .toList();
                      final pending = tasks.where((t) => !t.done).toList();

                      // 🎯 Ordenar: pendientes arriba, hechas abajo
                      final ordered = [
                        ...tasks.where((t) => !t.done),
                        ...tasks.where((t) => t.done),
                      ];

                      return Column(
                        children: [
                          _statsBar(total: tasks.length, pending: pending.length),
                          const SizedBox(height: 10),

                          Expanded(
                            child: tasks.isEmpty
                                ? const Center(child: Text('Sin tareas'))
                                : ListView.builder(
                                    itemCount: ordered.length,
                                    itemBuilder: (context, idx) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      child: _taskTile(ordered[idx]),
                                    ),
                                  ),
                          ),

                          // 🎨 Vista previa mejorada
                          if (pending.isNotEmpty)
                            Card(
                              margin: const EdgeInsets.only(top: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.receipt_long),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Vista previa',
                                          style: Theme.of(context).textTheme.titleMedium,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.outlineVariant,
                                        ),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Text(
                                          _buildSummaryText(pending, _selectedTitle),
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),
                          FilledButton.icon(
                            icon: const Icon(Icons.print),
                            label: const Text('Imprimir'),
                            onPressed: () => _printPending(tasks),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}