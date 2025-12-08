import 'package:flutter/material.dart';
import 'package:portafolio/jugar/2.dart';
import 'package:portafolio/portafolio.dart';

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  final TextEditingController _controller = TextEditingController();
  String _message = '';
  final String _secretCode = '6727';

  void _checkCode() {
    final input = _controller.text.trim();
    if (input == _secretCode) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎉 ¡Felicitaciones!'),
          content: const Text(
              'Has encontrado el código secreto.\n¿Quieres seguir jugando?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const PinpadScreen()),
                );
              },
              child: const Text('Sí, seguir'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              },
              child: const Text('No, volver'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _message = '❌ Código incorrecto. Intenta de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,          // Fondo blanco
      appBar: AppBar(
        title: const Text('¿Quieres jugar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child: const Text(
              'Volver a Home',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Card(
          elevation: 12,
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Qué interesante, no pensé que gente llegaría hasta aquí, '
                      'en especial con lo difícil de negarse a este lugar...\n\n'
                      'Si quieres jugar, aquí podemos jugar...\n\n'
                      'Por delante tienes un textbox en el cual tienes que poner '
                      '4 números, espero que los encuentres de color azul marino en la pantalla anterior.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _controller,
                  maxLength: 4,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Ingresa el código',
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF003366), // Azul marino
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _checkCode,
                  child: const Text('Verificar'),
                ),
                const SizedBox(height: 20),
                Text(
                  _message,
                  style: TextStyle(
                    color: _message.startsWith('🎉') ? Colors.green : Colors.red,
                    fontSize: 16,
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
