import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PinpadScreen extends StatefulWidget {
  const PinpadScreen({super.key});

  @override
  State<PinpadScreen> createState() => _PinpadScreenState();
}
class _PinpadScreenState extends State<PinpadScreen> {
  List<int> inputSequence = [];
  String display = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showStartupDialog();
    });
  }

  void _showStartupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Aviso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/mantenimiento.jpeg', fit: BoxFit.cover),
            const SizedBox(height: 16),
            const Text(
              'Aún estamos en construcción de esta página web. '
                  'Cualquier consulta o propuesta, enviar un WhatsApp a +56967279093',
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cerrar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
  void handleInput(String value) {
    // 1. Borrar todo
    if (value == "X") {
      setState(() {
        inputSequence.clear();
        display = "";
      });
      return;
    }

    // 2. Confirmar
    if (value == "✔") {
      // ──> Cambiado: solo pedimos que haya al menos un número
      if (inputSequence.isEmpty) {
        _showDialog(
          "Combinación incompleta",
          "Debes ingresar al menos un número (máximo 4).",
        );
        return;
      }

      // ──> Cambiado: ya no añadimos ceros a la izquierda
      String entered = inputSequence.join();

      // ──> Cambiado: la combinación correcta ahora es “48”
      if (entered == "48") {
        _showDialog("¡Superado!", "Has ingresado la combinación correcta.");
      } else {
        _showDialog("Error", "Combinación incorrecta.");
      }

      setState(() {
        inputSequence.clear();
        display = "";
      });
      return;
    }

    // 3. Máximo de 4 dígitos
    if (inputSequence.length >= 4) {
      _showDialog(
        "Límite alcanzado",
        "No se pueden agregar más de cuatro números.",
      );
      setState(() {
        inputSequence.clear();
        display = "";
      });
      return;
    }

    // 4. Añadir dígitos
    if (RegExp(r'^\d$').hasMatch(value)) {
      setState(() {
        inputSequence.add(int.parse(value));
        display += value;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Aceptar"),
              ),
            ],
          ),
    );
  }

  Widget buildButton(String label, {Color? color}) {
    return ElevatedButton(
      onPressed: () => handleInput(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.grey[800],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.all(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tarjeta con la pista
            Card(
              color: Colors.amber[700],
              elevation: 8,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Soy mayor que 40, divisible por 3, y mi suma de cifras es 12. ¿Quién soy?",
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Card con el pinpad
            Card(
              elevation: 12,
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pantalla
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      width: double.infinity,
                      color: Colors.black,
                      alignment: Alignment.centerRight,
                      child: Text(
                        display,
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Pinpad
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        buildButton("1"),
                        buildButton("2"),
                        buildButton("3"),
                        buildButton("4"),
                        buildButton("5"),
                        buildButton("6"),
                        buildButton("7"),
                        buildButton("8"),
                        buildButton("9"),
                        buildButton("X", color: Colors.red),
                        buildButton("0"),
                        buildButton("✔", color: Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

