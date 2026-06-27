import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/dex_tokens.dart';

/// Selo (coroa) que marca um utilizador premium. O brilho distingue o nível
/// (todos com movimento):
/// - Treinador (1): gradiente prata
/// - Mestre (2): gradiente azul
/// - Lendário (3): gradiente holográfico
class PremiumBadge extends StatelessWidget {
  final double size;
  final int tier;
  const PremiumBadge({super.key, this.size = 16, this.tier = 1});

  // Prata metálico com contraste: tons médios/escuros (leem-se no tema claro)
  // + um brilho claro que "varre" (lê-se no tema escuro).
  static const _silver = [
    Color(0xFF64748B), // slate-500 (escuro, contraste no claro)
    Color(0xFFE2E8F0), // slate-200 (brilho)
    Color(0xFF94A3B8), // slate-400
    Color(0xFF475569), // slate-600 (sombra metálica)
    Color(0xFF64748B),
  ];

  static const _blues = [
    Color(0xFF93C5FD),
    Color(0xFF2563EB),
    Color(0xFF22D3EE),
    Color(0xFF3B82F6),
    Color(0xFF93C5FD),
  ];

  /// Cores do gradiente de cada nível (reutilizadas pelo glow do ecrã premium):
  /// Treinador (1) prata · Mestre (2) azul · Lendário (3) holográfico.
  static List<Color> colorsFor(int tier) {
    if (tier >= 3) return DexSheens.holoVivid; // vívido p/ ler no tema claro
    if (tier == 2) return _blues;
    return _silver;
  }

  @override
  Widget build(BuildContext context) =>
      _AnimatedCrown(size: size, colors: colorsFor(tier));
}

/// Glow animado à volta de um retângulo, com a cor do nível premium. O
/// gradiente "varre" (movimento) e a auréola "respira". Envolve o filho com um
/// anel de gradiente + sombra colorida.
class PremiumGlow extends StatefulWidget {
  final int tier;
  final double radius;
  final Widget child;

  /// Glow reforçado (anel mais grosso + auréola mais intensa) — usado no plano
  /// atual/selecionado, em vez de uma moldura estática por cima.
  final bool strong;
  const PremiumGlow({
    super.key,
    required this.tier,
    required this.child,
    this.radius = 16,
    this.strong = false,
  });

  @override
  State<PremiumGlow> createState() => _PremiumGlowState();
}

class _PremiumGlowState extends State<PremiumGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 8500),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = widget.strong ? 3.0 : 2.0;
    final colors = PremiumBadge.colorsFor(widget.tier);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (_, child) {
          final shift = _c.value * 2;
          // Auréola "respira" ao longo do gradiente (0→1→0).
          final t = (math.sin(_c.value * 2 * math.pi) + 1) / 2;
          // O prata (achromático) quase não contrasta no branco → usa um tom
          // steel mais escuro e intenso, para a auréola se ler.
          final isSilver = widget.tier == 1;
          final glow = isSilver
              ? Color.lerp(const Color(0xFF64748B), const Color(0xFF334155), t)!
              : Color.lerp(colors[1], colors[2], t)!;
          final base =
              (widget.strong ? 0.7 : 0.5) + (isSilver ? 0.15 : 0.0);
          return Container(
            padding: EdgeInsets.all(ring),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.radius + ring),
              gradient: LinearGradient(
                begin: Alignment(-2 + shift, -0.3),
                end: Alignment(shift, 0.3),
                colors: colors,
                tileMode: TileMode.mirror,
              ),
              boxShadow: [
                BoxShadow(
                  color: glow.withValues(alpha: base + 0.2 * t),
                  blurRadius: (widget.strong ? 22 : 16) + 8 * t,
                  spreadRadius: (widget.strong ? 2.5 : 1.2) + 1.6 * t,
                ),
              ],
            ),
            child: child,
          );
        },
      ),
    );
  }
}

/// Coroa com um gradiente que "varre" continuamente (movimento).
class _AnimatedCrown extends StatefulWidget {
  final double size;
  final List<Color> colors;
  const _AnimatedCrown({required this.size, required this.colors});

  @override
  State<_AnimatedCrown> createState() => _AnimatedCrownState();
}

class _AnimatedCrownState extends State<_AnimatedCrown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 8500),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        // O ícone (filho) é fixo; só o shader anima → mais eficiente.
        child: Icon(Icons.workspace_premium,
            size: widget.size, color: Colors.white),
        builder: (_, child) {
          final shift = _c.value * 2;
          return ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(-2 + shift, -0.3),
              end: Alignment(shift, 0.3),
              colors: widget.colors,
              tileMode: TileMode.mirror,
            ).createShader(rect),
            child: child,
          );
        },
      ),
    );
  }
}
