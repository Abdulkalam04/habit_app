import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// A face that morphs continuously. [value] goes 0.0 (awful) to 1.0 (great).
class MoodFace extends StatelessWidget {
  const MoodFace({super.key, required this.value, this.size = 200});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      builder: (context, v, _) =>
          CustomPaint(size: Size.square(size), painter: _FacePainter(v)),
    );
  }
}

class _FacePainter extends CustomPainter {
  _FacePainter(this.v);

  final double v;

  static const _amber = Color(0xFFFFC857);

  Color get _faceColor => v < 0.5
      ? Color.lerp(AppColors.danger, _amber, v * 2)!
      : Color.lerp(_amber, AppColors.accent, (v - 0.5) * 2)!;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = size.center(Offset.zero);

    // Face
    canvas.drawCircle(center, s / 2, Paint()..color = _faceColor);

    final ink = Paint()..color = AppColors.onAccent;

    // Eyes: low and narrow when sad, high and round when happy.
    final eyeY = center.dy - s * lerpD(0.02, 0.1, v);
    final eyeH = s * lerpD(0.05, 0.13, v);
    final eyeW = s * 0.075;
    for (final dir in [-1, 1]) {
      final c = Offset(center.dx + dir * s * 0.18, eyeY);
      canvas.drawOval(
        Rect.fromCenter(center: c, width: eyeW, height: eyeH),
        ink,
      );
    }

    // Mouth: a quadratic curve whose control point flips from frown to smile.
    final mouthY = center.dy + s * lerpD(0.22, 0.12, v);
    final halfW = s * lerpD(0.14, 0.24, v);
    final bend = s * lerpD(-0.2, 0.34, v); // negative = frown
    final mouth = Path()
      ..moveTo(center.dx - halfW, mouthY)
      ..quadraticBezierTo(center.dx, mouthY + bend, center.dx + halfW, mouthY);

    canvas.drawPath(
      mouth,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.05
        ..strokeCap = StrokeCap.round
        ..color = AppColors.onAccent,
    );
  }

  double lerpD(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _FacePainter old) => old.v != v;
}

/// Face + label + custom drag slider.
class MoodPicker extends StatefulWidget {
  const MoodPicker({super.key, this.initial = 0.5, this.onChanged});

  final double initial;
  final ValueChanged<double>? onChanged;

  @override
  State<MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<MoodPicker> {
  static const _labels = ['Awful', 'Low', 'Okay', 'Good', 'Great'];
  static const double _thumb = 28;

  late double _v = widget.initial;
  late int _lastIndex = (_v * 4).round();

  void _update(double dx, double width) {
    final usable = width - _thumb;
    final v = ((dx - _thumb / 2) / usable).clamp(0.0, 1.0);
    final index = (v * 4).round();
    if (index != _lastIndex) {
      HapticFeedback.selectionClick();
      _lastIndex = index;
    }
    setState(() => _v = v);
    widget.onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final index = (_v * 4).round();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoodFace(value: _v, size: 200),
        const SizedBox(height: AppSpace.lg),
        AnimatedSwitcher(
          duration: AppMotion.fast,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: Text(
            _labels[index],
            key: ValueKey(index),
            style: text.displayMedium,
          ),
        ),
        const SizedBox(height: AppSpace.xl),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final usable = w - _thumb;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (d) => _update(d.localPosition.dx, w),
              onHorizontalDragUpdate: (d) => _update(d.localPosition.dx, w),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Track
                    Positioned(
                      left: _thumb / 2,
                      right: _thumb / 2,
                      child: Container(height: 1.5, color: AppColors.line),
                    ),
                    // Step ticks
                    for (int i = 0; i < 5; i++)
                      Positioned(
                        left: _thumb / 2 + usable * i / 4 - 0.75,
                        child: Container(
                          width: 1.5,
                          height: i == index ? 18 : 10,
                          color: i <= index ? AppColors.accent : AppColors.line,
                        ),
                      ),
                    // Thumb
                    Positioned(
                      left: usable * _v,
                      child: Container(
                        width: _thumb,
                        height: _thumb,
                        decoration: BoxDecoration(
                          color: AppColors.text,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bg, width: 4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
