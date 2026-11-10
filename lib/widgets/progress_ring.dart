import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// A watch-dial style progress ring made of tick marks.
/// [progress] goes from 0.0 to 1.0 and animates smoothly when it changes.
class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 220});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: progress.clamp(0.0, 1.0)),
      duration: AppMotion.slow,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size.square(size),
                painter: _TickPainter(value),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(value * 100).round()}', style: text.displayMedium),
                  const SizedBox(height: AppSpace.xs),
                  Text('PERCENT DONE', style: text.labelSmall),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TickPainter extends CustomPainter {
  _TickPainter(this.progress);

  final double progress;

  static const int ticks = 60;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    for (int i = 0; i < ticks; i++) {
      final frac = i / ticks;
      final angle = -math.pi / 2 + 2 * math.pi * frac;
      final lit = frac < progress;

      // Ticks close to the leading edge grow longer (a wave effect).
      double boost = 0;
      if (progress > 0 && progress < 1) {
        boost = math.max(0.0, 1 - (frac - progress).abs() / 0.08);
      }

      final length = 10 + 14 * boost;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final outer = center + dir * radius;
      final inner = center + dir * (radius - length);

      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = lit ? AppColors.accent : AppColors.line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TickPainter old) => old.progress != progress;
}
