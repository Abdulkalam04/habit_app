import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// A circle that fills, pops, ripples and draws its own checkmark.
class HabitCheck extends StatefulWidget {
  const HabitCheck({
    super.key,
    required this.checked,
    required this.onChanged,
    this.size = 36,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final double size;

  @override
  State<HabitCheck> createState() => _HabitCheckState();
}

class _HabitCheckState extends State<HabitCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
    reverseDuration: const Duration(milliseconds: 250),
    value: widget.checked ? 1 : 0,
  );

  @override
  void didUpdateWidget(covariant HabitCheck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != oldWidget.checked) {
      widget.checked ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extra room around the circle so the ripple isn't clipped.
    final box = widget.size * 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onChanged(!widget.checked);
      },
      child: SizedBox(
        width: box,
        height: widget.size,
        child: OverflowBox(
          maxWidth: box,
          maxHeight: box,
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final t = _c.value;
              // Pop: grows then settles back to 1.
              final pop =
                  1 + 0.18 * math.sin(math.pi * (t / 0.5).clamp(0.0, 1.0));
              return Transform.scale(
                scale: pop,
                child: CustomPaint(
                  size: Size(box, box),
                  painter: _CheckPainter(t, widget.size),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.t, this.diameter);

  final double t;
  final double diameter;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = diameter / 2;

    // Timeline split into phases of t (0 -> 1).
    final fill = Curves.easeOutCubic.transform((t / 0.4).clamp(0.0, 1.0));
    final draw = Curves.easeOutCubic.transform(
      ((t - 0.3) / 0.6).clamp(0.0, 1.0),
    );
    final ripple = ((t - 0.05) / 0.55).clamp(0.0, 1.0);

    // 1. Outline circle
    canvas.drawCircle(
      center,
      r - 1,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color.lerp(AppColors.muted, AppColors.accent, fill)!,
    );

    // 2. Filling circle
    if (fill > 0) {
      canvas.drawCircle(
        center,
        (r - 1) * fill,
        Paint()..color = AppColors.accent,
      );
    }

    // 3. Expanding ripple ring (only while animating forward)
    if (ripple > 0 && ripple < 1) {
      canvas.drawCircle(
        center,
        r + r * 0.9 * Curves.easeOut.transform(ripple),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.accent.withValues(alpha: 0.5 * (1 - ripple)),
      );
    }

    // 4. Self-drawing checkmark
    if (draw > 0) {
      final origin = center - Offset(r, r);
      final path = Path()
        ..moveTo(origin.dx + diameter * 0.28, origin.dy + diameter * 0.52)
        ..lineTo(origin.dx + diameter * 0.44, origin.dy + diameter * 0.68)
        ..lineTo(origin.dx + diameter * 0.74, origin.dy + diameter * 0.34);

      final metric = path.computeMetrics().first;
      final visible = metric.extractPath(0, metric.length * draw);

      canvas.drawPath(
        visible,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.onAccent,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter old) => old.t != t;
}
