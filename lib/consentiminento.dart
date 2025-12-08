import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// A minimal Flutter application that shows a short consent form for
/// recording and transcribing meetings, tailored for the Communications
/// Department of Colegio Adventista de Copiapó. The user can preview the
/// form with their data and export it as a PDF.
void main() {
  runApp(const ConsentApp());
}

class ConsentApp extends StatelessWidget {
  const ConsentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulario de consentimiento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const ConsentPage(),
    );
  }
}

class ConsentPage extends StatefulWidget {
  const ConsentPage({super.key});

  @override
  State<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends State<ConsentPage> {
  final _nameCtrl = TextEditingController();
  final _meetingCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String get _consentText =>
      '''Yo, ${_nameCtrl.text.isEmpty ? '[Nombre completo]' : _nameCtrl.text}, por medio de la presente autorizo al Departamento de Comunicaciones del Colegio Adventista de Copiapó a:

1. Grabar en audio y/o video la reunión titulada "${_meetingCtrl.text.isEmpty ? '[Nombre de la reunión]' : _meetingCtrl.text}", que se llevará a cabo el ${_dateCtrl.text.isEmpty ? '[Fecha]' : _dateCtrl.text}.
2. Elaborar la transcripción íntegra de dicha grabación.

Doy mi consentimiento para que ambos materiales se utilicen exclusivamente con fines laborales internos (documentación, seguimiento de acuerdos y/o capacitación) y permanezcan confidenciales, sin ser compartidos fuera de la organización sin mi autorización previa y por escrito.

Declaro haber leído y entendido esta autorización, firmando en señal de conformidad.

----------------------------------------------
Nombre: ${_nameCtrl.text.isEmpty ? '____________________________' : _nameCtrl.text}
Firma:  ____________________________
Fecha:  ${_dateCtrl.text.isEmpty ? '________________' : _dateCtrl.text}
''';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _meetingCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _printPdf() async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) => pw.Text(_consentText,
            style: const pw.TextStyle(fontSize: 12)),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consentimiento')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _meetingCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la reunión'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(labelText: 'Fecha (dd/mm/aaaa)'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_consentText),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              icon: const Icon(Icons.print),
              label: const Text('Imprimir / Exportar PDF'),
              onPressed: _printPdf,
            ),
          ],
        ),
      ),
    );
  }
}
