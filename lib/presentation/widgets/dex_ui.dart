import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';

/// Estado vazio (ícone + título + descrição + ação opcional).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            if (description != null) ...[
              const SizedBox(height: 6),
              Text(description!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Cartão de estatística (ícone, valor grande, etiqueta).
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(DexRadii.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.35
                    : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Barra de valor com etiqueta (HP/ATK, ou distribuição por tipo).
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final Color color;
  final double labelWidth;
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.max = 250,
    this.labelWidth = 44,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final frac = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(DexRadii.pill),
            child: LinearProgressIndicator(
              value: frac,
              minHeight: 10,
              color: color,
              backgroundColor: cs.surfaceContainerHigh,
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(' $value',
              textAlign: TextAlign.right,
              style: AppTheme.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
        ),
      ],
    );
  }
}

/// Escala "squishy" ao premir (não consome o toque — usa Listener).
class Pressable extends StatefulWidget {
  final Widget child;
  const Pressable({super.key, required this.child});
  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  double _scale = 1;
  void _set(double s) => setState(() => _scale = s);
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(0.97),
      onPointerUp: (_) => _set(1),
      onPointerCancel: (_) => _set(1),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Botão-pílula de variante (estilo "RarityBadge" do Dex Design System).
/// Quando possuída e com [sheen], mostra o gradiente animado (holo/foil/arco-íris);
/// possuída sem sheen → cor sólida; não possuída → contorno.
class VariantToggle extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool owned;
  final List<Color>? sheen;
  final Color solid;
  final VoidCallback onTap;
  const VariantToggle({
    super.key,
    required this.label,
    required this.icon,
    required this.owned,
    required this.onTap,
    this.sheen,
    this.solid = const Color(0xFF2FB344),
  });

  @override
  State<VariantToggle> createState() => _VariantToggleState();
}

class _VariantToggleState extends State<VariantToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _content(Color textColor) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              widget.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.displayFont,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                letterSpacing: 0.6,
                color: textColor,
              ),
            ),
          ),
          if (widget.owned) ...[
            const SizedBox(width: 5),
            Icon(Icons.check_circle, size: 15, color: textColor),
          ],
        ],
      );

  Widget _pill(BoxDecoration deco, Color textColor) => GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: deco,
          child: _content(textColor),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final owned = widget.owned;

    if (owned && widget.sheen != null) {
      return AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final shift = _c.value * 2;
          return _pill(
            BoxDecoration(
              borderRadius: BorderRadius.circular(DexRadii.pill),
              gradient: LinearGradient(
                begin: Alignment(-2 + shift, 0),
                end: Alignment(shift, 0),
                colors: widget.sheen!,
                tileMode: TileMode.mirror,
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
            ),
            const Color(0xFF3A2A14),
          );
        },
      );
    }
    if (owned) {
      return _pill(
        BoxDecoration(
          color: widget.solid,
          borderRadius: BorderRadius.circular(DexRadii.pill),
        ),
        Colors.white,
      );
    }
    return _pill(
      BoxDecoration(
        borderRadius: BorderRadius.circular(DexRadii.pill),
        border: Border.all(color: cs.outline),
      ),
      cs.onSurfaceVariant,
    );
  }
}

/// Brilho holográfico animado (holo / foil / arco-íris).
/// Sobrepõe um gradiente multicolor translúcido que "varre" a carta, mais
/// uma faixa branca de shimmer por cima.
class AnimatedSheen extends StatefulWidget {
  final List<Color> colors;
  final double opacity;
  const AnimatedSheen({super.key, required this.colors, this.opacity = 0.5});

  @override
  State<AnimatedSheen> createState() => _AnimatedSheenState();
}

class _AnimatedSheenState extends State<AnimatedSheen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          final shift = _c.value * 2 - 1; // -1..1
          final band = _c.value * 2 - 1;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Gradiente multicolor translúcido (o "holo").
              ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment(-1 + shift, -1),
                  end: Alignment(1 + shift, 1),
                  colors: widget.colors,
                  tileMode: TileMode.mirror,
                ).createShader(rect),
                child: Container(
                    color: Colors.white.withValues(alpha: widget.opacity)),
              ),
              // Faixa branca de brilho que percorre na diagonal.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(band - 0.3, -1),
                    end: Alignment(band + 0.3, 1),
                    colors: [
                      Colors.white.withValues(alpha: 0.0),
                      Colors.white.withValues(alpha: 0.35),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                    stops: const [0.4, 0.5, 0.6],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
