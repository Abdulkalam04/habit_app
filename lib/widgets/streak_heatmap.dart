import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Counts how many days in a row (ending at the last item) have value > 0.
int currentStreak(List<double> values) {
  int streak = 0;
  for (int i = values.length - 1; i >= 0; i--) {
    if (values[i] > 0) {
      streak++;
    } else {
      break;
    }
  }
  return streak;
}

/// Longest run of days with value > 0.
int bestStreak(List<double> values) {
  int best = 0, run = 0;
  for (final v in values) {
    run = v > 0 ? run + 1 : 0;
    if (run > best) best = run;
  }
  return best;
}

/// GitHub-style grid. [values] is day-by-day (oldest first), each 0.0 to 1.0.
/// Length should be weeks * 7. The last item is "today".
class StreakHeatmap extends StatefulWidget {
  const StreakHeatmap({super.key, required this.values, this.weeks = 12});

  final List<double> values;
  final int weeks;

  @override
  State<StreakHeatmap> createState() => _StreakHeatmapState();
}

class _StreakHeatmapState extends State<StreakHeatmap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gap = 5.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cell =
            (constraints.maxWidth - gap * (widget.weeks - 1)) / widget.weeks;
        final height = cell * 7 + gap * 6;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _c.forward(from: 0), // tap to replay the wave
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              size: Size(constraints.maxWidth, height),
              painter: _HeatmapPainter(
                values: widget.values,
                weeks: widget.weeks,
                cell: cell,
                gap: gap,
                t: _c.value,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  _HeatmapPainter({
    required this.values,
    required this.weeks,
    required this.cell,
    required this.gap,
    required this.t,
  });

  final List<double> values;
  final int weeks;
  final double cell;
  final double gap;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    for (int col = 0; col < weeks; col++) {
      for (int row = 0; row < 7; row++) {
        final i = col * 7 + row;
        if (i >= values.length) continue;

        // Each cell starts a little later than the one before it (the wave).
        final delay = (col / weeks) * 0.6 + (row / 7) * 0.12;
        final local = ((t - delay) / 0.28).clamp(0.0, 1.0);
        if (local == 0) continue;

        final scale = Curves.easeOutBack.transform(local);
        final v = values[i];

        final color = v <= 0
            ? AppColors.surfaceHigh
            : Color.lerp(
                AppColors.accent.withValues(alpha: 0.28),
                AppColors.accent,
                v,
              )!;

        final center = Offset(
          col * (cell + gap) + cell / 2,
          row * (cell + gap) + cell / 2,
        );
        final side = cell * scale;
        final rrect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: side, height: side),
          Radius.circular(cell * 0.28),
        );

        canvas.drawRRect(rrect, Paint()..color = color);

        // Outline today's cell (the last one).
        if (i == values.length - 1) {
          canvas.drawRRect(
            rrect.inflate(2),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = AppColors.text,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter old) =>
      old.t != t || old.values != values;
}
