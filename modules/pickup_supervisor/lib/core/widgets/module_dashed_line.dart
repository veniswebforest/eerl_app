import 'package:flutter/material.dart';

/// Horizontal 1px dashed line (Figma dividers in collected items / totals).
class ModuleDashedLine extends StatelessWidget {
  const ModuleDashedLine({
    super.key,
    required this.color,
    this.dash = 6,
    this.gap = 4,
  });

  final Color color;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 1,
    width: double.infinity,
    child: CustomPaint(painter: _DashPainter(color, dash, gap)),
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.color, this.dash, this.gap);

  final Color color;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += dash + gap) {
      canvas.drawLine(
        Offset(x, .5),
        Offset((x + dash).clamp(0, size.width), .5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.color != color || old.dash != dash || old.gap != gap;
}
