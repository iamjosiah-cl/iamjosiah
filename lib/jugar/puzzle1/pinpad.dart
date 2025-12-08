import 'package:flutter/material.dart';
import 'package:portafolio/jugar/dashboard_juegos.dart';

class PinpadScreen extends StatefulWidget {
  const PinpadScreen({super.key});

  @override
  State<PinpadScreen> createState() => _PinpadScreenState();
}

class _PinpadScreenState extends State<PinpadScreen> {
  List<int> inputSequence = [];
  String display = "";

  void handleInput(String value) {
    if (value == "X") {
      setState(() {
        inputSequence.clear();
        display = "";
      });
      return;
    }

    if (value == "✔") {
      if (inputSequence.length != 4) {
        _showDialog("Combinación incompleta", "Debes ingresar 4 números.");
        return;
      }

      if (inputSequence.join() == "0368") {
        _showDialog("¡Superado!", "Has ingresado la combinación correcta.", success: true);
      } else {
        _showDialog("Error", "Combinación incorrecta.");
      }

      setState(() {
        inputSequence.clear();
        display = "";
      });

      return;
    }

    if (inputSequence.length >= 4) {
      _showDialog("Límite alcanzado", "No se pueden agregar más que cuatro números.");
      setState(() {
        inputSequence.clear();
        display = "";
      });
      return;
    }

    if (RegExp(r'^\d$').hasMatch(value)) {
      setState(() {
        int number = int.parse(value);
        inputSequence.add(number);
        display += value;
      });
    }
  }

  void _showDialog(String title, String message, {bool success = false}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar dialogo
              if (success) {
                // Volver a la pantalla de juegos
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const GamesPage()),
                );
              }
            },
            child: const Text("Aceptar"),
          ),
        ],
      ),
    );
  }

  Widget buildButton(String label, {Color? color}) {
    return InkWell(
      onTap: () => handleInput(label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: color != null
                ? [color.withOpacity(0.8), color]
                : [Colors.grey[700]!, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              offset: const Offset(4, 4),
              blurRadius: 8,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.05),
              offset: const Offset(-4, -4),
              blurRadius: 8,
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 2,
                offset: Offset(1, 1),
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
      backgroundColor: Colors.grey[900],
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Card(
              elevation: 16,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey[700]!, width: 1.5),
              ),
              color: Colors.grey[850],
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[850]!, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pantalla digital
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.black87, Colors.black54],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        border: Border.all(color: Colors.greenAccent, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerRight,
                      child: Text(
                        display,
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.green,
                              blurRadius: 12,
                              offset: Offset(0, 0),
                            ),
                          ],
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
                        buildButton("X", color: Colors.redAccent),
                        buildButton("0"),
                        buildButton("✔", color: Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
