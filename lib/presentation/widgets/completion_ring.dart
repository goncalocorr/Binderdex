import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';

/// Anel circular de conclusão (estilo "CompletionRing" do Dex Design System).
/// Verde enquanto incompleto, dourado quando 100%.
class CompletionRing extends StatelessWidget {
  final double percent; // 0..1
  final double size;
  final double stroke;
  final String? sublabel;
  const CompletionRing({
    super.key,
    required this.percent,
    this.size = 132,
    this.stroke = 12,
    this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final p = percent.clamp(0.0, 1.0);
    final complete = p >= 1.0;
    final ringColor = complete ? DexColors.gold500 : DexColors.green500;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          percent: p,
          stroke: stroke,
          color: ringColor,
          track: cs.surfaceContainerHigh,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${(p * 100).round()}'),
                  const TextSpan(
                      text: '%', style: TextStyle(fontSize: 18)),
                ]),
                style: TextStyle(
                  fontFamily: AppTheme.displayFont,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.26,
                  color: cs.onSurface,
                  height: 1,
                ),
              ),
              if (sublabel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(sublabel!,
                      style: AppTheme.mono(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: cs.onSurfaceVariant)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final double stroke;
  final Color color;
  final Color track;
  _RingPainter({
    required this.percent,
    required this.stroke,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = (size.width - stroke) / 2;
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawCircle(center, r, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      2 * math.pi * percent,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent || old.color != color || old.track != track;
}
