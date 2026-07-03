import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';

class HorseshoeMark extends StatelessWidget {
  final double size;
  final Color color;
  final Color? nailColor;

  const HorseshoeMark({
    super.key,
    this.size = 42,
    this.color = AppColors.green,
    this.nailColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _HorseshoePainter(color: color, nailColor: nailColor ?? color),
      ),
    );
  }
}

class _HorseshoePainter extends CustomPainter {
  final Color color;
  final Color nailColor;

  const _HorseshoePainter({required this.color, required this.nailColor});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.15;
    final path = Path()
      ..moveTo(size.width * 0.27, size.height * 0.18)
      ..cubicTo(
        size.width * 0.14,
        size.height * 0.40,
        size.width * 0.18,
        size.height * 0.83,
        size.width * 0.50,
        size.height * 0.86,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.83,
        size.width * 0.86,
        size.height * 0.40,
        size.width * 0.73,
        size.height * 0.18,
      );

    final shoePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, shoePaint);

    final endPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final center in [
      Offset(size.width * 0.25, size.height * 0.17),
      Offset(size.width * 0.75, size.height * 0.17),
    ]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center,
            width: size.width * 0.22,
            height: size.height * 0.13,
          ),
          Radius.circular(size.width * 0.04),
        ),
        endPaint,
      );
    }

    final nailPaint = Paint()
      ..color = nailColor.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final holePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.82)
      ..style = PaintingStyle.fill;

    final nails = [
      Offset(size.width * 0.30, size.height * 0.36),
      Offset(size.width * 0.27, size.height * 0.55),
      Offset(size.width * 0.35, size.height * 0.72),
      Offset(size.width * 0.70, size.height * 0.36),
      Offset(size.width * 0.73, size.height * 0.55),
      Offset(size.width * 0.65, size.height * 0.72),
    ];

    for (final nail in nails) {
      canvas.drawCircle(nail, size.width * 0.045, nailPaint);
      canvas.drawCircle(nail, size.width * 0.022, holePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HorseshoePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.nailColor != nailColor;
  }
}
