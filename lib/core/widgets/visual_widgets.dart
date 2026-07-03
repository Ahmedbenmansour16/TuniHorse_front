import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tunihorse/core/constants/app_colors.dart';

class MapPreview extends StatelessWidget {
  final double height;
  final bool multiHorse;

  const MapPreview({super.key, this.height = 260, this.multiHorse = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF406E39), AppColors.mapGreen],
          ),
        ),
        child: CustomPaint(
          painter: RoutePainter(multiHorse: multiHorse),
          child: Stack(
            children: [
              Positioned(
                top: 12,
                left: 12,
                child: _MapChip(multiHorse ? '3 en direct' : 'En direct'),
              ),
              const Positioned(top: 12, right: 12, child: _MapChip('GPS')),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapChip extends StatelessWidget {
  final String label;

  const _MapChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class RoutePainter extends CustomPainter {
  final bool multiHorse;

  const RoutePainter({required this.multiHorse});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.055)
      ..strokeWidth = 1;

    for (var i = 0; i < 8; i++) {
      final x = size.width * i / 7;
      final y = size.height * i / 7;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path()
      ..moveTo(size.width * .10, size.height * .62)
      ..cubicTo(
        size.width * .24,
        size.height * .24,
        size.width * .52,
        size.height * .16,
        size.width * .74,
        size.height * .42,
      )
      ..cubicTo(
        size.width * .92,
        size.height * .66,
        size.width * .65,
        size.height * .88,
        size.width * .34,
        size.height * .75,
      )
      ..cubicTo(
        size.width * .17,
        size.height * .68,
        size.width * .20,
        size.height * .52,
        size.width * .36,
        size.height * .48,
      );

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    final points = [
      Offset(size.width * .17, size.height * .58),
      Offset(size.width * .38, size.height * .34),
      Offset(size.width * .62, size.height * .31),
      Offset(size.width * .76, size.height * .49),
      Offset(size.width * .62, size.height * .79),
    ];

    for (final point in points) {
      canvas.drawCircle(point, 9, Paint()..color = AppColors.gold);
      canvas.drawCircle(point, 3.5, Paint()..color = Colors.white);
    }

    canvas.drawCircle(
      Offset(size.width * .48, size.height * .56),
      12,
      Paint()..color = const Color(0xFF2494FF),
    );
    canvas.drawCircle(
      Offset(size.width * .48, size.height * .56),
      5,
      Paint()..color = Colors.white,
    );

    if (multiHorse) {
      final horsePoints = [
        Offset(size.width * .36, size.height * .47),
        Offset(size.width * .66, size.height * .40),
        Offset(size.width * .57, size.height * .70),
      ];
      for (final point in horsePoints) {
        canvas.drawCircle(point, 19, Paint()..color = Colors.white);
        canvas.drawCircle(point, 15, Paint()..color = AppColors.green);
        canvas.drawCircle(point, 5, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) {
    return oldDelegate.multiHorse != multiHorse;
  }
}

class GaitDonutChart extends StatelessWidget {
  const GaitDonutChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: CustomPaint(
        painter: GaitDonutPainter(),
        child: const Center(
          child: Text(
            '01:08:24\nDurée totale',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class GaitDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .34;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;

    final values = [
      (0.55, AppColors.green),
      (0.30, AppColors.amber),
      (0.15, AppColors.gold),
    ];

    var start = -math.pi / 2;
    for (final value in values) {
      final sweep = value.$1 * math.pi * 2;
      paint.color = value.$2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
