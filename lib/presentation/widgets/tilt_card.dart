import 'package:flutter/material.dart';

/// Carta "3D": inclina em perspetiva conforme o dedo/rato e mostra um brilho
/// que segue o movimento. Ao largar, volta ao centro com um ressalto elástico.
/// Funciona com toque (arrasto) e com rato (hover) — sem sensores.
class TiltCard extends StatefulWidget {
  final Widget child;

  /// Inclinação máxima em radianos (~0.22 ≈ 12°).
  final double maxTilt;

  /// Raio do recorte do brilho (deve coincidir com o da carta).
  final double radius;

  const TiltCard({
    super.key,
    required this.child,
    this.maxTilt = 0.22,
    this.radius = 16,
  });

  @override
  State<TiltCard> createState() => _TiltCardState();
}

class _TiltCardState extends State<TiltCard>
    with SingleTickerProviderStateMixin {
  final _key = GlobalKey();
  Offset _t = Offset.zero; // posição normalizada (-1..1)

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  Animation<Offset>? _spring;

  Size? get _size {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    return box?.size;
  }

  void _update(Offset local) {
    final s = _size;
    if (s == null || s.width == 0 || s.height == 0) return;
    _c.stop();
    setState(() {
      _t = Offset(
        (local.dx / s.width * 2 - 1).clamp(-1.0, 1.0),
        (local.dy / s.height * 2 - 1).clamp(-1.0, 1.0),
      );
    });
  }

  void _reset() {
    _spring = Tween(begin: _t, end: Offset.zero).animate(
      CurvedAnimation(parent: _c, curve: Curves.elasticOut),
    )..addListener(() => setState(() => _t = _spring!.value));
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rx = -_t.dy * widget.maxTilt;
    final ry = _t.dx * widget.maxTilt;
    final mag = _t.distance.clamp(0.0, 1.0);

    return GestureDetector(
      onPanStart: (d) => _update(d.localPosition),
      onPanUpdate: (d) => _update(d.localPosition),
      onPanEnd: (_) => _reset(),
      child: MouseRegion(
        onHover: (e) => _update(e.localPosition),
        onExit: (_) => _reset(),
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012) // perspetiva
            ..rotateX(rx)
            ..rotateY(ry),
          child: Stack(
            key: _key,
            children: [
              widget.child,
              // Brilho que segue o toque (só visível ao interagir).
              Positioned.fill(
                child: IgnorePointer(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(widget.radius),
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
      ),
    );
  }
}
