import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

const double kTicketWidthMm = 72.0;
const int kCharsPerLine = 29;

enum TextAlignment { left, center, right }
enum FontSize { small, normal, large }

class TextElement {
  String text;
  bool bold;
  FontSize fontSize;
  TextAlignment alignment;
  bool isSeparator;

  TextElement({
    required this.text,
    this.bold = false,
    this.fontSize = FontSize.normal,
    this.alignment = TextAlignment.left,
    this.isSeparator = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'bold': bold,
    'fontSize': fontSize.index,
    'alignment': alignment.index,
    'isSeparator': isSeparator,
  };

  factory TextElement.fromJson(Map<String, dynamic> json) => TextElement(
    text: json['text'] as String,
    bold: json['bold'] as bool? ?? false,
    fontSize: FontSize.values[json['fontSize'] as int? ?? 1],
    alignment: TextAlignment.values[json['alignment'] as int? ?? 0],
    isSeparator: json['isSeparator'] as bool? ?? false,
  );
}

class TextEditorPage extends StatefulWidget {
  const TextEditorPage({super.key});

  @override
  State<TextEditorPage> createState() => _TextEditorPageState();
}

class _TextEditorPageState extends State<TextEditorPage> {
  final List<TextElement> _elements = [];
  final _textController = TextEditingController();
  bool _currentBold = false;
  FontSize _currentFontSize = FontSize.normal;
  TextAlignment _currentAlignment = TextAlignment.left;
  int? _editingIndex; // Índice del elemento que se está editando

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addElement() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      if (_editingIndex != null) {
        // Actualizar elemento existente
        _elements[_editingIndex!] = TextElement(
          text: _textController.text,
          bold: _currentBold,
          fontSize: _currentFontSize,
          alignment: _currentAlignment,
        );
        _editingIndex = null;
      } else {
        // Agregar nuevo elemento
        _elements.add(TextElement(
          text: _textController.text,
          bold: _currentBold,
          fontSize: _currentFontSize,
          alignment: _currentAlignment,
        ));
      }
      _textController.clear();
      _currentBold = false;
      _currentFontSize = FontSize.normal;
      _currentAlignment = TextAlignment.left;
    });
  }

  void _addSeparator(String char) {
    setState(() {
      _elements.add(TextElement(
        text: char * kCharsPerLine,
        isSeparator: true,
      ));
    });
  }

  void _removeElement(int index) {
    setState(() {
      _elements.removeAt(index);
    });
  }

  void _moveUp(int index) {
    if (index == 0) return;
    setState(() {
      final temp = _elements[index];
      _elements[index] = _elements[index - 1];
      _elements[index - 1] = temp;
    });
  }

  void _moveDown(int index) {
    if (index >= _elements.length - 1) return;
    setState(() {
      final temp = _elements[index];
      _elements[index] = _elements[index + 1];
      _elements[index + 1] = temp;
    });
  }

  void _editElement(int index) {
    final element = _elements[index];
    if (element.isSeparator) return; // No se pueden editar separadores
    
    setState(() {
      _editingIndex = index;
      _textController.text = element.text;
      _currentBold = element.bold;
      _currentFontSize = element.fontSize;
      _currentAlignment = element.alignment;
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingIndex = null;
      _textController.clear();
      _currentBold = false;
      _currentFontSize = FontSize.normal;
      _currentAlignment = TextAlignment.left;
    });
  }

  String _buildPreviewText() {
    final buffer = StringBuffer();
    for (final element in _elements) {
      if (element.isSeparator) {
        buffer.writeln(element.text);
      } else {
        String line = element.text;
        switch (element.alignment) {
          case TextAlignment.left:
            line = line.padRight(kCharsPerLine);
            break;
          case TextAlignment.center:
            final padding = (kCharsPerLine - line.length) ~/ 2;
            line = ' ' * padding + line;
            break;
          case TextAlignment.right:
            line = line.padLeft(kCharsPerLine);
            break;
        }
        buffer.writeln(line);
      }
    }
    return buffer.toString();
  }

  Future<void> _printDocument() async {
    if (_elements.isEmpty) return;

    final doc = pw.Document();
    final previewText = _buildPreviewText();
    final lines = previewText.split('\n').length;
    final textHeightMm = (lines + 2) * 4.93;
    final pageHeightMm = textHeightMm + 20;

    final pageFormat = PdfPageFormat(
      kTicketWidthMm * PdfPageFormat.mm,
      pageHeightMm * PdfPageFormat.mm,
    );

    // Construir el contenido con estilos
    final content = <pw.Widget>[];
    for (final element in _elements) {
      double fontSize = 12;
      switch (element.fontSize) {
        case FontSize.small:
          fontSize = 10;
          break;
        case FontSize.normal:
          fontSize = 12;
          break;
        case FontSize.large:
          fontSize = 16;
          break;
      }

      pw.TextAlign pwAlign = pw.TextAlign.left;
      switch (element.alignment) {
        case TextAlignment.left:
          pwAlign = pw.TextAlign.left;
          break;
        case TextAlignment.center:
          pwAlign = pw.TextAlign.center;
          break;
        case TextAlignment.right:
          pwAlign = pw.TextAlign.right;
          break;
      }

      content.add(
        pw.Text(
          element.text,
          style: pw.TextStyle(
            fontSize: fontSize,
            fontWeight: element.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
          textAlign: pwAlign,
        ),
      );
    }

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: content,
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor de Texto 80mm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: _printDocument,
            tooltip: 'Imprimir',
          ),
        ],
      ),
      body: Row(
        children: [
          // Panel izquierdo: Editor
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _editingIndex != null ? 'Editando elemento' : 'Editor',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (_editingIndex != null)
                        TextButton.icon(
                          onPressed: _cancelEdit,
                          icon: const Icon(Icons.close),
                          label: const Text('Cancelar'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Campo de texto
                  TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Texto',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSubmitted: (_) => _addElement(),
                  ),
                  const SizedBox(height: 16),

                  // Controles de formato
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Negrita
                      FilterChip(
                        label: const Text('Negrita'),
                        selected: _currentBold,
                        onSelected: (value) {
                          setState(() {
                            _currentBold = value;
                          });
                        },
                      ),

                      // Tamaño de fuente
                      DropdownButton<FontSize>(
                        value: _currentFontSize,
                        items: const [
                          DropdownMenuItem(
                            value: FontSize.small,
                            child: Text('Pequeño'),
                          ),
                          DropdownMenuItem(
                            value: FontSize.normal,
                            child: Text('Normal'),
                          ),
                          DropdownMenuItem(
                            value: FontSize.large,
                            child: Text('Grande'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _currentFontSize = value;
                            });
                          }
                        },
                      ),

                      // Alineación
                      SegmentedButton<TextAlignment>(
                        segments: const [
                          ButtonSegment(
                            value: TextAlignment.left,
                            icon: Icon(Icons.format_align_left),
                          ),
                          ButtonSegment(
                            value: TextAlignment.center,
                            icon: Icon(Icons.format_align_center),
                          ),
                          ButtonSegment(
                            value: TextAlignment.right,
                            icon: Icon(Icons.format_align_right),
                          ),
                        ],
                        selected: {_currentAlignment},
                        onSelectionChanged: (Set<TextAlignment> newSelection) {
                          setState(() {
                            _currentAlignment = newSelection.first;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Botones de acción
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _addElement,
                        icon: Icon(_editingIndex != null ? Icons.check : Icons.add),
                        label: Text(_editingIndex != null ? 'Actualizar' : 'Agregar'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _addSeparator('-'),
                        icon: const Icon(Icons.horizontal_rule),
                        label: const Text('Línea'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _addSeparator('='),
                        icon: const Icon(Icons.drag_handle),
                        label: const Text('Doble'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),

                  // Lista de elementos
                  Expanded(
                    child: _elements.isEmpty
                        ? const Center(child: Text('Sin elementos'))
                        : ListView.builder(
                      itemCount: _elements.length,
                      itemBuilder: (context, index) {
                        final element = _elements[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              element.isSeparator
                                  ? '--- Separador ---'
                                  : element.text,
                              style: TextStyle(
                                fontWeight: element.bold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: element.isSeparator
                                ? null
                                : Text(
                              'Tamaño: ${element.fontSize.name}, '
                                  'Alineación: ${element.alignment.name}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!element.isSeparator)
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editElement(index),
                                    iconSize: 20,
                                    color: _editingIndex == index ? Colors.blue : null,
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_upward),
                                  onPressed: () => _moveUp(index),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_downward),
                                  onPressed: () => _moveDown(index),
                                  iconSize: 20,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _removeElement(index),
                                  iconSize: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel derecho: Vista previa
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vista Previa (80mm)',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _buildPreviewText(),
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
