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
  int? _editingIndex;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _addElement() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      if (_editingIndex != null) {
        _elements[_editingIndex!] = TextElement(
          text: _textController.text,
          bold: _currentBold,
          fontSize: _currentFontSize,
          alignment: _currentAlignment,
        );
        _editingIndex = null;
      } else {
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
      if (_editingIndex == index) {
        _editingIndex = null;
        _textController.clear();
        _currentBold = false;
        _currentFontSize = FontSize.normal;
        _currentAlignment = TextAlignment.left;
      }
    });
  }

  void _editElement(int index) {
    final element = _elements[index];
    if (element.isSeparator) return;
    
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

  // 🎨 Panel del editor
  Widget _buildEditorPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_editingIndex != null ? Icons.edit : Icons.tune),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _editingIndex != null ? 'Editando elemento' : 'Editor',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_editingIndex != null)
                    TextButton.icon(
                      onPressed: _cancelEdit,
                      icon: const Icon(Icons.close),
                      label: const Text('Cancelar'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildComposer(context),
              const SizedBox(height: 12),
              const Divider(),
              Expanded(child: _buildElementsList(context)),
            ],
          ),
        ),
      ),
    );
  }

  // 🎨 Compositor de texto
  Widget _buildComposer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          maxLines: 3,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Escribe una línea para el ticket…',
            prefixIcon: const Icon(Icons.short_text),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onSubmitted: (_) => _addElement(),
        ),
        const SizedBox(height: 12),

        // Toolbar
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              label: const Text('Negrita'),
              selected: _currentBold,
              avatar: const Icon(Icons.format_bold, size: 18),
              onSelected: (v) => setState(() => _currentBold = v),
            ),

            SegmentedButton<TextAlignment>(
              segments: const [
                ButtonSegment(value: TextAlignment.left, icon: Icon(Icons.format_align_left)),
                ButtonSegment(value: TextAlignment.center, icon: Icon(Icons.format_align_center)),
                ButtonSegment(value: TextAlignment.right, icon: Icon(Icons.format_align_right)),
              ],
              selected: {_currentAlignment},
              onSelectionChanged: (s) => setState(() => _currentAlignment = s.first),
            ),

            DropdownButtonHideUnderline(
              child: DropdownButton<FontSize>(
                value: _currentFontSize,
                items: const [
                  DropdownMenuItem(value: FontSize.small, child: Text('Pequeño')),
                  DropdownMenuItem(value: FontSize.normal, child: Text('Normal')),
                  DropdownMenuItem(value: FontSize.large, child: Text('Grande')),
                ],
                onChanged: (v) => setState(() => _currentFontSize = v ?? FontSize.normal),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: _addElement,
              icon: Icon(_editingIndex != null ? Icons.check : Icons.add),
              label: Text(_editingIndex != null ? 'Actualizar' : 'Agregar'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _addSeparator('-'),
              icon: const Icon(Icons.horizontal_rule),
              label: const Text('Línea'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => _addSeparator('='),
              icon: const Icon(Icons.drag_handle),
              label: const Text('Doble'),
            ),
          ],
        ),
      ],
    );
  }

  // 🎨 Lista de elementos con drag & drop
  Widget _buildElementsList(BuildContext context) {
    if (_elements.isEmpty) {
      return const Center(child: Text('Sin elementos'));
    }

    return ReorderableListView.builder(
      itemCount: _elements.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = _elements.removeAt(oldIndex);
          _elements.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        final e = _elements[index];

        return Card(
          key: ValueKey('el_$index\_${e.text}'),
          elevation: 0,
          child: ListTile(
            leading: e.isSeparator
                ? const Icon(Icons.horizontal_rule)
                : const Icon(Icons.text_fields),
            title: Text(
              e.isSeparator ? 'Separador' : e.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: e.bold ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            subtitle: e.isSeparator
                ? Text('—' * 8)
                : Text('Tamaño: ${e.fontSize.name} · Alineación: ${e.alignment.name}'),
            trailing: Wrap(
              spacing: 4,
              children: [
                if (!e.isSeparator)
                  IconButton(
                    tooltip: 'Editar',
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editElement(index),
                  ),
                IconButton(
                  tooltip: 'Eliminar',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _removeElement(index),
                ),
                const Icon(Icons.drag_indicator),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🎨 Panel de vista previa
  Widget _buildPreviewPanel(BuildContext context) {
    final text = _buildPreviewText();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long),
                  const SizedBox(width: 8),
                  Text(
                    'Vista previa (80mm)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: _printDocument,
                    icon: const Icon(Icons.print),
                    label: const Text('Imprimir'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: Container(
                    width: 320,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          spreadRadius: 2,
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: SingleChildScrollView(
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          height: 1.2,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor 80mm'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Imprimir',
            icon: const Icon(Icons.print),
            onPressed: _printDocument,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;

          final editor = _buildEditorPanel(context);
          final preview = _buildPreviewPanel(context);

          if (isWide) {
            return Row(
              children: [
                Expanded(child: editor),
                const VerticalDivider(width: 1),
                Expanded(child: preview),
              ],
            );
          }

          return Column(
            children: [
              Expanded(child: editor),
              const Divider(height: 1),
              Expanded(child: preview),
            ],
          );
        },
      ),
    );
  }
}
