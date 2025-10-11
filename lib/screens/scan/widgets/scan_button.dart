import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  final double size;

  const ScanButton({
    super.key,
    required this.onTap,
    required this.isLoading,
    this.size = 140, // default bigger size
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: size,
        width: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.purpleAccent,
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Icon(Icons.radar, color: Colors.white, size: 50),
        ),
      ),
    );
  }
}
