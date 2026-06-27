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

  static const _silver = [
    Color(0xFFEDEFF2),
    Color(0xFFAEB4BE),
    Color(0xFFFFFFFF),
    Color(0xFFC2C8D0),
    Color(0xFFEDEFF2),
  ];

  static const _blues = [
    Color(0xFF93C5FD),
    Color(0xFF2563EB),
    Color(0xFF22D3EE),
    Color(0xFF3B82F6),
    Color(0xFF93C5FD),
  ];

  @override
  Widget build(BuildContext context) {
    if (tier >= 3) return _AnimatedCrown(size: size, colors: DexSheens.holo);
    if (tier == 2) return _AnimatedCrown(size: size, colors: _blues);
    // Treinador (1) — prata com movimento.
    return _AnimatedCrown(size: size, colors: _silver);
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
    duration: const Duration(milliseconds: 5200),
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
