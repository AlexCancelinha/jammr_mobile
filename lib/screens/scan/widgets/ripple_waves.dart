import 'package:flutter/material.dart';

class RippleWaves extends StatefulWidget {
  final double size;
  final Color color;

  const RippleWaves({super.key, this.size = 140, this.color = Colors.purpleAccent});

  @override
  State<RippleWaves> createState() => _RippleWavesState();
}

class _RippleWavesState extends State<RippleWaves> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _RipplePainter(_controller.value, widget.size, widget.color),
          child: SizedBox(width: widget.size * 3, height: widget.size * 3),
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final double baseSize;
  final Color color;
  _RipplePainter(this.progress, this.baseSize, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1 - progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final radius = baseSize + 50 * progress;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius * 0.7, paint..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
