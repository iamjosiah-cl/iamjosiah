import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameWrapper extends StatefulWidget {
  final Widget child;
  final bool initialFullScreen;

  const GameWrapper({
    super.key,
    required this.child,
    this.initialFullScreen = false,
  });

  @override
  State<GameWrapper> createState() => GameWrapperState();

  static GameWrapperState? of(BuildContext context) {
    return context.findAncestorStateOfType<GameWrapperState>();
  }
}

class GameWrapperState extends State<GameWrapper> {
  late bool _isFullScreen;

  bool get isFullScreen => _isFullScreen;

  @override
  void initState() {
    super.initState();
    _isFullScreen = widget.initialFullScreen;
    if (_isFullScreen) {
      _enterFullScreen();
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      _enterFullScreen();
    } else {
      _exitFullScreen();
    }
  }

  void _enterFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    // Si estábamos en full screen, restauramos al salir
    if (_isFullScreen) {
      _exitFullScreen();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos un Stack para poner el botón flotante sobre el juego
      body: Stack(
        children: [
          // El juego
          Positioned.fill(child: widget.child),
          
          // Botón de pantalla completa
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: null, // Evitar conflictos de hero si hay múltiples
                mini: true,
                backgroundColor: Colors.black.withOpacity(0.5),
                elevation: 0,
                onPressed: _toggleFullScreen,
                tooltip: _isFullScreen ? 'Salir de pantalla completa' : 'Pantalla completa',
                child: Icon(
                  _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
