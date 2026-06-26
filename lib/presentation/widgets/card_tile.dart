import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../data/repositories/cards_repository.dart';
import 'dex_ui.dart';

const ColorFilter _grayscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

/// Miniatura de carta — estilo "CardThumb" do Dex Design System.
/// - Possuída: a cores, badge de tipo, check verde, brilho holo nas variantes.
/// - Em falta: borda tracejada, arte a cinzento esbatida, ícone "+".
class CardTile extends StatelessWidget {
  final CardItem item;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  const CardTile({
    super.key,
    required this.item,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final c = item.card;
    final owned = item.owned;
    final typeColor = colorForCardType(c.type);
    final tint = Color.alphaBlend(
        typeColor.withValues(alpha: 0.14), cs.surfaceContainerHigh);
    final sheen = sheenColorsForCard(
      rarity: c.rarity,
      ownedHolo: item.ownedHolo,
      ownedReverse: item.ownedReverse,
      ownedAny: owned,
    );

    Widget art = CachedNetworkImage(
      imageUrl: c.imageSmall,
      fit: BoxFit.contain,
      memCacheWidth: 360,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) =>
          Icon(Icons.broken_image_outlined, color: cs.onSurfaceVariant),
    );
    if (!owned) {
      art = Opacity(opacity: 0.28, child: ColorFiltered(colorFilter: _grayscale, child: art));
    }

    return Pressable(
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(DexRadii.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: owned ? cs.surface : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(DexRadii.lg),
            boxShadow: owned
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: CustomPaint(
            foregroundPainter: owned
                ? null
                : _DashedRRectPainter(
                    color: cs.outline, radius: DexRadii.lg, strokeWidth: 2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DexRadii.lg),
              child: Column(
                children: [
                  // Área da arte
                  Expanded(
                    child: Container(
                      color: owned ? tint : Colors.transparent,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                            Padding(
                              padding: const EdgeInsets.all(6),
                              child: art,
                            ),
                            if (sheen != null)
                              AnimatedSheen(colors: sheen, opacity: 0.4),
                            // Número (mono) — canto superior esquerdo
                            Positioned(
                              top: 6,
                              left: 6,
                              child: _Pill(
                                color: Colors.black.withValues(alpha: 0.55),
                                child: Text('#${c.number}',
                                    style: AppTheme.mono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                            ),
                            // Badge de tipo — canto superior direito (possuída)
                            if (owned)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: typeColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.2),
                                        blurRadius: 2,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Icon(iconForCardType(c.type),
                                      size: 13, color: Colors.white),
                                ),
                              ),
                            // "Em falta" — ícone "+"
                            if (!owned)
                              Center(
                                child: Icon(Icons.add_circle_outline,
                                    size: 32, color: cs.onSurfaceVariant),
                              ),
                            // Duplicados — ×N
                            if (owned && item.dupCount > 1)
                              Positioned(
                                bottom: 6,
                                right: 6,
                                child: _Pill(
                                  color: DexColors.gold500,
                                  child: Text('×${item.dupCount}',
                                      style: AppTheme.mono(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: DexColors.n900)),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                  // Rodapé: nome + check
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 7),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            owned ? c.name : '???',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      owned ? cs.onSurface : cs.onSurfaceVariant,
                                ),
                          ),
                        ),
                        if (owned) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                                color: DexColors.green500,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.check,
                                size: 13, color: Colors.white),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }
}

/// Pequena pílula de fundo para número/contagem.
class _Pill extends StatelessWidget {
  final Color color;
  final Widget child;
  const _Pill({required this.color, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(DexRadii.pill)),
        child: child,
      );
}

/// Borda tracejada arredondada (estado "carta em falta").
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;
  static const double dash = 6;
  static const double gap = 5;
  _DashedRRectPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(strokeWidth / 2);
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
            metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}