import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/dex_tokens.dart';
import '../../data/repositories/sets_repository.dart';
import 'dex_ui.dart';

/// Linha de uma coleção (set) — estilo "CollectionCard" do Dex Design System:
/// logo num quadrado arredondado tintado, nome em Fredoka, percentagem colorida,
/// barra de progresso e meta monoespaçada.
class SetTile extends StatelessWidget {
  final SetProgress data;
  final VoidCallback onTap;
  const SetTile({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = data.set;
    final p = data.progress;
    final pct = (p.percent * 100).round();
    final done = p.total > 0 && p.owned >= p.total;
    final pctColor = done ? DexColors.gold500 : DexColors.green500;
    final tint = Color.alphaBlend(
        cs.primary.withValues(alpha: 0.14), cs.surfaceContainerHigh);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Pressable(
        child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(DexRadii.lg),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DexRadii.lg),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
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
            child: Row(
              children: [
                // Logótipo da coleção (com o símbolo como reserva).
                Container(
                  width: 76,
                  height: 56,
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(DexRadii.md),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: (s.logoUrl.isEmpty && s.symbolUrl.isEmpty)
                      ? Icon(Icons.style, color: cs.primary)
                      : Padding(
                          padding: const EdgeInsets.all(7),
                          child: CachedNetworkImage(
                            imageUrl:
                                s.logoUrl.isNotEmpty ? s.logoUrl : s.symbolUrl,
                            fit: BoxFit.contain,
                            placeholder: (_, __) => const SizedBox.shrink(),
                            errorWidget: (_, __, ___) =>
                                Icon(Icons.style, color: cs.primary),
                          ),
                        ),
                ),
                const SizedBox(width: 14),
                // Corpo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              s.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$pct%',
                              style: AppTheme.mono(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: pctColor)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(DexRadii.pill),
                        child: LinearProgressIndicator(
                          value: p.percent,
                          minHeight: 6,
                          color: pctColor,
                          backgroundColor: cs.surfaceContainerHigh,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('${p.owned}/${p.total} cartas',
                          style: AppTheme.mono(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}