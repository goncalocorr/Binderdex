import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Carta "3D": inclina em perspetiva conforme o dedo/rato e mostra um brilho
/// que segue o movimento. Ao largar, volta ao centro com ressalto elástico.
/// Se [back] for fornecido, **tocar** vira a carta (flip 180°) para ver o verso.
class TiltCard extends StatefulWidget {
  final Widget child; // frente
  final Widget? back; // verso (opcional → ativa o flip ao tocar)
  final double maxTilt; // radianos (~0.22 ≈ 12°)
  final double radius; // recorte do brilho (= raio da carta)

  const TiltCard({
    super.key,
    required this.child,
    this.back,
    this.maxTilt = 0.22,
    this.radius = 16,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard> with TickerProviderStateMixin {
  final _key = GlobalKey();
  Offset _t = Offset.zero; // posição normalizada (-1..1)

  late final AnimationController _spring = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  Animation<Offset>? _springAnim;

  late final AnimationController _flip = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  Size? get _size {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    return box?.size;
  }

  void _update(Offset local) {
    final s = _size;
    if (s == null || s.width == 0 || s.height == 0) return;
    _spring.stop();
    setState(() {
      _t = Offset(
        (local.dx / s.width * 2 - 1).clamp(-1.0, 1.0),
        (local.dy / s.height * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  void _reset() {
    _springAnim = Tween(begin: _t, end: Offset.zero).animate(
      CurvedAnimation(parent: _spring, curve: Curves.elasticOut),
    )..addListener(() => setState(() => _t = _springAnim!.value));
    _spring.forward(from: 0);
  }

  void _toggleFlip() {
    if (widget.back == null) return;
    if (_flip.value > 0.5) {
      _flip.reverse();
    } else {
      _flip.forward();
    }
  }

  @override
  void dispose() {
    _spring.dispose();
    _flip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rx = -_t.dy * widget.maxTilt;
    final ry = _t.dx * widget.maxTilt;
    final mag = _t.distance.clamp(0.0, 1.0);

    return GestureDetector(
      onTap: _toggleFlip,
      onPanStart: (d) => _update(d.localPosition),
      onPanUpdate: (d) => _update(d.localPosition),
      onPanEnd: (_) => _reset(),
      child: MouseRegion(
        onHover: (e) => _update(e.localPosition),
        onExit: (_) => _reset(),
        child: AnimatedBuilder(
          animation: _flip,
          builder: (context, _) {
            final flipAngle = _flip.value * math.pi;
            final showFront = flipAngle <= math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012) // perspetiva
                ..rotateX(rx)
                ..rotateY(ry + flipAngle),
              child: Stack(
                key: _key,
                alignment: Alignment.center,
                children: [
                  // Frente (+ brilho).
                  Opacity(
                    opacity: showFront ? 1 : 0,
                    child: Stack(
                      children: [
                        widget.child,
                        Positioned.fill(
                          child: IgnorePointer(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(widget.radius),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment(_t.dx, _t.dy),
                                    radius: 0.9,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.35 * mag),
                                      Colors.white.withValues(alpha: 0.05 * mag),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.35, 1.0],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Verso (contra-rodado para não ficar espelhado).
                  if (widget.back != null)
                    Positioned.fill(
                      child: Opacity(
                        opacity: showFront ? 0 : 1,
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: widget.back,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
