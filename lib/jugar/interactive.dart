import 'package:flutter/material.dart';

// Helper for horizontal layout
class HorizontalLayoutWrapper extends StatelessWidget {
  final Widget child;
  const HorizontalLayoutWrapper({super.key, required this.child});
  @override
  Widget build(BuildContext context) => child;
}

// Helper for InteractiveArrow
class InteractiveArrow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const InteractiveArrow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.black54,
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 40),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
